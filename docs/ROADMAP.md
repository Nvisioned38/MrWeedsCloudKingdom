# Cloud Kingdom Development Roadmap

## Operating rule

This roadmap defines the approved implementation sequence. Coding agents should complete the current approved phase end-to-end, verify it, document it, and continue through that phase without routine approval requests. Moving into a later phase that materially changes product scope requires that phase to be marked approved here or in a direct owner instruction.

## Completed

### Phase 1 — Match-3 foundation
**Status: VERIFIED / COMPLETE**

Delivered:
- Flutter + Flame Android/web project foundation
- deterministic Match-3 domain
- authored Levels 1–10
- core objectives and special pieces
- Crate and Reinforced Crate blockers
- cascades, legal-move handling, scoring and rewards
- local save/progression
- automated tests and debug build verification

### Phase 2A — World + collection foundation
**Status: VERIFIED / COMPLETE**

Delivered:
- Cloud House hub/exterior
- Lounge world state and customization flow
- collection shelf/details/favorites
- initial 10-card collectible catalog
- evolution metadata foundation
- character catalog
- Chapter 1 playable story foundation with Chapter 2/3 teasers
- unmarked workshop mystery clue
- Phase 2 save migration foundation
- 34-test synchronized verification gate

Authoritative synchronized baseline: `1a96490a0843b9181f28d5ff7d39a41afea7a16e`

## Current approved work

### Phase 2B — Progression + Story Build
**Status: APPROVED / READY TO EXECUTE**

Execution specification: `06_CODEX_PHASE_2B_PROGRESSION_STORY_BUILD_PROMPT.md`

Primary outcomes:
1. Playable Levels 11–30.
2. Chapters 2 and 3 become playable.
3. Sticky Syrup and Fog engine support.
4. Collectible catalog expands to 30 cards.
5. Collection XP becomes real persisted progression.
6. Seedling → Bud → Frosted → Legendary evolution becomes functional.
7. One equipped card and one deterministic puzzle perk become functional.
8. Kitchen milestone at Level 20.
9. Higher Art Gallery preview/mystery milestone at Level 30.
10. Preserve subtle Keefler mystery continuity without explicit reveal.
11. Full save migration and regression coverage.

Phase 2B is complete only when its verification gate passes and `docs/CURRENT_STATE.md`/`docs/BUILD_LOG.md` are updated.

## Planned, not yet authorized for autonomous implementation

### Phase 2C — Visual identity + branded asset integration
**Status: PLANNED**

Intent:
- replace generic/placeholding presentation with approved Cloudcrafted Fantasy visual direction;
- integrate official Mr. Weed's and Cloud Cup branding assets without restyling them;
- establish the locked Match-3 visual style proof, tile language, board frame, UI chrome, and world-room art integration;
- preserve white Cloud Cup smoke unless a specific asset direction says otherwise;
- use the Lounge as the first locked environment reference.

Do not begin automatically until this phase is explicitly marked approved.

### Phase 3 — Expanded Kingdom systems
**Status: PLANNED**

Likely scope from the approved game blueprint includes:
- Higher Art Gallery as a full collection museum area;
- later Cloud House rooms and Secret Basement systems;
- additional blockers/objectives and Levels 31+;
- daily/weekly challenge framework;
- first mini-game framework;
- broader character/story progression;
- future Keefler Elves story arc and workshop reveal at the appropriate narrative point.

Detailed implementation scope will be split into bounded verified phases before execution.
