# Batch F: Core UI & Navigation artwork approval

**Owner approval:** 2026-11-09. All **8 original 1448×1086 RGBA source sheets** are visually **APPROVED AND LOCKED** without pixel alteration. See [source hash manifest](../art_production/ui/batch_f/approved_source_manifest.csv).

**Original package:** `Cloud_Kingdom_Batch_F_UI_Navigation_APPROVED_LOCKED.zip` (SHA-256 `aa0c8243524a469348fdb4d5b02b819c77df082c6b785bd7ace07c676b6f2c30`). This 8-image ZIP contains original PNG sheets, SHA-256 manifest, reference contact sheet, and Codex README, available in the owner's ChatGPT artwork conversation. **GitHub contains approval metadata, not the ZIP or PNG bytes.** The updated workbook `Mr_Weeds_Cloud_Kingdom_Asset_Review_v15_Batch_F_UI_LOCKED.xlsx` has also been prepared for owner/Codex handoff, but is not in GitHub.

## Approved sheet registry
- **UI-F-001 Mixed Style Reference:** `fantasy_cloud_kingdom_ui_asset_kit.png`
- **UI-F-002 Buttons & Tabs:** `glossy_fantasy_cloud_kingdom_ui_assets.png`
- **UI-F-003 Panels & Dialogs:** `glossy_cloud_kingdom_ui_asset_sheet.png`
- **UI-F-004 Navigation Icons:** `cloud_kingdom_icon_button_sprite_sheet.png`
- **UI-F-005 HUD & Energy:** `glossy_cloud_kingdom_hud_asset_sheet.png`
- **UI-F-006 Tutorial & Feedback:** `fantasy_cloud_kingdom_ui_asset_sheet.png`
- **UI-F-007 Rewards & Status:** `glossy_fantasy_game_ui_badge_collection.png`
- **UI-F-008 Level Map & Chapter:** `mr._weed_s_cloud_kingdom_ui_assets.png`

## Codex integration task
1. Obtain actual ZIP and verify all source SHA-256 hashes. Preserve these eight original sheet files exactly and avoid re-rendering.
2. Extract UI components individually with clean alpha edges, no neighboring tiles or halos, appropriate inset/padding, and nine-slice support for scalable panels and buttons. Source sheets contain multiple art elements; they are **not** themselves ready-to-render individual UI elements.
3. Implement interactive Flutter states and dynamic label/count/progress rendering: normal, pressed, selected, disabled, locked; buttons/navigation routes must have correct touch areas, semantics, and accessibility.
4. Reuse the exact canonical Mr. Weed's and Cloud Cup logo assets as independent overlays where applicable; do not redraw logos. The earlier locked visual canon says **no crowns**, cannabis leaves only in the Secret Basement, and no early Troll betrayal/Lord Nave/Keefler spoilers. Some approved concept sheets show crown/emblem imagery; **these specific motifs are excluded from V1 runtime** despite sheet-level approval.
5. Keep all 30 collectible IDs, Match-3 IDs, saves, logic, counter values, and current UI interaction behavior intact. Avoid fixed counters, nonfunctional fake UI, or screenshot-like flattened panels.
6. Test responsive layout across portrait 8×8 board / Cloud House / collection; large text, TalkBack, reduced motion, safe areas, touch targets, render sizing, and S24 Ultra QA. No forced uninstall of the owner's production game.
7. Treat approval, component extraction, alpha/9-slice QA, integration, and device acceptance as separate tracked states. Existing Issue #12 and Issue #19 release/animation QA gates remain in force.

**Only source artwork approval is complete.** No claim of standalone exports or runtime integration is made by this commit.
