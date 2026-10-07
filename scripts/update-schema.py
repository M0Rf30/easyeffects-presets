#!/usr/bin/env python3
"""Regenerate scripts/easyeffects-schema.json from upstream EasyEffects.

Source of truth (wwmm/easyeffects, a single pinned commit):
  src/contents/kcfg/easyeffects_db_<plugin>.kcfg   enum labels, min/max, types
  src/<plugin>_preset.cpp                          JSON key -> kcfg entry mapping
  src/tags_<plugin>.hpp                            per-band kcfg entry names

The JSON key names are NOT guessed from the kcfg: they are read from the
`json[section][instance_name]["key"] = settings->entry()` statements in each
<plugin>_preset.cpp save() function. Enum choices are the kcfg `<x>Labels`
StringList defaults; a preset stores the label string.

Usage:
  python3 scripts/update-schema.py              # pin to current master
  python3 scripts/update-schema.py --ref <sha>  # pin to a specific commit/tag
  python3 scripts/update-schema.py --local DIR  # use a local easyeffects checkout
  python3 scripts/update-schema.py --check      # exit 1 if the vendored file differs

Network access (stdlib urllib only) is needed unless --local is given. Set
GITHUB_TOKEN to avoid unauthenticated API rate limits.
"""

import argparse
import json
import os
import re
import sys
import urllib.error
import urllib.request
import xml.etree.ElementTree as ET

REPO = "wwmm/easyeffects"
SCHEMA_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "easyeffects-schema.json")


class Source:
    """Reads upstream files from GitHub (pinned sha) or a local checkout."""

    def __init__(self, ref, local):
        self.local = local
        if local:
            self.sha = ref or "local"
            self.files = set()
            for root, _dirs, names in os.walk(os.path.join(local, "src")):
                for n in names:
                    self.files.add(os.path.relpath(os.path.join(root, n), local))
            return
        self.sha = self._api("commits/" + (ref or "master"))["sha"]
        tree = self._api("git/trees/%s?recursive=1" % self.sha)
        self.files = {e["path"] for e in tree["tree"] if e["type"] == "blob"}

    @staticmethod
    def _open(url):
        req = urllib.request.Request(url, headers={"User-Agent": "easyeffects-presets-schema"})
        token = os.environ.get("GITHUB_TOKEN")
        if token and "api.github.com" in url:
            req.add_header("Authorization", "Bearer " + token)
        with urllib.request.urlopen(req, timeout=60) as resp:
            return resp.read().decode("utf-8")

    def _api(self, path):
        return json.loads(self._open("https://api.github.com/repos/%s/%s" % (REPO, path)))

    def has(self, path):
        return path in self.files

    def read(self, path):
        if self.local:
            with open(os.path.join(self.local, path), encoding="utf-8") as fh:
                return fh.read()
        return self._open("https://raw.githubusercontent.com/%s/%s/%s" % (REPO, self.sha, path))


def lcfirst(s):
    return s[:1].lower() + s[1:]


def num(text):
    try:
        v = float(text)
    except (TypeError, ValueError):
        return None
    return int(v) if v == int(v) else v


def parse_kcfg(text):
    root = ET.fromstring(text)
    entries = {}
    for el in root.iter():
        if not el.tag.endswith("entry"):
            continue
        d = {"type": el.get("type")}
        for child in el:
            name = child.tag.split("}")[-1]
            if name in ("min", "max", "default") and child.text is not None:
                d[name] = child.text.strip()
        entries[el.get("name")] = d
    return entries


def labels_of(entries, name):
    e = entries.get(name)
    if not e or e["type"] != "StringList":
        raise KeyError("no StringList entry %r" % name)
    return [x.strip() for x in e.get("default", "").split(",")]


def spec_for_entry(entries, name):
    e = entries[name]
    t = e["type"]
    if t == "Bool":
        return {"type": "bool"}
    if t == "String":
        return {"type": "string"}
    if t in ("Double", "Int", "Enum", "UInt"):
        s = {"type": "number" if t == "Double" else "int"}
        if num(e.get("min")) is not None:
            s["min"] = num(e["min"])
        if num(e.get("max")) is not None:
            s["max"] = num(e["max"])
        return s
    raise ValueError("unsupported kcfg type %s for %s" % (t, name))


