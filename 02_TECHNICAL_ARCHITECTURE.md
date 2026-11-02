# 02 — Technical Architecture

## Recommended stack
### Client
- Flutter application shell
- Flame 1.38.x stable for gameplay scenes
- Dart
- Android first
- iOS/web kept portable where dependencies permit

### Suggested packages
Use current stable compatible versions at implementation time.
- `flame` — gameplay loop/components/input/effects
- `go_router` — app navigation
- `flutter_riverpod` — app/game state orchestration
- `drift` + SQLite — durable offline-first local data
- `freezed` / `json_serializable` — immutable data models
- `shared_preferences` — tiny settings only, not progression
- `audioplayers` or `flame_audio` — audio
- `supabase_flutter` — optional account/cloud sync/live-ops backend

Do not store authoritative progression solely in SharedPreferences.

## Architecture boundary

### Flutter owns
- boot
- onboarding
- home/world map
- room decorating
- collection museum
- collection detail
- characters/story
- settings
- accessibility
- account/cloud sync
- store/cosmetics if added later

### Flame owns
- Match-3 board
- tile animation
- swaps
- match resolution
- cascades
- blockers
- special pieces
- objective tracking
- mini-game scenes
- gameplay effects

### Shared domain layer owns
- progression rules
- rewards
- inventory
- level definitions
- collectible definitions
- economy calculations
- save model
- deterministic RNG seed handling

Flame must not directly mutate persistence. It emits a `LevelResult`; the application layer validates and persists rewards.

## Suggested source tree

```text
lib/
  app/
    app.dart
    router.dart
    theme/
  core/
    analytics/
    audio/
    persistence/
    sync/
    rng/
  domain/
    economy/
    progression/
    inventory/
    collections/
    levels/
    world/
  features/
    home/
    world_map/
    decorating/
    collection/
    story/
    settings/
  game/
    cloud_game.dart
    match3/
      board/
      pieces/
      blockers/
      objectives/
      specials/
      systems/
      presentation/
    minigames/
  data/
    catalogs/
    repositories/
```

## Match-3 engine model
Use a pure-Dart board model separate from rendering.

Core classes:
- `BoardState`
- `Cell`
- `Piece`
- `PieceType`
- `Blocker`
- `Swap`
- `MatchGroup`
- `SpecialPiece`
- `ObjectiveState`
- `LevelDefinition`
- `LevelSession`
- `LevelResult`

### Turn pipeline
1. Receive swap.
2. Validate adjacency.
3. Simulate swap.
4. Reject if it creates no match unless a special-combo rule permits it.
5. Resolve matches.
6. Create special pieces.
7. Apply blocker damage.
8. Apply objective progress.
9. Collapse columns.
10. Spawn pieces from deterministic RNG.
11. Resolve cascades until stable.
12. Check win/loss.
13. Recompute legal moves.
14. Shuffle if needed.

## Determinism
Every level session receives a seed.
The same:
- level definition,
- seed,
- move sequence

must produce the same board outcome.

Why:
- reproducible bugs
- automated tests
- replay diagnostics
- fair event challenges later

## Data-driven content
Do not hard-code level logic into widgets.

`LevelDefinition` should include:
- id
- chapter
- board dimensions
- tile families
- initial seed policy
- move limit
- objectives
- blockers
- portals
- tutorial flags
- reward profile
- difficulty band

Catalog files are versioned.

## Persistence
Local database tables/entities:
- player_profile
- settings
- level_progress
- wallet
- inventory
- collectibles
- collectible_progress
- world_nodes
- decor_inventory
- decor_placement
- story_flags
- daily_state
- sync_queue

All reward grants should have an idempotency key.

## Cloud sync
Supabase is optional for the first vertical slice.

Later:
- anonymous/guest local play first
- optional account link
- Postgres stores normalized cloud profile
- Row Level Security
- append-only reward ledger for sensitive currency changes
- sync conflict policy favors validated progression, not blind last-write-wins

## Content delivery
Launch content ships locally.
Future live-ops content can be downloaded as signed/versioned manifests.
Never make the game unusable because the content server is offline.

## Testing gates

### Pure Dart unit tests
- swap validation
- match finding
- cascade resolution
- special creation
- special combinations
- blockers
- objectives
- deterministic seed replay
- no-move shuffle
- reward calculations

### Flutter tests
- navigation
- world-map unlock states
- collection filters
- decorating choices
- save/reload

### Integration tests
- complete a level → rewards persisted
- restore room → relaunch → state preserved
- offline progression → later sync

## Performance targets
- 60 FPS target on supported mainstream Android devices
- board input latency should feel immediate
- object pooling for frequently created effects where useful
- sprite atlases for board pieces
- avoid unnecessary Flutter rebuilds around active Flame scenes

## Accessibility
- color + shape differentiation on every tile
- reduced motion
- haptics toggle
- music and SFX sliders
- scalable UI text outside the board
- objective icons paired with numbers/text
- no essential information communicated by color alone

## Security / policy boundary
The game contains fantasy/collectible cannabis-culture themes only.
Do not include:
- ordering or sales of cannabis,
- pickup/delivery facilitation,
- dosage guidance,
- cultivation instructions,
- medical claims.

Keep the game economically and technically separate from any real-world regulated commerce.
