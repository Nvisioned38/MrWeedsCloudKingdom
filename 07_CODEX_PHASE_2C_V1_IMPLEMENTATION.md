# Phase 2C — First Polished Playable Android V1

**Status:** OWNER-AUTHORIZED for engineering preparation, stabilization, visual framework, and integration of *verified original, approved assets*. Missing artwork is a per-asset dependency, not permission to invent replacements.

**Engineering baseline:** `10ca8a5b0bdcb086c294785544d40732a16ef524` (Phase 2B, 43 tests, analyzer clean, debug APK reported successful).

## Mission and acceptance

Deliver the first polished **Mr. Weed's: Cloud Kingdom** Android debug APK suitable for hands-on testing on a Samsung S24 Ultra, prioritizing the entire **Home → Match-3 → Victory → Cloud House** path and the approved visual identity. This is a polish/integration release, **not** a feature-expansion/story release.

Keep all 30 levels, the 30-card catalog, Chapters 1–3, and schema 3 persistence working. No changes to later-arc plot, no Levels 31+, and no unapproved mechanics.

## Prerequisites / trust boundary

1. Read `AGENTS.md`, `docs/CURRENT_STATE.md`, `docs/ROADMAP.md`, `docs/V1_ASSET_INTAKE.md`, and this file before work.
2. The owner provided the original **v9 "Brand and V1 Priorities" workbook** and Game Art ZIP to ChatGPT, and the contents were audited (see `docs/V1_V9_ZIP_INTAKE_AUDIT.md`). **The original files have NOT been transferred to this GitHub/Codex checkout yet.** Import the curated V1 source package and inspect v9 directly before production sign-off; older tracker versions never override v9.
3. As of the 2026-11-06 intake audit, GitHub has only `assets/data/`, not artwork files. `lib/presentation/art_registry.dart` describes intended paths but is not proof the PNGs exist. Never mark a design visually integrated just because a registry key resolves.
4. The user's final supplied original files control branding. Never synthesize a substitute for a locked logo, portrait, environment, or already-approved art. If absent, use a deliberate, visibly unfinished fallback and mark that asset **BLOCKED: ORIGINAL REQUIRED**, while doing unblocked engineering work.
5. Visual concept approval does **not** imply a production-ready transparent sprite, correct crop, UI atlas, layered file, or animation. Validate export shape, source transparency, safe areas, scale, and licensing/usage before integration.
6. Do not treat the connected ChatGPT conversation or generator output as accessible filesystem assets unless the original bytes are actually imported into this repo. Do not source from web lookalikes.

## Ordered Phase 2C workstream

### 2C-0: Stabilize verified gameplay (first)

- Fix **GitHub Issue #1**: `gallery_glimpse` dialogue must unlock immediately *after completing* Level 30, not after Level 29, and stay reachable despite the 30-level cap.
- Add regression tests for Chapter 3 finale and existing intermediate story beat gates.
- Re-run format, `flutter analyze`, `flutter test`, `flutter build apk --debug`.
- Preserve save schema 3 and prior user progress. Record checkpoint and tests.
- This must precede any broad UI changes.

### 2C-1: Asset audit and foundational integration plumbing (no missing art needed)

- Inventory all referenced registry keys, actual files, `pubspec.yaml` asset declarations, dimensions, intended draw bounds, and runtime fallbacks.
- Design a **typed or strongly validated** asset inventory/manifest tied to stable keys. Asset entries carry source file, approval evidence (v9 row ID once available), exact intended game path, state (missing/original received/export validated/integrated/QA approved), and variant type/size; do not invent sign-off.
- Make rendering resilient to missing assets, but **never silently pass a placeholder as final art**. Surface a development-only missing-art report.
- Add asset-loading validation tests that fail when an asset is marked production-ready but is absent or undeclared.
- Create consistent brand theming primitives for readable typography, rounded panels, purple cloudstone/cloudglass surfaces, Kingdom brass/gold accents, sensible touch targets, focus/haptics/reduced-motion settings, and accessible tile differentiation. Use stable existing semantics and test UI behavior.
- Establish a reusable board sprite interface separated from Match-3 domain logic, with responsive scaling, safe-area behavior, and effects hooks. Do not modify scoring/progression to style screens.
- Preserve current versioned app identity and save key. No speculative architecture rewrite.

### 2C-2: Priority 0 artwork integration (only when masters exist)

Priority order:
1. **Exact official branding:** Mr. Weed's logo, official Cloud Cup logo, approved Cloud Kingdom title treatment (prefer game title v1 unless owner/v9 indicates otherwise). No AI redrawing or synthesized wordmarks.
2. **Core Match-3 presentation:** five approved distinct tile silhouettes/symbols; MW-stamped Crates and Reinforced Crates; Sticky Syrup and Fog readability; approved Prism and Cloud Bomb; approved butane **torch** as the directional-rocket visual; approved **Cloud Cup vaporizer** in place of hammer; readable objectives/moves/progress/victory affordances and controlled cascade FX. Preserve existing internal identifiers and tested behavior when changing appearance.
3. **Environment surfaces:** approved Cloud House exterior, Lounge, and High Cuisine Kitchen original art. Use approved source crops/layout, including aspect and parallax rules when documented. Room unlock/restore state must follow saved progression.
4. **Mr. Weed character:** existing approved likeness, OK hand gesture (not a thumbs-up), blank white shirt unless approved variant, jeans/shoes; original approved portrait/body only.
5. **Navigation and global UI:** replace generic widgets/icons only insofar as approved production art is ready, while ensuring all screens remain usable.

