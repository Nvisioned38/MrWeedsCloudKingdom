# Issue #26 — Historical Track B crop review (superseded)

**Superseded by latest main:** Chef Blaze, Dr. Cloud and The Collector already have 24 owner-approved, individually hash-locked standalone PNG exports. See `docs/BATCH_G_THREE_TROLLS_STANDALONE_LOCK_2026-11-11.md` and `art_production/characters/batch_g_three_trolls_2026_11_11/approved_export_manifest.csv`. No artwork redesign or reapproval is needed. This report describes older crop proposals only; they are not the approved files and must not be imported. Runtime intake is pending receipt and verification of the exact approved ZIP (`Cloud_Kingdom_Batch_G_Chef_Dr_Collector_24_EXPORTS_APPROVED_LOCKED.zip`, SHA-256 `15e1a83c0695be8a3781bc6e2ea69783e2a3abd9ac412c58846f0d7dbb4d2292`).

## Status and safety

| Character | Canonical design direction | Standalone export approval | Runtime readiness | S24 character QA |
|---|---|---|---|---|
| Riff | Approved/locked | 11 exports approved and hash-verified | Imported | PASS — S24 in-memory Level 15/16 fixtures; Riff playful portrait and Close Story navigation |
| Mona Chromatic | Approved/locked | 11 exports approved and hash-verified | Imported | PASS — S24 in-memory Level 25/26 fixtures; Mona thinking portrait and Close Story navigation |
| Chef Blaze | Approved/locked | 8 standalone exports approved and hash-locked | NOT IMPORTED — exact ZIP absent locally | NOT TESTED |
| Dr. Cloud | Approved/locked | 8 standalone exports approved and hash-locked | NOT IMPORTED — exact ZIP absent locally | NOT TESTED |
| The Collector | Approved/locked | 8 standalone exports approved and hash-locked | NOT IMPORTED — exact ZIP absent locally | NOT TESTED |

Riff and Mona statuses reflect the current Issue #26 branch and S24 story-fixture record. This old review-only Track B package contains no approved Track B runtime assets. The exact owner-approved archive was not found in the searched Downloads and existing handoff/intake folders. No production app, Secure Folder, saved game, level, Match-3 rule, animation, Cloud Bomb optimization, branding or schema was changed for this package.

## File-level visual and alpha findings

The 30 PNGs are rectangular crops from the unchanged canonical sheets. The source sheets and candidate crops were visually compared side by side in `BATCH_G_OWNER_VISUAL_REVIEW.html`. All 30 candidate PNGs have **zero fully transparent pixels**. Chef Blaze crops have partial alpha values throughout but no zero-alpha pixels; Dr. Cloud and The Collector crops are fully opaque. They therefore retain their source-sheet backgrounds, labels, frames or adjacent panel content. An exterior transparent-edge halo check is **NOT TESTED** because no standalone alpha extraction exists. Dimensions and SHA-256 below are verified against the current review files in `candidate_image_audit.csv`.

| Character | Visual comparison to locked details | Clipping / crop contamination | Transparency / halo |
|---|---|---|---|
| Chef Blaze | Face, ember hair, mustache/goatee, teal/gold uniform, cream apron and skillet are visible and consistent with the source sheet. | Hero crop is clipped at bottom and includes the title-panel edge. Expression labels/frames and UI title area remain. | 0 transparent pixels; partial alpha only. Halo NOT TESTED. |
| Dr. Cloud | Pale hair, bronze goggles, teal coat and open Cloud Glass with white smoke are visible and consistent with the source sheet. | Hero retains background and neighboring panel edge. Expressions and UI retain panel labels/framing. | 0 transparent pixels; fully opaque. Halo NOT TESTED. |
| The Collector | Gray stone skin, dark purple hair, spectacles, plum/gold outfit, watch chain and satchel are visible and consistent with the source sheet. | Hero retains background and neighboring panel edge. Expressions and UI retain panel labels/framing. | 0 transparent pixels; fully opaque. Halo NOT TESTED. |

These checks establish visual correspondence only. The crop files are not suitable for Flutter import. No character identity or artwork pixels were regenerated, repainted, recolored or altered during this review update.

## Exact review images

The hashes below are for these superseded review-only crop images and do not identify the owner-approved exports. Do not approve or import these crops. The authoritative approved standalone filenames, dimensions and hashes are in the latest main manifest; verify their original ZIP and included script before runtime import.

### Chef Blaze

Canonical source: `chef_blaze_LOCKED_SOURCE.png` — SHA-256 `7baf0bc31bc4b6e298a2bf028c557c4fb209d28385cc46dbea31026682ecdad6`.

Locked identity details reviewed: Moss-gray stone skin; ember-orange hair; mustache and goatee; teal/gold chef uniform; cream apron; skillet.

Visual review: The candidate hero matches the locked chef face, hair, uniform and apron, but is cut off at the bottom by the expression-panel edge and includes part of the title panel. The expression crops retain labels, gold frames and sheet backgrounds; the UI crop includes the branded title area.

