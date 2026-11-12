# Issue #26 — Batch G character asset implementation

This folder separates locked artwork approval from runtime and device readiness.

## Track A: Riff and Mona Chromatic

- 22 standalone PNG exports are retained unchanged under `assets/art/characters/`.
- The copied lock record and approved manifest are in this folder. Their bytes match the files inside the original locked ZIP. `tools/verify_issue26_character_art.ps1` checks the 22 image SHA-256 values against that lock manifest, dimensions, PNG header and RGBA color type.
- The original locked package `Cloud_Kingdom_Batch_G_Riff_Mona_APPROVED_LOCKED.zip` independently rehashed to `23e0a0e1f92d1717344c6ba6d73baf7d266234a83c0903aa8155f5c451adc085`. All 22 standalone archive members byte-match their per-file approval rows and the Flutter runtime copies.
- Dialogue frames render with `BoxFit.contain` and no oval crop, preserving the approved gold frame and retained interior background. UI round and square images remain separately registered.
- Expression keys are explicit and optional on dialogue lines. Riff is used in the existing Chapter 2 kitchen-progress beat and Mona in the existing Chapter 3 collection-clue beat. These additions do not introduce later-story reveals.
- Runtime state is **integrated; S24 visual QA pending**. This is not final V1 visual approval.

## Track B: Chef Blaze, Dr. Cloud, The Collector

- Canonical sheets are copied unchanged under `track_b_review/canonical_sources/`.
- `track_b_review/candidates/` contains 30 rectangular crop proposals (one hero, eight expressions, one UI proposal per character). They are derived from the canonical sheets without changing those originals. They are not approved exports, not included in `assets/`, and not imported by Flutter.
- The candidate audit lists dimensions, alpha distribution, corner alpha and SHA-256. No candidate has fully transparent pixels or a production-ready cutout. Chef Blaze's source has partial alpha throughout the cropped sheet, while Dr. Cloud and The Collector crops are fully opaque; all retain the composite-sheet background. This prevents meaningful exterior-halo assessment. Chef Blaze's hero crop is visibly clipped at the bottom and includes an edge of the title area. Expression crops retain gold panel framing and labels. Dr. Cloud's direction includes the open-topped Cloud Glass; preserve that identity detail in any future approved standalone export.
- See `track_b_review/review/BATCH_G_OWNER_VISUAL_REVIEW.html` for the side-by-side visual package and `character_approval_runtime_status.csv` for separate approval/runtime statuses.
- Standalone exports and runtime import remain **blocked on character-specific owner approval and file-level locked SHA-256 records**.

## Scope safeguards

No changes were made to Match-3 mechanics, animation timing, Cloud Bomb optimization, save schema, existing saved progress, the 30 authored levels, branding, iOS, TalkBack, Batch 5 collectible import, or Phase 3 content.
