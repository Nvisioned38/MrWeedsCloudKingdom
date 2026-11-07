# V1 Approved Artwork Intake and Source-of-Truth Register

## Verified availability (repository audit, 2026-11-06)

- GitHub `main` at `10ca8a5b0bdcb086c294785544d40732a16ef524` includes `assets/data/` but **does not include `assets/art/`**.
- `lib/presentation/art_registry.dart` contains intended relative PNG paths. They are placeholders for future imports, not existing file evidence.
- `pubspec.yaml` lists data assets, **not** an `assets/art/` bundle.
- The owner **supplied and we inspected** the authoritative v9 workbook alongside Game Art ZIP in ChatGPT on 2026-11-06. **Original binaries have not yet been transferred to GitHub/Codex.** See `docs/V1_V9_ZIP_INTAKE_AUDIT.md` for source matches and exact hashes; older trackers do not override v9.
- Approved art concepts/character sheets may still need separate exported transparent layers, correct slicing, resizing, and cropping before production use.

## Intake sequence

1. The owner has already supplied the **actual v9 XLSX** in ChatGPT. Codex must import and read that unchanged workbook from the curated V1 art intake package, or another verified transfer, before production approval sign-off. The workbook is NOT yet in this GitHub checkout.
2. Owner-supplied Game Art ZIP includes 77 PNG files and three nested ZIPs. A curated V1 intake package with 72 original PNG files and the v9 workbook has been prepared separately, but must still be transferred to Codex. The standalone official Mr. Weed's and Cloud Cup logos BR-001/002 were **not found** in the uploaded ZIP and must be supplied separately. Preserve unmodified source copies; do not use approximated lettering from art boards as substitutes.
3. Codex builds/updates machine-readable `assets/art/manifest.json` with stable in-app art keys, approval row IDs, variants, actual source filename, target filename, expected dimensions/aspect/transparency, import readiness, SHA-256, and QA status.
4. Process originals into game-ready exports in `assets/art/` while retaining source and approval traceability. Recompression/cropping of source is allowed only when it preserves the approved visible content and aspect/identity.
5. Integrate only validated exports; test asset loading; request approval for any visible stylistic change.

## P0 source-package request (exact filenames only when confirmed)

| Priority | Asset or group | Example existing expected runtime key | Original status |
|---|---|---|---|
| P0 | Mr. Weed's official horizontal logo | new brand key | Missing from GitHub |
| P0 | Cloud Cup official logo | new brand key | Missing from GitHub |
| P0 | Approved Cloud Kingdom title treatment (v1 priority) | new brand key | Missing from GitHub |
| P0 | Mr. Weed exact portrait/full-body master | `portrait_mr_weed`, `character_mr_weed` | Missing from GitHub |
| P0 | Cloud House approved exterior | `room_cloud_house` | Missing from GitHub |
| P0 | Lounge approved art | `room_lounge` | Missing from GitHub |
| P0 | High Cuisine Kitchen approved art | `room_kitchen` | Missing from GitHub |
| P0 | Five approved tile source exports and board/frame components | separate board keys | Missing from GitHub |
| P0 | MW crate, reinforced crate, Fog/Syrup, Prism, Cloud Bomb, butane torch, Cloud Cup vaporizer and their effects | separate gameplay keys | Missing from GitHub |
| P0 | Approved Match-3 HUD, moves, objective, and victory UI components | separate UI keys | Missing from GitHub |
| P1 | Chef Blaze and The Collector approved master portraits | `portrait_chef_blaze`, `portrait_collector` | Missing from GitHub |
| P1 | Card base, rarity frames, collection shelf, museum components | new card/UI keys | Missing from GitHub |
| P1 | Specific collectible card illustrations | `card_...` | Missing from GitHub; integrate in approved order |

These are **work categories**, not a substitute for the v9 tracker, and do not assert which exact source image is already exported as a sprite.

## Specific identity constraints

**Brand:** use supplied `FINAL_Logo_Words_HORIZONTAL(1).png` and `LOGO_CloudCup_Horizontal(2).png` unchanged, provided the owner-supplied canonical files match these prior references. Older filenames may be recorded in past notes. Never choose between variants silently when both exist.

