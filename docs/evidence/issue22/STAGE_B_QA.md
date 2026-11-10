# Issue #22 — Stage B verification

**Branch:** `animation/issue-22-stage-b`
**Base:** merged Stage A `main` commit `716836521698859e5906c17813362550a1c7be8e`
**Main CI:** run [42742349930](https://github.com/Nvisioned38/MrWeedsCloudKingdom/actions/runs/42742349930), completed successfully before Stage B work.

## Implementation

The renderer consumes gravity/refill movement and spawn destinations from the existing observation-only engine trace. Cascade streaks stay clipped to cells that actually moved or spawned. Torch trails follow the actual affected row/column; Prism glints use only the engine-reported target family; Cloud Bomb smoke is staged over trace-reported cells in its 3×3 blast. Crate damage and break cues differ and use the prior blocker kind/state. Fog and Syrup release cues are drawn only for actual condition changes. No new Cloud Cup gameplay action was introduced.

Stage A timing constants and Reduced Motion behavior were not changed. The deterministic resolver, all authored Levels 1–30, schema-3 save format, gameplay identifiers, 64 semantic board cells, and approved artwork bytes are unchanged.

## Verification results

| Gate | Result | Evidence |
|---|---|---|
| Dart formatting | PASS | `dart format` clean on all four affected Dart files |
| Full Flutter suite | PASS | **77/77 tests**, including new Issue #22 renderer fixtures |
| `flutter analyze` | PASS | No issues found |
| Approved artwork integrity | PASS | **37/37** independent PNGs match SHA-256 manifests, dimensions and RGBA format |
| QA install guard tests | PASS | Same-version replace and upgrade accepted; downgrade, signing mismatch, production package and non-user-0 targets refused |
| QA PowerShell parser | PASS | `tools/build_qa_apk.ps1` parses without errors |
| Android QA debug APK | PASS | `com.mrweeds.cloudkingdom.qa`, 0.1.0 (2001), arm64; SHA-256 `bf67c439f6f5574edac1677ca24b3083c6969cb681f4327dd93cf353ba3bab09` |
| Android QA profile APK | PASS | `com.mrweeds.cloudkingdom.qa`, 0.1.0 (2001), arm64; SHA-256 `778740d607780982c561e9484ec5a4840b788fba84f1ef2b12190d86ec02414e` |
| Profile-to-debug QA replacement | PASS | Explicit user-0 `install -r`; same package/version/signer; no uninstall or data clear |

## Issue #21 safety work

`tools/build_qa_apk.ps1` no longer has an uninstall action or uninstall fallback. Profile and debug installs target only Android user 0 and `.qa`; they verify the connected device state, active user, installed QA path, package identity, version monotonicity and signing certificate before explicit `cmd package install -r --user 0`. The staged APK hash is checked on-device before installation. The QA safety module has simulated downgrade and signer-mismatch refusal tests. The S24 profile APK was built and safely replace-installed, then the debug QA APK was safely restored. The production application was never installed, launched, queried or modified.

## S24 Ultra observations

Device `R5CX156CZNF` (SM-S928U), ADB-authorized; Android user 0. Every device action used `com.mrweeds.cloudkingdom.qa`.

- **Prism and cascade:** on the completed Level 4 replay, the seeded legal match advanced the Prism objective from 0/1 to 1/1, scored 780 and consumed one move. The board displayed a five-wave cascade. A follow-up special interaction advanced to score 860; the exact activated special is not independently confirmed by the capture. Screenshots and videos are in this directory (`18`, `33`–`36`).
- **Cloud Bomb:** on completed Level 8, the seeded move advanced Create Cloud Bomb from 0/1 to 1/1, score 550 and moves 26→25; the screen showed a four-wave cascade. The next move activated the bomb, destroyed one crate (0/4→1/4), scored 640 and moves 25→24. See `25`, `27`–`30`.
- **Crate damage:** Level 10 replay showed the reinforced-crate damaged state after an actual adjacent match. Normal and Reduced Motion recordings/screenshots are `07`–`14`.
- **Reduced Motion setting:** temporarily disabled for normal-motion captures and restored to its original enabled state. Final setting is visible in `38_s24_reduced_motion_restored_on.png`.
- **Saved progress:** QA SharedPreferences SHA-256 remained exactly `5506ce444d4ec61c1eea86da3f61b01d8c668c49c8bbe24af2f8a545b62de94f` after play, profile replacement, debug restoration and relaunch. Cloud House still showed 1,295 coins and 9 stars; the current path remained Level 10. No level was completed during Stage B checks.
- **Production app/Secure Folder:** NOT ACCESSED.

## NOT TESTED / remaining gate

**Automated S24 frame pacing comparison: NOT TESTED.** The profile APK replacement and restoration were safely verified. On this handset session, SurfaceFlinger TimeStats returned no fresh output and `dumpsys gfxinfo` exposed only one frame, so there is no valid per-app frame sample to compare against the earlier S24 benchmark. No Flutter build/raster percentile or frame-pacing PASS is claimed. The Stage A performance evidence remains separate and is not represented as a Stage B measurement.

**Owner visual checkpoint:** pending. Keep PR #23 draft until the owner reviews the new effect captures. Stage B does not complete V1 release gates.

## Visual evidence index

- `02_s24_cloud_house.png`, `03_s24_level10_board.png`: preserved QA progression and full board.
- `07_s24_crate_feedback_180ms.png`, `08_s24_crate_feedback_settled.png`, `09_s24_stage_b_crate_normal.mp4`: crate feedback.
- `12_s24_reduced_match_180ms.png`, `14_s24_stage_b_reduced_motion.mp4`, `38_s24_reduced_motion_restored_on.png`: Reduced Motion and restored setting.
- `18_s24_prism_created.png`, `33_s24_prism_fx.png`, `34_s24_stage_b_prism_cascade.mp4`, `35_s24_prism_trigger.png`, `36_s24_stage_b_prism_trigger.mp4`: Prism/cascade interaction.
- `25_s24_level8_bomb_board.png`, `27_s24_bomb_move_check.png`, `28_s24_cloud_bomb_trigger.png`, `29_s24_stage_b_cloud_bomb_create.mp4`, `30_s24_stage_b_cloud_bomb_trigger.mp4`: Cloud Bomb interaction.
- `39_s24_profile_welcome.png`, `41_s24_profile_path.png`, `42_s24_profile_level4_board.png`, `43_s24_profile_stage_b_match.png`: profile-mode safe replacement and replay. `44_s24_debug_cloud_house_after_profile.png`: debug QA relaunch with progress retained.