def enum_spec(entries, labels_entry):
    return {"type": "enum", "choices": labels_of(entries, labels_entry)}


def parse_tags(text):
    tags = {}
    n_bands = None
    for m in re.finditer(r"constexpr\s+auto\s+(\w+)\s*=\s*std::to_array\((.*?)\);", text, re.S):
        tags[m.group(1)] = re.findall(r'"(\w+)"', m.group(2))
    m = re.search(r"n_bands\s*=\s*(\d+)", text)
    if m:
        n_bands = int(m.group(1))
    return tags, n_bands


def statements(cpp):
    cpp = cpp.replace("\\\n", " ")
    for piece in cpp.split(";"):
        yield " ".join(piece.split())


def build_plugin(src, plugin):
    base = "src/" + plugin
    cpp = src.read(base + "_preset.cpp")
    kcfg_path = "src/contents/kcfg/easyeffects_db_%s.kcfg" % plugin
    entries = parse_kcfg(src.read(kcfg_path))

    chan_inc = re.search(r'#include "easyeffects_db_(\w+_channel)\.h"', cpp)
    band_entries = entries
    if chan_inc:
        band_entries = parse_kcfg(src.read("src/contents/kcfg/easyeffects_db_%s.kcfg" % chan_inc.group(1)))

    tags, n_bands = {}, None
    tag_inc = re.search(r'#include "tags_(\w+)\.hpp"', cpp)
    tags_name = tag_inc.group(1) if tag_inc else plugin
    if src.has("src/tags_%s.hpp" % tags_name):
        tags, n_bands = parse_tags(src.read("src/tags_%s.hpp" % tags_name))

    channels = sorted(set(re.findall(r'save_channel\(json\[section\]\[instance_name\]\["(\w+)"\]', cpp)))
    save_band_calls = [int(x) for x in re.findall(r"\bSAVE_BAND\((\d+)\)", cpp)]

    keys = {}
    nested = {}
    band_keys = {}
    unresolved = []

    def band_spec_from_tag(tag, labels_entry):
        names = [n for n in tags.get(tag, []) if n in band_entries]
        if not names:
            raise KeyError("tag %s has no kcfg entry" % tag)
        if labels_entry:
            return enum_spec(band_entries, labels_entry)
        return spec_for_entry(band_entries, names[0])

    for st in statements(cpp):
        m = re.search(r"\bjson((?:\[[^\]]+\])+)\s*=\s*(.+)$", st)
        if not m:
            continue
        path = re.findall(r"\[([^\]]+)\]", m.group(1))
        rhs = m.group(2).strip()
        if path[:2] == ["section", "instance_name"]:
            path = path[2:]
        if not path or not path[-1].startswith('"'):
            continue
        key = path[-1].strip('"')
        is_band = len(path) == 2 and path[0] == "bandn"
        nest = path[0].strip('"') if len(path) == 2 and path[0].startswith('"') else None

        spec = None
        try:
            m1 = re.match(r"settings->default(\w+?)LabelsValue\(\)\[settings->\w+\(\)\]", rhs)
            m2 = re.match(r"settings->(\w+Labels)\(\)\[settings->property\((\w+)\[n\]\.data\(\)\)\.value<int>\(\)\]", rhs)
            m3 = re.match(r"settings->property\((\w+)\[n\]\.data\(\)\)\.value<\w+>\(\)$", rhs)
            m4 = re.match(r"settings->(\w+)Band##index\(\)$", rhs)
            m5 = re.match(r"settings->(\w+)\(\)\.toStdString\(\)$", rhs)
            m6 = re.match(r"settings->(\w+)\(\)$", rhs)
            if m1:
                spec = enum_spec(entries, lcfirst(m1.group(1)) + "Labels")
            elif m2:
                spec = band_spec_from_tag(m2.group(2), m2.group(1))
            elif m3:
                spec = band_spec_from_tag(m3.group(1), None)
            elif m4:
                spec = spec_for_entry(entries, m4.group(1) + "Band0")
                is_band = True
            elif m5:
                spec = spec_for_entry(entries, m5.group(1))
            elif m6:
                spec = spec_for_entry(entries, m6.group(1))
            elif rhs == "nbands":
                spec = spec_for_entry(entries, "numBands")
        except (KeyError, ValueError) as exc:
            unresolved.append("%s: %s (%s)" % (key, exc, rhs))
            continue
        if spec is None:
            unresolved.append("%s: unrecognised RHS %r" % (key, rhs))
            continue
        if is_band:
            band_keys[key] = spec
        elif nest:
            nested.setdefault(nest, {})[key] = spec
        else:
            keys[key] = spec

    # Keys only read in load(): UPDATE_PROPERTY("json-key", EntryName)
    for m in re.finditer(r'UPDATE(?:_ENUM_LIKE)?_PROPERTY\("([\w-]+)",\s*(\w+)\)', cpp):
        key, ent = m.group(1), lcfirst(m.group(2))
        if key in keys or key in band_keys or ent not in entries:
            continue
        if entries[ent]["type"] == "StringList":
            continue
        if ent + "Labels" in entries:
            keys[key] = enum_spec(entries, ent + "Labels")
        else:
            keys[key] = spec_for_entry(entries, ent)

    for name, sub in nested.items():
        keys[name] = {"type": "object", "keys": sub}

    spec = {"type": "object", "keys": keys}
    if band_keys:
        if channels:
            count = n_bands or len(tags.get("band_id", [])) or 0
            chan = {"type": "object", "keys": {}, "bands": {"count": count, "keys": band_keys}}
            for c in channels:
                spec["keys"][c] = chan
        else:
            count = (max(save_band_calls) + 1) if save_band_calls else (n_bands or 0)
            spec["bands"] = {"count": count, "keys": band_keys}
    return spec, unresolved


