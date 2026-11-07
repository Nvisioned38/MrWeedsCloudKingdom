# Current State

## Historical verified baselines

The original verified Phase 1 project state used Flutter 3.47.7, Dart 3.13.5, Flame 1.38.2, Android application ID `com.mrweeds.cloudkingdom`, and 24 automated tests. It covered the authored ten-level catalog, blocker data, save-data round trips, static analysis, and a debug build. Historical checkpoint: `718b4c9`.

The complete local/Codex project was synchronized to GitHub as the Phase 2A baseline at `1a96490a0843b9181f28d5ff7d39a41afea7a16e`. That verified baseline passed 34 tests and `flutter analyze` with no issues. Its debug APK SHA-256 was `D444A1F4BBBBC8D75C1648E4164EE7D457DC714449753FD7E4CCE525B26A6059`.

## Current implementation — Phase 2B

Phase 2B progression and story systems are implemented and verified on top of the synchronized baseline.

- Flutter + Flame source, Android and web runner/configuration files, assets, tests, dependency manifests, and project documentation are retained in the repository.
- Runtime level catalog now spans Levels 1–30. Levels 1–10 retain their authored behavior; Levels 11–20 are Chapter 2 and Levels 21–30 are Chapter 3. All levels use deterministic seeds and supported objectives. Any unsupported master-map intent is retained as source metadata while runtime goals use implemented mechanics.
- Sticky Syrup prevents tile movement until an adjacent qualifying clear; Fog hides but preserves tile identity until an adjacent qualifying clear. Both states are rendered with non-color cues. Existing Crate and Reinforced Crate behavior remains supported.
- All 30 stable collectible identities are represented. Collection XP is persisted, centralized thresholds drive Seedling → Bud → Frosted → Legendary, and one unlocked card can be equipped.
- The active deterministic perk is Cloud Nine's +150 starting score. It is small, seed-independent, easy to communicate, and cannot make a board less solvable. Other ability copy remains informational.
- Schema 2 saves migrate to schema 3, preserving prior progress and adding collection XP, per-card XP/evolution, equipped card, and Level 20/30 milestone state. New Game resets the new fields.
- Chapters 2 and 3 are playable at their progression gates, featuring Chef Blaze and The Collector. Level 20 unlocks the Kitchen milestone; Level 30 awards its key/milestone and previews the Higher Art Gallery without marking the full Gallery complete.
- The unmarked workshop and `keefler_mystery_seen` continuity remain. No Keefler Elves reveal or Cloud Cup/CannaTapper explanation was added.

## Phase 2B verification

Verified from the synchronized GitHub checkout:

- `flutter pub get` — passed.
- Formatting — applied with `dart format lib test`.
- `flutter analyze` — passed, no issues found.
- `flutter test` — passed, all 43 tests.
- `flutter build apk --debug` — passed; output: `build/app/outputs/flutter-apk/app-debug.apk`.
- Save schema 2 → 3 migration, XP/evolution, equipment persistence/perk, New Game reset, 30-level catalog, blocker mechanics, and milestone progression are covered by regression tests.

The Gradle build emitted an Android SDK XML version compatibility warning, but the debug APK completed successfully.

## Current phase and next action

**Phase 2B — VERIFIED / COMPLETE.** The next roadmap item is Phase 2C — Visual identity + branded asset integration, which remains planned and is not authorized for autonomous implementation. Do not start Phase 2C until it is explicitly approved.

## 2026-11-06 Phase 2C coordination update (no new build verification claimed)

The owner has prioritized the first visually polished, playable Android V1 before any expanded story chapters. **Phase 2C is authorized for engineering stabilization, infrastructure, and integration of available verified approved original art** per `07_CODEX_PHASE_2C_V1_IMPLEMENTATION.md`. The detailed V1 asset-intake and QA gate are `docs/V1_ASSET_INTAKE.md` and `docs/V1_QA_CHECKLIST.md`.

**Latest verified *code* baseline remains `10ca8a5b0bdcb086c294785544d40732a16ef524`.** No Phase 2C implementation, new tests, original-art imports, device installation, or new Android APK has been verified by this documentation-only change.

**Outstanding from code review:** GitHub Issue #1 is still OPEN: Chapter 3's final gallery dialogue beat is gated at Level 31 while the playable level path caps at 30. Fix this in 2C-0 before broad UI polish.

**Artwork readiness:** `assets/` contains only `data/`; `assets/art/` masters/production exports are not present in GitHub. The user names a v9 `Brand and V1 Priorities` review tracker as the current approval authority, but its actual workbook is not in the repository; only earlier contextual notes can presently be consulted. Obtain v9 and the original approved image files before claiming any per-row approval and before visually integrating protected art. There is no authorization to redraw logos, Mr. Weed, characters, locked environments, tiles, or any original asset.

**Narrative scope:** retain Chapters 1–3 and subtle workshop mystery only. Troll betrayal, Lord Nave, Copycat Cloud Co., the Cloud Bottle, and Keefler Elves revelations remain later-game material.

**Next action:** Codex pulls latest `main`, reads `AGENTS.md` and the Phase 2C files, fixes Issue #1, then implements all unblocked V1 art infrastructure with format/analyze/test/build checks. Final integration of a specific art asset waits for the original and v9 approval evidence, not for routine engineering approvals.
