# V1 Android QA and Release Gate

This is a **working checklist**, not a claim that tests have run in the current Phase 2C session. Codex updates statuses with evidence at each checkpoint.

## Status legend

**NOT TESTED** = no current evidence; **PASS** = tested and documented; **FAIL** = defect; **BLOCKED** = waiting on original art / owner device / other dependency.

| Gate | Status | Evidence / commit / device |
|---|---|---|
| Resolve GitHub Issue #1 and regression for Level 30 Chapter 3 finale dialogue | NOT TESTED | |
| Format clean | NOT TESTED | |
| `flutter analyze` no issues | NOT TESTED | |
| Existing 43 tests pass, plus all newly added tests | NOT TESTED | |
| 30-level catalogue and progression unaffected | NOT TESTED | |
| Save schema 3 upgrade/restart/reset/perk persisted | NOT TESTED | |
| Original official logos exactly integrated and visually correct | BLOCKED | Original sources missing from repo |
| Core P0 Match-3 tiles, blockers, specials and FX integrated | BLOCKED | Original sources missing from repo |
| Cloud House, Lounge and Kitchen originals integrated | BLOCKED | Original sources missing from repo |
| Home → Match-3 → Victory → Cloud House flow polished and responsive | NOT TESTED | |
| Collection/equipment/evolution and V1 museum/shelf states | NOT TESTED | |
| Chapter 2/3 story visuals correct; no future spoilers | NOT TESTED | |
| Accessible labels / shape cues / large text / reduced motion | NOT TESTED | |
| Portrait notches and safe areas, scaling, background/resume | NOT TESTED | |
| Android debug APK built, filename and SHA-256 recorded | NOT TESTED | |
| Samsung S24 Ultra install/launch/gameplay manually verified | BLOCKED | Requires device session or owner's results |
| Owner final visual sign-off against v9 workbook | BLOCKED | v9 original workbook and source masters required |

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
