#!/usr/bin/env bash
#
# validate-presets.sh — QA gate for the EasyEffects presets in this repo.
#
# Presets checked: root *.json (output pipeline, single top-level key
# "output") and input/*.json (microphone pipeline, single top-level key
# "input").
#
# FAIL checks (exit 1):
#   - file parses as JSON, has no duplicate object keys, and is byte-identical
#     to json.dumps(obj, indent=4, sort_keys=True, ensure_ascii=False) + "\n"
#   - exactly one top-level key, matching the directory ("output"/"input")
#   - blocklist == []; plugins_order has no duplicates and equals the set of
#     plugin instance keys ("<type>#<n>")
#   - every plugin value has the right JSON type, enum values are one of the
#     upstream labels, and numbers are inside the upstream min/max (table:
#     scripts/easyeffects-schema.json, regenerate with scripts/update-schema.py)
#   - equalizer: num-bands equals the number of bandN entries in left and right
#   - every "kernel-name" resolves to irs/<name>.irs or irs/<name>.sofa
#   - .irs files are RIFF/WAVE with 1, 2 or 4 channels; .sofa files start with
#     the HDF5 magic
#   - install.sh manifest (# BEGIN MANIFEST / # END MANIFEST, "<group>|<path>"
#     lines) lists every preset and every irs/ file, and every listed path exists
#   - README.md mentions every preset basename (filename without ".json")
#
# WARN checks (never change the exit status):
#   - keys not present in the upstream schema (unknown plugin type, unknown key)
#   - .irs sample rate other than 48000 Hz
#   - irs/ files that no preset references (orphans) or with unknown extension
#
# Exit codes: 0 = no FAIL; 1 = at least one FAIL; 2 = environment problem
# (python3 missing, schema table unreadable, no presets found).
#
# Usage: ./scripts/validate-presets.sh   (works from any directory)
#
# Requires python3 (stdlib only). There is no jq fallback: the schema checks
# need a real JSON/binary parser, and a partial fallback would let CI pass on
# a weaker check than a developer's machine.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT" || { echo "error: cannot cd to repo root" >&2; exit 2; }

if ! command -v python3 >/dev/null 2>&1; then
    echo "error: python3 is required but not installed." >&2
    exit 2
fi

exec python3 - "$REPO_ROOT" <<'PYEOF'
import json
import math
import os
import re
import struct
import sys

ROOT = sys.argv[1]
os.chdir(ROOT)

fails = 0
warns = 0
checked = 0
EPS = 1e-9


def out(line, err=False):
    stream = sys.stderr if err else sys.stdout
    print(line, file=stream, flush=True)


def passed(msg):
    out("[PASS] " + msg)


def fail(msg):
    global fails
    fails += 1
    out("[FAIL] " + msg, err=True)


def warn(msg):
    global warns
    warns += 1
    out("[WARN] " + msg)


# ---------------------------------------------------------------- schema ----
try:
    with open(os.path.join("scripts", "easyeffects-schema.json"), encoding="utf-8") as fh:
        SCHEMA = json.load(fh)
    PLUGINS = SCHEMA["plugins"]
    SCHEMA_SHA = SCHEMA["source"]["commit"]
except (OSError, ValueError, KeyError) as exc:
    out("error: cannot load scripts/easyeffects-schema.json: %s: %s" % (type(exc).__name__, exc), err=True)
    sys.exit(2)
out("info: schema from wwmm/easyeffects@%s" % SCHEMA_SHA[:12])


def is_number(v):
    return isinstance(v, (int, float)) and not isinstance(v, bool) and math.isfinite(v)


