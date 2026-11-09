# V1 Android QA and Release Gate

This checklist records automated evidence and isolated S24 physical QA. Final visual and artwork sign-off remain open.

## Status legend

**NOT TESTED** = no current evidence; **PASS** = tested and documented; **PARTIAL** = evidence exists but scope is incomplete; **FAIL** = defect; **BLOCKED** = waiting on owner device / other dependency.

| Gate | Status | Evidence / commit / device |
|---|---|---|
| Resolve GitHub Issue #1 and regression for Level 30 Chapter 3 finale dialogue | PASS | Pulled `edcf151`; 29/30 and 30/30 story gate and save round-trip covered in tests |
| Format clean | PASS | `dart format lib test` and `--set-exit-if-changed` |
| `flutter analyze` no issues | PASS | Flutter 3.47.7, 2026-11-07 |
| Full Flutter test suite | PASS | 71 tests passed on 2026-11-08; includes Issues #14/#15 QA fixtures, adaptive HUD sizing, progression, mechanics, migration, rewards, save round-trip and semantics |
| 30-level catalogue and progression unaffected | PASS | Existing catalog and progression tests pass |
| Save schema 3 upgrade/restart/reset/perk persisted | PASS | Phase 2B migration and round-trip tests pass; schema remains 3 |
| Official logos and approved title treatment integrated | PASS | BR-005/006 alpha-bound exports verified pixel-exact to BR-001/002 masters; BR-003 v1 treatment copied unchanged; S24 title/app-shell rendering checked |
| Approved Mr. Weed character portrait integrated | PASS | v10 CS-001 `MW_img_CS-001b.png` copied byte-identically; CH-001 OK-gesture/blank-shirt notes traced; S24 Story character catalog rendered it |
| Core P0 Match-3 production tiles, blockers, specials and FX integrated | PASS — 37/37 assets; S24 visual partial | 37 approved PNGs passed exact manifest validation and are visible on S24. Issue #14 automated fixtures now exercise Fog/Syrup composition, special/booster states, smoke/combo effects, and fallback; physical optional-state visuals remain not tested. See `docs/evidence/issue12/RESULTS.md` and `docs/evidence/issue14/RESULTS.md`. |
| Cloud House, Lounge and Kitchen source artwork integrated | PASS | 7 intact originals; source hashes, dimensions and v10 approval row IDs in `assets/art/manifest.json`; Home screen rendered on S24 |
| Home → Match-3 → Victory/replay → Cloud House → relaunch on current integrated build | PASS — replay path | S24 Level 1 replay scored 1,030; duplicate first-clear reward was suppressed; 1,295 coins / 9 stars persisted after force-stop and Continue. Fresh first-clear payout on this already-cleared QA save was not repeated. |
| Collection/equipment/evolution runtime states | PASS | Dynamic 30-card UI and progression tests pass; new collection art not yet approved/integrated |
| V1 museum/shelf art states | BLOCKED | Supplement sources have pending new-file sign-off; full Gallery remains preview-only |
| Story scope and spoiler firewall | PASS | Chapters 1–3 retained; no later-story content added |
| Shape cues, reduced-motion and haptics wiring | PASS | Distinct fallback silhouettes; legacy leaf identity is a green spiral-bloom Mystic Bloom; settings control animation/haptic behavior |
| TalkBack spoken navigation and cell semantics | PARTIAL — Issue #6 open | Actual S24 speech confirms welcome controls, Cloud House transition, named 8×8 board, “Cloud Puff, row one, column one,” “selected,” “Objectives, Score, 0 of 800,” and “18 moves remaining.” A blank-label board node was fixed. A missing Close-level name and duplicated title were also fixed in the latest APK. Victory/reward/home/relaunch speech and updated title/Close announcements are pending. |
| Objective panel content fit at 0.9×, 1×, 1.5× and 2×, 1–3 objectives | PASS — widget and S24 | Content-sized frame contains all labels/values and the 30-move counter. S24 Level 10 captures at 0.9× and 2× show all three rows and all 64 cells; scale restored to 0.9. See `docs/evidence/issue15/`. |
| Large text, portrait cutout and landscape layout | PASS — S24 portrait 2× | S24 at 2× retained all 64 cells and readable title/objectives. System scale restored to 0.9. Emulator landscape/cutout checks also pass. |
| Background/resume lifecycle | PASS | S24 completed-level force-stop/relaunch showed Continue and restored Level 2/100 coins/1 star; no fatal logs. Mid-level board state is not saved by design |
| Profile-mode emulator performance | PASS | Warm `watchPerformance` sample of 122 API 36 emulator frames: avg/p90 build 0.456/0.663 ms; avg/p90 raster 2.024/2.513 ms; 0 build-budget misses and 1 raster-budget miss |
| Physical S24 Ultra performance | PASS — profile timeline | 419 Flutter UI frame events avg/p90/p99 1.201/1.369/1.496 ms; 417 GPU rasterizer draws 3.478/3.912/4.169 ms; zero samples over 16.67 ms. See Issue #12 evidence; method differs from prior `watchPerformance` baseline. |
| Android debug APK identities and SHA-256 recorded | PASS | Final QA arm64 APK `com.mrweeds.cloudkingdom.qa`, SHA `5cdb0d40…e1a67`, installed by user-0 QA `-r` script; production-ID debug APK separately built/verified but not installed. Full hashes in `docs/evidence/issue14/RESULTS.md`. |
| Samsung S24 Ultra install, launch and visual smoke for integrated art | PASS — QA only | Active user 0 and QA identity verified; explicit `cmd package install -r --user 0` path used; 8×8 board/frame and approved art photographed. Production package/save untouched. |
| Full isolated gameplay loop on current integrated build | PARTIAL — replay | Level 1 victory replay → Cloud House → force-stop/relaunch Continue passed. Fresh first-clear payout is not re-tested because the retained QA save already completed Level 1. |
| Issue #14 optional-state physical S24 visuals | NOT TESTED | Deterministic test-only fixtures cover these cases; no Fog/Syrup level, active special state, injected missing APK image, or fresh-save payout was run on the phone. Existing QA progress was preserved. |
| First-clear rewards on fresh isolated data | PASS — automated fixture | Fresh `ProgressState` gets +100 coins/+1 star/+6 XP; serialized restoration and replay idempotence pass. No S24 save was reset. |
| S24 physical gameplay/reward/accessibility/performance QA | PARTIAL | Tile/frame/touch, blockers, live HUD, normal/reduced effects, replay, saved progress, 0.9×/2× text, low/zero moves and profile checks passed. Optional-state device checks remain not tested; TalkBack speech remains Issue #6. |
| Owner final visual sign-off against v10 workbook | BLOCKED | Owner approval authorizes integration; final device visual acceptance and remaining release gates are still open |
| No generic placeholders on primary V1 path | NOT TESTED | Newly integrated Match-3 artwork needs on-device visual inspection; broader V1 release gate remains open |

