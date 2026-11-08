# V1 release readiness: independent engineering track

**Current classification: TECHNICAL PREVIEW.** This document is a working gate, not a declaration that V1 is visually signed off or approved for Google Play.

Engineering branch: `engineering/v1-release-readiness`  
Task: [Issue #8](https://github.com/Nvisioned38/MrWeedsCloudKingdom/issues/8)  
Art branch being developed independently: `art/issue-4-approved-bc-intake` ([Issue #4](https://github.com/Nvisioned38/MrWeedsCloudKingdom/issues/4))  
Spoken screen-reader gate: [Issue #6](https://github.com/Nvisioned38/MrWeedsCloudKingdom/issues/6)

## Release classification

| Build type | Intended use | Current status |
|---|---|---|
| Technical-preview debug APK | Development, internal testing, known missing or unmerged visuals | **Supported / verified on S24** |
| Isolated QA debug APK | Separate app `com.mrweeds.cloudkingdom.qa`, disposable save, repeatable test install | **Proved in manual QA session; repeatable automated build not yet implemented** |
| V1 release candidate | All v10-approved required sprites integrated, tested, accessible, and accepted on S24 | **Blocked / not yet delivered** |
| Google Play-distributable build | Owner signing, versioning, store-content and platform reviews, acceptance | **Not authorized/verified by this document** |

## Immutable app state and user-data boundaries

- Production package: `com.mrweeds.cloudkingdom`.
- QA package: `com.mrweeds.cloudkingdom.qa`.
- Production Samsung S24 Ultra save has been preserved across in-place upgrade checks. Do not uninstall, reset, delete, clear, or mutate production app data during engineering QA.
- Existing save schema 3 and `cloud_kingdom_progress_v2` key remain stable; preserve migration from schema 2.
- Do not imply an unfinished level resumes on relaunch; only completed-level progress persistence was demonstrated.
- All future QA must identify the **actual installed package** in APK metadata before installation, and refuse any QA-targeted installation if metadata shows the production package.
- Prefer isolated emulator or `.qa` package for any mutating gameplay, reward, or New Game test.

## Verified test evidence as of 2026-11-07

- `dda1104933c5f06b45dd28c945355008172f3bd8`: Isolated Android QA/board semantics, 51 Flutter tests, analyzer clean, arm64 debug APK build.
- `d106668cf53fa570e4e1da9759d2110d5f75da7e`: QA documentation verified by [GitHub Actions #22](https://github.com/Nvisioned38/MrWeedsCloudKingdom/actions/runs/42433703369).
- Actual separate `.qa` installation on S24: level 1 score 1,020, +100 coins, +1 star, +6 collection XP; Cloud House Level 2 progress restored by Continue after force-stop/relaunch; 64 labeled cells; 2× font; settings persisted; 123 profile frames with **zero misses**.
- **NOT VERIFIED:** Actual spoken TalkBack announcements/gestures/focus behavior because phone TalkBack service was disabled.
- **Art in flight:** [Issue #4 branch](https://github.com/Nvisioned38/MrWeedsCloudKingdom/tree/art/issue-4-approved-bc-intake) has 37 independent PNG exports and board-renderer changes. Its [branch CI](https://github.com/Nvisioned38/MrWeedsCloudKingdom/actions/runs/42435828720) passed, but the artwork branch has **not been merged into `main`**; do not count its new art as distributed in main's APK.

## Engineering tasks for this branch

| Gate | Status | Owner / required evidence |
|---|---|---|
| Repeatable isolated `.qa` build with correct identity | NOT TESTED | Codex, Issue #8: choose safe separate build path, verify APK manifest |
| Default debug build still uses exact production ID | NOT TESTED AFTER QA BUILD CHANGE | Codex, Issue #8 |
| Build metadata and SHA recorded for each variant | NOT TESTED | Codex, Issue #8 |
| Reliability regressions (partial/corrupt save, reward idempotence, offline startup) | PENDING TEST GAP AUDIT | Codex, Issue #8; don't duplicate existing tests |
| Android app permission/signing/version checks | PENDING AUDIT | Codex, Issue #8; no owner Play/release key |
| Match-3 art export manifests + all 37 SHA checks on merged branch | BLOCKED UNTIL ART PR | Art team, Issue #4 |
| Board sprite composition, safe areas, overlay/tile states and responsive 8×8 device fit | BLOCKED UNTIL ART PR | Art team + QA, Issue #4 |
| Actual spoken TalkBack semantics and navigation on QA package | NOT TESTED | Issue #6, needs accessibility service and listening |
| Full 30-level gameplay/regression and spoiler restrictions | PARTIALLY AUTOMATED | Codex: audit catalog/test coverage, preserve gates |
| S24 full win/reward/save restore without touching production | PASS | Separate QA package, 2026-11-07 |
| Original brand logo/character identity integrity | PASS FOR CURRENT MAIN ASSETS | Pixel-exact v10 logos/portrait/room exports; final art merge still to check |
| Final owner visual acceptance | BLOCKED | Not asserted by engineering or CI |

## Notes for safe parallel development

1. **Never alter the art team's branch or independently merge it.** Its `main.dart`, `cloud_board_game.dart`, `pubspec.yaml`, test/widget files, and CI workflow overlap with shared integration work.
2. Keep implementation of Issue #8 confined to Android packaging, new isolated scripts/tests, and this release QA doc where possible. Do not write into the art team's file list.
3. If a CI workflow addition is needed, stage the instructions in this document; postpone the edit to `.github/workflows/v1-android-preview.yml` until the Issue #4 art branch merges or an explicit conflict-free integration PR is ready.
4. Do not merge debug-signed release builds into a public distribution workflow. Current Android `release` build uses the debug signing config as a development convenience, not an owner signing setup.
5. Record PASS/FAIL/BLOCKED only from an actual test run; do not infer device pass from Flutter widget tests, or asset approval from the presence of PNGs.
6. Merge/check integration after successful art QA. Re-run all checks for the merged commit and compare visual/source manifest hashes.
7. Scope remains Phase 2C first polished playable V1. Do not introduce Levels 31+, Phase 3, villain betrayals, Lord Nave, Copycat Cloud Co., Cloud Bottle, or Keefler Elves revelations.

## Definition of done for Issue #8

A reproducible and tested QA build procedure that cannot accidentally target the production save; clean default production debug build; focused reliability/packaging tests; release evidence table updated with real values; clean CI/PR; no art-branch conflicts. The **polished V1 final release** still requires separate Issue #4 art and Issue #6 TalkBack acceptance.