def check_value(spec, val, where, issues):
    """Append ('FAIL'|'WARN', message) tuples to issues."""
    t = spec["type"]
    if t == "bool":
        if not isinstance(val, bool):
            issues.append(("FAIL", "%s: expected boolean, got %r" % (where, val)))
    elif t == "string":
        if not isinstance(val, str):
            issues.append(("FAIL", "%s: expected string, got %r" % (where, val)))
    elif t == "enum":
        if not isinstance(val, str) or val not in spec["choices"]:
            issues.append(("FAIL", "%s: %r is not one of %s" % (where, val, spec["choices"])))
    elif t in ("number", "int"):
        if not is_number(val):
            issues.append(("FAIL", "%s: expected number, got %r" % (where, val)))
        elif t == "int" and val != int(val):
            issues.append(("FAIL", "%s: expected integer, got %r" % (where, val)))
        else:
            if "min" in spec and val < spec["min"] - EPS:
                issues.append(("FAIL", "%s: %r is below minimum %r" % (where, val, spec["min"])))
            if "max" in spec and val > spec["max"] + EPS:
                issues.append(("FAIL", "%s: %r is above maximum %r" % (where, val, spec["max"])))
    elif t == "object":
        check_object(spec, val, where, issues)
    else:
        issues.append(("FAIL", "%s: schema has unknown type %r" % (where, t)))


def check_object(spec, obj, where, issues):
    if not isinstance(obj, dict):
        issues.append(("FAIL", "%s: expected object, got %s" % (where, type(obj).__name__)))
        return
    keys = spec.get("keys", {})
    bands = spec.get("bands")
    for k, v in obj.items():
        sub = "%s.%s" % (where, k)
        if k in keys:
            check_value(keys[k], v, sub, issues)
            continue
        m = re.fullmatch(r"band(\d+)", k)
        if bands and m and int(m.group(1)) < bands["count"]:
            check_object({"keys": bands["keys"]}, v, sub, issues)
            continue
        issues.append(("WARN", "%s: key not in upstream schema" % sub))


# ---------------------------------------------------------------- kernels ---
referenced = set()
irs_index = {}  # stem -> list of (filename)
if os.path.isdir("irs"):
    for fn in sorted(os.listdir("irs")):
        stem, ext = os.path.splitext(fn)
        if ext.lower() in (".irs", ".sofa"):
            irs_index.setdefault(stem, []).append(fn)


def walk_kernels(obj):
    if isinstance(obj, dict):
        for k, v in obj.items():
            if k == "kernel-name" and isinstance(v, str):
                yield v
            yield from walk_kernels(v)
    elif isinstance(obj, list):
        for item in obj:
            yield from walk_kernels(item)


def reject_dupes(pairs):
    d = {}
    for k, v in pairs:
        if k in d:
            raise ValueError("duplicate key %r" % k)
        d[k] = v
    return d


# ---------------------------------------------------------------- presets ---
def discover(directory):
    base = directory or "."
    names = sorted(n for n in os.listdir(base) if n.endswith(".json") and os.path.isfile(os.path.join(base, n)))
    return [os.path.join(directory, n) if directory else n for n in names]


root_presets = discover("")
input_presets = discover("input") if os.path.isdir("input") else []
if not root_presets:
    out("error: no *.json preset files found at repo root", err=True)
    sys.exit(2)

PLUGIN_KEY = re.compile(r"^([a-z_]+)#(\d+)$")


