#!/usr/bin/env node
// Generates "irs/Synthetic Binaural Room (Structural HRTF, 48kHz).irs", a true-stereo
// (4-channel) EasyEffects Convolver kernel derived entirely from closed-form acoustics and a
// deterministic (seeded) reverberation model -- nothing is ripped from any vendor software.
//
// This is the "advanced" sibling of generate-synthetic-crossfeed.js. Where the crossfeed kernel
// models only ITD + a single head-shadow shelf (a dry, in-head-ish crossfeed), this kernel adds
// the three ingredients that actually externalize a stereo image on headphones:
//
//   Stage 1 - Directional structural HRIR (per source, per ear):
//       * Per-ear propagation delay + 1/r spreading, taken from real 3-D geometry (head radius a,
//         two virtual speakers at +/-SOURCE_AZIMUTH_DEG, SOURCE_DISTANCE_M away, at ear height).
//         The interaural time difference falls out of the geometry (~0.25 ms at 30 deg).
//       * Brown & Duda (1998) structural head-shadow: a first-order shelving filter whose HF gain
//         alpha(theta) depends on the angle of incidence to that ear -- bright on the near ear,
//         low-passed on the far ear. Bilinear-transformed from H(s)=(1+alpha*s/(2w0))/(1+s/(2w0)),
//         w0 = c/a.  This gives frequency-dependent ILD, not a flat level trim.
//   Stage 2 - Pinna reflection bank (Brown & Duda structural-model style):
//       * A short FIR of a few delayed, alternating-sign reflections. Their delays place the first
//         spectral notch near ~8 kHz (the classic pinna-notch region) and scale with source
//         elevation. This is the dominant monaural cue for front localization / out-of-head imaging.
//   Stage 3 - Modeled small room:
//       * First-order image sources for all 6 surfaces (image-source method) rendered through the
//         same directional HRIR -> early reflections that vary per ear (the biggest externalization
//         cue after the pinna).
//       * A deterministic exponentially-decaying diffuse tail per ear (independent seeded noise ->
//         interaural coherence < 1 -> spaciousness), target reverb time RT60 and a controlled
//         direct-to-reverberant ratio so the room stays clear rather than washed out.
//
// Every parameter below is a documented physical constant or a stated design assumption; see
// README.md's "Synthetic Binaural Room" and "Impulse Responses" sections.
//
// Run: node scripts/generate-synthetic-binaural-room.js
// Output is written straight into irs/, overwriting the existing file. Deterministic: same bytes
// every run (seeded PRNG), so it is safe to commit and validate.

const fs = require('fs');
const path = require('path');

const REPO_ROOT = path.resolve(__dirname, '..');

// ---- Global format ---------------------------------------------------------------------------
const SAMPLE_RATE = 48000;
const NUM_CHANNELS = 4;          // EasyEffects true-stereo: LL, LR, RL, RR
const BITS_PER_SAMPLE = 32;      // IEEE float

// ---- Head / geometry -------------------------------------------------------------------------
const HEAD_RADIUS_M = 0.0875;    // average adult head radius (Woodworth & Schlosberg, 1954)
const SPEED_OF_SOUND = 343;      // m/s at ~20 C
const SOURCE_AZIMUTH_DEG = 30;   // standard stereo speaker placement (+/- 30 deg from front)
const SOURCE_ELEVATION_DEG = 0;  // virtual speakers at ear height; pinna model still colors
const SOURCE_DISTANCE_M = 1.8;   // listening-triangle radius (typical near-field monitor distance)

// ---- Room (image-source model) ---------------------------------------------------------------
// Small, fairly dry listening room. Listener centred L/R, a little forward of centre, seated.
const ROOM_X_M = 4.2;            // width  (left <-> right)
const ROOM_Y_M = 3.6;            // depth  (front <-> back)
const ROOM_Z_M = 2.6;            // height
const HEAD_X_M = ROOM_X_M / 2;   // centred left/right
const HEAD_Y_M = 1.3;            // seated toward the front third of the room
const HEAD_Z_M = 1.2;            // seated ear height
// Per-surface pressure reflection coefficients (0..1). Carpeted floor is the most absorptive.
const REFL_WALL = 0.62;          // side + front + back walls
const REFL_FLOOR = 0.42;         // carpet
const REFL_CEIL = 0.70;          // painted ceiling

