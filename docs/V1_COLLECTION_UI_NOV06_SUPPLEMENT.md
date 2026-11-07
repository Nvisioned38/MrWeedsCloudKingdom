# Nov 06 Collection & Museum UI Supplement — Seven Original PNGs

The owner uploaded seven additional original artwork files after supplying the v9 "Brand and V1 Priorities" workbook and initial Game Art ZIP. These are **new source versions**; none was byte-identical to an image in either earlier archive. The files were inspected and SHA-256 fingerprinted on 2026-11-06.

**Important:** The seven PNG bytes, plus the updated review workbook, are packaged separately in `CloudKingdom_Nov06_Collection_UI_Supplement.zip` in the ChatGPT handoff. **They are NOT yet committed to GitHub or automatically available to Codex.** The package does not replace the earlier `CloudKingdom_V1_Codex_Art_Source_Pack.zip`.

The workbook `Mr_Weeds_Cloud_Kingdom_v9_WITH_NOV06_UI_ADDENDUM.xlsx` retains the original v9 approval sheets and prior ZIP audits, then adds **Nov 06 UI Additions** and **UI Handoff Notes** sheets. Every new source version starts with **New File Sign-off = Pending**, regardless of the approval status of its previously locked v9 *design concept*. Do not treat upload alone as fresh design sign-off.

## Exact source inventory

| File | v9 mapping | Pixels | SHA-256 |
|---|---|---|---|
| `ITEM_Collection.png` | CO-024 progress plaque | 1774×887 | `3bc81f9a2b737087bff81efe5be9e689fd42129eac277081b37dd7cb576e9a06` |
| `ITEM_Filters.png` | CO-023 rarity filter bar | 2048×682 | `0c021c33cafa7b4fae49036e8bbf302ae27872142730d095eff766cc65972664` |
| `ITEM_Navitation Buttons.png` | Provisional UI-001/002/009; new navigation-specific v9 ID unconfirmed | 2048×682 | `2bd4543eb58fd725dd464105b678fc09aa7536d1e097d5fcceb1f6c313eceb1b` |
| `ITEM_Card States.png` | CO-013 locked/unlocked/favorite | 1448×1086 | `e33c145168035c45ca9c3e025dbd3aa8b101bbc7d89e0a3a0603545fa9d9f198` |
| `ITEM_Rarity Examples.png` | CO-002/003/004/005 rarity frame examples | 1448×1086 | `95895152a87b3d1fb4bb957625da000216724ccec9063f7d65be1d93a76d7206` |
| `ITEM_Evolution Path.png` | CO-006/007/008/009/026 evolution visual comparison | 1448×1086 | `a616f0b79d783cd3d05451ff927421488bc86f50227c1b25ff6f57b94c2e5de0` |
| `ITEM_New Strain Discovery.png` | CO-014 reveal illustration | 1254×1254 | `182e993ae6d6f22e7cd7babae9073e24fc6b78de7df55d8d795e836adb8d2753` |

All seven PNGs contain alpha transparency. **Transparency alone does not make a composite review image a clean, independently reusable or interactive sprite.** Inspect clipping, halos, baked text and scale before importing.

## Codex integration constraints

1. **Collection progress plaque:** the uploaded source contains example text **`Collection: 10 / 42`**, but the current game has **30 collectible identities**. Count, slash and label should be rendered from the runtime collection state; do not ship `10/42` as a static picture or infer 42 collectible items. Preserve ornamental plaque art during extraction.
2. **Filter bar:** the image has **All** visually selected. Implement All/Common/Rare/Epic/Legendary as separate accessible interactive states, including selected/disabled states and actual 30-card filtering. Do not flatten all buttons into an inert navigation strip.
3. **Navigation:** the image displays Home, Collection, Gallery, Progress and Rewards with Collection selected. These are a **visual reference**, not authorization to rewrite navigation or introduce new screens. Existing V1 Gallery is **preview-only at Level 30**, not a full open museum; keep user progression gates and do not infer features from a pictured button. Use runtime selected tab states and correct touch targets.
4. **Card states:** use the illustration to define unlocked/locked/favorite appearance, but preserve dynamic card identity, favorites, unlock gates, tap actions and current save schema.
5. **Rarity frames:** use Common silver, Rare blue/teal, Epic violet, Legendary gold visual language; split/recreate **frame behavior** without flattening sample flower art and rarity labels into final cards. Check any cannabis-leaf motifs against locked no-leaf UI rule. Do not silently alter artwork.
6. **Evolution path:** stages Seedling → Bud → Frosted → Legendary come from real per-card XP and schema 3 save data, not the four fixed demonstration images.
7. **New Strain Discovery:** use this as the approved *style reference* pending new-file sign-off; card identity, reward acknowledgement, reveal timing, animation, accessibility/reduced motion and Collect action must be runtime-managed.

## Priority and V1 scope

These are **P1 Collection/Museum polish and P2 evolution sample assets**, **not** a replacement for P0 Home → Match-3 → Victory → Cloud House polish. V1 still needs official exact standalone logo masters BR-001/002 and production exports of gameplay elements.

The v9 **concept approvals remain unchanged**; owner review for each of the seven uploaded image versions is pending. Future antagonist/Nave/Copycat/Troll betrayal/Keefler story assets must not be bundled into the initial Android V1.

## Intake procedure

- Transfer the supplement ZIP into the Codex working environment. Extract originals to a **non-runtime source art** area first. Preserve source filenames and hashes.
- Audit the original source and v9 approval row, decide which parts can be safely sliced into independent transparent art versus must be implemented as dynamic Flutter UI.
- Record new file sign-off separately from original v9 review decisions. If any component requires creative rework, request owner approval rather than approximating.
- Keep the working Android APK size manageable by bundling only runtime exports, not review boards and redundant masters.
- Update the art manifest and tests. Mark imported/validated/integrated/device-reviewed as separate states.

This document is an intake register, not a claim that these assets are integrated or that Phase 2C is tested.
