# Phase 2C next art sprint — Match-3 and V1 release gates

**Status update (2026-11-08):** The owner-approved Issue #4 Batch A/B/C handoff supersedes the missing-standalone-sprite blocker below. All 37 exports are present and integrated on the Issue #4 integration branch; hash/dimension/RGBA manifest verification passes. Use the current `docs/V1_ART_EXPORT_MATRIX.md` and `docs/V1_QA_CHECKLIST.md` for current status. The work described in this file remains useful for general gates, and final Android/S24 visual QA is still required.

**Current code baseline:** `04aca22f3f1566f11ec935e914b6a73ebd58a5b5` (2026-11-07). This is the **verified v10 branding technical preview**, not final V1 sign-off.

## Verified at the checkpoint

- Flutter `48/48` tests pass, formatting and `flutter analyze` clean; the [GitHub CI run](https://github.com/Nvisioned38/MrWeedsCloudKingdom/actions/runs/42408455904) also completed successfully.
- v10 canonical pixel-exact BR-005 and BR-006 standalone logo exports, BR-003 v1 title, and seven approved EN-002–EN-008 original room/preview images are integrated and manifest-tracked.
- `assets/art/manifest.json` records 80 entries: 10 **integrated**, 12 **originalReceived** (not production-ready), and 58 **missing**. Never equate originalReceived with integrated.
- On Samsung S24 Ultra, a prior build showed title, Cloud House, and a portrait 8×8 Level 3 board, and an in-place update retained the existing Level 3 / 210 coin / 2-star save. The **final export-only APK was installed but was not recaptured because the phone was locked**. Full win/reward loop and accessibility/performance QA remain unverified.
- Issue #1 (Chapter 3 finale gate) has verified regression coverage and is closed.
- **v10 Standalone Assets workbook** is current authority. v9 remains historical; never silently revert to v9 values.

## Approved autonomous work order

1. **Production sprite inventory and exports**
   - Inspect the owner's accessible **v10 workbook** and the actual `Game Art.zip`/other approved source files in the Codex environment.
   - Prepare one precise P0 missing-export matrix: `v10 ID | design source | original path | export type | dimensions/transparency | hash | ready/integrated/QA status`.
   - Produce **isolated** approved Match-3 assets: Cloud Puff, Mystic Bloom, Ember Drop, Dream Crystal, Golden Nugget; MW Crate and reinforced MW Crate; Sticky Syrup, Fog; Torch lighter visual (legacy Rocket behavior), Cloud Cup vaporizer (legacy Hammer behavior), Prism, Cloud Bomb; moves/objectives/score/stars/victory controls and effects. Keep enum/save identities unchanged.
   - Full board/HUD concept screenshots are **references**, not ready sprites. Avoid baking numbers or state into static images. Slicing/cropping is allowed only when visually faithful and correct for production. Do not synthesize new icons/character faces/logos.
   - For each usable export: track source hash, v10 approval ID, exact runtime path and dimension; run automated loading/safe-area checks.
2. **Gameplay V1 polish**
   - Prioritize actual mobile gameplay screens: Home → Board → Victory/Rewards → Cloud House. Make board frame and overlays scale on S24 Ultra portrait with labels readable at normal and large-text sizes.
   - Make objective and star progress, low/zero moves, booster-selected/pressed/disabled controls, win/lose states explicit and interactive. Keep preexisting scoring, level seeds, fairness and 30-level catalog intact.
   - When a required art original is absent or can't be cleanly exported, keep the honest technical fallback, record the single missing source, and continue with unrelated engineering.
3. **Character and collection V1 polish**
   - Only after P0 gameplay presentation, integrate approved Mr. Weed image export matching the exact face/blank shirt/OK gesture, then Chef Blaze and The Collector portraits as available. The five Trolls remain **friendly**; no later story clues.
   - Integrate collection-card base/rarity/evolution, selected filters, unlocked/favorite/equipped states and museum/shelf presentation from approved standalone source exports, keeping 30-card runtime data and schema 3 progress authoritative.
   - The seven Nov 06 collection UI PNGs are known **new source versions**. Validate against v10 sign-offs. Never bake a `10/42` sample into a game with 30 launch collectibles, and never unlock the full Gallery due to an example navigation bar.
4. **Device QA and release**
   - Maintain format, analyze, full test suite (at least 48 existing tests), manifest/asset tests, Android arm64 debug APK build, and GitHub Actions artifacts for meaningful checkpoints.
   - Verify true on-device **tap → swap → score → win → reward → Cloud House**, then relaunch and ensure save persists; no uninstall/reset of the existing progress-bearing Samsung app.
   - Run large text, TalkBack/content descriptions, reduced motion, landscape behavior if supported, cutouts/safe area, background/resume and performance checks.
   - Save APK SHA-256, screenshot/QA evidence and regression results in `docs/V1_QA_CHECKLIST.md`, `docs/CURRENT_STATE.md`, and `docs/BUILD_LOG.md`. Distinguish automated widget tests, local emulator, and owner S24 Ultra manual evidence.
   - Maintain a **technical preview** designation until all mandatory P0 production assets, full device QA, and final owner visual acceptance pass.

## Locked rules

Cloudcrafted Fantasy, no crowns, no visible cannabis leaves outside Secret Basement, no substituted official marks, white smoke by default. Internal legacy TileFamily names may remain for save compatibility; actual displayed tiles must match approved v10 visual names/shape language. No Phase 3, Levels 31+, later Troll betrayal, Copycat Cloud Co., Lord Nave, or Keefler reveals.

## Autonomous continuation

Continue verified, unblocked P0 work without routine approvals. Commit logical units and push; let GitHub Actions build/check APK artifacts. Escalate only exact missing original sources, irreversible/dangerous changes, or legal/platform decisions. Never present an incomplete APK as the final polished V1.

**Codex task:** [GitHub Issue #3](https://github.com/Nvisioned38/MrWeedsCloudKingdom/issues/3), with image availability tracked by [Issue #2](https://github.com/Nvisioned38/MrWeedsCloudKingdom/issues/2).
# 2026-11-07 checkpoint — portrait integrated; source art gate remains

Integrated the v10-approved standalone CS-001 Mr. Weed portrait, copied unchanged and rendered in the Story catalog. The tracking manifest now reports 11 integrated / 11 original received but pending / 58 missing assets. Detailed v10 row/source decisions for M3-001–015 are in `docs/V1_ART_EXPORT_MATRIX.md`.

No standalone P0 tile, blocker, special, effect, or modular board/HUD production masters were present in the inspected workspace archive. The available M3 review, combo FX, Cloud Cup, Chef Blaze, and collection references are composites/screenshots with baked layout/content and remain unintegrated. Their approved design references do not authorize derived sprites. Continue when isolated approved originals are available; keep technical-preview status and Phase 3 out of scope.