// ---- Head-shadow shelf (Brown & Duda 1998) ---------------------------------------------------
const ALPHA_MIN = 0.1;           // HF gain floor of the fully-shadowed ear
const THETA_MIN_DEG = 150;       // incidence angle of maximum shadowing
const SHADOW_IR_LEN = 96;        // taps to render the (fast-decaying) shelf impulse response

// ---- Pinna reflection bank -------------------------------------------------------------------
// Delays in samples @ 48 kHz. First reflection ~3 samples -> first notch near 8 kHz. Alternating
// signs spread further notches across 8-16 kHz. Gains kept modest: color, don't gut, the signal.
const PINNA_DELAYS = [3, 6, 9, 13];
const PINNA_GAINS = [-0.35, 0.22, -0.16, 0.11];
const PINNA_ELEV_SENS = 0.004;   // per-degree fractional delay stretch with elevation

// ---- Diffuse reverberation tail --------------------------------------------------------------
const RT60_S = 0.26;             // reverberation time of the modeled room
const TAIL_START_MS = 6;         // diffuse tail onset (overlaps the discrete early reflections)
const DRR_DB = 8.0;              // direct-to-reverberant ratio (higher = drier/clearer)
const TAIL_LP_ALPHA = 0.45;      // one-pole LP on the tail noise (models HF air/wall absorption)
const RNG_SEED = 0x9e3779b9;     // fixed seed -> byte-identical output every run

// ---- Trim ------------------------------------------------------------------------------------
const TRIM_THRESHOLD_DB = -80;
const TRIM_PAD_FRAMES = 16;
const TRIM_FADE_FRAMES = 32;

// ==============================================================================================

