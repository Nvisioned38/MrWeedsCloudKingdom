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
**Status: VERIFIED / COMPLETE**

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

Verified outcomes:
- Runtime catalog expanded to Levels 1–30 while preserving Levels 1–10 behavior and adapting unsupported master-map objective intents to implemented mechanics.
- Chapters 2 and 3 are playable at their progression milestones; Chef Blaze and The Collector story beats are included.
- Sticky Syrup and Fog are deterministic domain mechanics with visible non-color UI cues; Crate and Reinforced Crate remain supported.
- 30 collectible identities, persisted collection XP/evolution, one equipped collectible, and Cloud Nine's deterministic +150 starting-score perk are implemented.
- Schema 2 saves migrate to schema 3, with New Game reset and persistence coverage.
- Kitchen unlocks at Level 20; Level 30 records its reward and shows a Higher Art Gallery preview without claiming the full Gallery is complete.
- Mystery continuity remains subtle; no Keefler reveal was introduced.
- Verification: `flutter analyze` clean, all 43 Flutter tests pass, and Android debug APK build succeeds.

Phase 2B remains the latest verified game implementation. Phase 2C was explicitly prioritized for the first polished Android V1 on 2026-11-06.

## Current owner-authorized work

### Phase 2C — First Polished Android Playable V1
**Status: IN PROGRESS / V10 BRANDING INTEGRATED / DEVICE SMOKE PASSED / P0 GAME ART OPEN**

Execution specification: `07_CODEX_PHASE_2C_V1_IMPLEMENTATION.md`  
Visual intake: `docs/V1_ASSET_INTAKE.md`  
V1 QA gate: `docs/V1_QA_CHECKLIST.md`  
Phase 2B baseline: `10ca8a5b0bdcb086c294785544d40732a16ef524`; Issue #1 fix in `edcf151`; latest v10 checkpoint is in `docs/CURRENT_STATE.md`.

Priority order:
1. **2C-0 Stability: COMPLETE.** Issue #1 finale gate has regression coverage.
2. **2C-1 Production art infrastructure: COMPLETE for current approved engineering scope.** Stable registry/manifest, pending detection, renderer interface, theme and settings hooks are in place.
3. **2C-2 Approved P0 artwork integration: IN PROGRESS.** Exact v10 BR-001/002 masters, v1 BR-003 title treatment, approved EN-002–008 environments and the approved CS-001 Mr. Weed OK-gesture portrait are integrated. Match-3 isolated production sprites and modular board/HUD exports remain blocked by missing originals; see `docs/V1_ART_EXPORT_MATRIX.md`.
4. **2C-3 Collection and museum V1 UI:** Approved collection card framework, real runtime player state, collection shelf and optionally limited museum exhibit UI. Do not prematurely unlock the full Gallery.
5. **2C-4 V1 Android validation: PARTIAL.** Arm64 APK installed via in-place update and cold-launched on S24 Ultra; existing Level 3/210 coins/2 stars were preserved; title, Cloud House and Level 3 board were visually checked. Full turn/win/reward flow, performance/accessibility checks and owner visual sign-off remain.

**Visual priority:** replace generic Flutter placeholders on primary gameplay path before expansion. **Story freeze:** Chapters 1–3 only. The five Trolls are friendly in V1; no betrayal, Nave, Copycat Cloud Co., Cloud Bottle, or Keefler reveal. Keep the mystery hook subtle.

**Verified checkpoint (2026-11-07):** current approval source is the supplied v10 workbook (SHA-256 `a9256d1d2802226782ab0a4ab23268c0e6eb62309c5a075052925cc03808e3c0`). BR-001/002 official masters, BR-003 v1 title treatment and seven approved room/preview originals are integrated. All 48 tests pass; analyzer and formatting are clean. Samsung S24 Ultra install/update and limited screen smoke checks pass with saved state intact. Final arm64 technical preview SHA and details are in `docs/CURRENT_STATE.md` / `docs/V1_QA_CHECKLIST.md`.

The approved BR-005/006 standalone exports were generated by an alpha-bound crop from their locked canonical masters and verified pixel-exact; both had full-canvas alpha bounds. CS-001 Mr. Weed character art is integrated, but isolated approved Match-3 sprites, modular UI exports, the full-body Mr. Weed export and The Collector portrait remain unavailable. The connected phone has passed launch/layout and character-art checks; full gameplay/reward and accessibility QA plus owner sign-off remain open. Do not fabricate art or sign-off. Continue unblocked Phase 2C work and keep the V1 release gate open.

**No expanded game scope:** no Levels 31+, no new chapter arcs, no new backend/commerce, no economy refactor, and no spoiler story additions. A build without all mandatory verified originals is a **technical preview**, not a polished V1 release candidate.

## Future phases, not authorized for autonomous implementation

### Phase 3 — Expanded Kingdom Systems
**Status: PLANNED / DEFERRED UNTIL POLISHED V1 APPROVED**

Later development may include Higher Art Gallery expansion, new rooms, more levels, mini-games, wider collections, and later-story revelations. Do not begin without separate explicit authorization.
