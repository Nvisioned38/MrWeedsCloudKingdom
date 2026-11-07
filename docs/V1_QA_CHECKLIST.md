# V1 Android QA and Release Gate

This checklist records the latest automated/local evidence. It does not claim Samsung device QA or final visual approval.

## Status legend

**NOT TESTED** = no current evidence; **PASS** = tested and documented; **FAIL** = defect; **BLOCKED** = waiting on original art / owner device / other dependency.

| Gate | Status | Evidence / commit / device |
|---|---|---|
| Resolve GitHub Issue #1 and regression for Level 30 Chapter 3 finale dialogue | PASS | Pulled `edcf151`; 29/30 and 30/30 story gate and save round-trip covered in tests |
| Format clean | PASS | `dart format lib test` and `--set-exit-if-changed` |
| `flutter analyze` no issues | PASS | Flutter 3.47.7, 2026-11-07 |
| Full Flutter test suite | PASS | 48 tests passed, including manifest, renderer, progression, migration, and widget regressions |
| 30-level catalogue and progression unaffected | PASS | Existing catalog and progression tests pass |
| Save schema 3 upgrade/restart/reset/perk persisted | PASS | Phase 2B migration and round-trip tests pass; schema remains 3 |
| Original official logos exactly integrated and visually correct | BLOCKED | Original sources missing from repo |
| Core P0 Match-3 tiles, blockers, specials and FX integrated | BLOCKED | Only composite board/UI references are present; isolated source sprites and v9 evidence are missing |
| Cloud House, Lounge and Kitchen source artwork integrated | PASS | 7 intact room/preview originals; source hashes, dimensions and audit references in `assets/art/manifest.json`; v9 workbook and device sign-off remain open |
| Home → Match-3 → Victory → Cloud House automated flow | PASS | New Game and controlled victory/reward widget tests pass |
| Collection/equipment/evolution runtime states | PASS | Dynamic 30-card UI and progression tests pass; new collection art not yet approved/integrated |
| V1 museum/shelf art states | BLOCKED | Supplement sources have pending new-file sign-off; full Gallery remains preview-only |
| Story scope and spoiler firewall | PASS | Chapters 1–3 retained; no later-story content added |
| Shape cues, reduced-motion and haptics wiring | PASS | Distinct fallback silhouettes; legacy leaf identity is flower-shaped Mystic Bloom; settings control animation/haptic behavior |
| TalkBack, large-text, notches, background/resume device QA | NOT TESTED | Requires authorized Android device |
| Android debug APK built, filename and SHA-256 recorded | PASS | Local arm64 technical preview; SHA recorded below |
| Samsung S24 Ultra install/launch/gameplay manually verified | BLOCKED | Device `R5CX156CZNF` is detected as `unauthorized` by ADB |
| Owner final visual sign-off against v9 workbook | BLOCKED | v9 original workbook is not in the accessible workspace |
| No generic placeholders on primary V1 path | BLOCKED | Exact logos and isolated Match-3 production sprites are not available |

## 2026-11-07 local technical preview evidence

- Build: `flutter build apk --debug --target-platform android-arm64` — passed locally.
- APK: `C:\Users\LifeN\OneDrive\Desktop\Mr Weeds\App_Game\The Build\MrWeedsCloudKingdom_V1_Technical_Preview_arm64.apk`
- SHA-256: `FEEEEC74227290089EAB57B56D82E3611375C7614A46C7B5FCAC12E8EC13DEA4`
- APK produced: yes. Installed on Samsung S24 Ultra: no; ADB authorization is pending on the handset.
- This is a **technical preview**, not a visually accepted V1 release candidate.

## Manual Samsung S24 Ultra pass

1. Install V1 preview debug APK **without uninstalling an existing progress-bearing build** when testing migration. Back up save if needed; do not overwrite or clear user progress during automated checks.
2. Launch fresh install/new game and use the normal portrait orientation. Verify official logos and scaling around cutouts.
3. Start Level 1, complete a level, watch Victory, ensure stars/coins/progress appear in the Cloud House hub.
4. Play a representative blocker/special level, verify tile contrast/shape cues, animation, sound/haptics and reduced motion.
5. Restore Lounge, view Kitchen milestone around Level 20, verify Gallery is preview only after Level 30.
6. Open Collection, equip Cloud Nine, confirm +150 start score and saved equipment; inspect card, rarity, evolution and shelf.
7. Inspect Chapters 1–3 and ensure Chapter 3 closing dialogue is reachable after finishing Level 30, not sooner.
8. Background/relaunch the app and confirm all progress remains. Check Settings and navigation.
9. Review all P0 approved artwork against the actual v9 sign-off package and mark each individually accepted or needs revision.
10. Record APK SHA-256, Android OS/device info, build commit, manual pass/fail notes, screenshots if supplied, and final sign-off.

**A compiled APK is not proof of a successful Samsung S24 Ultra installation or player experience.**