## 2026-11-07 v10 Android technical preview evidence

- Build: `flutter build apk --debug --target-platform android-arm64` — passed locally.
- APK: `C:\Users\LifeN\OneDrive\Desktop\Mr Weeds\App_Game\The Build\MrWeedsCloudKingdom_V1_Technical_Preview_arm64.apk`
- SHA-256: `33D2FBBD856ECD5E59BA00D7205424B9DC7196033D37ADC2C670DC204174A339`
- APK produced: yes. Installed/updated on Samsung S24 Ultra: yes, with `adb install -r`; no uninstall or data clear. Cloud House reopened with prior Level 3, 210 coins and 2 stars. The game board was viewed but no turn was taken.
- This is a **technical preview**, not a visually accepted V1 release candidate.

## 2026-11-07 CS-001 portrait update

- Source: v10-approved `Game Art/MW_img_CS-001b.png`; v10 workbook CS-001 and CH-001 identity notes.
- Export: `assets/art/characters/mr_weed_portrait.png`, copied without pixel edits; 1254×1254 transparent PNG.
- Verification: `flutter pub get`; `dart format lib test` (0 files changed); all 48 Flutter tests pass; `flutter analyze` clean; arm64 Android debug APK built.
- APK: `C:\Users\LifeN\OneDrive\Desktop\Mr Weeds\App_Game\The Build\MrWeedsCloudKingdom_V1_Technical_Preview_arm64.apk`
- SHA-256: `AED184E6BA0A234AA22B6A0B86ECED2D6BAE273837432C043A78B9204614FD1B`
- Samsung S24 Ultra `R5CX156CZNF`: in-place install succeeded; title/Home/Story screens opened; the existing Level 3, 210 coins and 2 stars were visible; no move or story beat was taken. No Flutter/Android error logs were present in the checked buffers.
- P0 Match-3 and modular HUD originals remain blocked; exact candidate artwork and rejected crop trials are recorded in `docs/V1_ART_EXPORT_MATRIX.md`. This remains a technical preview.