| Candidate review file | Dimensions | Alpha counts (transparent / partial / opaque) | Review-file SHA-256 | Status |
|---|---:|---:|---|---|
| `expression_01_candidate.png` | 132 × 140 | 0 / 18480 / 0 | `06aff9e54bf041386383d242c0b379690bf1fbd701d9afbe7cb6370300267350` | REVIEW ONLY; not a final export |
| `expression_02_candidate.png` | 132 × 140 | 0 / 18480 / 0 | `d04c30b8846d9ac19b58904fef35288bb784baf8c4ae0df74d80264f4940b568` | REVIEW ONLY; not a final export |
| `expression_03_candidate.png` | 132 × 140 | 0 / 18480 / 0 | `86e4a7e7b56c9bba2067aa0fe88e28cd4a812495bc6eef0b0e92eb0d77512031` | REVIEW ONLY; not a final export |
| `expression_04_candidate.png` | 132 × 140 | 0 / 18480 / 0 | `07ed8dd969a45ab83db92a3ee808914799ec3cfe918ab7edd4f1ee41df54889a` | REVIEW ONLY; not a final export |
| `expression_05_candidate.png` | 132 × 140 | 0 / 18480 / 0 | `0c1780f124690a1d0716a0bb2b8e1aa98757f8bbdfdc6d7bd87e2c3dc71dc027` | REVIEW ONLY; not a final export |
| `expression_06_candidate.png` | 132 × 140 | 0 / 18480 / 0 | `a74ea240cf78c4a201fd6acc61791f0f449c302824b8cbf044c71ac4ba553ab1` | REVIEW ONLY; not a final export |
| `expression_07_candidate.png` | 132 × 140 | 0 / 18480 / 0 | `dcc319ad142b62173303299a0c8e3314d38bd6aecc6063286c28e1913f89eb69` | REVIEW ONLY; not a final export |
| `expression_08_candidate.png` | 132 × 140 | 0 / 18480 / 0 | `29f9fc2725b8b10737ed3eda8817d3f6c47e15278589586617d27ed1aa808f67` | REVIEW ONLY; not a final export |
| `hero_candidate.png` | 535 × 700 | 0 / 374500 / 0 | `30d7d1ddc7264a3ab7b5e8034689160b9b88dc7388c4edcd8560acfae1cfe752` | REVIEW ONLY; not a final export |
| `ui_candidate.png` | 106 × 106 | 0 / 11236 / 0 | `76a9e376054fe5acea0188b57b480e9ac72de4e2a6df0bbbb802f1ad4ed29383` | REVIEW ONLY; not a final export |

### Dr. Cloud

Canonical source: `dr_cloud_LOCKED_SOURCE.png` — SHA-256 `c9d0660519eb47a78d538e3628955427a97d44996282211c111ec89716213043`.

Locked identity details reviewed: Moss-gray/olive stone skin; pale lavender-gray hair; bronze goggles; teal-blue lab coat; open-top pear-shaped Cloud Glass with white smoke.

Visual review: The hero crop shows the locked goggles, coat, hair and open Cloud Glass presentation, but retains the painted sheet background and a neighboring panel edge. Expression crops retain their labels and frames; the UI crop contains surrounding panel artwork.

| Candidate review file | Dimensions | Alpha counts (transparent / partial / opaque) | Review-file SHA-256 | Status |
|---|---:|---:|---|---|
| `expression_01_candidate.png` | 95 × 160 | 0 / 0 / 15200 | `13e42e6a5d31cab790cb0c9f3c989160892ad96b49f69b2c025db26d34801377` | REVIEW ONLY; not a final export |
| `expression_02_candidate.png` | 95 × 160 | 0 / 0 / 15200 | `9e9847548a83e82a78d23dd31bd46dc8613681c3389a9e17ba488563a909c976` | REVIEW ONLY; not a final export |
| `expression_03_candidate.png` | 95 × 160 | 0 / 0 / 15200 | `cd70c6eb137bca58c4acf94accf4f967117027c2d8da1f2c86889518067284d7` | REVIEW ONLY; not a final export |
| `expression_04_candidate.png` | 95 × 160 | 0 / 0 / 15200 | `333b2a8fcce6f2e65d7920141352ce584cb7b3c68bcccf93bcacb30b4a100834` | REVIEW ONLY; not a final export |
| `expression_05_candidate.png` | 95 × 160 | 0 / 0 / 15200 | `190fe930fecd4beddf6b9b544921b172b8ec10da16b502bc53b24f05a0df518b` | REVIEW ONLY; not a final export |
| `expression_06_candidate.png` | 95 × 160 | 0 / 0 / 15200 | `794bf1975d28c6e2fb5ba90e021cf509d83bb944d6ea7cee2523317db2f2f050` | REVIEW ONLY; not a final export |
| `expression_07_candidate.png` | 95 × 160 | 0 / 0 / 15200 | `093a2379b3173bff03a101513c8ef0d9cb760bc530dda2d9f95ca55c1931391b` | REVIEW ONLY; not a final export |
| `expression_08_candidate.png` | 95 × 160 | 0 / 0 / 15200 | `ee43a364c480d38005b12cacd9153c8eb8d235821308c68f94f1dada9c9d2255` | REVIEW ONLY; not a final export |
| `hero_candidate.png` | 345 × 843 | 0 / 0 / 290835 | `0098f058a50ddb1685dbb72bad586c9ae78cf71b2d20d24d18cd6ad7c74f314d` | REVIEW ONLY; not a final export |
| `ui_candidate.png` | 220 × 235 | 0 / 0 / 51700 | `964dd7e81d80f7e35dddadfdc2662d34707cbd393c3cff3b21567ded06d26d3b` | REVIEW ONLY; not a final export |

