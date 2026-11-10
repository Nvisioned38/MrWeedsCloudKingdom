# V1 Match-3 animation implementation handoff

**GitHub:** [Issue #19](https://github.com/Nvisioned38/MrWeedsCloudKingdom/issues/19)  
**Branch:** `animation/issue-19-stage-a` (created from `main` at `c6229e5c5ba154021e4bc44286b1c4e842497c33`)  
**Deliverable:** tactile, readable, deterministic Android Match-3 animation. **Stage A must be implemented and verified before Stage B.**

## Current technical reality, verified from code

- `lib/domain/match3.dart`: `Match3Board.resolveSwap` computes a swap, match waves, crate/condition damage, gravity, refill, cascades and possible shuffle **synchronously**. `LevelSession.swap` then immediately updates moves, objectives and outcome.
- `TurnResult` has an **aggregate** `cleared`, `changedCells`, score and `cascadeCount`, but **no per-wave tile positions, distinct gravity trajectories or refill sources**. The aggregate cannot truthfully reconstruct sequential falling.
- `lib/game/cloud_board_game.dart` currently draws the **already-resolved final board**, briefly overlays swapped starting pieces for ~0.28 seconds, and uses a simple resolving gate. It does not render a true match → gravity → refill event timeline; invalid swaps just reselect the second cell.
- The 37 approved Issue #4 standalone PNGs are integrated. Existing `CloudKingdomPngBoardRenderer`/fallback and the Issue #14 animation/render QA fixtures provide a starting point.
- `main` currently contains approved Batch 5 collectible **approval documentation**, but Batch 5 binaries/runtime integration are a separate project. Do not import those images as part of animation.
- [PR #18](https://github.com/Nvisioned38/MrWeedsCloudKingdom/pull/18) (TalkBack improvements) is a **draft, unmerged and paused**. Keep all 64 semantically labeled cells and event callbacks intact; don't merge, cherry-pick or duplicate the paused accessibility branch in this animation scope.

## Stage A: motion before additional effects (P0)

### A0. Trace only; preserve the engine

Add an optional, ephemeral **turn animation trace** that observes the engine's existing resolution path. Do not write an independent Match-3 resolver in the view and do not change matching, RNG order, seed, scoring, blockers, special creation, shuffle fairness, move counts, objectives, save schema 3, or LevelSession outcome rules.

The trace needs enough immutable information to render:
1. Source/destination cells and the two **original pieces** on attempted swap.
2. Acceptance/rejection; invalid swap creates **no logical move** or board mutation.
3. For each resolved match/cascade wave in real order: the **pre-clear board state**, cleared positions and pieces, created/triggered specials, damaged/destroyed crate states, Fog/Syrup changes, and post-clear state.
4. Each gravity displacement `source Cell → destination Cell`, with the piece snapshot and per-column blocker/Syrup segment bounds; refill spawns must include their actual destination/family and a visual origin just beyond the segment top, not a newly chosen random tile.
5. Optional shuffle stage if the existing `shuffleUntilPlayable` fires, so no visual teleport without feedback.
6. The final existing engine board state, `TurnResult`, and `LevelSession` outcome.

**Important implementation detail:** `Piece` has no persistent unique ID. Record movement source/destination *inside the existing gravity/refill traversal* or use animation-only turn-local IDs, so repeated identical families are never guessed by comparing final screenshots. No trace fields are serialized or stored in preferences. Tracing must not make any extra RNG calls.

Prefer immutable DTOs / optional callbacks as observation-only code. Keep a non-tracing fast path and deterministic seeded regression comparisons: tracing ON vs OFF must yield identical tiles/specials/blocker HP, score, moves, objectives, outcome and RNG-driven refill on the same legal/invalid moves.

### A1. Flame presentation timeline

Separate **logical state** from **presentation state**: after `session.swap` the engine has finished, but during playback render from immutable turn snapshots and event stages, not immediately from final `session.board`. Prevent both duplicate starting pieces and final-board tiles showing underneath moving tiles.

Sequence: selection press → accepted swap travel → match shrink/fade/sparkle → gravity travel → refill appear/drop → next cascade, if any → settled board → UI callback/result navigation. For rejected adjacent swap, briefly travel toward neighbor and ease back; keep score, moves and board unchanged. For nonadjacent selections, keep existing selection semantics and avoid fake swap animation.

Use easing, scales and alpha transitions suitable for a handheld 8×8 grid. Initial target durations may be tuned by S24 visual review, for example swap 120–180 ms, clear 90–150 ms, drops 120–220 ms and invalid return 120–180 ms. Prefer a clear readable cadence to arbitrary fixed delays; bound long-cascade total playback and cap effects work per frame without skipping required final-state reconciliation.

The existing `onTurn` invokes `_finish()` and navigates to Results for terminal turns. **Delay only the presentation/navigation until the animation completes**, and guarantee exactly one award/save/result transition. If the app is paused, backgrounded, closed, rotated or unmounted during playback, cancel all scheduled FX/continuations safely and reconcile to authoritative resolved board/state on reentry. Avoid reentrant `onTurn`, setState-after-dispose, and leaked `ui.Image` resources.

### A2. Input, accessibility and Reduced Motion

A single animation-busy gate must apply to **both** Flame touch callbacks and the 64 Flutter semantic cell actions; rapid tap spam cannot cause second moves mid-resolution, phantom selections or duplicate results.

Preserve 64 accessible cell positions and names. Do not hide/delete semantic controls just because sprites are travelling. Keep board group and selection/state feedback compatible with later PR #18 integration, but **pause actual spoken TalkBack acceptance** until the owner resumes Issue #6.

Reduced Motion: minimal or zero travel, no strobing or full-screen flashes, still-visible short completion indication and correct goal/reward progression. Respect haptics-off, background/resume, screen sizes/cutouts, and large-text 0.9–2× without shifting hitboxes.

### Stage A tests and checkpoint

- Seeded game-state equivalence with animation trace ON/OFF for accepted, invalid, repeated-family gravity, segmented columns with crates/sticky tiles, multicascades, special-triggered clears, and possible shuffle.
- Trace ordering and movement/source/cell content assertions, no phantom/duplicate pieces, and end-snapshot equality with actual engine result.
- Frame/time simulation for rejected rollback, accepting move, fast tap debounce including semantic taps, selected/deselected feedback, Reduced Motion, cancellation/pause/disposal and terminal outcome navigation exactly once.
- No changes to all 30 authored levels, rewards/schema/currency, 64 labeled board controls, official art hashes or full 37/37 verification.
- Format, analyzer, full Flutter suite (baseline **71**), Android arm64 QA build/identity, CI artifacts, and **isolated `com.mrweeds.cloudkingdom.qa` only** manual S24 review with recorded FPS/frame pacing, screen clips and screenshots. Never touch production install/save or Secure Folder.
- **Checkpoint:** Finish Stage A, push, and report exact evidence. Do not present it as finished if only a pre-swap crossfade was implemented.

## Stage B: code-driven power-up/combination FX (after Stage A passes)

Art direction: magical yet legible, **white smoke** as default, restrained particle counts, no leaves (except Secret Basement), no crowns and no unapproved logo reinterpretation. Use approved Issue #4 `fx_white_smoke_01..03`, `fx_cascade_streak`, `fx_combo_ring`, `fx_magic_sparkles`, `butane_torch_lighter`, `prism`, `cloud_bomb`, Cloud Cup vaporizer and canonical logo as *separate* unchanged overlays.

- Torch (`SpecialKind.rocket` legacy ID): directional row/column warm fire trail along actual cleared path; do not change rocket mechanics.
- Prism: color-target pulse on selected matching family only, using recorded engine target/coverage.
- Cloud Bomb: soft radial/white-smoke burst centered on actual affected cells.
- Cloud Cup vaporizer: localized white-smoke fade with exact standalone official logo overlay **only if the corresponding power-up action exists**. Do not invent a new paid mechanic, booster charge or gameplay rule just to show FX; record absent mechanics as precise blockers.
- MW Crate/reinforced MW Crate: readable crack→break states; Fog reveal, Sticky Syrup clear when present in QA fixture; modest combo/cascade celebration.
- Reuse existing approved alpha art and programmatic Tween/Flame particle/opacities first. Produce new transparent frames **only** when clearly necessary, through the separate approved art workflow.
- Bound particles and simultaneous effects for S24; pause and dispose safely; Reduced Motion alternative; no color-only cues.

Because Fog/Syrup and some specials aren't used in authored V1 Levels 1–30, verify via **isolated, test-only fixtures**, not production-level modification or secret shipping debug screens.

## Delivery and boundaries

1. Codex starts from latest verified `main` and existing `animation/issue-19-stage-a` branch. Keep the animation branch independent of paused accessibility PR #18, remaining issue #6 and score provenance issue #17.
2. Implement Stage A first, commit and push tests and demonstrations, then open/update a **draft** PR for animation. Run complete GitHub checks before merging; do not merge merely because a PR is open.
3. Stage B begins after Stage A's true engine-trace/tween acceptance and owner-facing S24 review. Separate logical commits/PRs are preferred.
4. Store `docs/evidence/issue19/` results, identify **code-driven vs standalone alpha-sprite** effects, include side-by-side normal/reduced-motion evidence and real device timing without claiming tool-only tests are physical QA.
5. No Phase 3, no Level 31+, no later Troll betrayal/Nave/Copycat/Keefler reveal, no new commerce, no schema or animation-derived save fields. Batch 5 collection art import remains separately queued.

**Definition of done:** Match-3 play is genuinely animated through existing deterministic waves, accessible tapping and saved rewards stay correct, approved art is pixel-unmodified, and Android QA records trace/checksum/full-loop verification. V1 remains a technical preview until explicit visual owner sign-off.
