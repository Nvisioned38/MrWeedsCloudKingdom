# Issue #19 — event-driven Match-3 motion and FX checkpoint

**Branch:** `animation/issue-19-stage-a`  
**Scope:** smooth tile movement and tying the already integrated Issue #4 effect layers to observed Match-3 resolver events. New animation-sheet crops were not used.

## Implementation

The Flame presentation now sends each active `MatchWaveTrace` to the artwork renderer as a short-lived `BoardTurnEffectFrame`. It carries the actual cleared cells, created/triggered specials, blocker and tile-condition changes, previous/current wave snapshots, gravity/clear phase, and phase progress. It is never saved and cannot affect engine outcomes.

- Match clear: smoke and sparkles follow the current wave’s cleared pieces.
- Created special: sparkles appear at the resolver-reported special anchor.
- Torch: a directional warm trail follows the actually cleared row or column.
- Prism: the engine trace carries the exact selected target family and the pulse follows only that family's cleared cells.
- Cloud Bomb: localized white smoke appears at its actual trigger cell.
- Cascade: combo ring and gravity streak are tied to later cascade waves.
- Crate damage/break, Fog reveal, and Sticky Syrup removal receive feedback only where the trace records a state change.
- Reduced Motion keeps a brief static sparkle cue and omits travel/burst FX.

Cloud Cup vaporizer FX remains absent because the V1 resolver has no corresponding player action; no booster mechanic or logo placement was invented.

## Verification

- `dart format`: changed files formatted.
- `flutter analyze`: no issues.
- `flutter test`: **74/74 passed**; Issue #14 render fixture now verifies phase-progress smoke, cascade layer, Reduced Motion and a triggered Cloud Bomb event.
- Approved Issue #4 artwork manifest: **37/37** hashes and dimensions pass.
- QA APK: `com.mrweeds.cloudkingdom.qa`, arm64 debug, version 0.1.0 (2001), SHA-256 `d2ec5b504514b64ce1fa626fdbd528e7f1d510066fa8e95d569b75e4ef4c3d33`. A follow-up domain regression asserts exact Prism target-family trace data.
- S24 install: the verified QA APK replaced only the existing package under Android user 0 using `-r`. The saved progress payload remained byte-for-byte equal to checkpoint hash `90823d16ca76a7c993a653213c7e8eeae967b237fda5b0349cedafb854122579`.
- **S24 animation visual QA: PASS for normal motion and Reduced Motion.** On SM-S928U / serial `R5CX156CZNF`, only `com.mrweeds.cloudkingdom.qa` under user 0 was launched. With Reduced Motion temporarily off, Level 1's legal four-Mystic-Bloom swap changed score 0→30 and moves 18→17, created the Torch special, and was recorded in [normal match/cascade clip](28_s24_normal_event_fx.mp4). Activating that Torch cleared its actual row; score advanced 30→110 and moves 17→16; see [Torch activation clip](30_s24_torch_event_fx.mp4). With Reduced Motion restored on, the same legal match resolved to score 30 / 17 moves and retained completion feedback with travel omitted; see [Reduced Motion clip](35_s24_reduced_motion_event.mp4). Screenshots: [normal settled board](27_s24_after_normal_match.png), [Torch settled board](29_s24_after_torch_event.png), and [Reduced Motion settled board](34_s24_after_reduced_match.png). Neither replay reached Victory. The original Reduced Motion-on setting was restored. The final QA progress payload is byte-identical to its pretest value, SHA-256 `90823d16ca76a7c993a653213c7e8eeae967b237fda5b0349cedafb854122579`; it still reflects 1,295 coins, 9 stars and nine completed levels.
- **Frame pacing: NOT MEASURED in this follow-up.** Screen recordings document visual behavior, not a frame-time sample. The earlier partial SurfaceFlinger sample and its measurement limits remain in `STAGE_A_QA.md`; no new frame-rate or jank claim is made.

## Locked animation-sheet intake