### The Collector

Canonical source: `the_collector_LOCKED_SOURCE.png` — SHA-256 `f8bb255370ba6a2dd78df7d8d6c827f7dae0b2e7f90696a7ad2a191af7eb829b`.

Locked identity details reviewed: Moss-gray stone skin; charcoal-purple hair; spectacles; plum/gold curator outfit; watch chain; satchel.

Visual review: The hero crop visibly matches the locked spectacles, hair, plum/gold outfit, chain and satchel, with the full shoes visible, but includes the painted sheet background and neighboring panel edge. Expression crops retain their labels and frames; the UI crop contains surrounding panel artwork.

| Candidate review file | Dimensions | Alpha counts (transparent / partial / opaque) | Review-file SHA-256 | Status |
|---|---:|---:|---|---|
| `expression_01_candidate.png` | 91 × 160 | 0 / 0 / 14560 | `84ba4da7e9aa9f90d6af4838ea83f82de21f5776c4b03b98568565202902d036` | REVIEW ONLY; not a final export |
| `expression_02_candidate.png` | 91 × 160 | 0 / 0 / 14560 | `4d0682915466cce0e9df5bed5723498e28acdd8c0466a78390991d2388b9e5f7` | REVIEW ONLY; not a final export |
| `expression_03_candidate.png` | 91 × 160 | 0 / 0 / 14560 | `91516a3a43fdad6b8b2cc5dd2584c42a1178090d3b4a375e89a65e19900d173f` | REVIEW ONLY; not a final export |
| `expression_04_candidate.png` | 91 × 160 | 0 / 0 / 14560 | `e264b64b4954e7c478868e4d03e54a0f8aecb83d2bfa9c3f96191ad740fc5a81` | REVIEW ONLY; not a final export |
| `expression_05_candidate.png` | 91 × 160 | 0 / 0 / 14560 | `bf60d0007bd343a1c9ca72c31de3cf4cc3bc223dc3ef0991433a676dbf785625` | REVIEW ONLY; not a final export |
| `expression_06_candidate.png` | 91 × 160 | 0 / 0 / 14560 | `9f5299b53e90313b3490b61078a7416edb5ad46c757b58b3ff37036b8ec895e7` | REVIEW ONLY; not a final export |
| `expression_07_candidate.png` | 91 × 160 | 0 / 0 / 14560 | `8f23f0c158e27e1ce6785faca77e7f5eb83175f6e45fa37edf213200441698e3` | REVIEW ONLY; not a final export |
| `expression_08_candidate.png` | 91 × 160 | 0 / 0 / 14560 | `694175cf7cfd76dcc354c5a9fed8fce4e48121ed32d04563cc1137bbac1ddd61` | REVIEW ONLY; not a final export |
| `hero_candidate.png` | 358 × 725 | 0 / 0 / 259550 | `c0f805a86ea7200b6bea345822d66826df5cb58706f916c6b324bf020908ab5b` | REVIEW ONLY; not a final export |
| `ui_candidate.png` | 190 × 190 | 0 / 0 / 36100 | `f6048d7bf49de79f87bbfc7ec08a2eac867b6a5a558d0a150ddb33764d0f077e` | REVIEW ONLY; not a final export |

## Binary receipt required before runtime

The 24 standalone exports are already owner-approved. The exact archive binary is not present locally; copy the original into `art_production/characters/batch_g_three_trolls_2026_11_11/intake/` and verify its locked SHA before use. These 30 older crop roles are references only:

- Chef Blaze: `hero_candidate.png`, `expression_01_candidate.png` through `expression_08_candidate.png`, and `ui_candidate.png`.
- Dr. Cloud: `hero_candidate.png`, `expression_01_candidate.png` through `expression_08_candidate.png`, and `ui_candidate.png`.
- The Collector: `hero_candidate.png`, `expression_01_candidate.png` through `expression_08_candidate.png`, and `ui_candidate.png`.

Do not substitute any of these historical crops for the 24 approved standalone exports.

## Package contents

- `BATCH_G_OWNER_VISUAL_REVIEW.html`: canonical reference next to hero, eight expression and UI crop proposals for each character.
- `candidate_image_audit.csv`: per-file dimensions, alpha pixel counts, corner alpha, SHA-256 and review status.
- `character_approval_runtime_status.csv`: separate source approval, export approval, runtime readiness and device QA states.
- `../canonical_sources/` and `../candidates/`: unchanged sources and review-only crop proposals.
