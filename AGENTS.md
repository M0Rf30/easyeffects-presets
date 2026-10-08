# Repository Guidelines

## Project Overview

A curated collection of preset configuration files for [wwmm/EasyEffects](https://github.com/wwmm/easyeffects) (a PipeWire-based Linux audio effects app). Originally forked from JackHack96/EasyEffects-Presets, now maintained as a standalone repository (`M0Rf30/easyeffects-presets`, no fork relationship). There is **no application code** here — the repo's product is JSON preset files, the binary impulse-response (IR/HRTF) assets they reference, and a bash installer that fetches both onto a user's machine. Presets range from simple EQ curves to headphone-virtualization technologies (HeSuVi, EFOtech MLV) driven by convolution kernels, to SOFA-based scientific HRTF datasets.

## Architecture & Data Flow

```
root/*.json (preset)  --kernel-name-->  irs/<name>.irs | irs/<name>.sofa  (binary IR/HRTF asset)
       |
       v
  install.sh  --curl(<base URL>/<manifest path>)-->  ~/.local/share/easyeffects/{output,input,irs}/
                                                      (or the Flatpak-sandboxed equivalent)
       |
       v
  EasyEffects app loads output/*.json, resolves each plugin's kernel-name
  against irs/ at runtime (Convolver plugin, via libmysofa for .sofa)
```

- A preset is a serialized EasyEffects pipeline: an ordered list of plugin instances (`equalizer#0`, `convolver#0`, `limiter#0`, …). Convolver-based presets don't embed audio — they reference a `kernel-name` that must resolve to a same-named file under `irs/`.
- Two convolver kernel formats coexist: plain RIFF/WAVE `.irs` (mono/stereo/4-channel "true stereo") loaded directly, and AES69 `.sofa` (HDF5, full measured HRTF datasets) loaded via `libmysofa` with **zero conversion**.
- Distribution is pull-based: `install.sh` curls manifest files from raw.githubusercontent.com at a chosen ref (default `main`, or a tag via `--ref`); nothing is packaged ahead of time. Writes are atomic and failed downloads give a non-zero exit.
- No preset is consumed anywhere except by the EasyEffects app itself; this repo has no runtime of its own.

## Key Directories

| Path | Purpose |
|---|---|
| `/*.json` | 105 output preset files, one pipeline definition each. Root-level only. |
| `input/` | 2 microphone (`"input"` pipeline) presets: Voice Noise Suppression, Voice Broadcast. Installed to `<data>/input/`. |
| `irs/` | 92 binary impulse-response/HRTF files (`.irs` WAVE, `.sofa` HDF5), each referenced by a preset via `kernel-name`. |
| `scripts/` | `validate-presets.sh` (QA suite), `easyeffects-schema.json` + `update-schema.py` (vendored schema table), `generate-synthetic-crossfeed.js` and `generate-synthetic-binaural-room.js` (the two programmatically generated kernels). |
| `.github/workflows/` | Single CI workflow with `lint`, `validate`, `generators` jobs. |
| `install.sh` | End-user installer (bash) with an embedded manifest. |
| `THIRD-PARTY-NOTICES.md` | Licenses and attribution for bundled third-party assets. |
| `io.github.wwmm.easyeffects.Presets.M0Rf30.metainfo.xml` | AppStream/Flatpak addon metadata (not consumed by install.sh or EasyEffects). |

## Development Commands

```bash
# QA gate — run before every commit touching *.json, irs/, install.sh or README.md (python3 required)
bash scripts/validate-presets.sh

# Regenerate the synthetic kernels (overwrite irs/ unconditionally; output is deterministic)
node scripts/generate-synthetic-crossfeed.js
node scripts/generate-synthetic-binaural-room.js

# Refresh the vendored EasyEffects schema table
python3 scripts/update-schema.py

# Installer: interactive menu, or non-interactive
bash install.sh
bash install.sh all | <n> | <group> | uninstall   # plus --ref <tag>, --flatpak, -y/--yes, -h
```

There is no build step, no lint config, and no package manager (no `package.json`, no lockfile). CI additionally runs ShellCheck and `node --check` (see Testing & QA).

## Code Conventions & Common Patterns

**JSON preset schema** (identical shape across all files):
```json
{
    "output": {
        "blocklist": [],
        "<plugin_type>#<N>": { "...kebab-case-fields...": 0 },
        "plugins_order": ["<plugin_type>#<N>", "..."]
    }
}
```
- Single top-level key is `"output"` for root presets and `"input"` for `input/*.json` microphone presets (the validator checks it matches the directory). Same plugin/field schema otherwise.
- `blocklist` is always `[]` — leave it that way.
- Plugin instance keys are `"<snake_case_type>#<index>"` (e.g. `equalizer#0`, `convolver#0`). When a preset uses several instances of one type they are numbered `#0`, `#1`, … without gaps (e.g. two compressors → `compressor#0`, `compressor#1`). `plugins_order` lists the same keys to define signal-chain order (object key order is not load-bearing).
- **All object keys are strictly alphabetically sorted** (`plugins_order` sorts after the plugin blocks) and the file must equal `json.dumps(indent=4, sort_keys=True, ensure_ascii=False)` plus a trailing newline — the validator enforces this byte-for-byte.
- Fields are kebab-case (`input-gain`, `kernel-name`, `num-bands`, `stereo-link`, …), matching EasyEffects' GSettings schema 1:1 — these are literal serialized settings dumps, not a repo-invented format.
- 4-space indent, trailing newline, one preset per file.
- Numeric literal style (bare `0`/`-100` vs explicit `0.0`/`-100.0`) is inconsistent **by family**, not randomly — match whatever your preset's closest sibling already uses rather than mixing styles within a lineage.

**Naming convention** — three independent strings must line up, only one link is load-bearing:
1. Preset filename (e.g. `HeSuVi GSX.json`) — cosmetic, shown in EasyEffects' preset list.
2. `convolver#0.kernel-name` (e.g. `"HeSuVi GSX (True Stereo, 48kHz)"`) — no extension.
3. `irs/<kernel-name>.irs` or `irs/<kernel-name>.sofa` — **this is the only link EasyEffects (and `validate-presets.sh`) actually enforces.** Preset filename and kernel-name are usually near-identical but are never required to match each other.

**True-stereo `.irs` channel order** (4-channel kernels): `L→L, L→R, R→L, R→R` (left/right source crossed into left/right ear) — this is the order EasyEffects' Convolver expects; get it backwards and crosstalk channels are silently swapped. See `scripts/generate-synthetic-crossfeed.js:124-137` for a worked, commented example cross-checked against upstream `convolver_kernel_manager.cpp`.

**Adding or renaming a preset** (the validator enforces the last two items):
1. The preset `.json` (+ its `.irs`/`.sofa` in `irs/` if convolver-based; root for output presets, `input/` for microphone presets).
2. `install.sh` manifest (between `# BEGIN MANIFEST` and `# END MANIFEST`): one `group|path` line per file (paths literal, not URL-encoded; root `.json` → `output/`, `input/*` and `irs/*` keep their directory). A new menu entry additionally needs a `MENU_GROUPS`/`MENU_LABELS` pair (menu: 1 all, 2-22 output groups, 23 `input`, 24 `uninstall`).
3. `README.md`: an entry with provenance/citation, containing the preset basename literally; update the Installation table and counts if a group changed.
4. `THIRD-PARTY-NOTICES.md` if the asset is third-party; the README `Impulse Responses` inventory if a kernel was added.
5. `scripts/validate-presets.sh` needs no changes — it discovers presets/kernels dynamically. Run it before committing.

**Convolver level matching.** For every new convolver preset, set `output-gain` so the mono-input gain averaged over 200 Hz–4 kHz is about 0 dB, accounting for EasyEffects' autogain (it peak-normalises the kernel, then scales by min(1, 1/sqrt(max channel energy))); set the limiter threshold to −1 dB (not 0). Both synthetic generators normalise their kernels to 0 dB themselves. Trim leading silence from imported kernels.

**Sidechain routing keys.** `-80.01` means off (the schema minimum). `0.0` is active unity routing, not "off". Use `-80.01` for unused dry/release-threshold style fields where the schema minimum is −80.01, not `-100`. Do not use the legacy external-sidechain fields. Limiter oversampling labels must be real enum values (e.g. `Full x8/24 bit`), and values must respect the kcfg min/max (the validator checks this).

**Provenance/citation convention** (README): every preset entry states exactly where its data came from (upstream repo/paper links, measurement metadata like sample count/rate), and explicitly flags uncertainty where provenance can't be fully verified rather than asserting it. Match this tone for any new preset.

## Important Files

- `install.sh` — end-user installer. The base URL defaults to `raw.githubusercontent.com/M0Rf30/easyeffects-presets/<ref>` (`--ref`/`EASYEFFECTS_PRESETS_REF`, default `main`; `EASYEFFECTS_PRESETS_BASE_URL` overrides); a repo rename or a renamed file breaks downloads. Files come from the manifest block, not from hard-coded `curl` lines.
- `scripts/validate-presets.sh` — the repo's QA gate; read it before changing preset/`irs/` layout conventions.
- `README.md` — canonical, human-facing documentation; keep the preset list, the "Impulse Responses" section, and the Installation table in sync with reality (it explicitly says to trust the live `install.sh` menu over itself if they drift).
- `io.github.wwmm.easyeffects.Presets.M0Rf30.metainfo.xml` — AppStream addon metadata (id, developer, URLs, description, `<releases>`, SPDX `project_license`). Add a `<release>` per git tag and keep `project_license` consistent with `THIRD-PARTY-NOTICES.md`. Validate with `appstreamcli validate --pedantic`; the only accepted warning is the uppercase component id (`cid-contains-uppercase-letter`; the id must not change). `LICENSE`'s copyright line names Matteo Iervasi (2018 original author) — historical attribution, not a bug.
- `THIRD-PARTY-NOTICES.md` — source, license, attribution and caveats per bundled asset group. Update it when adding or replacing any third-party preset or kernel.

## Runtime/Tooling Preferences

- **`install.sh`**: bash (`#!/usr/bin/env bash`), requires `curl` on the end-user's machine. Passes ShellCheck (CI enforces it).
- **`scripts/generate-*.js`**: Node.js (`#!/usr/bin/env node`), zero third-party dependencies (only `fs`/`path`). Output must be deterministic (CI regenerates and diffs `irs/`).
- **`scripts/validate-presets.sh`** and **`scripts/update-schema.py`**: require `python3` (stdlib only). There is no `jq` fallback; exit 2 if `python3` is missing.
- No package manager, no lockfile, no declared Node/Python version — don't add a `package.json` unless you're introducing an actual dependency.

## Testing & QA

`scripts/validate-presets.sh` is the test suite (no unit tests, no pre-commit hooks).

FAIL checks (exit 1), for root `*.json` (`"output"`) and `input/*.json` (`"input"`):
- Parses as JSON, no duplicate keys, and is byte-identical to `json.dumps(obj, indent=4, sort_keys=True, ensure_ascii=False) + "\n"` (canonical serialization).
- Exactly one top-level key matching the directory; `blocklist == []`; `plugins_order` has no duplicates and equals the set of `<type>#<n>` keys.
- Every plugin value has the right JSON type, enum values are upstream labels, numbers are within the upstream min/max (table: `scripts/easyeffects-schema.json`).
- Equalizer `num-bands` equals the number of `bandN` entries in left and right.
- Every `kernel-name` resolves to `irs/<name>.irs` or `.sofa`; `.irs` is RIFF/WAVE with 1, 2 or 4 channels; `.sofa` has the HDF5 signature.
- The `install.sh` manifest lists every preset and every `irs/` file, and every listed path exists.
- `README.md` contains every preset basename (filename without `.json`) literally.

WARN only: keys unknown to the upstream schema, `.irs` sample rate other than 48 kHz, orphaned `irs/` files. A clean run has none.

Exit codes: `2` = environment problem (no `python3`, unreadable schema table, no presets); `1` = at least one FAIL; `0` = success.

**Schema table.** `scripts/easyeffects-schema.json` is vendored from upstream `wwmm/easyeffects` (pinned commit `2bd13837` at the time of writing). Regenerate it with `python3 scripts/update-schema.py` when upgrading the targeted EasyEffects version, then re-run the validator.

**CI** (`.github/workflows/validate-presets.yml`): runs on push to `main` and on pull requests, `contents: read` only, checkout pinned by SHA. Jobs: `lint` (ShellCheck on `install.sh` and `scripts/*.sh`, `node --check` on `scripts/*.js`), `validate` (`bash scripts/validate-presets.sh`), `generators` (regenerate both synthetic kernels, `git diff --exit-code -- irs/`).