def check_preset(path, section):
    global checked
    checked += 1
    try:
        with open(path, "rb") as fh:
            raw = fh.read()
        text = raw.decode("utf-8")
        data = json.loads(text, object_pairs_hook=reject_dupes)
    except (OSError, UnicodeDecodeError, ValueError) as exc:
        fail("%s: invalid JSON: %s" % (path, exc))
        return
    passed("%s: valid JSON" % path)

    canonical = json.dumps(data, indent=4, sort_keys=True, ensure_ascii=False) + "\n"
    if text != canonical:
        fail("%s: not in canonical form (json.dumps(indent=4, sort_keys=True, ensure_ascii=False) + newline)" % path)

    if not isinstance(data, dict) or list(data.keys()) != [section]:
        got = list(data.keys()) if isinstance(data, dict) else type(data).__name__
        fail("%s: top level must be exactly one key %r, got %s" % (path, section, got))
        return
    body = data[section]
    if not isinstance(body, dict):
        fail("%s: %r must be an object" % (path, section))
        return

    if body.get("blocklist") != []:
        fail("%s: blocklist must be [] (got %r)" % (path, body.get("blocklist", "<missing>")))

    plugin_keys = [k for k in body if k not in ("blocklist", "plugins_order")]
    order = body.get("plugins_order")
    if not isinstance(order, list) or not all(isinstance(x, str) for x in order):
        fail("%s: plugins_order must be a list of strings" % path)
    else:
        if len(order) != len(set(order)):
            dupes = sorted({x for x in order if order.count(x) > 1})
            fail("%s: plugins_order has duplicate entries: %s" % (path, dupes))
        if set(order) != set(plugin_keys):
            fail("%s: plugins_order %s does not match plugin keys %s" % (path, sorted(set(order)), sorted(plugin_keys)))

    issues = []
    for key in plugin_keys:
        m = PLUGIN_KEY.match(key)
        if not m:
            issues.append(("WARN", "%s: unexpected key (not '<type>#<n>')" % key))
            continue
        ptype = m.group(1)
        if ptype not in PLUGINS:
            issues.append(("WARN", "%s: plugin type %r not in upstream schema" % (key, ptype)))
            continue
        check_value(PLUGINS[ptype], body[key], key, issues)
        if ptype == "equalizer" and isinstance(body[key], dict):
            eq = body[key]
            nb = eq.get("num-bands")
            for side in ("left", "right"):
                chan = eq.get(side)
                if not isinstance(chan, dict):
                    issues.append(("FAIL", "%s.%s: missing channel object" % (key, side)))
                    continue
                n = sum(1 for k in chan if re.fullmatch(r"band\d+", k))
                if isinstance(nb, int) and not isinstance(nb, bool) and n != nb:
                    issues.append(("FAIL", "%s.%s: num-bands is %d but %d bandN entries present" % (key, side, nb, n)))
    bad = False
    for level, msg in issues:
        if level == "FAIL":
            fail("%s: %s" % (path, msg))
            bad = True
        else:
            warn("%s: %s" % (path, msg))
    if not bad:
        passed("%s: plugin schema, enums, ranges" % path)

    for kname in walk_kernels(data):
        referenced.add(kname)
        files = irs_index.get(kname)
        if files:
            passed('%s: kernel-name "%s" -> irs/%s found' % (path, kname, files[0]))
            continue
        near = [s for s in irs_index if s.lower() == kname.lower()]
        hint = " (case differs from irs/%s)" % irs_index[near[0]][0] if near else ""
        fail('%s: kernel-name "%s" has no matching irs/%s.irs (or .sofa) file%s' % (path, kname, kname, hint))


for p in root_presets:
    check_preset(p, "output")
for p in input_presets:
    check_preset(p, "input")


# --------------------------------------------------------- kernel files ----
def check_irs(path):
    try:
        with open(path, "rb") as fh:
            head = fh.read(12)
            if len(head) < 12 or head[:4] != b"RIFF" or head[8:12] != b"WAVE":
                fail("%s: not a RIFF/WAVE file" % path)
                return
            while True:
                ch = fh.read(8)
                if len(ch) < 8:
                    fail("%s: no 'fmt ' chunk found" % path)
                    return
                cid, size = ch[:4], struct.unpack("<I", ch[4:])[0]
                if cid == b"fmt ":
                    fmt = fh.read(min(size, 16))
                    if len(fmt) < 16:
                        fail("%s: truncated 'fmt ' chunk" % path)
                        return
                    _tag, channels, rate = struct.unpack("<HHI", fmt[:8])
                    break
                fh.seek(size + (size & 1), 1)
    except (OSError, struct.error) as exc:
        fail("%s: cannot read: %s: %s" % (path, type(exc).__name__, exc))
        return
    if channels not in (1, 2, 4):
        fail("%s: %d channels (EasyEffects convolver supports 1, 2 or 4)" % (path, channels))
    elif rate != 48000:
        warn("%s: sample rate %d Hz (not 48000)" % (path, rate))
        passed("%s: RIFF/WAVE, %d channel(s)" % (path, channels))
    else:
        passed("%s: RIFF/WAVE, %d channel(s), 48000 Hz" % (path, channels))


