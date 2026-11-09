# V1 Match-3 Animation Timing & Layering Spec (Codex implementation proposal)

**Source approval:** [Eight FX sheets locked visually](MATCH3_ANIMATION_FX_BATCH1_HANDOFF.md). Timing values below are **proposed engineering defaults for playtesting**, not new owner-approved artwork or evidence of integrated behavior. Ensure gameplay engine owns truth, not sprite playback.

## Deterministic event pipeline

1. User selects adjacent tile: overlay highlight only; no board mutation.
2. Valid swap: interpolate pixel position in render layer, logical swap still handled by existing engine.
3. Invalid swap: interpolation out and back with gentle bounce. Logical state unchanged; do not consume a move.
4. Resolve matches: matched pieces brighten, shrink/fade, and spawn existing approved sparkle FX without blocking the final score state.
5. Resolve blockers: render current block damage states and appropriately keyed particle; use crate/break frames only when engine reports damage/break.
6. Fall/refill: animate only actual gravity and spawn positions from engine-provided board result. Never generate random visual tile types unrelated to the seed.
7. Cascade: repeat reveal/clear/gravity sequence; keep events in ordered queue. Debounce touch while processing.
8. HUD: animate objective, stars, moves and reward numbers based on model values, not baked frames.
9. Screen exit/pause: cancel visual timeline cleanly and snap to authoritative board state. No lost save.

## Suggested timing targets (tunable; avoid fixed-delay logic in tests)

| Trigger | Suggested motion duration | Visual treatment | Audio/haptic |
|---|---:|---|---|
| Tile selection | 90–120 ms | Scale 1.0 → 1.06, glow ring | Subtle tap |
| Legal swap | 160–220 ms | Both sprites translate, smooth ease | Tiny tick |
| Invalid rollback | 120–170 ms out + return | short overshoot; no new random tile | soft reject |
| 3-tile match | 140–210 ms | bright sparkle/scale down, alpha fade | short pop |
| 4/5 tile match | 180–280 ms | line pop or prism pulse, not excessive flash | success accent |
| Tile gravity | ~80–110 ms per traversed cell, capped near 330 ms | smooth fall, subtle landing bounce | no repetitive clatter |
| New tile refill | 120–240 ms | slide from above plus fade, then land | soft tap |
| Cascade bonus | 200–350 ms | reuse combo ring, white smoke, sparkles | rising chime optional |
| Cloud Cup vaporizer | 250–450 ms | target smoke bloom/clear, exact separate canonical logo if shown | soft whoosh |
| Butane torch | 180–360 ms travel | horizontal/vertical fire trail, clear only row/column target | short ignition |
| Prism activation | 220–420 ms | rainbow ring then per-color tile pop | twinkle |
| Cloud Bomb | 240–400 ms | white/lavender radial plume within blast radius | muted puff |
| Crate damage | 120–220 ms | wood dust, crack/metal impact stages | wood tick |
| Fog reveal/syrup clear | 200–360 ms | dissolve haze / syrup ribbons; opacity fade | soft sweep |
| Victory/rewards | ~500–800 ms | stars and MW Bars pop sequentially | rewarding but not startling |

Durations are **not** new gameplay rules; all sprites must synchronize to actual engine events with `Future`/timeline completion rather than arbitrary frame counts. Never add pauses to model update that cause unresponsive taps.

## Draw-order and scene constraints
- Bottom: board background and transparent-center board frame.
- Tile layer: tile sprites/selected swap sprites/physical moving tile entities.
- Board blocker layer: MW crates, Reinforced crates, Fog, Sticky Syrup.
- FX layer: particle clouds, Prism, torch trail, clouds, combo ring/sparkles. Clip to board where appropriate.
- HUD overlay: scores/moves/objectives/buttons always visible, dynamically calculated; FX never obscures score or tap targets.
- Modal foreground: victory/reward screen on top; stop board input while modal.
- Keep burst brightness moderate; no repeated high-intensity full-screen flash.

## Performance/accessibility / gating
- S24 target smooth at native resolution: pool effects and cap particles, avoid full-screen overdraw and large per-frame allocations.
- Reduced motion: omit or compress travel and big bursts while retaining objective/booster feedback. No strobing.
- TalkBack: keep interactive board semantics stable; don't announce every intermediate animation frame.
- Rapid tap, back/resume, orientation, accessibility scale, touch under game FX, invalid swap and multi-cascade regression tests.
- Preserve tile identity/sprites approved V2; keep legacy internal enum/save IDs unchanged.
- No crowns, cannabis leaf motifs outside Secret Basement, random fake branding, unapproved story spoiler art or app commerce.

## Art inventory handoff
- ZIP: `Cloud_Kingdom_Animation_FX_Batch1_APPROVED_LOCKED.zip` (SHA-256 `4dce3273ec8993f380445de4bb0fd353316eff01ed631e70a1e46a476055dc60`).
- 8 source sheets are visually locked; **64 cut PNG candidate frames need seam/alpha/frame order/device QA** before declaring production-ready.
- Do **not** import overview-poster image generations as runtime assets.
- Base 37 Match-3 PNGs from Issue #4 already in main; only owner-approved new art may replace them, never silently overwrite.
- Integration progress tracked by [Issue #19](https://github.com/Nvisioned38/MrWeedsCloudKingdom/issues/19); visual S24 review tracked by [Issue #12](https://github.com/Nvisioned38/MrWeedsCloudKingdom/issues/12).