## Manual Samsung S24 Ultra pass

1. Install V1 preview debug APK **without uninstalling an existing progress-bearing build** when testing migration. Back up save if needed; do not overwrite or clear user progress during automated checks.
2. Launch an existing save in normal portrait orientation. Verify official logos and scaling around cutouts.
3. Start Level 1, complete a level, watch Victory, ensure stars/coins/progress appear in the Cloud House hub.
4. Play a representative blocker/special level, verify tile contrast/shape cues, animation, sound/haptics and reduced motion.
5. Restore Lounge, view Kitchen milestone around Level 20, verify Gallery is preview only after Level 30.
6. Open Collection, equip Cloud Nine, confirm +150 start score and saved equipment; inspect card, rarity, evolution and shelf.
7. Inspect Chapters 1–3 and ensure Chapter 3 closing dialogue is reachable after finishing Level 30, not sooner.
8. Background/relaunch the app and confirm all progress remains. Check Settings and navigation.
9. Review all P0 approved artwork against the v10 sign-off workbook and mark each individually accepted or needs revision.
10. Record APK SHA-256, Android OS/device info, build commit, manual pass/fail notes, screenshots if supplied, and final sign-off.

**A compiled APK is not proof of a successful Samsung S24 Ultra installation or player experience.**

## 2026-11-07 GitHub Issue #5 isolated Android QA

- Baseline pulled: `e72b0e5` (latest main before QA work). The owner's S24 save was explicitly kept out of all modifying checks; connected S24 `R5CX156CZNF` reported `unauthorized`, and no install, launch, or app-data command targeted that serial.
- Isolation: disposable `MrWeeds_API36` Android emulator, package `com.mrweeds.cloudkingdom`, clean profile. Emulator installation and Level 1 play used only its own data. Existing S24 progress was not read or changed.
- Gameplay/rewards/save: isolated widget route invoked semantic tap actions for a valid tile swap, reached victory/reward, verified first-clear coins/stars/Level 2 unlock, deserialized persisted schema-3 save, and returned to Home. On the clean emulator, legal touch play reached score 800 and the game displayed +100 coins/+1 star/+6 collection XP. Home showed Level 2/100 coins/1 star. Force-stop/relaunch displayed Continue; resuming returned to the saved Level 2/100-coin/1-star Home state.
- Mechanics: existing domain regressions cover invalid swap rollback, zero-move loss, blockers, Sticky Syrup, Fog identity reveal, Rocket, Prism, Cloud Bomb, score/collect objectives, deterministic replay, reward idempotence, Level 20 Kitchen, Level 30 Gallery preview, 30-card state/evolution/equipment/perk and schema 2→3 migration. Undo is not implemented in V1 and was not applicable.
- Accessibility/layout: widget semantic action and 2× text-scale settings tests pass. Android UIAutomator observed 64 labeled/tappable board cells with row/column and selection guidance. API 36 emulator checks at 2× font, portrait cutout and landscape showed no overflow; system TalkBack audio/service was not enabled or assessed.
- Lifecycle/logs: after the emulator victory, Home/background, force-stop/relaunch and Continue restored post-victory progress with no Flutter or Android fatal errors. Mid-level board moves are not persisted; completed-level progress persists.
- Performance: used Flutter integration driver's profile-mode `watchPerformance` on the API 36 emulator after warm-up, with mocked preferences and a board interaction. It captured 122 frames: average/p90 build 0.456/0.663 ms (0 build-budget misses); average/p90 raster 2.024/2.513 ms (1 raster-budget miss). This passes the emulator sample only; it does not replace an S24 benchmark. No ANR or crash occurred.
- Tool gate: `dart format --set-exit-if-changed lib test integration_test test_driver` clean; full Flutter suite 51/51 passed; `flutter analyze` no issues; arm64 Android APK build passed. APK: `C:\Users\LifeN\OneDrive\Desktop\Mr Weeds\App_Game\The Build\MrWeedsCloudKingdom_Issue5_V1_Technical_Preview_arm64.apk`; split arm64-v8a, 116,586,303 bytes; SHA-256 `7798B9D55D4164B172EAE42D24BA6C52DA7B5869273D282C885DBA5CB661967D`. A first test attempt had a test-harness compile/setup issue that was corrected before the green full run.
- S24 physical QA remains blocked by ADB authorization. The prior known owner state was Level 3 / 210 coins / 2 stars; this run did not touch it.

