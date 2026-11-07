# Phase 2C V1 — Automation Dispatch & Source Package

## Status
- **Owner authorization:** Proceed with approved V1 implementation, including newly supplied UI art. No routine approval pauses.
- **Codex work ticket:** [Issue #3](https://github.com/Nvisioned38/MrWeedsCloudKingdom/issues/3).
- **Remaining asset transfer:** The user-provided 79 source PNG files and original v9 tracker exist in ChatGPT's handoff archive, **not yet in GitHub**.
- **Automated build:** [Android V1 preview workflow](../.github/workflows/v1-android-preview.yml) runs on `main` pushes / PRs and uploads debug APK plus SHA if all checks succeed.
- **APK release status:** **not yet V1 visually accepted**. An automated build of the unmodified game is a technical preview, not evidence of new art integration or device QA.

## Consolidated transfer package

Owner-facing archive:
`CloudKingdom_V1_AUTOMATION_HANDOFF.zip`

- SHA-256: `b6b68bdb7a0fdcf009521d0c068f8cf22171683161d97293654d352aa5401620`
- Size: **198,717,500 bytes**
- Contents:
  1. `CloudKingdom_V1_Codex_Art_Source_Pack.zip`: 72 curated V1 source PNGs, original v9 XLSX, source inventory and hashes.
  2. `CloudKingdom_Nov06_Collection_UI_Supplement.zip`: 7 newly supplied collection/museum UI originals, supplement manifest, v9-preserving addendum.
  3. `CODEX_V1_IMPORT_ART.py`: checksum-verified, non-destructive source import script, tested locally; counts all 72 source PNGs including five nested board-state images, plus seven supplemental originals.
  4. `CODEX_V1_README.md`: precise intake, sprite-export, and rollout instructions.

The owner must transfer this ZIP to the Codex working directory or another directly accessible location; **neither a GitHub issue link nor this Markdown alone transfers binary ZIP bytes**. GitHub connector write APIs available to this ChatGPT session accept text or base64 content but not a local binary file path. No Codex task was started directly from this ChatGPT session.

## Start / finish for coding agent

After actual source-package access is established:

```bash
python CODEX_V1_IMPORT_ART.py --repo /absolute/path/to/MrWeedsCloudKingdom
```

Inspect `AGENTS.md`, `07_CODEX_PHASE_2C_V1_IMPLEMENTATION.md`, `docs/V1_V9_ZIP_INTAKE_AUDIT.md`, `docs/V1_COLLECTION_UI_NOV06_SUPPLEMENT.md` and `docs/V1_QA_CHECKLIST.md`; work through Issue #3. Push code and verified production art, not raw composite masters. Verify the CI APK and SHA; report device installation separately.

## Visual and story guardrails

- Exact standalone canonical official Mr. Weed's and Cloud Cup logos are still missing from the owner ZIP. Do not synthesize or trace them.
- Preserve approved character identities and V1 30-card / 30-level data.
- UI collection count, selected filters, navigation states, card status and evolution stages come from runtime data.
- No full Higher Art Gallery unlock from the pictured navigation button; after Level 30 Gallery remains preview only.
- Exclude villain Lord Nave, Copycat Cloud Co., Troll betrayal, and Keefler Elves reveals from V1.

## Available automation vs actual task launch

The **GitHub Actions pipeline is genuinely installed and is capable of automatically creating an Android APK artifact after a successful push**. GitHub Issue #3 is a ready-to-run task specification. **Issue creation is not itself a Codex session launch**. An authorized Codex environment or GitHub Coding Agents assignment is needed to initiate independent coding, and the art ZIP must be made accessible to that agent.

This document intentionally distinguishes prepared, dispatched, executing, tested and released states rather than over-claiming unattended work.

## 2026-11-07 accessible-source and build status

The accessible `Game Art.zip` was inspected and its seven environment/preview originals were integrated with hashes and traceability. Its SHA-256 (`4a1824f098c498ffeebdfa1c90ab697f039ecc06cccdecccee29216978935739`) differs from the consolidated handoff package hash above. The expected consolidated archive and v9 workbook were not located, so P0 branding/sprite approval and final art acceptance remain open. A 48-test-clean, analyzer-clean arm64 debug technical preview was built; see `docs/V1_QA_CHECKLIST.md`. Samsung S24 Ultra ADB authorization is still pending. This checkpoint does not claim a polished V1 release.

## 2026-11-07 v10 workbook and phone availability update

The owner supplied the v10 Standalone Assets workbook (SHA-256 `a9256d1d2802226782ab0a4ab23268c0e6eb62309c5a075052925cc03808e3c0`), superseding the earlier v9 approval-status blocker. Exact BR-001 and BR-002 canonical masters and the BR-003 v1 title treatment are now accessible and integrated unchanged, with hashes and row IDs in `assets/art/manifest.json`. BR-005/006 standalone cropped exports named in the workbook were not separately located; the canonical masters are used directly. The Samsung S24 Ultra now reports ADB state `device` (authorized), enabling install/run QA without uninstalling or clearing app data.

The v10 arm64 APK was updated in place on the phone and cold-launched. The title, Cloud House and Level 3 board were visually checked; existing Level 3/210 coins/2 stars remained visible. The board opened without a move. Full turn/win/reward and accessibility/performance QA remain unverified. Current build SHA: `DDF1678FD10B2FC93E07F558D55005BBE2CBD3F3A0E68A48FACF2AF6FE65EA82`.
