# V1 Approved Artwork Intake and Source-of-Truth Register

## Verified availability (repository audit, 2026-11-06)

- GitHub `main` at `10ca8a5b0bdcb086c294785544d40732a16ef524` includes `assets/data/` but **does not include `assets/art/`**.
- `lib/presentation/art_registry.dart` contains intended relative PNG paths. They are placeholders for future imports, not existing file evidence.
- `pubspec.yaml` lists data assets, **not** an `assets/art/` bundle.
- The owner identifies tracker `v9: Brand and V1 Priorities` as current. The **v9 workbook itself is NOT in this repo and was not supplied as a readable original here**. Earlier trackers/notes are reference context only. Do **not** mark any v9 line as verified without seeing that exact workbook.
- Approved art concepts/character sheets may still need separate exported transparent layers, correct slicing, resizing, and cropping before production use.

## Intake sequence

1. Owner supplies the **actual v9 XLSX workbook** in the conversation or the repository. Preserve original workbook rather than creating a guessed reconstruction. Codex should compare P0/P1 decisions against the workbook, and create an asset ID → file/approval matrix.
2. Owner supplies original exact logo/image masters in a named, shareable package or `assets/source_art/` folder; preserve unmodified source copies. Do not use screenshots from old chats as substitutes.
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
