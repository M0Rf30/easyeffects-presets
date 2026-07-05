#!/usr/bin/env bash
#
# validate-presets.sh — sanity-check EasyEffects presets in this repo.
#
# What it checks:
#   1. Every *.json file at the repo root parses as valid JSON.
#   2. Every "kernel-name" value referenced anywhere inside those presets has
#      a matching impulse-response file at irs/<kernel-name>.irs (or .sofa).
#      A preset pointing at a missing kernel file is reported as FAIL.
#   3. Every *.irs/*.sofa file under irs/ that is never referenced by any
#      preset's "kernel-name" is reported as a WARNING (not a failure) —
#      this repo intentionally ships some general-purpose IRs that users
#      pick manually in the EasyEffects GUI without a preset wiring them in.
#
# Usage:
#   ./scripts/validate-presets.sh
# Run from the repo root (or anywhere; the script cd's to the repo root on
# its own). Exit status is non-zero ONLY when a FAIL is reported (invalid
# JSON, or a preset referencing a missing kernel file); orphaned irs files
# alone still exit 0 (warnings-only run).
#
# Requires python3 (preferred, uses the stdlib json module) or jq (fallback)
# for JSON parsing. Errors out clearly if neither is installed.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT" || { echo "error: cannot cd to repo root" >&2; exit 2; }

fail_count=0
warn_count=0
checked_count=0

have_py=0
have_jq=0
command -v python3 >/dev/null 2>&1 && have_py=1
command -v jq >/dev/null 2>&1 && have_jq=1

if [ "$have_py" -eq 0 ] && [ "$have_jq" -eq 0 ]; then
    echo "error: neither 'python3' nor 'jq' is installed; cannot validate JSON." >&2
    exit 2
fi

if [ "$have_py" -eq 1 ]; then
    echo "info: using python3 (json module) for JSON validation and kernel-name extraction"
else
    echo "info: python3 not found; using jq for JSON validation and kernel-name extraction"
fi

declare -A referenced_kernels

validate_json() {
    # $1 = file path. Returns 0 if valid JSON, 1 otherwise.
    file="$1"
    if [ "$have_py" -eq 1 ]; then
        python3 -m json.tool "$file" >/dev/null 2>&1
        return $?
    else
        jq empty "$file" >/dev/null 2>&1
        return $?
    fi
}

extract_kernel_names() {
    # $1 = file path (already confirmed to be valid JSON). Prints one
    # kernel-name value per line, found anywhere in the document tree.
    file="$1"
    if [ "$have_py" -eq 1 ]; then
        python3 - "$file" <<'PYEOF'
import json
import sys


def walk(obj):
    if isinstance(obj, dict):
        for key, value in obj.items():
            if key == "kernel-name" and isinstance(value, str):
                print(value)
            walk(value)
    elif isinstance(obj, list):
        for item in obj:
            walk(item)


try:
    with open(sys.argv[1], encoding="utf-8") as fh:
        walk(json.load(fh))
except Exception:
    pass
PYEOF
    else
        jq -r '.. | objects | .["kernel-name"]? // empty' "$file" 2>/dev/null
    fi
}

shopt -s nullglob
json_files=( *.json )
shopt -u nullglob

if [ "${#json_files[@]}" -eq 0 ]; then
    echo "error: no *.json preset files found at repo root" >&2
    exit 2
fi

for f in "${json_files[@]}"; do
    checked_count=$((checked_count + 1))
    if validate_json "$f"; then
        echo "[PASS] $f: valid JSON"
    else
        echo "[FAIL] $f: invalid JSON" >&2
        fail_count=$((fail_count + 1))
        continue
    fi

    while IFS= read -r kname; do
        [ -n "$kname" ] || continue
        referenced_kernels["$kname"]=1
        found=0
        match=""
        for ext in irs sofa; do
            if [ -f "irs/${kname}.${ext}" ]; then
                found=1
                match="irs/${kname}.${ext}"
                break
            fi
        done
        if [ "$found" -eq 1 ]; then
            echo "[PASS] $f: kernel-name \"$kname\" -> $match found"
        else
            echo "[FAIL] $f: kernel-name \"$kname\" has no matching irs/${kname}.irs (or .sofa) file" >&2
            fail_count=$((fail_count + 1))
        fi
    done < <(extract_kernel_names "$f")
done

# Orphan check: irs/*.irs and irs/*.sofa never referenced by any preset.
if [ -d irs ]; then
    while IFS= read -r -d '' irs_file; do
        base="$(basename "$irs_file")"
        name="${base%.*}"
        if [ -z "${referenced_kernels[$name]+x}" ]; then
            echo "[WARN] irs/$base is not referenced by any preset's kernel-name (orphaned IR)"
            warn_count=$((warn_count + 1))
        fi
    done < <(find irs -maxdepth 1 -type f \( -iname '*.irs' -o -iname '*.sofa' \) -print0 | sort -z)
fi

echo
echo "Summary: $checked_count preset(s) checked, $fail_count failure(s), $warn_count warning(s)"

if [ "$fail_count" -gt 0 ]; then
    exit 1
fi
exit 0