// Deterministic PRNG (mulberry32) so the reverb tail is reproducible across runs/machines.
function mulberry32(seed) {
  let a = seed >>> 0;
  return function () {
    a |= 0; a = (a + 0x6d2b79f5) | 0;
    let t = Math.imul(a ^ (a >>> 15), 1 | a);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

function deg2rad(d) { return (d * Math.PI) / 180; }

// Brown & Duda angle-dependent HF gain: 2.0 (near, source at the ear) down to ALPHA_MIN (shadowed).
function shadowAlpha(incidenceDeg) {
  const t = Math.min(180, Math.max(0, incidenceDeg));
  return (1 + ALPHA_MIN / 2) + (1 - ALPHA_MIN / 2) * Math.cos((t / THETA_MIN_DEG) * Math.PI);
}

// Impulse response of the first-order head-shadow shelf for a given alpha.
// Continuous prototype H(s) = (1 + alpha*s/(2 w0)) / (1 + s/(2 w0)), w0 = c/a; bilinear transform.
function shadowImpulseResponse(alpha, len) {
  const w0 = SPEED_OF_SOUND / HEAD_RADIUS_M;
  const k = SAMPLE_RATE / w0;            // = 2*fs*tau, tau = 1/(2 w0)
  const b0 = (1 + alpha * k) / (1 + k);
  const b1 = (1 - alpha * k) / (1 + k);
  const a1 = (1 - k) / (1 + k);
  const h = new Float64Array(len);
  let xPrev = 0, yPrev = 0;
  for (let n = 0; n < len; n++) {
    const x = n === 0 ? 1 : 0;
    const y = b0 * x + b1 * xPrev - a1 * yPrev;
    h[n] = y;
    xPrev = x; yPrev = y;
  }
  return h;
}

// Pinna reflection FIR (elevation-dependent delays). p[0] = 1 (the direct pinna path).
function pinnaFir(elevationDeg) {
  const stretch = 1 + PINNA_ELEV_SENS * elevationDeg;
  let maxDelay = 0;
  const taps = PINNA_DELAYS.map((d) => Math.max(1, Math.round(d * stretch)));
  for (const d of taps) if (d > maxDelay) maxDelay = d;
  const fir = new Float64Array(maxDelay + 1);
  fir[0] = 1;
  for (let i = 0; i < taps.length; i++) fir[taps[i]] += PINNA_GAINS[i];
  return fir;
}

function convolve(a, b) {
  const out = new Float64Array(a.length + b.length - 1);
  for (let i = 0; i < a.length; i++) {
    const av = a[i];
    if (av === 0) continue;
    for (let j = 0; j < b.length; j++) out[i + j] += av * b[j];
  }
  return out;
}

// Add gain * srcIR into dst starting at integer sample offset.
function addAt(dst, srcIR, offset, gain) {
  for (let i = 0; i < srcIR.length; i++) {
    const idx = offset + i;
    if (idx >= 0 && idx < dst.length) dst[idx] += gain * srcIR[i];
  }
}

// One arrival: a point sound source at 3-D position `src`, heard at ear position `ear` whose
// outward normal points along `earNormalX` (+1 right ear, -1 left ear). Renders the directional
// HRIR (shadow shelf x pinna) and places it into `chan` at the geometric delay, scaled by 1/r,
// path gain, and reflection gain. Returns the ear's arrival distance (for tail alignment).
function renderArrival(chan, src, ear, earNormalX, pinna, extraGain, refDelaySamples) {
  const dx = src.x - ear.x, dy = src.y - ear.y, dz = src.z - ear.z;
  const dist = Math.sqrt(dx * dx + dy * dy + dz * dz);
  const delaySamples = Math.round((dist / SPEED_OF_SOUND) * SAMPLE_RATE) - refDelaySamples;

  // Horizontal angle of incidence relative to the ear's outward normal (for the shadow shelf).
  const srcAzFromHead = Math.atan2(src.x - HEAD_X_M, src.y - HEAD_Y_M); // 0 = front, +x = right
  const earAz = earNormalX > 0 ? Math.PI / 2 : -Math.PI / 2;
  let incidence = Math.abs(srcAzFromHead - earAz) * (180 / Math.PI);
  if (incidence > 180) incidence = 360 - incidence;

  const shadow = shadowImpulseResponse(shadowAlpha(incidence), SHADOW_IR_LEN);
  const hrir = convolve(shadow, pinna);
  const gain = (extraGain / Math.max(dist, 0.05)); // 1/r spreading * reflection coefficient
  addAt(chan, hrir, delaySamples, gain);
}

// Reflect a point across each of the 6 room planes -> first-order image sources, each carrying
// the product of that surface's reflection coefficient.
function firstOrderImages(src) {
  return [
    { x: -src.x, y: src.y, z: src.z, g: REFL_WALL },                 // left wall  (x = 0)
    { x: 2 * ROOM_X_M - src.x, y: src.y, z: src.z, g: REFL_WALL },   // right wall (x = X)
    { x: src.x, y: -src.y, z: src.z, g: REFL_WALL },                 // front wall (y = 0)
    { x: src.x, y: 2 * ROOM_Y_M - src.y, z: src.z, g: REFL_WALL },   // back wall  (y = Y)
    { x: src.x, y: src.y, z: -src.z, g: REFL_FLOOR },                // floor      (z = 0)
    { x: src.x, y: src.y, z: 2 * ROOM_Z_M - src.z, g: REFL_CEIL },   // ceiling    (z = Z)
  ];
}

function energy(a, from = 0, to = a.length) {
  let s = 0; for (let i = from; i < to; i++) s += a[i] * a[i]; return s;
}

function main() {
  // Virtual speaker positions (front is +y, right is +x, ear height z).
  const az = deg2rad(SOURCE_AZIMUTH_DEG);
  const el = deg2rad(SOURCE_ELEVATION_DEG);
  const rHoriz = SOURCE_DISTANCE_M * Math.cos(el);
  const dz = SOURCE_DISTANCE_M * Math.sin(el);
  const leftSpk = { x: HEAD_X_M - rHoriz * Math.sin(az), y: HEAD_Y_M + rHoriz * Math.cos(az), z: HEAD_Z_M + dz };
  const rightSpk = { x: HEAD_X_M + rHoriz * Math.sin(az), y: HEAD_Y_M + rHoriz * Math.cos(az), z: HEAD_Z_M + dz };

  // Ear positions.
  const leftEar = { x: HEAD_X_M - HEAD_RADIUS_M, y: HEAD_Y_M, z: HEAD_Z_M };
  const rightEar = { x: HEAD_X_M + HEAD_RADIUS_M, y: HEAD_Y_M, z: HEAD_Z_M };

  const pinna = pinnaFir(SOURCE_ELEVATION_DEG);

  // Reference delay: align on the earliest (ipsilateral direct) arrival so the kernel starts near t=0.
  const dref = (() => {
    const dx = leftSpk.x - leftEar.x, dy = leftSpk.y - leftEar.y, dz2 = leftSpk.z - leftEar.z;
    return Math.round((Math.sqrt(dx * dx + dy * dy + dz2 * dz2) / SPEED_OF_SOUND) * SAMPLE_RATE);
  })();

  // Total length: tail onset + RT60 decay to about -80 dB, plus HRIR/room headroom.
  const tailStart = Math.round((TAIL_START_MS / 1000) * SAMPLE_RATE);
  const tailLen = Math.round((RT60_S * (80 / 60)) * SAMPLE_RATE);
  const totalLen = tailStart + tailLen + 512;

  // channels: 0=LL (Lspk->Lear), 1=LR (Lspk->Rear), 2=RL (Rspk->Lear), 3=RR (Rspk->Rear)
  const chans = [
    new Float64Array(totalLen),
    new Float64Array(totalLen),
    new Float64Array(totalLen),
    new Float64Array(totalLen),
  ];

  // ---- Stages 1+3a: direct + first-order early reflections, per source/ear ------------------
  const paths = [
    { spk: leftSpk, ear: leftEar, en: -1, ch: 0 },
    { spk: leftSpk, ear: rightEar, en: +1, ch: 1 },
    { spk: rightSpk, ear: leftEar, en: -1, ch: 2 },
    { spk: rightSpk, ear: rightEar, en: +1, ch: 3 },
  ];
  for (const p of paths) {
    renderArrival(chans[p.ch], p.spk, p.ear, p.en, pinna, 1.0, dref);        // direct
    for (const img of firstOrderImages(p.spk)) {                              // early reflections
      renderArrival(chans[p.ch], img, p.ear, p.en, pinna, img.g, dref);
    }
  }

  // Direct-path energy (for setting the reverb level via DRR). Use the ipsilateral channel.
  const directEnergyPerCh = energy(chans[0], 0, tailStart);

  // ---- Stage 3b: deterministic diffuse tail (independent noise per channel) -----------------
  const rng = mulberry32(RNG_SEED);
  const decayPerSample = Math.pow(10, -3 / (RT60_S * SAMPLE_RATE)); // -60 dB over RT60 seconds
  const targetTailEnergy = directEnergyPerCh * Math.pow(10, -DRR_DB / 10);
  for (let ch = 0; ch < NUM_CHANNELS; ch++) {
    const tail = new Float64Array(totalLen);
    let env = 1.0;
    let lp = 0;
    for (let n = tailStart; n < totalLen; n++) {
      const white = rng() * 2 - 1;
      lp = TAIL_LP_ALPHA * white + (1 - TAIL_LP_ALPHA) * lp;   // HF-damped diffuse noise
      // Smooth onset over the first ~4 ms so the tail fades in under the early reflections.
      const onset = Math.min(1, (n - tailStart) / (0.004 * SAMPLE_RATE));
      tail[n] = lp * env * onset;
      env *= decayPerSample;
    }
    // Scale this channel's tail to hit the DRR target, then fold into the channel.
    const e = energy(tail);
    const g = e > 0 ? Math.sqrt(targetTailEnergy / e) : 0;
    for (let n = 0; n < totalLen; n++) chans[ch][n] += g * tail[n];
  }

  // ---- Normalize (single global scalar preserves all ILD/ITD relationships) ------------------
  let peak = 0;
  for (const c of chans) for (let n = 0; n < totalLen; n++) { const v = Math.abs(c[n]); if (v > peak) peak = v; }
  const norm = peak > 0 ? 0.9 / peak : 1;
  for (const c of chans) for (let n = 0; n < totalLen; n++) c[n] *= norm;

  // ---- Interleave -> float32 PCM, trim trailing silence, wrap in WAV -------------------------
  const fmt = { audioFormat: 3, numChannels: NUM_CHANNELS, sampleRate: SAMPLE_RATE, bitsPerSample: BITS_PER_SAMPLE };
  const bytesPerFrame = (NUM_CHANNELS * BITS_PER_SAMPLE) / 8;
  const pcm = Buffer.alloc(totalLen * bytesPerFrame);
  for (let n = 0; n < totalLen; n++) {
    const o = n * bytesPerFrame;
    pcm.writeFloatLE(chans[0][n], o + 0);
    pcm.writeFloatLE(chans[1][n], o + 4);
    pcm.writeFloatLE(chans[2][n], o + 8);
    pcm.writeFloatLE(chans[3][n], o + 12);
  }
  const trimmed = trimTrailingSilence(pcm, fmt, TRIM_THRESHOLD_DB, TRIM_PAD_FRAMES, TRIM_FADE_FRAMES);
  const wav = buildWav(trimmed, fmt);

  const outPath = path.join(REPO_ROOT, 'irs', 'Synthetic Binaural Room (Structural HRTF, 48kHz).irs');
  fs.writeFileSync(outPath, wav);

  const frames = trimmed.length / bytesPerFrame;
  console.log(`Room ${ROOM_X_M}x${ROOM_Y_M}x${ROOM_Z_M} m, speakers +/-${SOURCE_AZIMUTH_DEG} deg @ ${SOURCE_DISTANCE_M} m`);
  console.log(`RT60 ${RT60_S * 1000} ms, DRR ${DRR_DB} dB, tail onset ${TAIL_START_MS} ms`);
  console.log(`Wrote ${outPath}`);
  console.log(`  ${wav.length} bytes, ${frames} frames (${(frames / SAMPLE_RATE * 1000).toFixed(0)} ms)`);
}

function buildWav(pcmData, fmt) {
  const fmtChunkSize = 18;
  const factChunkSize = 4;
  const headerSize = 4 + (8 + fmtChunkSize) + (8 + factChunkSize) + 8;
  const totalSize = headerSize + pcmData.length;
  const buf = Buffer.alloc(8 + totalSize);
  let o = 0;
  const byteRate = (fmt.sampleRate * fmt.numChannels * fmt.bitsPerSample) / 8;
  const blockAlign = (fmt.numChannels * fmt.bitsPerSample) / 8;
  buf.write('RIFF', o); o += 4;
  buf.writeUInt32LE(totalSize, o); o += 4;
  buf.write('WAVE', o); o += 4;
  buf.write('fmt ', o); o += 4;
  buf.writeUInt32LE(fmtChunkSize, o); o += 4;
  buf.writeUInt16LE(fmt.audioFormat, o); o += 2; // 3 = IEEE float
  buf.writeUInt16LE(fmt.numChannels, o); o += 2;
  buf.writeUInt32LE(fmt.sampleRate, o); o += 4;
  buf.writeUInt32LE(byteRate, o); o += 4;
  buf.writeUInt16LE(blockAlign, o); o += 2;
  buf.writeUInt16LE(fmt.bitsPerSample, o); o += 2;
  buf.writeUInt16LE(0, o); o += 2;
  buf.write('fact', o); o += 4;
  buf.writeUInt32LE(factChunkSize, o); o += 4;
  buf.writeUInt32LE(pcmData.length / blockAlign, o); o += 4;
  buf.write('data', o); o += 4;
  buf.writeUInt32LE(pcmData.length, o); o += 4;
  pcmData.copy(buf, o);
  return buf;
}

function trimTrailingSilence(pcm, fmt, thresholdDb, padFrames, fadeFrames) {
  const bytesPerFrame = (fmt.numChannels * fmt.bitsPerSample) / 8;
  const totalFrames = pcm.length / bytesPerFrame;
  let peak = 0;
  const envelope = new Float64Array(totalFrames);
  for (let i = 0; i < totalFrames; i++) {
    let m = 0;
    for (let c = 0; c < fmt.numChannels; c++) {
      const v = Math.abs(pcm.readFloatLE(i * bytesPerFrame + c * 4));
      if (v > m) m = v;
    }
    envelope[i] = m;
    if (m > peak) peak = m;
  }
  const threshold = peak * 10 ** (thresholdDb / 20);
  let last = totalFrames - 1;
  while (last >= 0 && envelope[last] < threshold) last--;
  const end = Math.min(totalFrames - 1, last + padFrames);
  const newFrames = end + 1;

  const out = Buffer.alloc(newFrames * bytesPerFrame);
  pcm.copy(out, 0, 0, newFrames * bytesPerFrame);

  const actualFade = Math.min(fadeFrames, newFrames);
  for (let i = 0; i < actualFade; i++) {
    const gain = i / actualFade;
    const idx = newFrames - actualFade + i;
    for (let c = 0; c < fmt.numChannels; c++) {
      const o = idx * bytesPerFrame + c * 4;
      out.writeFloatLE(out.readFloatLE(o) * gain, o);
    }
  }
  for (let c = 0; c < fmt.numChannels; c++) {
    out.writeFloatLE(0, (newFrames - 1) * bytesPerFrame + c * 4);
  }
  return out;
}

main();