The source may include old generic terms such as `TileFamily.leaf`, `rocket`, or `coins`. Preserve domain/save identity and map the **visual** to the locked non-leaf tile/torch/MW Coins treatment instead of breaking saves or inventing new gameplay currencies.

### 2C-3: Collection and museum V1 polish

- Use the approved collectible-card base template, rarity/evolution visual rules, collection shelf, discovery feedback, and existing 30-card catalog.
- Runtime names, lore, rarity, XP, favorite/equipped/progress indicators must come from data, not flattened into pictures.
- Implement an MVP **display/museum presentation only where approved component art exists**, backed by unlocked and displayed cards, with locked/empty/occupied states and accessible interactions.
- The Higher Art Gallery still **previews only** after Level 30. Do not unlock a fully playable gallery or add the missing-content story as part of polishing.
- If individual card illustrations or museum exports are missing, keep explicit pending status; do not produce unapproved recreations.

### 2C-4: V1 integration QA and Android artifact

- Verify fresh install and upgrading from Phase 2B schema 3 without loss: New Game → Home → Match-3 → Victory → rewards → Cloud House, resume after relaunch, and navigation to Collection/Story/Settings.
- Verify level 20 kitchen milestone, level 30 gallery preview, final Chapter 3 dialogue, collectible/evolution/equip/Cloud Nine +150 perk, timers/FX and reduced motion.
- Test on phone-like portrait safe areas, dense DPI, large font, notches/cutouts, scrolling, overflow, and background/resume. Support orientation behavior consistent with current app; do not introduce a new orientation lock without approval.
- Run all tests, analyzer, format, then Android debug APK build. Record APK SHA-256 and absolute or relative output path. Report whether this was **CI/emulator/local**, and distinguish **APK produced** from **actually installed and tested on Samsung S24 Ultra**. The latter requires owner/device hands-on confirmation unless an authorized connected device is genuinely accessible.
- Produce `docs/V1_QA_CHECKLIST.md` with objective status: PASS / FAIL / BLOCKED / NOT TESTED.
- Record all implementation checkpoints with commits, test counts, warnings, and remaining missing originals.

## Locked visual rules

- **Cloudcrafted Fantasy:** premium, dimensional 2.5D, tactile and magical; approximately 70% stylized / 30% believable materials/lighting. Warm key light, cool cloud fill, restrained magical accents. Selective outlines.
- Materials: purple cloudstone, cloudglass, Kingdom brass/gold, enchanted wood and dream fabric.
- **No visible cannabis leaves** in environments, gameplay, or UI except within the **Secret Basement**. Apply visually, preserving internal tile IDs where needed.
- Mr. Weed is founder, host, guide, dreamer, **not a literal king**. **No crowns**.
- Cloud Cup is clear with green straw, white smoke by default, and exact approved logo where branding is shown.
- Match-3 art is readable by shape + silhouette + symbol, not color alone. Gold/brass/purple cloudglass UI with approved green primary and purple secondary actions.
- Economy visual labels: **MW Coins**, **MW Bars**, **Cloud Energy**. **Dream Crystal remains a tile, not currency**. Do not introduce monetization/economy rules as a visual task.
- Locked canonical source logo names recorded in prior art direction: `FINAL_Logo_Words_HORIZONTAL(1).png` and `LOGO_CloudCup_Horizontal(2).png`; names are references only until actual byte files and v9 review are available.
- Do not recolor/reletter/redraw approved logos or adjust Mr. Weed's face. No generic brand lookalikes.

## Narrative firewall for Android V1

The five Trolls are known as friendly support characters early in the story. Do not signal a betrayal in V1 UI, character poses, descriptions, splash art or dialogue. Lord Nave Von Elrekce, Copycat Cloud Co., the Cloud Bottle rival, and the theft/betrayal plot are **future revelations**. The original Keefler Elves and their role in Cloud Cup/CannaTapper origins are also future revelations. Preserve the subtle unmarked-workshop mystery hook; do not name/reveal the Keeflers. No new antagonist or spinoff content in V1.

## V1 definition of done

A release candidate is **not visually complete** merely because the build passes. It must have:
- Source and approval trail for every mandatory P0 image;
- no unresolved missing P0 original assets;
- no visible generic placeholders on the primary Home → Match-3 → Victory → Cloud House path;
- gameplay, save/migration, accessibility, and first three chapters regression gates passing;
- documented Android debug APK SHA and owner/device acceptance status;
- no involuntary later-chapter spoilers;
- user review/sign-off for final branded visuals.

If artwork prevents full V1 completion, ship a **technical preview APK** instead of claiming a polished V1 release.

## Autonomous work rule

Complete every unblocked engineering item in the approved 2C-0/1/2/3/4 scope, with incremental tested commits and docs. When a master image is missing, skip only that asset-dependent item, mark the exact blocked item, and continue elsewhere. No routine check-ins. Do not start Phase 3. Do not merge a knowingly incomplete release as a final polished V1.

For the first Codex run, **2C-0 + 2C-1 are immediate**, while 2C-2/3 asset-dependent integration waits only on their particular originals. Keep a single consolidated missing-file request.