`Cloud_Kingdom_Animation_FX_Batch2_APPROVED_LOCKED.zip` was found in Downloads and its archive SHA-256 matches the handoff (`d9d520219cc9097641e350151bcb7e07250765479b09d4b8747db279e9420eb1`). All eight gravity/refill candidate crop hashes and dimensions matched the package manifest. Visual/boundary QA rejected them for runtime: sampled nontransparent pixels occupied **78.1–93.9% of frame-edge samples** across the set, with the purple/blue glow visibly cut at the crop borders. They remain unimported; do not use them until clean standalone frame exports are available. The original approved sheets were not altered. The Batch 1 approved source ZIP was not found in the inspected Downloads/Desktop/OneDrive locations. Existing Issue #4 FX layers were used byte-exactly.

**Gate:** event-driven implementation, automated/build checks, and the S24 normal/Reduced Motion visual checks above pass. Frame-pacing remeasurement and clean source-frame artwork remain pending; Issue #19 and V1 remain open.

## Owner-approved Reduced Motion cue refinement — 2026-11-09

Per the updated Issue #19 acceptance, normal-mode timing is locked and unchanged. Reduced Motion now presents the authoritative final board immediately with a stationary warm-gold softened ring and restrained approved sparkle that fades smoothly over **300 ms** after successful matches; invalid swaps use a subdued stationary cue for **220 ms**. No tile travel, explosion, camera shake, or flashing is used. Gameplay resolution and score/reward mutation remain immediate; the shared touch/semantic resolving gate remains active only through presentation completion.

Regression coverage verifies the cue is still rendering at 150 ms, the approved sparkle opacity declines and reaches zero by the end of the normalized timeline, tile renderer positions are identical at the start and 150 ms (no Reduced Motion travel), all 64 semantic cells remain mounted, and the existing normal-mode timeline remains active past 150 ms. Full suite is **74/74**, analyzer clean, format clean, and approved-art verification **37/37**. QA APK package is `com.mrweeds.cloudkingdom.qa`, version 0.1.0 (2001), SHA-256 `db2ce300a11b4b2cf146761db6b12105cae5594f34106b0c8265d88f9c47f631`.

**Updated-cue S24 acceptance: PASS — 2026-11-09.** After USB debugging was reauthorized, ADB reported serial `R5CX156CZNF` as `device`; the active Android user was `0`, and the verified target was only `com.mrweeds.cloudkingdom.qa`. The latest APK was installed with the repository safety script's replace-only `-r --user 0` path. No uninstall, clear-data, Flutter Driver, profile change, or production-package action was used.

The physical Level 1 replay produced a successful match: score 0→90, moves 18→17, with a Torch special created. At the synchronized 150 ms capture, the successful cells show a clearly visible stationary warm-gold halo; the board has no tile travel. The cue is gone in the settled capture, consistent with the 300 ms fade. The [S24 Reduced Motion recording](52_s24_reduced_motion_feedback.mp4), [150 ms feedback capture](53_s24_reduced_motion_feedback_150ms.png), [settled board](54_s24_reduced_motion_settled_refined.png), and [Cloud House after replay](55_s24_final_cloud_house_refined.png) are the latest evidence. This is a visual responsiveness/no-travel check, not a new frame-pacing measurement. The replay did not reach Victory or alter rewards/progression.

Before install and after all device work, the isolated QA preferences/save payload SHA-256 was exactly `5506ce444d4ec61c1eea86da3f61b01d8c668c49c8bbe24af2f8a545b62de94f`; saved progression remained 1,295 coins, 9 stars and nine completed levels, and Reduced Motion remained on. Production app and save were not accessed. APK package/version: `com.mrweeds.cloudkingdom.qa`, 0.1.0 (2001), arm64; SHA-256 `58655e4948b04ca3d67651f666026b5b2b03a54b51c238ba04a7d4e90959fa38`. PR #20 remains draft pending owner checkpoint approval. Stage B and accessibility work remain paused.
