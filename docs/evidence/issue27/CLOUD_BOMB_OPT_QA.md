# Issue #27 — Cloud Bomb performance diagnosis

**Branch:** `performance/issue-27-cloud-bomb`
**PR:** #28 (draft)
**Baseline:** `main` at `fbf0dce1b7e1c2b540fe9a52da5d8b0e2ddd4703`; CI run 42930607499 passed before work began.
**Device:** Samsung Galaxy S24 Ultra `R5CX156CZNF`, Android user 0, 120 Hz.
**Application:** isolated `com.mrweeds.cloudkingdom.qa` only.

## Current result

The QA profiler now labels board-idle, transition, Cloud Bomb phase and other effect frames, and joins Flutter `FrameTiming` samples to nearby rendered-frame markers. The physical capture confirmed that the seeded Level 8 move creates a Cloud Bomb and four-wave cascade, and the next move triggers it. The capture recorded two accepted swaps, six match waves, 32 cleared tiles, 23 gravity drops, 33 refills, one blocker change, one created Cloud Bomb, one triggered Cloud Bomb, and maximum cascade depth four.

One 3,000-sample mixed Level 8 capture ran at 120 Hz. Build p50/p90/p99/max was **1.860 / 2.015 / 2.232 / 5.289 ms**; raster was **5.255 / 5.603 / 6.078 / 12.640 ms**; total span was **8.362 / 8.890 / 9.490 / 18.224 ms**. There were **1,585/3,000** total-span samples over the 8.333 ms refresh interval and **2** over 16.67 ms. The report joined 2,993 frames to board render markers; seven were unmatched.

This mixed-session result is not an effect-versus-idle comparison. The earlier summary serialized all per-scene data into one debug line, which Android truncated before the scene statistics. The collector was updated to emit bounded `CK_FRAME_TIMING_SCENE` lines; focused tests now cover exact and near-timestamp joins. The corrected logger needs a fresh physical capture before the Cloud Bomb cost can be compared with its matching idle board scene.

No renderer optimization has been made. Although the current renderer enters `saveLayer` around static tiles and blockers, that observation alone does not prove those layers cause the Cloud Bomb regression. Cloud Bomb artwork, alpha, 3×3 coverage, particles and timing remain unchanged.

## S24 QA and save integrity

- The exact Level 8 seeded move `r2c5 → r3c5` created the bomb, scored 550, and produced four match waves. This was independently confirmed with the pure Dart deterministic engine before replaying it on-device.
- The neighboring-cell swap triggered the bomb. The QA screen showed Level 8, **24 moves**, **Create Cloud Bomb 1/1**, **Destroy crates 1/4**, and score 700. The level remained incomplete; no Victory, rewards or save progression was written.
- QA `FlutterSharedPreferences.xml` SHA-256 before and after the completed capture was `bf7f8095e9781e59fad2879a8fab50142d3764c255af7a369d31cfe46fca2b90`.
- Screenshot: [S24 post-trigger board](s24_cloud_bomb_trigger.png). It documents the objective and cascade state; it is not a frame-by-frame capture of the smoke animation.
- Later, the handset foreground changed to Life360. Device input stopped at that point. The final profile APK was built and verified locally, but no further physical interaction was attempted.

## Automated verification

- Focused frame collector tests: **8/8 passed**.
- Full Flutter suite: **85/85 passed**.
- `flutter analyze`: **clean**.
- Dart format: **clean** for changed Dart files.
- Approved standalone artwork: **37/37** SHA-256, PNG signature, dimensions, 8-bit RGBA checks passed.
- QA install safety tests: **passed** (same-version replacement and upgrade accepted; downgrade, signer mismatch, production identity and non-user-0 rejected).
- QA arm64 debug APK: `com.mrweeds.cloudkingdom.qa`, version 0.1.0 (2001), SHA-256 `50b8c9b86762b593089992289d43b0fdf2d316dc4f4649727e73490be5c48caf`.
- QA arm64 profile APK: `com.mrweeds.cloudkingdom.qa`, version 0.1.0 (2001), SHA-256 `e4863da89c5c181caa39b447139286f06f401401555490e182432510e353717b`.
- The profile APK was installed over the existing QA app earlier by `tools/build_qa_apk.ps1` using explicit user-0 `install -r`; data was preserved. The final locally built APK was not reinstalled after the phone foreground changed.

## Remaining verification

1. With the S24 available, use only the QA profile APK and repeat the same Level 8 creation/trigger sequence twice.
2. Preserve complete `CK_FRAME_TIMING` and `CK_FRAME_TIMING_SCENE` log records; compare Cloud Bomb onset/midpoint/fade against `board_idle` samples from the same level and device session.
3. Capture the active smoke effect and a settled board under the same scene framing.
4. Inspect overlapping translucent smoke, image decode/cache behavior, vector operations and `saveLayer` counts against those measured deltas. Make the smallest code-only optimization only if the repeated comparison proves a bottleneck, then rerun the same two profiles.

Issue #27 is not performance-signed-off. PR #28 remains draft. No gameplay rules, save schema, approved art, animation timing or authored levels changed; no Phase 3 work began.