def check_sofa(path):
    try:
        with open(path, "rb") as fh:
            magic = fh.read(8)
    except OSError as exc:
        fail("%s: cannot read: %s" % (path, exc))
        return
    if magic != b"\x89HDF\r\n\x1a\n":
        fail("%s: missing HDF5 signature" % path)
    else:
        passed("%s: HDF5 signature" % path)


irs_files = []
if os.path.isdir("irs"):
    for fn in sorted(os.listdir("irs")):
        path = "irs/" + fn
        if not os.path.isfile(path):
            continue
        ext = os.path.splitext(fn)[1].lower()
        if ext == ".irs":
            check_irs(path)
        elif ext == ".sofa":
            check_sofa(path)
        else:
            warn("%s: unexpected file type in irs/" % path)
            continue
        irs_files.append(path)
        if os.path.splitext(fn)[0] not in referenced:
            warn("%s is not referenced by any preset's kernel-name (orphaned IR)" % path)

# ---------------------------------------------------------------- install ---
all_presets = root_presets + input_presets
manifest = {}
try:
    with open("install.sh", encoding="utf-8") as fh:
        lines = fh.read().splitlines()
except (OSError, UnicodeDecodeError) as exc:
    fail("install.sh: cannot read: %s" % exc)
    lines = []
begin = [i for i, ln in enumerate(lines) if ln.strip() == "# BEGIN MANIFEST"]
end = [i for i, ln in enumerate(lines) if ln.strip() == "# END MANIFEST"]
if len(begin) != 1 or len(end) != 1 or end[0] < begin[0]:
    fail("install.sh: needs exactly one '# BEGIN MANIFEST' ... '# END MANIFEST' block")
else:
    for n, ln in enumerate(lines[begin[0] + 1:end[0]], start=begin[0] + 2):
        s = ln.strip()
        if not s or s.startswith("#"):
            continue
        group, sep, path = s.partition("|")
        if not sep or not group or not path:
            fail("install.sh:%d: malformed manifest line %r (want '<group>|<path>')" % (n, s))
            continue
        manifest.setdefault(path, group)
    missing_files = [p for p in manifest if not os.path.isfile(p)]
    for p in missing_files:
        fail("install.sh manifest lists %r which does not exist" % p)
    unlisted = [p for p in all_presets + irs_files if p not in manifest]
    for p in unlisted:
        fail("install.sh manifest does not list %r" % p)
    if not missing_files and not unlisted:
        passed("install.sh manifest covers %d file(s)" % len(manifest))

# ----------------------------------------------------------------- README ---
try:
    with open("README.md", encoding="utf-8") as fh:
        readme = fh.read()
except (OSError, UnicodeDecodeError) as exc:
    fail("README.md: cannot read: %s" % exc)
    readme = None
if readme is not None:
    gaps = [p for p in all_presets if os.path.splitext(os.path.basename(p))[0] not in readme]
    for p in gaps:
        fail("README.md does not mention preset %r" % os.path.splitext(os.path.basename(p))[0])
    if not gaps:
        passed("README.md mentions all %d preset(s)" % len(all_presets))

out("")
out("Summary: %d preset(s) checked, %d failure(s), %d warning(s)" % (checked, fails, warns))
sys.exit(1 if fails else 0)
PYEOF
