# Batch G standalone exports: Chef Blaze, Dr. Cloud, The Collector

**Owner sign-off:** November 11, 2026. **All 24 individual transparent PNG exports are APPROVED and LOCKED, byte-for-byte.** Do not redraw, recolor, regenerate, re-crop, compress, resize or otherwise modify approved source/export pixels. Source files are approved design references; do not substitute past incorrect character generations.

**Visual approval:** complete. **GitHub binary import, Flutter wiring, and S24 QA:** NOT DONE by this approval commit.

## Downloadable owner handoff
- Filename: `Cloud_Kingdom_Batch_G_Chef_Dr_Collector_24_EXPORTS_APPROVED_LOCKED.zip`
- SHA-256: `15e1a83c0695be8a3781bc6e2ea69783e2a3abd9ac412c58846f0d7dbb4d2292`
- 24 approved RGBA PNGs: **3** hero portraits (896×1152), **15** emotion busts (512×512), **6** UI portraits (256×256).
- Also in ZIP: **3 original unchanged approved RGBA master sheets**, review contact sheet/JPEG previews, full approved export manifest, source hashes, `codex_asset_mapping.json`, `verify_locked_exports.py`, `README.md`.
- Exact individual PNG hashes: [Approved export manifest](../art_production/characters/batch_g_three_trolls_2026_11_11/approved_export_manifest.csv). **Local receipt verified 2026-11-12:** the exact ZIP is in the ignored development intake folder; its archive SHA-256 and included verifier passed. The PNG binaries are integrated in the Issue #26 branch and individually checked against this manifest. Isolated S24 visual QA passed for all three heroes, icons, expression sets and applicable story portrait cards; evidence is in `docs/evidence/issue26/DEVICE_QA.md`. The source ZIP remains local and is not committed. Owner review of the integrated presentation remains pending.

## Canonical character identity / actual game keys

| Character ID | Existing portraitAssetKey | Existing fullBodyAssetKey | Approved pack |
|---|---|---|---|
| `chef_blaze` | `portrait_chef_blaze` | `character_chef_blaze` | `exports/chef_blaze/*` |
| `dr_cloud` | `portrait_dr_cloud` | `character_dr_cloud` | `exports/dr_cloud/*` |
| `the_collector` | `portrait_collector` | `character_collector` | `exports/the_collector/*` |

Keys above are from existing `assets/data/characters.json`. Do not create duplicate character IDs. `hero.png` files are large character **portraits**, not separately certified complete full-body turnarounds. Do not imply full-body silhouette coverage not present in the art.

### Steps when the owner/Codex initiates integration
1. Keep active [Issue #27](https://github.com/Nvisioned38/MrWeedsCloudKingdom/issues/27) Cloud Bomb profiling uninterrupted; queue this art work in [Issue #26](https://github.com/Nvisioned38/MrWeedsCloudKingdom/issues/26).
2. Receive the exact **approved ZIP bytes** into Codex's workspace; verify archive SHA-256 listed above and run `python verify_locked_exports.py` from its extracted root. The included script validates 24 RGBA PNGs, dimensions and per-file SHA-256 plus the original source-master hashes. Stop on any mismatch.
3. Copy 24 untouched PNG files into a dedicated versioned character assets directory, avoiding destructive overwrites of existing art. Wire them to the current `assets/data/characters.json`, art registry, and Flutter assets declaration. Preserve all existing IDs and the save schema.
4. Dialogue expression availability is **per character**, not a uniform global enum: `chef_blaze` has happy/excited/thinking/determined/playful; `dr_cloud` has happy/surprised/thinking/curious/determined; `the_collector` has excited/surprised/thinking/determined/satisfied. Unknown states should gracefully select an approved neutral/UI portrait rather than fabricate expressions. Keep dynamic dialogue text and speaking identity in Flutter.
5. Use `*_hero.png` in character details / story callouts and `*_icon_*.png` in UI. Verify cropping, alpha edges, transparent hair/glass effects and 256px legibility at intended device sizes, on both light and dark backdrops. Dr. Cloud's canonical signature Cloud Glass has an **open mouth**, is pear-shaped and emits smoke; never replace with sealed lab flask.
6. Use existing V1 story navigation, interactable dialogue actions, accessibility semantics, Reduced Motion, scalable text, and existing unlock gates. Preserve friendly versions of all Trolls, no premature betrayal, Nave, Copycat Cloud Co. or Keefler spinoff reveals. All official Mr. Weed's/Cloud Cup logos are separate exact originals, not drawn from generated posters.
7. Verify format/analyze/test/build and asset checksum gates. On-device acceptance should use safe isolated `com.mrweeds.cloudkingdom.qa` package, user 0, **no uninstall/data clear**. Respect Issue #21 guarded install path and preserve production saves. Record S24 screenshot evidence for each character and representative expressions.
8. Log separately: **ART_APPROVED_LOCKED** (done); **PNG_BINARY_RECEIVED** (pending); **HASH_VERIFIED_BY_CODEX** (pending); **FLUTTER_INTEGRATED** (pending); **S24_DEVICE_VERIFIED** (pending). Do not say deployed merely from signoff.

## Source master hashes
- Chef Blaze original `chef_blaze_expression_sticker_sheet.png`: `7956377b3a785251c0b9dc1817272d2f8b09fe0d93398f1de303465e6b4897d1`
- Dr. Cloud original `dr._cloud_expression_asset_pack.png`: `f8062d2bbb699af8b6cf9c603c3c12c3aaf506f97444882475ac6a6ed09ac0e7`
- The Collector original `the_collector_expression_sticker_sheet.png`: `11afdae72246f740c72fd18339c70f6d2bbf62fda86be82ea5c4bb270e51ce5e`

**Result:** This approval record is an authoritative ready-to-import design handoff, not a claim of runtime status or a request to terminate ongoing Issue #27 work.