**Character:** Mr. Weed must match supplied head/face reference, with default white blank shirt and OK hand sign. Chef Blaze is a rounded-ear moss-gray/olive **Troll**, not Keefler baker Bakie. Do not reveal future betrayal through styling.

**World:** avoid cannabis leaf symbols except Secret Basement; no crowns; white Cloud Cup smoke.

**Tracker review:** v9 has final authority over earlier trackers. Treat locked design approval separately from bytes-ready, asset-in-app, and device-approved status.

## Consolidated blocker report format

Use this table in Codex's closing report when any art is absent:

| v9 Row ID | Art key | Expected original filename | Source supplied? | Export ready? | Integrated? | Required owner action |
|---|---|---|---|---|---|---|

If v9 is missing, leave `v9 Row ID` explicitly **unverified**, rather than inventing IDs or approvals.

No image generation, visual reimagining, substitute AI faces, or third-party lookalike logos is authorized by this intake instruction.

## 2026-11-06 additional Collection UI PNGs

Seven further original PNGs were received and audited separately from the prior Game Art ZIP. See **`docs/V1_COLLECTION_UI_NOV06_SUPPLEMENT.md`** for exact SHA-256 hashes, v9 mapping, and dynamic UI restrictions. The new image versions remain pending new-file sign-off. A companion source ZIP and v9-preserving workbook addendum were prepared in the ChatGPT handoff but **not automatically transferred to GitHub or Codex**. Preserve static plaques/frames, render filters/counts/navigation/card states dynamically. Keep the Gallery preview gate intact.

## 2026-11-07 accessible archive intake update (historical; approval source superseded)

The archive accessible to the Codex checkout was `C:\Users\LifeN\OneDrive\Desktop\Mr Weeds\App_Game\The Build\Game Art.zip`, SHA-256 `4a1824f098c498ffeebdfa1c90ab697f039ecc06cccdecccee29216978935739`. It did not match the expected consolidated handoff ZIP hash recorded above; at that checkpoint no v9 workbook or consolidated handoff ZIP was found. The later v10 update below supersedes the approval-source limitation.

Seven intact environment/preview images from the available archive are integrated: Cloud House restored/damaged, Lounge, two Lounge styles, Kitchen, and Higher Art Gallery preview. Source filenames, per-file hashes, dimensions and audit references are in `assets/art/manifest.json`. The Higher Art Gallery image is only shown in the existing Level 30-gated preview. Fifteen other source candidates are recorded as pending, not runtime-approved assets. Candidate standalone logo images in the archive are not verified canonical brand files and are not shipped as official logos. No isolated Match-3 production tile/blocker/special exports were available; composite artwork remains unsuitable as a set of sprites. The nested app images package is recipe/Higher Art content and was not integrated into runtime features.

## 2026-11-07 — v10 approval workbook supplied

The current approval authority is `Mr_Weeds_Cloud_Kingdom_Asset_Review_v10_Standalone_Assets.xlsx` (SHA-256 `a9256d1d2802226782ab0a4ab23268c0e6eb62309c5a075052925cc03808e3c0`), supplied at `C:\Users\LifeN\Downloads\...`. v10 directly confirms approved status for BR-001/002 official logo masters, BR-003 v1 title treatment, and the imported EN-002 through EN-008 environment images. The exact source masters were found outside the mismatched ZIP: `FINAL_Logo_Words_HORIZONTAL.png` (SHA-256 `e2f18c8ba65b4c622d839bc3c5fcb25e80f26fc4c225b04747e2cc1d5a2aa6c4`) and `LOGO_CloudCup_Horizontal.png` (SHA-256 `86d0345786c3e62e1a57c28213e779efd7614d8838009f626a924d60f3505c4d`). They are imported byte-identically. The approved v10 BR-005/006 cropped export filenames were not separately found, so the manifest records their absence; runtime scales the unchanged master pixels to display bounds.

The v10-referenced v1 title treatment `Game Art/MW_img_CloudKingdomLogo.png` (SHA-256 `641e4725c42393d1557df4d737d83cd45f4ba6afd3f5c4622b2dc9cdd4a6d29f`) is imported unchanged. P0 Match-3 concepts are approved, but standalone sprite exports and board/UI slicing remain outstanding; locked villain-era and later-story visuals are excluded from V1. The v10 release-priority sheet keeps story spoilers reserved for later and sets the initial release boundary.
