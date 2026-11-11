# Issue #24: S24 FrameTiming QA handoff (Phase 2C V1)

**Active task:** [Issue #24](https://github.com/Nvisioned38/MrWeedsCloudKingdom/issues/24)  
**Baseline:** merged and owner-approved Stage A/B Match-3 animations, `main` at `e0535401c728d834cf7216cba57d48b057deacdc`; [post-merge main CI](https://github.com/Nvisioned38/MrWeedsCloudKingdom/actions/runs/42754300491) SUCCESS.  
**Branch:** `qa/issue-24-s24-frame-timing`. **Deliverable:** truthful, repeatable **per-app Flutter** frame pacing on Samsung S24 Ultra, with no gameplay/art changes.

## Why

The Stage B profile install was safe, but SurfaceFlinger TimeStats yielded no recent layer timing and `dumpsys gfxinfo` yielded a single frame. This is NOT a usable test or zero-jank evidence. Older profiles include:
- Historical S24 board run: 123 Flutter frames; mean/p90/p99 build 1.275/2.295/5.882ms, raster 3.290/5.399/8.450ms, zero 16.67ms budget misses. Different build/code and capture.
- Stage A SurfaceView 609-frame zero-drop count, NOT equivalent to Flutter `FrameTiming`. Do not compare metrics across methods.

## Implement measured QA instrumentation, not a UI animation rewrite

1. Add **QA-only, opt-in** in-app `SchedulerBinding.addTimingsCallback` collector for `FrameTiming` durations (build, raster, total span) and event metadata. Prefer an isolated diagnostics module with proper add/remove callback lifecycle; do not use unrestricted global logging, don't capture save/level/player identifiers or secrets. Guard with a compile-time QA profiling flag AND package separation so it is inactive in production `com.mrweeds.cloudkingdom`. No developer-facing menu or telemetry in normal shipping builds.
2. Start capture after a documented warm-up (e.g. at least 2s); capture >=300 active frames in **profile mode** per run, and label samples <300 **insufficient / NOT TESTED**, not PASS. Ensure the frame-timing callback counts delivered timings, not wall-clock render frames, and report active game window, pauses and device refresh rate. Record raw durations or bounded percentile summary to clearly tagged local `adb logcat`/test artifact, **not** to progress save or preferences. Flush on exit/cancel safely and prevent leaked callbacks.
3. Compute p50/p90/p99 for build/raster/total in ms; count samples exceeding actual refresh budget (e.g. 8.33ms at 120Hz, 16.67ms at 60Hz) and separately count >16.67ms for comparison, labelling both. Report max tail times, sample size, profile package identity/build commit, Android user, test duration, whether normal motion or Reduced Motion and whether a level started/ended. A `FrameTiming` measurement and SurfaceFlinger result are separate metrics.
4. Tests: verify frame batch ingestion, deterministic percentile calculation including odd/even sample count, correct units and threshold calculations, capture start/stop, insufficient sample treatment and no collection in release/production builds. No reliance on external FPS web APIs.
5. No gameplay-logic, Stage A speed, Stage B FX, level, reward, save, sticker/logo or approved-art changes. Retain 64 semantic board actions and existing Reduced Motion defaults. Run format/analyzer/full Flutter tests, 37/37 exact art verification and Android arm64 QA package builds.

## Device and install boundaries

- The owner's persistent S24 `.qa` game and saved progress must not be uninstalled, reset, cleared or overwritten. Production `com.mrweeds.cloudkingdom` and Secure Folder are forbidden.
- The [Issue #21 safe install script](https://github.com/Nvisioned38/MrWeedsCloudKingdom/issues/21) already supports fail-closed user-0 profile/debug replacement after package/version/signer check. Use ONLY its verified path; no naked `flutter drive` driver that can uninstall/downgrade as fallback.
- Prefer capture in a **disposable fully isolated test package / emulator** for scripted multi-level/reward/combo runs; for actual S24 benchmarks, use a QA-identity-compatible profile APK or separate, verified test-only package with its own save namespace. Never silently create/clear user saves, even for a high-score replay. Verify original `.qa` save/preference SHA before and after any authorized update, but don't modify it to achieve equality.
- Profiles should cover ordinary tile swapping, clears/refill, long cascade, Prism, Torch, Cloud Bomb, crate hits and Reduced Motion, using existing seeded levels when possible. Fog/Syrup only with non-shipping QA fixtures, not new V1 levels. If a state cannot be physically reproduced non-destructively, mark automated only.
- Collect S24 data, not just emulator data; record confidence and technical limitations. Ensure the device's original Reduced Motion setting is preserved after the session (ask if the owner changed it intentionally).
- Do not generate fake benchmark figures or extrapolate 0 sampled frames. If profile sampling is blocked, document exact blocker and stop safely.

## Acceptance and delivery

- `docs/evidence/issue24/FRAME_TIMING_QA.md` with a table: each scenario, APK/commit, device, refresh rate, frame count, p50/p90/p99 build/raster/total, 16.67ms and refresh-rate misses, FAIL/PASS/NOT TESTED, and comparability to earlier baseline.
- Attach bounded raw data (CSV/json/logcat capture), explicit profiling collection method, reproducible safe PowerShell steps, and screenshot/video of representative normal vs Reduced Motion effects if available.
- At least one **valid S24 per-app profile-mode sample with >=300 active frames** and clear normal-motion mode; seek other effects samples where safely achievable. An absent valid sample leaves Issue #24 open.
- Keep new work in a **draft PR** until full GitHub CI and evidence are available. This is profiling acceptance only, not V1 Play Store readiness.
- [Issue #6](https://github.com/Nvisioned38/MrWeedsCloudKingdom/issues/6) actual spoken accessibility and its draft PR #18 remain **paused**, as do iOS, Batch 5 collectible import and Phase 3/later reveals.
