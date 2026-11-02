# Current State

## Historical Phase 1 baseline

The original verified Phase 1 project state was recorded as complete before the later Phase 2A work. That gate used Flutter 3.47.7, Dart 3.13.5, Flame 1.38.2, Android application ID `com.mrweeds.cloudkingdom`, and 24 automated tests. It covered the authored ten-level catalog, blocker data, save-data round trips, static analysis, and a debug build.

Historical Phase 1 checkpoint noted in project history: `718b4c9`.

## Current synchronized implementation

The GitHub repository contains the complete current implementation imported from the owner's authoritative local/Codex project at synchronized baseline commit:

`1a96490a0843b9181f28d5ff7d39a41afea7a16e`

The app is an offline Flutter + Flame match-3 game and includes the verified Phase 2A world, collectible, character, and story foundation.

Included project content:

- Flutter and Flame source in `lib/`, including the deterministic match-3 domain, game renderer, Phase 2 models, and presentation screens.
- Android and web runner/configuration files, package manifests, lockfile, analyzer configuration, and Git ignore metadata.
- Level, collectible, world-node, character, and story catalogs under `assets/data/`.
- Existing automated test suite and project planning documents (`00_PROJECT_CHARTER.md` through `05_CODEX_PHASE_1_PROMPT.md`).
- Repository management/control documents.

Generated build outputs, dependency caches, machine-specific Android `local.properties`, and IDE metadata are excluded from version control. The verified local debug APK was left untouched during synchronization.

## Phase 2A verified capability

Phase 2A currently establishes:

- Cloud House hub/exterior and navigation.
- Lounge unlock/world state and customization flow.
- Collection shelf, details, favorites, displayed-card state, and initial 10-card catalog.
- Evolution metadata foundation, but not working XP-driven evolution gameplay yet.
- Character catalog including Mr. Weed, Chef Blaze, The Collector, and other planned recurring characters.
- Chapter 1 playable story foundation.
- Chapter 2 and Chapter 3 present as non-playable teasers.
- Unmarked workshop clue and persisted `keefler_mystery_seen` hook without an explicit Keefler reveal.
- Save schema/migration foundation for Phase 2 state.
- Detailed runtime Match-3 catalog currently loaded for Levels 1–10.
- Crate and Reinforced Crate gameplay support.

Several world nodes remain locked/teasers, art components remain lightweight placeholders, and collectible puzzle abilities are not broadly implemented.

## Verification for synchronized source

Run from the synchronized repository checkout on 2026-11-02:

- `flutter pub get` — passed.
- `flutter test` — passed, all 34 tests.
- `flutter analyze` — passed, no issues found.

The authoritative local Phase 2A debug APK at `build/app/outputs/flutter-apk/app-debug.apk` had SHA-256:

`D444A1F4BBBBC8D75C1648E4164EE7D457DC714449753FD7E4CCE525B26A6059`

before and after synchronization.

## Current authorized phase

**Phase 2B — Progression + Story Build is approved and ready to execute.**

Execution specification:

`06_CODEX_PHASE_2B_PROGRESSION_STORY_BUILD_PROMPT.md`

Roadmap:

`docs/ROADMAP.md`

Build/checkpoint log:

`docs/BUILD_LOG.md`

Phase 2B has been authorized in `AGENTS.md`. At the time of this status update, no Phase 2B code implementation has yet been verified after the synchronized Phase 2A baseline.

Primary Phase 2B targets are:

- playable Levels 11–30;
- playable Chapters 2–3;
- Sticky Syrup and Fog engine support;
- full 30-card launch collectible catalog;
- persisted collection XP and working Seedling → Bud → Frosted → Legendary evolution;
- one equipped card with one deterministic puzzle perk;
- Kitchen milestone at Level 20;
- Higher Art Gallery preview/mystery milestone at Level 30;
- save migration and expanded regression coverage;
- continued mystery continuity without explicit Keefler reveal.

## Next engineering action

A coding agent should pull the latest `main`, read `AGENTS.md`, then execute `06_CODEX_PHASE_2B_PROGRESSION_STORY_BUILD_PROMPT.md` through its full verification gate without routine approval requests.
