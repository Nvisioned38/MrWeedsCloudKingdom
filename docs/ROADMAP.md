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
**Status: OWNER-AUTHORIZED / ENGINEERING READY / ORIGINAL ART DEPENDENCIES OPEN**

Execution specification: `07_CODEX_PHASE_2C_V1_IMPLEMENTATION.md`  
Visual intake: `docs/V1_ASSET_INTAKE.md`  
V1 QA gate: `docs/V1_QA_CHECKLIST.md`  
Base implementation: `10ca8a5b0bdcb086c294785544d40732a16ef524`

Priority order:
1. **2C-0 Stability:** Fix GitHub Issue #1 (unreachable Chapter 3 closing beat), add regression coverage, rerun gates.
2. **2C-1 Production art infrastructure:** Audit art keys/files, stable asset manifest, visible placeholder detection, theme/tile/HUD sprite architecture, accessibility and responsive rules. Can proceed without missing image originals.
3. **2C-2 Approved P0 artwork integration:** Official logos, Cloud Kingdom title, Mr. Weed, approved Match-3 tiles/blockers/specials/FX/UI, Cloud House, Lounge and Kitchen **only using source originals approved in actual v9 tracker**.
4. **2C-3 Collection and museum V1 UI:** Approved collection card framework, real runtime player state, collection shelf and optionally limited museum exhibit UI. Do not prematurely unlock the full Gallery.
5. **2C-4 V1 Android validation:** Home → Match-3 → Victory → Cloud House flow, regression/performance/accessibility, debug APK + SHA, then Samsung S24 Ultra owner/device verification and visual sign-off.

**Visual priority:** replace generic Flutter placeholders on primary gameplay path before expansion. **Story freeze:** Chapters 1–3 only. The five Trolls are friendly in V1; no betrayal, Nave, Copycat Cloud Co., Cloud Bottle, or Keefler reveal. Keep the mystery hook subtle.

**Asset dependency:** The owner-supplied v9 workbook and 77-PNG ZIP were inspected in ChatGPT on 2026-11-06 and documented at `docs/V1_V9_ZIP_INTAKE_AUDIT.md`. They are **not yet transferred to GitHub/Codex**. The curated 72-PNG V1 package excludes later-story spoilers. Official standalone brand logos BR-001/002 remain missing. Do not fabricate art or sign-off; continue unblocked 2C-0/1 engineering and transparently flag integration blockers.

**No expanded game scope:** no Levels 31+, no new chapter arcs, no new backend/commerce, no economy refactor, and no spoiler story additions. A build without all mandatory verified originals is a **technical preview**, not a polished V1 release candidate.

## Future phases, not authorized for autonomous implementation

### Phase 3 — Expanded Kingdom Systems
**Status: PLANNED / DEFERRED UNTIL POLISHED V1 APPROVED**

Later development may include Higher Art Gallery expansion, new rooms, more levels, mini-games, wider collections, and later-story revelations. Do not begin without separate explicit authorization.
