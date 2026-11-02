# 05 — Codex Phase 1 Prompt

Use this prompt to begin implementation.

---

You are building the first playable vertical slice of a new standalone Flutter game:

**Mr. Weed's: Cloud Kingdom**

Read these project files first:
- `00_PROJECT_CHARTER.md`
- `01_GAME_DESIGN_BLUEPRINT.md`
- `02_TECHNICAL_ARCHITECTURE.md`
- `03_CONTENT_CATALOG.json`
- `04_LEVELS_001_100.json`

## Phase 1 goal
Build a high-quality, deterministic Match-3 vertical slice containing levels 1–10 inside a Flutter shell.

Do not attempt the whole game yet.

## Technical requirements
- Flutter/Dart
- Flame stable 1.38.x
- Pure-Dart board/domain model separate from Flame rendering
- Offline only for Phase 1
- Local durable persistence
- No Supabase dependency required yet
- No ads
- No purchases
- Portrait-first mobile layout
- Architecture must remain compatible with Android, iOS and web where possible

## Required user flow
1. Splash/boot screen
2. Simple title screen
3. Continue/New Game
4. Cloud House home screen
5. Level-select path for levels 1–10
6. Play a Match-3 level
7. Results screen
8. Award coins + first-clear star
9. Return to world
10. After the designated milestone, restore one Lounge node
11. Present 3 cosmetic choices for that node
12. Save the selected choice
13. Relaunch and restore all progress

## Match-3 engine requirements
Implement:
- 8×8 board
- 5 visually distinct tile families
- adjacent orthogonal swaps
- invalid-swap rollback
- horizontal and vertical matching
- cascades
- gravity
- deterministic refill using seeded RNG
- legal-move detection
- automatic dead-board shuffle
- move counter
- objective tracker
- win/loss
- score
- Crate blocker
- Reinforced Crate blocker if needed by level data
- 4-match Rocket
- 5-match Prism
- T/L Cloud Bomb if practical within Phase 1; otherwise leave a tested extension point

## Animation/game feel
Aim for responsive, cheerful game feel:
- quick swap animation
- clear/pop animation
- subtle particles
- cascade timing
- objective feedback
- restrained haptics hooks
- no animation should block state correctness

Rendering must follow domain state, not become the source of truth.

## Determinism requirement
A test must prove that:
same level definition + same seed + same move sequence = same final board and score.

## Persistence
Persist:
- completed level IDs
- best score
- first-clear star state
- coin balance
- chosen Lounge cosmetic
- settings placeholder

Progress must survive a full process restart.

## Accessibility
- each tile must differ by both color and shape/icon
- reduced-motion setting support point
- haptics toggle support point
- sound/music settings placeholders
- readable objective labels

## Tests required
Unit tests:
- board generation has at least one legal move
- match detection
- invalid swap rollback
- valid swap resolution
- gravity/refill
- cascade
- dead-board shuffle
- Crate damage
- Rocket creation
- Prism creation
- deterministic replay
- level win
- level loss
- reward calculation is idempotent

Widget/integration tests:
- new game → level 1
- finish mocked level → rewards persist
- unlock next level
- Lounge restoration choice persists after restart

## Content
Read level definitions from data rather than hard-coding each level into widgets.
Use `04_LEVELS_001_100.json`, but Phase 1 only exposes levels 1–10.

Placeholder graphics are acceptable in this phase if they are clean, internally consistent, and trivial to replace with final art later.

Do not redraw or invent official Mr. Weed's or Cloud Cup logos. If official brand assets are not present in the repository, use neutral placeholders and clearly mark the asset slots.

## Code quality
- format clean
- analyzer clean
- no ignored failing tests
- document architecture in README
- keep game rules out of UI classes
- avoid giant god objects
- no network requirement

## Completion report
When finished, report:
1. files created/changed,
2. architecture summary,
3. tests and results,
4. exact build/run commands,
5. what is implemented,
6. what is intentionally deferred,
7. any blockers or asset needs,
8. recommended Phase 2.

Do not expand scope beyond this vertical slice until the above acceptance criteria pass.
