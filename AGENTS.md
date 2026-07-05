# Repository Guidelines

## Project Overview

A curated collection of preset configuration files for [wwmm/EasyEffects](https://github.com/wwmm/easyeffects) (a PipeWire-based Linux audio effects app). Originally forked from JackHack96/EasyEffects-Presets, now maintained as a standalone repository (`M0Rf30/easyeffects-presets`, no fork relationship). There is **no application code** here — the repo's product is JSON preset files, the binary impulse-response (IR/HRTF) assets they reference, and a bash installer that fetches both onto a user's machine. Presets range from simple EQ curves to headphone-virtualization technologies (HeSuVi, EFOtech MLV) driven by convolution kernels, to SOFA-based scientific HRTF datasets.

## Architecture & Data Flow

```
root/*.json (preset)  --kernel-name-->  irs/<name>.irs | irs/<name>.sofa  (binary IR/HRTF asset)
       |
       v
  install.sh  --curl(GIT_REPOSITORY + filename)-->  ~/.local/share/easyeffects/{output,irs}/
                                                      (or the Flatpak-sandboxed equivalent)
       |
       v
  EasyEffects app loads output/*.json, resolves each plugin's kernel-name
  against irs/ at runtime (Convolver plugin, via libmysofa for .sofa)
```

- A preset is a serialized EasyEffects pipeline: an ordered list of plugin instances (`equalizer#0`, `convolver#0`, `limiter#0`, …). Convolver-based presets don't embed audio — they reference a `kernel-name` that must resolve to a same-named file under `irs/`.
- Two convolver kernel formats coexist: plain RIFF/WAVE `.irs` (mono/stereo/4-channel "true stereo") loaded directly, and AES69 `.sofa` (HDF5, full measured HRTF datasets) loaded via `libmysofa` with **zero conversion**.
- Distribution is pull-based and unversioned: `install.sh` curls files straight from a live GitHub branch at install time — nothing is packaged/bundled ahead of time.
- No preset is consumed anywhere except by the EasyEffects app itself; this repo has no runtime of its own.

## Key Directories

| Path | Purpose |
|---|---|
| `/*.json` | ~49 preset files, one pipeline definition each. Root-level only — no subfolders. |
| `irs/` | ~45 binary impulse-response/HRTF files (`.irs` WAVE, `.sofa` HDF5), each referenced by a preset via `kernel-name`. |
| `scripts/` | `validate-presets.sh` (the entire QA suite) and `generate-synthetic-crossfeed.js` (the one programmatically-generated kernel). |
| `.github/workflows/` | Single CI workflow, mirrors `scripts/validate-presets.sh`. |
| `install.sh` | End-user installer (bash), root of repo. |
| `io.github.wwmm.easyeffects.Presets.M0Rf30.metainfo.xml` | AppStream/Flatpak addon-discovery metadata (not consumed by install.sh or EasyEffects; Flatpak tooling only). |

## Development Commands

```bash
# The only "test" in this repo — run before every commit touching *.json or irs/
bash scripts/validate-presets.sh

# Regenerate the one physically-modeled kernel (overwrites irs/ unconditionally)
node scripts/generate-synthetic-crossfeed.js

# Try the install flow end-to-end (menu-driven, defaults to option 1 on Enter)
bash install.sh
```

There is no build step, no lint config, and no package manager anywhere in this repo (no `package.json`, no lockfile).

## Code Conventions & Common Patterns

**JSON preset schema** (identical shape across all 49 files):
```json
{
    "output": {
        "blocklist": [],
        "<plugin_type>#<N>": { "...kebab-case-fields...": 0 },
        "plugins_order": ["<plugin_type>#<N>", "..."]
    }
}
```
- Single top-level key is always `"output"` (no preset targets the microphone/`"input"` pipeline).
- `blocklist` is always `[]` — leave it that way.
- Plugin instance keys are `"<snake_case_type>#<index>"` (e.g. `equalizer#0`, `convolver#0`); every preset in this repo only ever uses `#0` of a given type. `plugins_order` lists those same keys to define actual signal-chain order (object key order is not load-bearing).
- **All object keys are strictly alphabetically sorted**, including `plugins_order` sorting after the plugin blocks it lists (verified with zero exceptions across all 49 files) — this is what EasyEffects itself produces on export, so match it in any hand edit.
- Fields are kebab-case (`input-gain`, `kernel-name`, `num-bands`, `stereo-link`, …), matching EasyEffects' GSettings schema 1:1 — these are literal serialized settings dumps, not a repo-invented format.
- 4-space indent, trailing newline, one preset per file.
- Numeric literal style (bare `0`/`-100` vs explicit `0.0`/`-100.0`) is inconsistent **by family**, not randomly — match whatever your preset's closest sibling already uses rather than mixing styles within a lineage.

**Naming convention** — three independent strings must line up, only one link is load-bearing:
1. Preset filename (e.g. `HeSuVi GSX.json`) — cosmetic, shown in EasyEffects' preset list.
2. `convolver#0.kernel-name` (e.g. `"HeSuVi GSX (True Stereo, 48kHz)"`) — no extension.
3. `irs/<kernel-name>.irs` or `irs/<kernel-name>.sofa` — **this is the only link EasyEffects (and `validate-presets.sh`) actually enforces.** Preset filename and kernel-name are usually near-identical but are never required to match each other.

**True-stereo `.irs` channel order** (4-channel kernels): `L→L, L→R, R→L, R→R` (left/right source crossed into left/right ear) — this is the order EasyEffects' Convolver expects; get it backwards and crosstalk channels are silently swapped. See `scripts/generate-synthetic-crossfeed.js:124-137` for a worked, commented example cross-checked against upstream `convolver_kernel_manager.cpp`.

**Adding or renaming a preset requires updating four places in the same commit** (nothing enforces this beyond code review + `validate-presets.sh`):
1. The preset `.json` file (+ its `.irs`/`.sofa` in `irs/` if convolver-based).
2. `install.sh`: a new numbered `install_menu()` option, `read_choice()`'s regex range, and the matching `case` branch's `curl --fail` lines (URL-encode spaces/parens/`+` in the URL, e.g. `Perfect%20EQ.json`).
3. `README.md`: a numbered list entry (with provenance/citation) **and** an `Installation` table row.
4. `scripts/validate-presets.sh` needs no changes — it discovers presets/kernels dynamically.

**Provenance/citation convention** (README): every preset entry states exactly where its data came from (upstream repo/paper links, measurement metadata like sample count/rate), and explicitly flags uncertainty where provenance can't be fully verified rather than asserting it. Match this tone for any new preset.

## Important Files

- `install.sh` — end-user installer; `GIT_REPOSITORY` (line 4) hardcodes `raw.githubusercontent.com/M0Rf30/easyeffects-presets/main` — every curl call is relative to this, so a renamed/moved file (or a repo/branch rename, as already happened once) breaks every download silently until this stays in sync.
- `scripts/validate-presets.sh` — the repo's QA gate; read it before changing preset/`irs/` layout conventions.
- `README.md` — canonical, human-facing documentation; keep the preset list, the "Impulse Responses" section, and the Installation table in sync with reality (it explicitly says to trust the live `install.sh` menu over itself if they drift).
- `io.github.wwmm.easyeffects.Presets.M0Rf30.metainfo.xml` — rebranded to this repo's actual ownership (id, developer, and all three `<url>` fields point at `M0Rf30/easyeffects-presets`). `LICENSE`'s copyright line still names a third party (Matteo Iervasi, the 2018 original author of the preset collection this repo descended from) — historical attribution, not a bug, but don't assume it names the current maintainer.

## Runtime/Tooling Preferences

- **`install.sh`**: bash (`#!/usr/bin/env bash`), requires `curl` on the end-user's machine.
- **`scripts/generate-synthetic-crossfeed.js`**: explicitly Node.js (`#!/usr/bin/env node`), zero third-party dependencies (only `fs`/`path`). No Bun requirement, but also no repo convention favoring Node specifically for anything else — there simply is no other script.
- **`scripts/validate-presets.sh`**: prefers `python3` (stdlib `json` module) for JSON parsing/kernel-name extraction, falls back to `jq` if `python3` is absent, exits 2 (hard environment failure) if neither is installed.
- No package manager, no lockfile, no declared Node/Python version anywhere in the repo — don't add a `package.json` unless you're introducing an actual dependency.

## Testing & QA

`scripts/validate-presets.sh` is the **entire** test suite (no unit tests, no linter, no pre-commit hooks exist anywhere in this repo):
- Validates every root-level `*.json` is parseable.
- Resolves every `kernel-name` found anywhere in the JSON tree against `irs/<name>.irs` or `irs/<name>.sofa` — missing match is a **FAIL**.
- Reports any `irs/`/`.sofa` file not referenced by a preset as a **WARNING** only (never fatal). The repo currently ships zero orphaned kernels — every IR is wired to a preset — so a clean run has no warnings; a new warning means you added a kernel without a preset (or removed the preset that used it).
- Exit codes: `2` = environment/setup failure (no JSON tool, no preset files found); `1` = one or more FAILs; `0` = success (warnings alone never fail the run).

CI (`.github/workflows/validate-presets.yml`) triggers on push/PR to **all branches**, no path filters, and just runs `bash scripts/validate-presets.sh` on `ubuntu-latest` — run the same command locally before opening a PR; it's byte-for-byte what CI checks.
