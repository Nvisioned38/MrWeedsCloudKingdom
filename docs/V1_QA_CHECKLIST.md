# V1 Android QA and Release Gate

This checklist records current automated evidence and a limited Samsung screen smoke. It does not claim full device QA or final visual approval.

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
| Official logos and approved title treatment integrated | PASS | BR-005/006 alpha-bound exports verified pixel-exact to BR-001/002 masters; BR-003 v1 treatment copied unchanged; S24 title/app-shell rendering checked |
| Core P0 Match-3 production tiles, blockers, specials and FX integrated | BLOCKED | v10 approves the concepts, but no isolated source sprites/modular exports were transferred; board remains an explicit technical renderer |
| Cloud House, Lounge and Kitchen source artwork integrated | PASS | 7 intact originals; source hashes, dimensions and v10 approval row IDs in `assets/art/manifest.json`; Home screen rendered on S24 |
| Home → Match-3 → Victory → Cloud House automated flow | PASS | New Game and controlled victory/reward widget tests pass |
| Collection/equipment/evolution runtime states | PASS | Dynamic 30-card UI and progression tests pass; new collection art not yet approved/integrated |
| V1 museum/shelf art states | BLOCKED | Supplement sources have pending new-file sign-off; full Gallery remains preview-only |
| Story scope and spoiler firewall | PASS | Chapters 1–3 retained; no later-story content added |
| Shape cues, reduced-motion and haptics wiring | PASS | Distinct fallback silhouettes; legacy leaf identity is a green spiral-bloom Mystic Bloom; settings control animation/haptic behavior |
| TalkBack, large-text, notches, background/resume device QA | NOT TESTED | Device is connected; these checks remain unrun |
| Android debug APK built, filename and SHA-256 recorded | PASS | Local arm64 technical preview; SHA recorded below |
| Samsung S24 Ultra install, launch and screen smoke | PASS | `adb install -r` updated in place; cold launch, title, Home and Level 3 8×8 board rendered; existing Level 3/210 coins/2 stars retained; no move made |
| Full S24 gameplay/reward/accessibility/performance QA | NOT TESTED | Only layout smoke was performed; no turn or win/reward was triggered |
| Owner final visual sign-off against v10 workbook | BLOCKED | Workbook is read; full V1 art and manual QA gates remain open |
| No generic placeholders on primary V1 path | BLOCKED | Exact logos and isolated Match-3 production sprites are not available |

## 2026-11-07 v10 Android technical preview evidence

- Build: `flutter build apk --debug --target-platform android-arm64` — passed locally.
- APK: `C:\Users\LifeN\OneDrive\Desktop\Mr Weeds\App_Game\The Build\MrWeedsCloudKingdom_V1_Technical_Preview_arm64.apk`
- SHA-256: `33D2FBBD856ECD5E59BA00D7205424B9DC7196033D37ADC2C670DC204174A339`
- APK produced: yes. Installed/updated on Samsung S24 Ultra: yes, with `adb install -r`; no uninstall or data clear. Cloud House reopened with prior Level 3, 210 coins and 2 stars. The game board was viewed but no turn was taken.
- This is a **technical preview**, not a visually accepted V1 release candidate.

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