def build(src):
    plugins = {}
    problems = []
    for path in sorted(src.files):
        m = re.fullmatch(r"src/(\w+)_preset\.cpp", path)
        if not m:
            continue
        plugin = m.group(1)
        if not src.has("src/contents/kcfg/easyeffects_db_%s.kcfg" % plugin):
            continue
        spec, unresolved = build_plugin(src, plugin)
        if not spec["keys"] and "bands" not in spec:
            continue
        plugins[plugin] = spec
        problems += ["%s: %s" % (plugin, u) for u in unresolved]
    return {
        "_comment": "Generated by scripts/update-schema.py from wwmm/easyeffects; do not edit by hand.",
        "source": {"repo": "https://github.com/" + REPO, "commit": src.sha},
        "plugins": plugins,
    }, problems


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--ref", help="upstream commit/branch/tag to pin (default: master)")
    ap.add_argument("--local", help="path to a local easyeffects checkout instead of GitHub")
    ap.add_argument("--check", action="store_true", help="do not write; exit 1 if file differs")
    ap.add_argument("--output", default=SCHEMA_PATH)
    args = ap.parse_args()

    try:
        schema, problems = build(Source(args.ref, args.local))
    except (urllib.error.URLError, OSError, KeyError, ET.ParseError) as exc:
        print("error: %s: %s" % (type(exc).__name__, exc), file=sys.stderr)
        return 2
    for p in problems:
        print("warning: unresolved: " + p, file=sys.stderr)

    text = json.dumps(schema, indent=1, sort_keys=True, ensure_ascii=False) + "\n"
    if args.check:
        try:
            with open(args.output, encoding="utf-8") as fh:
                same = fh.read() == text
        except OSError:
            same = False
        print("schema up to date" if same else "schema differs from upstream")
        return 0 if same else 1
    with open(args.output, "w", encoding="utf-8") as fh:
        fh.write(text)
    print("wrote %s (%d plugins, commit %s)" % (args.output, len(schema["plugins"]), schema["source"]["commit"]))
    return 0


if __name__ == "__main__":
    sys.exit(main())
