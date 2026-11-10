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
3. **2C-2 Approved P0 artwork integration: implementation complete; build/device verification pending.** Exact v10 BR-001/002 masters, v1 BR-003 title treatment, EN-002–008 environments, CS-001 portrait, and all 37 owner-approved Issue #4 Batch A/B/C exports are integrated. The separate Cloud Cup logo overlays the logo-free vaporizer. Run the full verification gate and record fresh visual/device QA before advancing this workstream. See `docs/V1_ART_EXPORT_MATRIX.md` and `docs/V1_QA_CHECKLIST.md`.
4. **2C-3 Collection and museum V1 UI:** Approved collection card framework, real runtime player state, collection shelf and optionally limited museum exhibit UI. Do not prematurely unlock the full Gallery.
5. **2C-4 V1 Android validation: PARTIAL.** Issue #5 gameplay/rewards/save relaunch, accessibility semantics, large text, landscape, cutout, lifecycle and a 122-frame profile performance sample pass in isolated widget/API 36 emulator profiles (1 raster-budget miss). S24 Ultra is currently ADB-unauthorized, so no physical-device action was taken. Full V1 remains open pending physical-device validation and art/owner gates.

**Visual priority:** replace generic Flutter placeholders on primary gameplay path before expansion. **Story freeze:** Chapters 1–3 only. The five Trolls are friendly in V1; no betrayal, Nave, Copycat Cloud Co., Cloud Bottle, or Keefler reveal. Keep the mystery hook subtle.

**Verified checkpoint (2026-11-07):** current approval source is the supplied v10 workbook (SHA-256 `a9256d1d2802226782ab0a4ab23268c0e6eb62309c5a075052925cc03808e3c0`). BR-001/002 official masters, BR-003 v1 title treatment and seven approved room/preview originals are integrated. All 48 tests pass; analyzer and formatting are clean. Samsung S24 Ultra install/update and limited screen smoke checks pass with saved state intact. Final arm64 technical preview SHA and details are in `docs/CURRENT_STATE.md` / `docs/V1_QA_CHECKLIST.md`.

The 2026-11-07 checkpoint above preceded the 2026-11-08 Issue #4 artwork handoff. Current artwork status is recorded in the checkpoint below; the older Match-3-asset blocker is resolved for integration, while the final integrated-build/device and owner visual gates remain open.

## 2026-11-08 Issue #4 integration checkpoint

All 37 owner-approved standalone Batch A/B/C exports are imported and wired into Match-3 rendering/HUD/result presentation; hashes, dimensions, and RGBA format passed the repository manifest verifier. The approved Cloud Cup logo is a separate overlay over the logo-free vaporizer. This checkpoint awaits fresh Flutter CI/build and S24 isolated-package visual QA. See `docs/CURRENT_STATE.md`, `docs/V1_ART_EXPORT_MATRIX.md`, and `docs/V1_QA_CHECKLIST.md`; V1 remains a technical preview pending release gates.

**No expanded game scope:** no Levels 31+, no new chapter arcs, no new backend/commerce, no economy refactor, and no spoiler story additions. A build without all mandatory verified originals is a **technical preview**, not a polished V1 release candidate.

## Future phases, not authorized for autonomous implementation

### Phase 3 — Expanded Kingdom Systems
**Status: PLANNED / DEFERRED UNTIL POLISHED V1 APPROVED**

Later development may include Higher Art Gallery expansion, new rooms, more levels, mini-games, wider collections, and later-story revelations. Do not begin without separate explicit authorization.

## 2026-11-07 — S24 isolated gameplay gate complete; art and TalkBack still pending

