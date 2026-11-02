# Mr. Weed's: Cloud Kingdom

**MATCH • BUILD • COLLECT • EXPLORE**

Mr. Weed's: Cloud Kingdom is a mobile casual game built around Match-3 gameplay, persistent world-building, collectible characters and strain cards, room customization, mini-games, story progression, secrets, and a larger Mr. Weed's universe.

## Repository status

This repository now contains the complete current Flutter + Flame project synchronized from the owner's authoritative local working project. The synchronized implementation includes the verified Phase 1 game and Phase 2A world, collection, and story foundation. See [`docs/CURRENT_STATE.md`](docs/CURRENT_STATE.md) for the verification record and known boundaries.

The original repository setup notes and Phase 1 baseline are retained as project history. The imported implementation was not recreated from scratch.

## Agent workflow

Before making changes, read:

1. `AGENTS.md`
2. `docs/CURRENT_STATE.md`
3. `00_PROJECT_CHARTER.md`
4. `01_GAME_DESIGN_BLUEPRINT.md`
5. `02_TECHNICAL_ARCHITECTURE.md`
6. Existing code, catalogs, and tests

Codex is expected to continue through approved roadmap work autonomously, testing and documenting each implementation unit, and stop only for the human-decision conditions defined in `AGENTS.md`. Task-specific owner instructions, including an explicit request to pause development, take precedence over automatic continuation.

## Project structure and verification

The Flutter app uses `lib/domain/match3.dart` for deterministic match-3 rules and persisted progress, `lib/game/cloud_board_game.dart` for Flame gameplay rendering and input, and `lib/presentation/` for shared art components and Phase 2A screens. JSON catalogs in `assets/data/` define levels, collectibles, world nodes, characters, and story chapters. Android and web runners, tests, package configuration, and the original project planning documents are included.

Run locally with Flutter installed:

```sh
flutter pub get
flutter analyze
flutter test
flutter run
```

The synchronized checkout passed all 34 automated tests and `flutter analyze` with no issues. Phase 2B and later feature work has not started.
