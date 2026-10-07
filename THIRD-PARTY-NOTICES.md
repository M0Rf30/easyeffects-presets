# Third-Party Notices

The repository's own files (original presets, scripts, the synthetic and FLORA kernels) are under the MIT license in `LICENSE`. The assets below are bundled from other sources and are **not** all MIT. Where a license could not be verified, that is stated rather than assumed. Checked 2026-10-07.

## GentleDynamics presets

- Files: `GentleDynamics.json`, `GentleDynamics Feather Loudness.json`, `GentleDynamics Dialogue Clarity Engine.json`
- Source: https://github.com/droidwayin/GentleDynamics
- License: GNU General Public License v3 (the upstream `LICENSE` file is the GPLv3 text; GitHub reports GPL-3.0). Whether "or later" applies is not stated in the upstream files checked; the metainfo expression therefore uses `GPL-3.0-only`.
- Attribution: credit droidwayin/GentleDynamics; upstream carries no separate copyright line beyond the GPL text.
- Caveats: these files are preset data (configuration), vendored with local edits (schema fixes, instance renumbering). Redistribution of them, modified or not, falls under GPLv3 terms. Whether preset data is a covered work is not settled here; treat them as GPLv3.

## ARI HRTF (Subject NH2, DTF)

- File: `irs/ARI HRTF (Subject NH2, DTF).sofa`
- Source: https://sofacoustics.org/data/database/ari/dtf_nh2.sofa (Acoustics Research Institute, Austrian Academy of Sciences)
- License: Creative Commons Attribution-ShareAlike 3.0 Unported (the file's own `License` attribute says so).
- Attribution required: credit the Acoustics Research Institute (ARI HRTF database, subject NH2) and indicate changes; none were made to this file.
- Caveats: ShareAlike applies to adaptations of the dataset, not to the presets that merely reference it.

## IRCAM LISTEN HRTF (Subject 1002)

- File: `irs/IRCAM LISTEN HRTF (Subject 1002, True Stereo, 48kHz).irs` (4-channel true-stereo kernel derived from the HeSuVi `irc02` kernel, i.e. a second-hand adaptation of IRC_1002)
- Source: http://recherche.ircam.fr/equipes/salles/listen/
- License: not verified from IRCAM's own page (not fetched here). A copy of the LISTEN terms shipped in libmysofa's test data (https://github.com/deepin-community/libmysofa/blob/master/tests/LICENSE.LISTEN_1002_IRC_1002_C_HRIR) reads: "Copyright (c) 2002 IRCAM ... All Rights Reserved. Use of Materials: The Listen database is public and available for any use. We would however appreciate an acknowledgment of the database ...". The earlier README wording was "free for research". These two statements differ; confirm against IRCAM before any commercial redistribution, and treat the restriction as possibly non-commercial until confirmed.
- Attribution: acknowledge the IRCAM LISTEN HRTF database (IRCAM, Room Acoustics Team).
- Caveats: the derivation passes through HeSuVi's repackaging, whose own terms are unclear (see below).

## MIT KEMAR HRTF

- File: `irs/MIT KEMAR HRTF (Normal Pinna).sofa`
- Source: https://sound.media.mit.edu/resources/KEMAR.html (MIT Media Lab Machine Listening Group; Gardner & Martin, 1995)
- License: the original archive README (https://sound.media.mit.edu/resources/KEMAR/README) states: "This data is Copyright 1994 by the MIT Media Laboratory. It is provided free with no restrictions on use, provided the authors are cited when the data is used in any research or commercial application."
- Attribution required: cite Bill Gardner and Keith Martin, MIT Media Lab, "HRTF measurements of a KEMAR dummy-head microphone" (1994/1995).
- Caveats: the SOFA conversion bundled here was not traced to a specific converter or redistribution (the file's own metadata was not inspected for a license); the MIT terms above are for the original data only. Unverified: whether the SOFA conversion adds terms.

## HeSuVi kernels

- Files: all `irs/HeSuVi *.irs` (41 kernels)
- Source: HeSuVi, https://sourceforge.net/projects/hesuvi/ (bundled HRIR set), adapted here to 4-channel true-stereo `.irs`.
- License: unclear. HeSuVi's own license for its bundled HRIR files was not verified. Many of the impulse responses are measured or derived from commercial headphone-virtualization products (Dolby, DTS, Creative, Razer, Waves, Microsoft, Nahimic, SteelSeries, ...), whose rights holders did not license them for redistribution as far as is known. No permission from those parties is documented in this repository.
- Attribution: credit the HeSuVi project and its contributors.
- Caveats: redistribution risk is real and unresolved. Do not assume MIT. Downstream packagers who need clean licensing should exclude the `hesuvi` group (`install.sh` menu entry 2) and the IRCAM kernel.

## EFOtech MLV kernels

- Files: `irs/EFOtech MLV *.irs` (6 kernels)
- Source: https://github.com/Joe0Bloggs/EFOtech_MLV
- License: MIT. Upstream copyright line: `Copyright (c) 2020 Joe0Bloggs, Joseph Siu Fai Yeung, efotech.fi`
- Attribution required: keep the copyright and permission notice (reproduced here):

  > MIT License
  >
  > Copyright (c) 2020 Joe0Bloggs, Joseph Siu Fai Yeung, efotech.fi
  >
  > Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
  >
  > The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
  >
  > THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED. (full disclaimer as in the upstream LICENSE)
- Caveats: kernels here are resampled/adapted true-stereo versions with leading silence trimmed.

## LibreAtmos kernel

- File: `irs/LibreAtmos (Stereo, 48kHz).irs`
- Source: unknown. The README states that the provenance of this kernel is unverified.
- License: unknown.
- Caveats: the EQ/dynamics part of the preset is hand-tuned in this repository; the kernel is the unverified part. Remove it if provenance cannot be established.

## FLORA kernels

- Files: `irs/FLORA Cinema (True Stereo, 48kHz).irs`, `irs/FLORA Music (True Stereo, 48kHz).irs`, and the FLORA presets
- Source: self-authored in this repository; not derived from a published dataset or measurement corpus.
- License: MIT (repository `LICENSE`).

## Synthetic kernels

- Files: `irs/Synthetic Spherical-Head Crossfeed (48kHz).irs`, `irs/Synthetic Binaural Room (Structural HRTF, 48kHz).irs`
- Source: generated by `scripts/generate-synthetic-crossfeed.js` and `scripts/generate-synthetic-binaural-room.js` from closed-form models (the room model cites Woodworth ITD and Brown & Duda, 1998 as published methods, not data).
- License: MIT (repository `LICENSE`).

## Original presets and scripts

Aurora Immersive, Cupertino Laptop Speakers, the Utility & Effects presets, the microphone presets and the scripts are original work, MIT. `LICENSE` names Matteo Iervasi (2018), author of the collection this repository descends from.

## Unverified items

- Redistribution rights for the HeSuVi-derived kernels (and thus the IRCAM `.irs` derived from HeSuVi).
- IRCAM LISTEN current terms from IRCAM itself.
- Origin and license of the LibreAtmos kernel.
- Origin of the bundled MIT KEMAR `.sofa` conversion.
- "GPL-3.0-or-later" vs "GPL-3.0-only" for GentleDynamics.
