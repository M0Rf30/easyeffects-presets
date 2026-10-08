# EasyEffects Presets

A collection of audio presets for [EasyEffects](https://github.com/wwmm/easyeffects) (PipeWire).

> Looking for PulseEffects presets? Switch to the `pulseffects` branch and install manually.

## Presets

### Dynamics
Vendored from [droidwayin/GentleDynamics](https://github.com/droidwayin/GentleDynamics) (GPLv3 upstream; carried here as data, with attribution).
- **GentleDynamics** — 8-band Bark-scale multiband compressor for transparent dynamic-range restoration.
- **GentleDynamics Feather Loudness** — same chain plus a compressor for a gentle loudness lift.
- **GentleDynamics Dialogue Clarity Engine** — compressors + de-esser + expander to keep film/TV dialogue intelligible.

### Immersive
- **Aurora Immersive** — hand-tuned pure-DSP chain (EQ → bass enhancer → multiband → exciter → stereo widening → subtle reverb → crossfeed → limiter) for immersive headphone listening. It's a voiced preset, not a reference one — start ~6 dB below your usual volume.

### Laptop speakers
- **Cupertino Laptop Speakers** — an original, from-scratch pure-DSP loudness + clarity chain (high-pass driver protection → EQ boxiness-cut & presence/air lift → psychoacoustic bass enhancer → 8-band multiband compressor → high-frequency exciter → stereo widening → brickwall limiter) hand-tuned to make built-in laptop speakers sound big, loud and refined, inspired by the tuning philosophy of MacBook speakers. Not derived from any measurement dataset — it's a heuristic engineering voicing. Aggressive and speaker-specific (not for headphones); start a few dB below your usual volume.

### Utility & Effects
Original pure-DSP presets built entirely from EasyEffects' built-in plugins (no IR assets); parameters follow the EasyEffects 8.2.7 plugin schema. Each is a heuristic engineering voicing, not derived from a measurement dataset, and each deliberately exercises plugins the rest of the collection doesn't use.
- **Night Listening** — `loudness` (ISO 226-2023 equal-loudness contour) → multiband compressor → limiter, so bass and treble stay perceptually balanced at low late-night volume. Set the Loudness *volume* control to your actual listening level.
- **Levelizer (EBU R128)** — `autogain` normalizes any source toward a −16 LUFS integrated target (plus a safety limiter), taming wildly inconsistent track-to-track / video loudness.
- **Mono Sum (Accessibility)** — collapses stereo to mono via Stereo Tools (stereo-base −1), so single-sided-deaf or one-earbud listeners never lose center-panned content.
- **Tiny Speaker Rescue** — high-pass driver protection → psychoacoustic bass enhancer (implies a sub-bass the driver can't physically produce) → crystalizer transient clarity → limiter, for phone / laptop / small Bluetooth speakers.
- **Analog Warmth** — high-frequency exciter plus a short, subtle reverb for gentle tonal warmth and air.
- **Concert Hall** — a large-room zita reverb for spacious, ambient music listening. An effect voicing, not a reference curve.
- **Movie Dialogue Boost** — presence-lift EQ (~2.5 kHz) → multiband compression → de-esser to keep film/TV dialogue intelligible over music and effects.
- **Reference Transparency** — `filter` (18 Hz subsonic guard, Butterworth Q) → `loudness` (ISO 226-2023 equal-loudness compensation, defaulted to the −14 dBFS "K-14" home/critical-listening reference) → `limiter` (−1 dB ceiling, 8x oversampled for true-peak safety, 20 ms release, essentially inaudible under normal use). No EQ curve, no exciter/enhancer/compressor/reverb — the philosophy is "the best processing is the one you don't hear": only two additions to a flat pass-through, both backed by measurement standards (Butterworth alignment, ISO 226) rather than taste, plus a safety net that should never audibly engage on well-mastered source material. **Note:** EasyEffects' Loudness `volume` field directly sets the plugin's output level, not just a curve reference.

### Headphone virtualization (Convolver)
- **HeSuVi Virtualization Pack** (41 presets) — true-stereo IRs adapted from [HeSuVi](https://sourceforge.net/projects/hesuvi/)'s per-technology HRTF data, with `+`/`++`/`+++` intensity variants. The HeSuVi DS3D + and Sound Blaster SBX 100 presets were removed as audibly identical to DS3D and SBX. See [Impulse Responses](#impulse-responses) and [Licensing](#licensing). Presets:
  - Atmos: HeSuVi Atmos
  - DTS: HeSuVi DTS Headphone X
  - GSX: HeSuVi GSX, HeSuVi GSX +, HeSuVi GSX ++
  - CMSS-3D: HeSuVi CMSS-3D Entertainment, HeSuVi CMSS-3D Game, HeSuVi CMSS-3D RX+
  - Dolby: HeSuVi Dolby Headphone, HeSuVi Dolby Headphone ++, HeSuVi Dolby Home Theater
  - DS3D: HeSuVi DS3D, HeSuVi DS3D ++, HeSuVi DS3D +++
  - DVS: HeSuVi DVS, HeSuVi DVS +
  - Nahimic / Waves / Flux: HeSuVi Nahimic, HeSuVi Waves, HeSuVi Flux HEar
  - Windows Sonic: HeSuVi Windows Sonic, HeSuVi Windows Sonic +
  - Out Of Your Head: HeSuVi Out Of Your Head, HeSuVi Out Of Your Head 2
  - Sound Blaster: HeSuVi Sound Blaster SBX, HeSuVi Sound Blaster SBX 33, HeSuVi Sound Blaster SBX 67
  - SSC: HeSuVi SSC Dublin, HeSuVi SSC New York, HeSuVi SSC New York +, HeSuVi SSC Sydney, HeSuVi SSC Sydney +, HeSuVi SSC Hù, HeSuVi SSC Hù+
  - OpenAL: HeSuVi OpenAL +, HeSuVi OpenAL ++, HeSuVi OpenAL +++, HeSuVi OpenAL CIAIR, HeSuVi OpenAL CIAIR Wide, HeSuVi OpenAL Default
  - Razer: HeSuVi Razer Surround, HeSuVi Razer Surround Bass Fix
- **EFOtech MLV Pack** (6 presets) — crossfeed IRs from [Joe0Bloggs/EFOtech_MLV](https://github.com/Joe0Bloggs/EFOtech_MLV) (MIT). The number is the effect depth (256–22000); start low. Presets: EFOtech MLV 00256, EFOtech MLV 00512, EFOtech MLV 01024, EFOtech MLV 02048, EFOtech MLV 04096, EFOtech MLV 22000.
- **Synthetic Spherical Crossfeed** — a mathematically modelled true-stereo crossfeed (rigid-sphere head, Woodworth ITD), generated by `scripts/generate-synthetic-crossfeed.js`.
- **Synthetic Binaural Room** — an "advanced" model-based true-stereo kernel generated by `scripts/generate-synthetic-binaural-room.js`. Fully closed-form, nothing ripped from vendor software: geometric per-ear delay/ITD from two virtual speakers at ±30°, a Brown & Duda (1998) angle-dependent structural head-shadow shelf, a pinna reflection bank (spectral notches near 8 kHz for externalization), first-order image-source early reflections from a modelled 4.2×3.6×2.6 m room, and a deterministic (seeded) exponentially-decaying diffuse tail (RT60 ≈ 260 ms, DRR ≈ 8 dB). Adds room/externalization over the drier Synthetic Spherical Crossfeed; measured ITD ≈ 250 µs, tail interaural coherence ≈ 0. Deterministic output (safe to commit/validate).
- **LibreAtmos** — an approximation of an object-audio mobile headphone chain (Music profile): EQ + bass enhancer + a short convolver coloration stage + limiter. The EQ/dynamics curve is hand-tuned from the chain's publicly documented behavior; provenance of the convolver kernel itself is unverified — it is currently a short 2-channel stereo IR (not the 4-channel true-stereo crossfeed format used by the other Convolver presets in this pack), so no HRTF/crossfeed spatialization is actually applied yet.
- **MIT KEMAR HRTF (SOFA)** — the [MIT KEMAR](http://sound.media.mit.edu/resources/KEMAR.html) measured HRTF (Gardner & Martin, 1995), loaded as `.sofa` with no conversion.
- **ARI HRTF (SOFA)** — a measured DTF HRTF of subject NH2 from the [Acoustics Research Institute](https://sofacoustics.org/data/database/ari/dtf_nh2.sofa) (CC BY-SA 3.0); a flatter alternative to MIT KEMAR.
- **IRCAM LISTEN HRTF (Subject 1002)** — the [IRCAM LISTEN](http://recherche.ircam.fr/equipes/salles/listen/) measured HRTF (subject IRC_1002; see [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md) for terms), delivered as a 4-channel true-stereo `.irs` derived from HeSuVi's `irc02` kernel (front L/R pair, head-symmetric). Unlike the SOFA presets it convolves a fixed frontal image (no live azimuth/elevation), but it loads directly without libmysofa.
- **Synthesized renderers** — the families below are convolver → limiter chains whose kernels were synthesized here by system identification: a headphone virtualization engine was driven with test signals at 48 kHz and a linear 4-channel true-stereo (or 2-channel) kernel was fitted to its output. They are linear snapshots of adaptive or level-dependent processing, so they match the original only near the measured operating point. The names describe what each family sets out to reproduce; the measured responses and their redistribution terms are discussed in [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md). No head tracking.
  - **FLORA** (Free/Libre Object Reality Audio) — an object-based spatial audio upmix: Cinema room (spacious, reverberant) and Music room (tighter, more natural). Presets: FLORA Cinema, FLORA Music.
  - **ORCHARD** — a "spatialize stereo" headphone engine. The default presets include its virtual room; the `Dry` variants are binaural only. General is music/everyday, Game is positional, Movie has a wider stage. The `Upmix` variants follow the route that first upmixes stereo to surround; that upmix adapts to content, so they are a snapshot for typical music. Presets: ORCHARD General, ORCHARD General Dry, ORCHARD Game, ORCHARD Game Dry, ORCHARD Movie, ORCHARD Movie Dry, ORCHARD General Upmix, ORCHARD Movie Upmix.
  - **AQUILA** (Latin for eagle) — a headphone virtualizer with named modes: balanced Default, two game tunings for positional cues, a wide Movie and a subtler Music mode. Presets: AQUILA Default, AQUILA Game 1, AQUILA Game 2, AQUILA Movie, AQUILA Music.
  - **DELTA** (after the Dirac delta) — DELTA HD Earbud is a generic earbud correction (tonal and timing correction, not a virtualizer); DELTA Surround is a movie-mode virtualizer with bass boost off; DELTA Crossfeed is a headset crossfeed, built from extracted data and not checked against the running engine. Presets: DELTA HD Earbud, DELTA Surround, DELTA Crossfeed.
  - **LibreAtmos profiles** — object-audio headphone profiles, measured directly (unlike the hand-tuned LibreAtmos chain above). Each comes alone and as `+ Spatial`, chained with a spatial-sound filter as on the original chain. Presets: LibreAtmos Dynamic, LibreAtmos Dynamic + Spatial, LibreAtmos Game, LibreAtmos Game + Spatial, LibreAtmos Default, LibreAtmos Default + Spatial, LibreAtmos On The Go, LibreAtmos On The Go + Spatial, LibreAtmos Movie, LibreAtmos Movie + Spatial, LibreAtmos Music, LibreAtmos Music + Spatial.
  - **LibreSpatial** — a spatial-sound headphone filter on its own: tonal shaping, no crossfeed.
  - **LibreHolo** — a holographic spatial-audio engine. LibreHolo Movie Quiet is Movie measured at ≤ −30 dBFS, where its level-dependent behaviour changes. Presets: LibreHolo Movie, LibreHolo Movie Quiet, LibreHolo Music.
  - **LibreDecibel** — a spatializer that places stereo as front speakers in a virtual room.
  - **RICE Spatial** — spatial audio for headphones, stereo input.

The SOFA presets convolve the whole mix as one virtual source — change azimuth/elevation live in the Convolver's SOFA controls.

### Microphone (input)
Installed to `<easyeffects data>/input/` (menu entry 22). Both start with an 80 Hz high-pass and RNNoise and end with a −1 dB limiter.
- **Voice Noise Suppression** — filter (HPF 80 Hz) → rnnoise → gate (−12 dB threshold, 250 ms release) → limiter (−1 dB).
- **Voice Broadcast** — filter (HPF 80 Hz) → rnnoise → de-esser (3:1) → compressor (3:1, −20 dB threshold, +3 dB makeup) → equalizer (−1.5 dB @ 250 Hz, +2 dB @ 3.5 kHz, +1 dB shelf @ 10 kHz) → limiter (−1 dB). Heuristic voicing, not derived from measurements.

## Impulse Responses

`irs/` holds the convolution kernels (RIFF/WAVE `.irs` and AES69 `.sofa`) used by the Convolver-based presets — every kernel here is referenced by a preset. EasyEffects' Convolver only loads mono, 2-channel, or 4-channel "true stereo" (`L, LR, RL, R`) kernels, so raw multi-channel HeSuVi/HRIR files have to be adapted first — that's how the HeSuVi and EFOtech kernels here were built. Inventory:

- **HeSuVi** (41 `.irs`) — HeSuVi-derived true-stereo IRs.
- **EFOtech MLV** (6 `.irs`) — EFOtech-derived true-stereo crossfeed IRs.
- **Synthesized renderers** (36 `.irs`) — FLORA (2), ORCHARD (8), AQUILA (5), DELTA (3), LibreAtmos profiles (12), LibreSpatial, LibreHolo (3), LibreDecibel, RICE Spatial; see THIRD-PARTY-NOTICES.md.
- **IRCAM LISTEN** (1 `.irs`) — Subject 1002, derived from HeSuVi's `irc02`.
- **Synthetic Spherical-Head Crossfeed** and **Synthetic Binaural Room** (2 `.irs`) — generated by `scripts/generate-synthetic-crossfeed.js` and `scripts/generate-synthetic-binaural-room.js`.
- **LibreAtmos** (1 `.irs`) — short 2-channel coloration IR, unverified provenance.
- **MIT KEMAR** and **ARI NH2** (2 `.sofa`) — measured HRTFs, loaded without conversion.

Kernels are trimmed of leading/trailing silence to cut Convolver CPU and latency (leading silence was trimmed from the SSC Sydney/Hù/New York, DVS and Nahimic kernels; FLORA tails were trimmed). The LibreAtmos right channel is delayed 49 samples to align with the left.

**Level matching.** Every Convolver preset's output gain is set so the mono-input gain averaged over 200 Hz–4 kHz is about 0 dB, accounting for EasyEffects' convolver autogain (it peak-normalises the kernel, then scales by min(1, 1/sqrt(max channel energy))). Their limiters sit at −1 dB. Switching between convolver presets should not change perceived level much.

More community IRs to experiment with: [icy-comet/EasyEffects-presets-impulses](https://github.com/icy-comet/EasyEffects-presets-impulses).

## Installation

```shell
bash -c "$(curl -fsSL https://raw.githubusercontent.com/M0Rf30/easyeffects-presets/main/install.sh)"
```

Press Enter for the default. The on-screen menu (`install.sh --help`) is authoritative if this table drifts:

| # | Group | Installs |
|---|---|---|
| 1 (default) | `all` | Everything (all output presets, input presets and IR/SOFA files) |
| 2 | `hesuvi` | HeSuVi virtualization pack (41 presets) |
| 3 | `crossfeed` | Synthetic Spherical Crossfeed |
| 4 | `efotech` | EFOtech MLV pack (6 presets) |
| 5 | `kemar` | MIT KEMAR HRTF (SOFA) |
| 6 | `ari` | ARI HRTF (SOFA) |
| 7 | `gentledynamics` | GentleDynamics pack (3 presets) |
| 8 | `aurora` | Aurora Immersive |
| 9 | `cupertino` | Cupertino Laptop Speakers |
| 10 | `ircam` | IRCAM LISTEN HRTF (Subject 1002) |
| 11 | `utility` | Utility & Effects pack (8 presets) |
| 12 | `binaural` | Synthetic Binaural Room |
| 13 | `libreatmos` | LibreAtmos + 12 profile presets (13 presets) |
| 14 | `flora` | FLORA pack (2 presets) |
| 15 | `orchard` | ORCHARD pack (8 presets) |
| 16 | `aquila` | AQUILA pack (5 presets) |
| 17 | `delta` | DELTA pack (3 presets) |
| 18 | `libreholo` | LibreHolo pack (3 presets) |
| 19 | `librespatial` | LibreSpatial |
| 20 | `libredecibel` | LibreDecibel |
| 21 | `rice` | RICE Spatial |
| 22 | `input` | Microphone (input) presets (2 presets) |
| 23 | `uninstall` | Remove everything listed in the installer manifest |

`curl` is required (`sudo apt install curl` on Ubuntu).

### Non-interactive use

The choice can be given as an argument (menu number, group name, `all` or `uninstall`). Without an argument and without a TTY on stdin the installer prints its usage and exits 2.

```shell
./install.sh all                  # everything
./install.sh 3                    # menu entry 3
./install.sh --ref v1.1.3 hesuvi  # pin a tag or branch
./install.sh --yes uninstall      # no confirmation prompt
```

Options: `--ref <tag|branch>` (or `EASYEFFECTS_PRESETS_REF`; default `main`), `EASYEFFECTS_PRESETS_BASE_URL` (overrides the whole download URL), `--flatpak` (use the Flatpak data directory even if a native install exists), `-y`/`--yes` (skip the uninstall confirmation), `-h`/`--help`. Files are written atomically; failed downloads are listed and make the script exit non-zero. Uninstall removes only files named in the manifest.

## Manual installation

Copy the root `.json` files into your EasyEffects `output/` directory and `input/*.json` into `input/` — `~/.local/share/easyeffects` (native) or `~/.var/app/com.github.wwmm.easyeffects/data/easyeffects` (Flatpak). For Convolver presets, also copy the referenced `.irs`/`.sofa` (see each preset's `kernel-name`) into the sibling `irs/` directory.

## Licensing

The repository's own files (original presets, scripts and synthetic kernels) are MIT, see `LICENSE`. Bundled third-party assets are **not** all MIT: the GentleDynamics presets are GPLv3 upstream, the ARI SOFA file is CC BY-SA 3.0, IRCAM LISTEN and MIT KEMAR carry their own terms, and the license of the HeSuVi-derived kernels, of the LibreAtmos kernel and of the synthesized-renderer kernels could not be verified. Sources, licenses and required attribution per asset group are in [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md).

## Contributing

Run `./scripts/validate-presets.sh` (needs `python3`) before opening a PR. It checks canonical JSON serialization, plugin keys/values against the vendored EasyEffects schema, kernel references and headers, that every preset and kernel is listed in the `install.sh` manifest, and that every preset name appears in this README. CI (push to `main` and pull requests) also runs ShellCheck, `node --check` and a generator determinism check. See `AGENTS.md` for the full workflow.