**Latest observed engineering head:** `dda1104933c5f06b45dd28c945355008172f3bd8` (51 Flutter tests at the initial Issue #5 checkpoint). The documentation-only follow-up `d106668cf53fa570e4e1da9759d2110d5f75da7e` has a successful GitHub Actions analyzer/test/Android build run: https://github.com/Nvisioned38/MrWeedsCloudKingdom/actions/runs/42433703369. No new gameplay code or art was integrated by that documentation commit.

**Phase 2C-4 isolated gameplay/performance QA:** the separate `com.mrweeds.cloudkingdom.qa` app on actual Samsung S24 Ultra completed Level 1 (1,020 points); Victory gave 100 coins, 1 star, 6 Collection XP; Cloud House Level 2/100 coins/1 star persisted through force-stop/relaunch Continue. Board offered 64 labeled controls; 2× text remained visible; haptics-off and reduced-motion-on persisted. Device profile logged 123 frames, build avg/p90/p99 1.275/2.295/5.882 ms and raster 3.290/5.399/8.450 ms with no frame-budget misses. Production package and save were untouched. **Issue #5 closed** as gameplay QA complete.

**Phase 2C remaining gates:**
- [Issue #4](https://github.com/Nvisioned38/MrWeedsCloudKingdom/issues/4): approval trail and device QA for the 37 integrated standalone Match-3 exports. Integration is implemented; full build and visual acceptance remain release gates.
- [Issue #6](https://github.com/Nvisioned38/MrWeedsCloudKingdom/issues/6): actual TalkBack spoken announcements/focus/gesture testing, separately pending because TalkBack was disabled in the completed physical device QA.
- Further specific approved character/collection production exports, final comprehensive visual QA and owner sign-off.

Continue Phase 2C only. **A CI-validated technical preview is available, not yet the finished polished V1.** Do not begin Phase 3 or future storyline reveals.

## 2026-11-08 Issues #15 and #14 — current Phase 2C work

PR #13 has merged to main (`8cd09011dcd33fab612d5bc27279bed0a00bad2b`). Issue #15 is being handled first: the objectives panel now uses a content-sized Flutter frame instead of stretching the approved decorative backing, preserving every approved asset file unchanged. Focused layout tests pass at 0.9×, 1×, 1.5× and 2×, including three objectives, a long label, a 30-move counter and all 64 visible board cells. Issue #14 follows on the same branch with deterministic test-only fixtures; production levels and S24 save data must remain unchanged. TalkBack Issue #6 and owner visual sign-off remain open.

## 2026-11-08 — Issues #15 and #14 (Phase 2C)

- **Issue #15: implemented and verified.** The objectives HUD uses a content-aware Flutter frame rather than stretching or editing its approved ornamental PNG. Widget/device evidence covers 1–3 objectives, long labels, 30 moves, and 0.9×/1×/1.5×/2×. The S24 QA-only Level 10 display fits all text and keeps all 64 cells visible at 0.9× and 2×.
- **Issue #14: isolated QA fixtures implemented and verified.** Approved-art Fog/Syrup, crate damage, Torch direction, booster art/semantics, smoke/combo/reduced-motion, resolver-driven missing-image fallback, playable/tappable cells, and fresh first-clear reward persistence/idempotence have deterministic tests. No production debug route or authored-level change was added. Optional state tests remain automated-only, not physical S24 visual acceptance.
- Current gate: 71 Flutter tests pass; analyzer, changed-file format, 37/37 approved-art verification and both arm64 debug builds pass. QA app update was user-0 `.qa` replace-only; production package/save untouched. TalkBack Issue #6 and owner visual approval remain release gates. Phase 2C remains in progress; Phase 3 is not started.

## Active animation work — Issue #19
**Status: STAGE A VERIFIED; EVENT-DRIVEN FX IMPLEMENTED; OWNER-APPROVED NORMAL TIMING; REDUCED MOTION S24 VISUAL CHECK PASS; OWNER CHECKPOINT REVIEW PENDING**

Work remains on `animation/issue-19-stage-a`, draft PR #20. Stage A engine trace, deterministic parity, snapshot rendering, Reduced Motion, input lock and lifecycle cancellation are verified in `docs/evidence/issue19/STAGE_A_QA.md`. The owner then authorized continued motion and event-linked effects. The existing Issue #4 smoke/sparkle/combo artwork now follows actual clear, special, cascade, blocker and tile-condition changes; details and limitations are in `docs/evidence/issue19/EVENT_DRIVEN_FX_CHECKPOINT.md`.

The latest gate is clean (74 Flutter tests, analyzer and 37/37 approved-art hashes); the arm64 QA APK was package-verified and replace-installed using `-r --user 0`. On the reauthorized S24, the new stationary Reduced Motion glow was visibly responsive at 150 ms and absent after its 300 ms fade, with no tile travel. The isolated QA save/preferences hash remained unchanged before/after; production was not accessed. Evidence and APK SHA-256 are in `docs/evidence/issue19/EVENT_DRIVEN_FX_CHECKPOINT.md`. Frame pacing was not remeasured, and clean source-frame artwork remains pending. Keep PR #20 draft pending owner checkpoint approval. Stage B and accessibility remain paused. Do not resume Issue #6/PR #18, import Batch 5, or start Phase 3.
