# Issue #12 — Samsung S24 Ultra QA

**Date:** 2026-11-08  
**Device:** Samsung SM-S928U (S24 Ultra), Android API 37, ADB serial `R5CX156CZNF`  
**Target:** Android user `0`, package `com.mrweeds.cloudkingdom.qa` only  
**Baseline:** `main` at `5e6f149290b0901bf9557b83ec198ef7b91c1671`, CI run [42446015783](https://github.com/Nvisioned38/MrWeedsCloudKingdom/actions/runs/42446015783) passed.

## Safety and artifact

- ADB authorization: **PASS** (`device` state); active user: **PASS** (`0`); QA package path before and after install: **PASS**.
- The installed ADB 37.0.1 does not support `adb install --user`; the first guard probe failed closed before installation. `tools/build_qa_apk.ps1` now verifies active user 0 and the existing QA package, confirms Android Package Manager's documented `install --user USER_ID`, stages only the locally verified QA APK, checks the staged SHA-256, then uses `cmd package install -r --user 0` and verifies `pm path --user 0`.
- Reinstall used replace semantics (`-r`); no uninstall, app-data clear, profile switch, Secure Folder operation, production-package command, or production save access was performed. Existing QA progress was retained.
- Final debug APK: `build/qa/app/outputs/flutter-apk/app-arm64-v8a-debug.apk` (arm64, package `com.mrweeds.cloudkingdom.qa`, version `0.1.0` / code `2001`, min SDK 24). See `qa-build-metadata.json` for the final commit and SHA-256.

## Results

| Check | Result | Device evidence |
|---|---|---|
| Five standalone tile families at 8×8 size | **PASS** | Cloud Puff, Mystic Bloom, Ember Drop, Dream Crystal, Golden Nugget are distinct and legible; [03-board-aligned.png](03-board-aligned.png) |
| Standard and reinforced MW crates | **PASS** | Both types render; a legal adjacent match changed reinforced-crate damage state; [03-board-aligned.png](03-board-aligned.png), [05-after-match-fx.png](05-after-match-fx.png) |
| Fog and Sticky Syrup overlays | **NOT TESTED on device** | No authored Levels 1–30 configuration places these conditions on the S24 board. Renderer/domain automated coverage remains in the test suite. |
| Torch, Prism, Cloud Bomb, Cloud Cup vaporizer and canonical logo overlay | **PASS, static guide** | Art and separate Cloud Cup logo overlay render; guide semantics identify each special. Dynamic active, pressed, and selected states were not reachable on the inspected board; [04-specials-guide.png](04-specials-guide.png) |
| Full 8×8 grid, frame transparency, visible/touch alignment | **PASS after fix** | All 64 labeled cells fall inside the frame's clear center. A valid touch swap changed score 0→30 and moves 30→29. Fixed the former over-wide board under the bezel; added widget regression. |
| HUD objectives, moves, score, stars/progress | **PASS** | Dynamic counters changed during real play; low/zero move backing and score progress rendered; [18-low-moves.png](18-low-moves.png), [19-zero-moves-result.png](19-zero-moves-result.png) |
| Match smoke/cascade effects, normal and Reduced Motion | **PASS, observed swap sequence** | Normal-motion match showed smoke/cascade feedback; with Reduced Motion enabled a legal match and HUD change completed without stalling. See [05-after-match-fx.png](05-after-match-fx.png), [08-normal-motion-match.png](08-normal-motion-match.png). Combo/special FX sequence was not triggered. |
| Victory/results and no duplicate replay rewards | **PASS** | Replayed already-cleared Level 1 to score 1,030. Results explicitly said “Replay complete · no duplicate first-clear reward”; [12-level1-results.png](12-level1-results.png) |
| First-clear reward amount on this build | **NOT TESTED on device** | The preserved QA save already had Level 1 cleared and nine stars. No reset was performed. Automated tests cover first-clear 100 coins / 1 star / 6 Collection XP and idempotence. |
| Cloud House and completed-progress persistence after relaunch | **PASS** | Cloud House showed 1,295 coins and 9 stars before and after QA force-stop/relaunch and Continue; [13-cloudhouse-after-replay.png](13-cloudhouse-after-replay.png), [15-relaunch-cloudhouse.png](15-relaunch-cloudhouse.png) |
| 2× system text and safe-area portrait layout | **PASS after fix** | Level title reflows to two lines; 64 cells remain visible; 0.9 system scale restored. App content remains within status/navigation safe areas. Objective content uses an expandable high-contrast backing at large text scale. See [21-board-title-2x-after-fix.png](21-board-title-2x-after-fix.png). |
| Missing-image fallback | **NOT TESTED on device** | No bundled image was removed or corrupted on the phone. Automated renderer fallback coverage passed; the 37-art manifest verifier passed. |
| Profile-mode performance | **PASS, timeline sample** | 419 Flutter `Frame` events: avg/p90/p99 1.201/1.369/1.496 ms; 417 `GPURasterizer::Draw`: 3.478/3.912/4.169 ms; 0 UI/raster samples over 16.67 ms. Raw summary: [profile-timeline.json](profile-timeline.json). |
| Device fatal / ANR smoke | **PASS** | QA process log had no `FATAL EXCEPTION`, Flutter error, or ANR line; [qa-process-logcat.txt](qa-process-logcat.txt). System logs were not cleared. |
| Production app and production save untouched | **PASS** | No device operation addressed the production package; no production identity query was needed. |
| TalkBack spoken output | **NOT TESTED** | TalkBack audio remains Issue #6. |

### Performance comparison

The previous S24 benchmark recorded 123 frames: build avg/p90/p99 `1.275/2.295/5.882 ms`, raster `3.290/5.399/8.450 ms`, zero budget misses. This run's Flutter VM timeline shows UI `Frame` avg/p90/p99 `1.201/1.369/1.496 ms` and `GPURasterizer::Draw` `3.478/3.912/4.169 ms`, zero samples above 16.67 ms. The event sources differ from the earlier `watchPerformance` `FrameTiming` fields, so this is a directional comparison, not a same-method benchmark. The rasterizer average is 0.188 ms higher; p90/p99 and UI percentiles are lower in this sample.

## Software changes and verification

- `tools/build_qa_apk.ps1` now fails closed on wrong user, missing QA package, unsupported explicit user install, hash mismatch, APK identity mismatch, or Package Manager install failure. It does not attempt uninstall/clear fallback.
- Board and semantic hit targets are constrained to the approved frame's transparent center (`82.4%` of the frame); widget regression covers centering and bounds.
- At 2× text, the board title reflows and the objectives panel uses a dynamic high-contrast backing so text does not spill onto the ornamental bezel.
- Verification: `flutter test` **65 passed**; `flutter analyze` **clean**; approved art manifest **37/37 SHA/dimensions/RGBA verified**; formatting check on changed presentation/test files **clean**; `git diff --check` **clean**.

## Remaining gates

Fog/Sticky Syrup, dynamic special activation/selected/pressed art, combo FX, on-device missing-image fault injection, first-clear payout on a fresh QA save, TalkBack speech, and owner visual sign-off remain unverified. The QA data was deliberately not reset to obtain a fresh first-clear state. V1 remains a technical preview; Phase 3 was not started.