## 2026-11-07 S24 Ultra isolated-package touch QA (additional device evidence)

- **Source:** owner-reported Codex QA results after verified commit `dda1104933c5f06b45dd28c945355008172f3bd8`; GitHub Actions checks passed at https://github.com/Nvisioned38/MrWeedsCloudKingdom/actions/runs/42428249531.
- **Isolation PASS:** Android app package `com.mrweeds.cloudkingdom.qa` installed separately on the S24 Ultra. Production `com.mrweeds.cloudkingdom` and its existing save were untouched.
- **Physical tap controls PASS:** 64 semantically labeled tiles exposed; a legal touch swap on the S24 changed the score 0 → 30 and remaining moves 18 → 17.
- **Phone relaunch observation:** force-stop/relaunch returned to the intro with an **unfinished level**. This does **not** establish mid-level resume. The earlier **emulator** completed-level rewards and progression relaunch remained verified independently.
- **Log smoke PASS:** no recent Flutter/Android fatal errors observed during the described device checks.
- **STILL NOT TESTED physically:** S24 full victory → reward → Cloud House → relaunch, true TalkBack audio semantics, S24 performance, system font scaling, reduced motion, lifecycle/cutouts, and final image/visual sign-off. These must not inherit emulator PASS status.
- **V1 release status:** Technical preview. Mandatory standalone P0 Match-3 tiles, specials/blockers, modular HUD components and other approved original exports still blocked by Issue #4; unchanged gameplay/save schema maintained.

This newer device-specific entry supersedes the older “ADB unauthorized” statement **for the S24 only**. Historical prior QA checkpoints remain recorded above.

## 2026-11-07 S24 Ultra isolated gameplay and accessibility/performance pass

- Device: Samsung SM-S928U, Android API 37, serial R5CX156CZNF.
- Isolation: all mutating checks targeted com.mrweeds.cloudkingdom.qa. A clean QA-only save was used. No install/clear/uninstall command targeted com.mrweeds.cloudkingdom or its existing save.
- Gameplay: five accepted legal swaps cleared Level 1 with score 1,020. Victory showed +100 coins, +1 Star, and +6 Collection XP. Back to Cloud House displayed Level 2, 100 coins, and 1 star.
- Persistence: force-stop/relaunch showed Continue; selecting it restored the same Cloud House progression. The QA package’s Haptics-off and Reduced motion-on settings also survived relaunch.
- Accessibility: UIAutomator showed 64 labeled/clickable board cells with row/column and selection hints. At temporary 2× system font scale the 64 cells and Level 2 objective remained visible; device font scale was restored to 0.9. Settings switches were labeled and clickable. System TalkBack was disabled (accessibility_enabled=0), so spoken announcements were not assessed.
- Performance: profile-mode integration timing, 123 frames: build avg/p90/p99 1.275/2.295/5.882 ms with 0 missed budgets; raster avg/p90/p99 3.290/5.399/8.450 ms with 0 missed budgets.
- After the performance run the regular debug QA APK was reinstalled under the separate QA package ID, preserving package isolation. Gradle applicationId is restored to the production value in the checkout.

