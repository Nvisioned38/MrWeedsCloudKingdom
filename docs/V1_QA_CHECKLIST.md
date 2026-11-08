# V1 Android QA and Release Gate

This checklist records automated evidence and isolated S24 physical QA. Final visual and artwork sign-off remain open.

## Status legend

**NOT TESTED** = no current evidence; **PASS** = tested and documented; **PARTIAL** = evidence exists but scope is incomplete; **FAIL** = defect; **BLOCKED** = waiting on owner device / other dependency.

| Gate | Status | Evidence / commit / device |
|---|---|---|
| Resolve GitHub Issue #1 and regression for Level 30 Chapter 3 finale dialogue | PASS | Pulled `edcf151`; 29/30 and 30/30 story gate and save round-trip covered in tests |
| Format clean | PASS | `dart format lib test` and `--set-exit-if-changed` |
| `flutter analyze` no issues | PASS | Flutter 3.47.7, 2026-11-07 |
| Full Flutter test suite | PASS | 51 tests passed, including progression, mechanics, migration, reward/save round-trip, board semantics and large-text widget coverage |
| 30-level catalogue and progression unaffected | PASS | Existing catalog and progression tests pass |
| Save schema 3 upgrade/restart/reset/perk persisted | PASS | Phase 2B migration and round-trip tests pass; schema remains 3 |
| Official logos and approved title treatment integrated | PASS | BR-005/006 alpha-bound exports verified pixel-exact to BR-001/002 masters; BR-003 v1 treatment copied unchanged; S24 title/app-shell rendering checked |
| Approved Mr. Weed character portrait integrated | PASS | v10 CS-001 `MW_img_CS-001b.png` copied byte-identically; CH-001 OK-gesture/blank-shirt notes traced; S24 Story character catalog rendered it |
| Core P0 Match-3 production tiles, blockers, specials and FX integrated | BLOCKED | v10 approves the concepts, but no isolated source sprites/modular exports were transferred; board remains an explicit technical renderer |
| Cloud House, Lounge and Kitchen source artwork integrated | PASS | 7 intact originals; source hashes, dimensions and v10 approval row IDs in `assets/art/manifest.json`; Home screen rendered on S24 |
| Home → Match-3 → Victory → Rewards → Cloud House | PASS | Widget route plus S24 QA package: score 1,020, +100 coins/+1 star/+6 XP, Level 2 / 100 coins / 1 star in Home; Continue restored the same state after force-stop/relaunch |
| Collection/equipment/evolution runtime states | PASS | Dynamic 30-card UI and progression tests pass; new collection art not yet approved/integrated |
| V1 museum/shelf art states | BLOCKED | Supplement sources have pending new-file sign-off; full Gallery remains preview-only |
| Story scope and spoiler firewall | PASS | Chapters 1–3 retained; no later-story content added |
| Shape cues, reduced-motion and haptics wiring | PASS | Distinct fallback silhouettes; legacy leaf identity is a green spiral-bloom Mystic Bloom; settings control animation/haptic behavior |
| TalkBack cell semantics | PASS | S24 hierarchy exposed 64 named/clickable cells with row/column and selection hints; semantic widget action test passes. System TalkBack service was off; spoken output not assessed |
| Large text, portrait cutout and landscape layout | PASS | S24 at temporary 2× system text scale retained all 64 board cells and the Level 2 objective; font scale restored to 0.9. Emulator landscape/cutout checks also pass |
| Background/resume lifecycle | PASS | S24 completed-level force-stop/relaunch showed Continue and restored Level 2/100 coins/1 star; no fatal logs. Mid-level board state is not saved by design |
| Profile-mode emulator performance | PASS | Warm `watchPerformance` sample of 122 API 36 emulator frames: avg/p90 build 0.456/0.663 ms; avg/p90 raster 2.024/2.513 ms; 0 build-budget misses and 1 raster-budget miss |
| Physical S24 Ultra performance | PASS | S24 API 37 profile run, 123 frames: build avg/p90/p99 1.275/2.295/5.882 ms, 0 misses; raster 3.290/5.399/8.450 ms, 0 misses |
| Android debug APK built, filename and SHA-256 recorded | PASS | Local arm64 technical preview; SHA recorded below |
| Samsung S24 Ultra install, launch and screen smoke | PASS | Installed/launched separate package com.mrweeds.cloudkingdom.qa on SM-S928U/API 37; production app package was not targeted by mutating commands |
| Full isolated gameplay loop on Android | PASS | Emulator and S24 QA package completed Level 1, reward and Home flow; S24 reached 1,020 and restored Level 2/100 coins/1 star after relaunch |
| S24 physical gameplay/reward/accessibility/performance QA | PARTIAL | Gameplay, rewards, saved progression, semantic cells, 2× text, settings persistence and profile timing passed. Spoken TalkBack output was not assessed because the service was off |
| Owner final visual sign-off against v10 workbook | BLOCKED | Workbook is read; full V1 art and manual QA gates remain open |
| No generic placeholders on primary V1 path | BLOCKED | Exact logos and isolated Match-3 production sprites are not available |

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
