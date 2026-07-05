#!/usr/bin/env node
// Generates "irs/Synthetic Spherical-Head Crossfeed (48kHz).irs", a true-stereo (4-channel)
// EasyEffects Convolver kernel derived entirely from closed-form acoustics, not ripped from any
// vendor software. Every parameter below is a documented physical constant or a stated assumption
// (see README.md's "Synthetic Spherical Crossfeed" and "Impulse Responses" sections).
//
// Model:
//   - Rigid sphere head, radius HEAD_RADIUS_M, two virtual stereo speakers at +/-SOURCE_AZIMUTH_DEG.
//   - Interaural time difference: Woodworth & Schlosberg (1938/1954) spherical-head formula
//         ITD = (a/c) * (theta + sin(theta))
//   - Interaural level difference: a single-pole head-shadow low-pass (Brown & Duda style
//     simplified structural HRTF), rendered as a shelf from 0 dB at DC to HF_SHADOW_DB at Nyquist,
//     with cutoff f0 = c / (2*pi*a).
//
// Run: node scripts/generate-synthetic-crossfeed.js
// Output is written straight into irs/, overwriting the existing file.

const fs = require('fs');
const path = require('path');

const REPO_ROOT = path.resolve(__dirname, '..');
const SAMPLE_RATE = 48000;
const HEAD_RADIUS_M = 0.0875;   // average adult head radius (Woodworth & Schlosberg, 1954)
const SPEED_OF_SOUND = 343;     // m/s at ~20C
const SOURCE_AZIMUTH_DEG = 30;  // standard stereo speaker placement (Chu Moy / BS2B-style crossfeed
                                 // designs use the same assumption); also matches the median ITD
                                 // measured empirically across this repo's real HeSuVi-derived kernels
const HF_SHADOW_DB = -6.0;      // high-frequency attenuation applied to the shadowed (far) ear
const IR_LENGTH_SAMPLES = 512;  // pre-trim shadow-filter render length
const TRIM_THRESHOLD_DB = -80;  // trailing-silence trim threshold (see scripts/validate-presets.sh
                                 // note in README about why trimming near-silent tails is safe)
const TRIM_PAD_FRAMES = 16;
const TRIM_FADE_FRAMES = 8;

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

function main() {
  const thetaRad = (SOURCE_AZIMUTH_DEG * Math.PI) / 180;
  const itdSeconds = (HEAD_RADIUS_M / SPEED_OF_SOUND) * (thetaRad + Math.sin(thetaRad));
  const itdSamples = Math.round(itdSeconds * SAMPLE_RATE);

  const f0 = SPEED_OF_SOUND / (2 * Math.PI * HEAD_RADIUS_M);
  const alpha = 1 - Math.exp((-2 * Math.PI * f0) / SAMPLE_RATE);
  const gInf = 10 ** (HF_SHADOW_DB / 20);

  console.log(`ITD: ${(itdSeconds * 1000).toFixed(3)} ms = ${itdSamples} samples @ ${SAMPLE_RATE} Hz`);
  console.log(`Head-shadow cutoff f0 = ${f0.toFixed(1)} Hz, shelf floor = ${HF_SHADOW_DB} dB`);

  // shadow-filter impulse response: one-pole lowpass blended with dry per a shelf design
  const shadowIR = new Float64Array(IR_LENGTH_SAMPLES);
  let lp = 0;
  for (let n = 0; n < IR_LENGTH_SAMPLES; n++) {
    const x = n === 0 ? 1 : 0;
    lp = alpha * x + (1 - alpha) * lp;
    shadowIR[n] = lp * (1 - gInf) + x * gInf;
  }

  const totalLen = IR_LENGTH_SAMPLES + itdSamples + 8;
  const chL = new Float64Array(totalLen);
  const chLR = new Float64Array(totalLen);
  const chRL = new Float64Array(totalLen);
  const chR = new Float64Array(totalLen);
  chL[0] = 1.0;
  chR[0] = 1.0;
  for (let n = 0; n < IR_LENGTH_SAMPLES; n++) {
    chLR[n + itdSamples] = shadowIR[n];
    chRL[n + itdSamples] = shadowIR[n];
  }

  // EasyEffects true-stereo channel order (verified against convolver_kernel_manager.cpp):
  // channel 0 = L (LL), channel 1 = LR, channel 2 = RL, channel 3 = R (RR)
  const fmt = { audioFormat: 3, numChannels: 4, sampleRate: SAMPLE_RATE, bitsPerSample: 32 };
  const pcm = Buffer.alloc(totalLen * 4 * 4);
  for (let n = 0; n < totalLen; n++) {
    const o = n * 16;
    pcm.writeFloatLE(chL[n], o + 0);
    pcm.writeFloatLE(chLR[n], o + 4);
    pcm.writeFloatLE(chRL[n], o + 8);
    pcm.writeFloatLE(chR[n], o + 12);
  }

  const trimmedPcm = trimTrailingSilence(pcm, fmt, TRIM_THRESHOLD_DB, TRIM_PAD_FRAMES, TRIM_FADE_FRAMES);
  const wav = buildWav(trimmedPcm, fmt);

  const outPath = path.join(REPO_ROOT, 'irs', 'Synthetic Spherical-Head Crossfeed (48kHz).irs');
  fs.writeFileSync(outPath, wav);
  console.log(`Wrote ${outPath} (${wav.length} bytes, ${trimmedPcm.length / 16} frames)`);
}

main();