## 2026-11-08 Issue #4 integration verification status

- Approval/integration evidence: the owner approved all 37 Batch A/B/C exports. `python tools/verify_issue4_art.py` passed for all 37 exact SHA-256 values, dimensions and RGBA PNG format.
- Current Flutter verification and Android artifact: **NOT RUN in this environment** because `flutter`, `dart`, and `adb` executables are unavailable. GitHub Actions is required to run format, analyze, tests and debug APK build.
- Current Samsung S24 visual/gameplay verification: **NOT RUN**. Prior S24 QA applies to the earlier art baseline; no production app or save was touched in this work. Repeat the loop only on the isolated QA application after obtaining the integrated build.
- V1 is not declared complete. Phase 3 remains unstarted.

- Current build evidence: PR #10 run 42441154111 succeeded; Flutter 3.47.7, 53/53 tests, analyzer clean, Android debug artifact `cloud-kingdom-android-debug-32` (SHA-256 `f58b2bc3938f2f90e15db15b888edebb2cd45fccd541884e0bdb0add34192d9b`). Device-specific rows above refer to earlier APK source and still require a current isolated-package run.

## 2026-11-08 — Issue #6 actual TalkBack testing (in progress)

- Device: Samsung S24 Ultra SM-S928U, serial `R5CX156CZNF`, Android user 0. TalkBack and touch exploration were enabled only for owner-authorized QA. Only `com.mrweeds.cloudkingdom.qa` was launched/updated; the production package was not targeted.
- Owner-reported spoken results: right-swipe navigation on welcome spoke the title, subtitle, Continue button with “double tap to activate,” and Level Path button. Continue announced “Mr. Weed’s Cloud Kingdom QA,” then “Cloud House.” On collection navigation, one earlier focus move announced “tab 2 of 4,” not the Undiscovered card; this needs retest to determine whether it was expected tab navigation or skipped content.
- On Level 1, the pre-fix board was spoken as “unlabeled” before the first named tile. The device accessibility tree confirmed an empty-label, focusable view exactly covering the 8×8 board before the 64 individual cell buttons. Added an explicit “Match-3 board, 8 rows by 8 columns” semantic label and excluded the Flame rendering node from semantics. The rebuilt QA APK was installed using `tools/build_qa_apk.ps1 -Action InstallQa` for user 0 with `-r`; actual owner listening confirmed the board is now announced by name. The rebuilt tree exposes the named board group and 64 named/clickable tile cells.
- Existing QA progress was not reset. The progress entry value remained byte-identical to the pre-reinstall snapshot (749 characters; value SHA-256 `B11238429A13057E52791C982A8C3AA3BC6D61E13E15B04891D9EF4375BBBACB`). Android’s preference XML wrapper changed independently.
- Updated QA build: `com.mrweeds.cloudkingdom.qa`, versionCode 2001, minSdk 24; APK `build/qa/app/outputs/flutter-apk/app-arm64-v8a-debug.apk`; SHA-256 `8b66c3ec47e3ae640af9b901a777f02a65ce2c5a702d430e63e5b7dd5c34a1ef`.
- Verification: focused widget tests passed 8/8; full Flutter suite passed 71/71; `flutter analyze` reported no issues; modified Dart files formatted. Android QA arm64 build and package identity verification passed.
- **Still under test / not yet PASS:** updated title/Close speech on the latest installed APK; victory/results, replay reward and Cloud House announcements; relaunch/resume announcements; restoring the original accessibility settings to off. Do not close Issue #6 or call the V1 accessibility gate complete until these are assessed.
- Follow-up listening confirmed the first cell announcement, its “selected” feedback, the 0/800 objective, and “18 moves remaining.” Commit `9a7dcd2` fixes an unlabeled Close icon and duplicate title semantics. The latest APK is `71c51df5a24a3387bf106a19058caab33580fa1b5ed7372d06459882f5dc287c`. The QA profile’s Level 1 best score changed 1,030→3,100 during testing; coins/stars/XP/completions/unlocks did not change. Owner reports no completed replay; current higher score was retained.
