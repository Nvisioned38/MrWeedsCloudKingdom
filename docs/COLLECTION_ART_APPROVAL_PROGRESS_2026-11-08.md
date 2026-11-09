# Collection artwork inventory — owner approvals through Batch 5 (2026-11-08)

This is an **approval registry**, not proof of binary-art import or runtime integration.

| Art batch | Approved/locked unique image versions | Purpose | Catalog coverage |
|---|---:|---|---|
| Batch 1 | 10 | 2 launch strains + 8 optional concepts | BlueBEARy Pancakes, Sugar Skull Sherbet |
| Batch 2 | 9 | 9 launch-catalog IDs, including 2 alternate visual treatments | Purple Voodoo, Baked Alien, BlueBEARy Pancakes, Cortez's Curse, Exotic Kush, Blackberry Kush, Sugar Skull Sherbet, Avatar OG, Blue Walker |
| Batch 3 | 10 | 10 additional launch-catalog IDs | Soldier Field Haze, Bong Berry Blitz, Blue Slurpicana, Cranberry Haze, Creme de la Chem, Chocolate Mint, Biscotti, Cocoas of the Mintway, Blueberry Diesel, Strawberry Safety |
| Batch 4 | 10 | 10 optional expansion concepts | Not in launch catalog; do not silently add as playable strains |
| Batch 5 | 10 | 10 additional launch-catalog IDs | Black Truffle, Blueberry Pancakes, Uncle Snoop, Chimera, Green Cheese, Minute Man OG, Mamba, Ghosts in the Graveyard, Cloud Nine, Neon Nugget |

**Totals:** 49 owner-approved/locked **image versions**, covering **29 distinct launch-catalog IDs of 30** in `03_CONTENT_CATALOG.json`. Batch 1/B2 share two IDs as alternate approved treatments; 18 images belong to optional expansion concepts and must not inflate the 30-card runtime collection. **Only missing launch collectible illustration: `basement_legend` (Basement Legend, Secret Set, Legendary).**

**Batch 5 authoritative SHA-256:** [approval manifest](../art_production/collection/batch5/approval_manifest.csv). User-owned locked local workbook: `Mr_Weeds_Cloud_Kingdom_Asset_Review_v12_Batch5_Locked.xlsx`, which preserves v11 and reconciles all 49 versions with exact hash-verified prior ZIP manifests. Workbook XLSX and images have **not** been committed through this GitHub text-only update.

**Runtime boundaries:** All collectible images are visual approvals; no claim they were imported into `assets/art`, connected to `lib`, rendered on S24 Ultra, or tested. Existing locked wood-and-gold card system and rarity/evolution components are separate; labels, stats, rarity, and evolution are live Flutter fields. These original card PNGs contain blank text regions but are full-card RGB composites, not transparent individual panels.

**Next V1 animation issue:** [#19 Tile swaps, cascades and power-up FX](https://github.com/Nvisioned38/MrWeedsCloudKingdom/issues/19). Prioritize motion/tween logic, then reuse approved particle/smoke effects and produce new alpha-frame artwork only if needed. Preserve existing deterministic board and save IDs.

Story firewall: no premature Nave/Troll betrayal/Keefler reveals; no unapproved new art, crowns, or unofficial logo redrawing. V1 remains a technical preview until owner device QA.
