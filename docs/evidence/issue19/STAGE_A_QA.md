# Issue #19 Stage A — implementation and QA status

**Branch:** `animation/issue-19-stage-a`
**Base:** verified `main` `c6229e5c5ba154021e4bc44286b1c4e842497c33`
**PR:** [#20](https://github.com/Nvisioned38/MrWeedsCloudKingdom/pull/20), kept draft
**Scope:** Stage A only. Stage B, Issue #6, PR #18, Batch 5 runtime art and Phase 3 were not started.

## Implemented

- Added opt-in, ephemeral `TurnAnimationTrace`/`LevelTurnAnimationTrace` snapshots inside the existing `Match3Board` resolution path. A trace records the attempted swap/original pieces, accepted or rejected result, each match wave, created/triggered specials, cleared piece snapshots, condition and blocker changes, post-clear and post-gravity boards, survivor source→destination movements, actual deterministic refill pieces/origins and per-segment bounds, optional shuffle crossfade input, final board/result/outcome and objective values.
- Trace creation is presentation-only. With tracing absent the resolver keeps its non-trace path; it makes no extra RNG calls and does not serialize animation state. Seeded trace-on/off comparisons cover the result fields, score, board fingerprint, moves, objective values and outcome.
- Replaced the old final-board/pre-swap overlay with a snapshot-driven timeline: selected-cell pulse; accepted swap tween; invalid attempt/rollback; clear shrink/fade and restrained sparkle; exact gravity and spawn travel; ordered cascades; optional dead-board reshuffle crossfade; authoritative settled board. Reduced Motion skips travel and provides a short still-visible changed-cell indication. Nonadjacent selections retain the prior selection behavior and do not render a fake swap.
- The resolving gate rejects Flame and semantic tap input. The 64 named cell semantics remain mounted and become disabled during playback. Result/reward navigation waits until playback completion and is emitted once. Pause/inactive cancels presentation, reconciles to the already-resolved board and defers the pending turn callback until resume; disposal safely abandons view work.
- No authored level, objective/reward rule, save identifier/schema, approved PNG, logo, or story content changed.

## Automated verification — PASS

- `dart format --set-exit-if-changed lib test integration_test test_driver`: 27 files checked, 0 changes on the final check.
- `flutter analyze`: no issues.
- `flutter test`: **74/74 passed**, including trace parity/order, gravity lineage and segment bounds, invalid rollback, input locking, Reduced Motion result flow, lifecycle cancellation, all existing progression/save/art tests.
- Approved-art manifest validation: **37/37** Issue #4 PNGs match SHA-256 and declared dimensions; all are valid 8-bit RGBA PNGs. The host Python launcher was unavailable, so the same committed CSV/hash/IHDR checks were run with PowerShell.
- QA APK: built and installed via `tools/build_qa_apk.ps1 -Action InstallQa -DeviceSerial R5CX156CZNF`. The script verified arm64 package `com.mrweeds.cloudkingdom.qa`, version 0.1.0 (2001), minSdk 24, active Android user 0, exact installed QA package, staged/local SHA equality and replace-only `-r` installation. APK size **135,589,105 bytes**, SHA-256 **`ea7ee13d0a58a91c51705a6edc5c8ab537c5c48591d8a6090940599738ba176d`**. Artifact: `build/qa/app/outputs/flutter-apk/app-arm64-v8a-debug.apk`.
- QA save preservation: hash of `flutter.cloud_kingdom_progress_v2` was **`90823d16ca76a7c993a653213c7e8eeae967b237fda5b0349cedafb854122579`** before and after final replacement. It remained schema 3, 1,295 coins, 9 stars, 9 completed levels, Reduced Motion enabled, Level 1 best 3,100. No progress was cleared. No production package command was issued.

## Samsung S24 Ultra — device gate BLOCKED by lock screen

- ADB authorization, device model SM-S928U / serial `R5CX156CZNF`, current user 0, and existing `com.mrweeds.cloudkingdom.qa` identity were verified. The final APK was replace-installed on user 0 without clearing its data.
- The phone was at its lock screen. It was only woken to confirm the screen state and returned to sleep; no lock bypass was attempted. The QA game could not be inspected or physically played while locked.
- **NOT TESTED on this Stage A APK:** real accepted/invalid motion, cascade video/screenshot, Reduced Motion visual comparison, physical frame pacing/profile comparison, and S24 launch-to-board visual check. No app screenshot is attached because the only available capture showed the lock screen.
- Earlier S24 reference sample (Issue #5, 123 frames) was build avg/p90/p99 1.275/2.295/5.882 ms and raster 3.290/5.399/8.450 ms, 0 budget misses. This is a historical comparison point only; it is not a measurement of this animation build.

## Gate status

Stage A code and automated/build gates are complete. **Stage A is not accepted/closed yet** because the required current-build physical S24 animation and frame-pacing review could not be done while the phone was locked. Do not begin Stage B until that review is performed and Stage A is reported complete.


