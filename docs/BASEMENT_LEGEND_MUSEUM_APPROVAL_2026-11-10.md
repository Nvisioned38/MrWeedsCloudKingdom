# Basement Legend collectible and Collection Museum: owner art approval

**Owner approval date:** 2026-11-10. Both image masters are **APPROVED & LOCKED** visually. This is **not** runtime acceptance, a claim of binary ingestion, or proof the museum UI is interactive.

- `basement_legend`: final Secret Set Legendary collection-card image. Catalog coverage now **30/30 launch collectible identities have owner-approved art** (some have multiple visual versions). Keep identity/spoilers hidden behind intended discovery gating. Source PNG: 1086×1448 RGB, SHA-256 `a3d075f41357520432911b7efaa03035b390bcd657696ef53e7a300d1e8ce675`.
- `collection_museum_interactive_screen`: final **visual design**, not Flutter logic. Source PNG: 941×1672 RGB, SHA-256 `9c66336df66a903426dd5afb5836413a9bc17703d166f16b7cddd33cc6fb8c80`. Interactive exhibits, card details, selection, locked/empty/featured states, favorites, sorting and filtering require separate engineering. Do not pass off this flattened mockup as implemented buttons or live counters.

Source owner-approved zip: `Cloud_Kingdom_Basement_Legend_Museum_APPROVED_LOCKED.zip`, SHA-256 `1aee7e8d5e891d58c2b0980c9e7b7ed39f1988e289f8257324c59069b9a38d58`. Original two PNGs are preserved byte-for-byte in archive. **GitHub text approval record only; actual PNG binaries are in owner artwork handoff, not committed by this note.** Machine-readable source hashes: [manifest](../art_production/collection/basement_legend_museum_2026_11_10/approved_sources.csv).

## Development intake
1. After current Issue #27 performance scope is complete or the owner reprioritizes, obtain ZIP and verify source hashes.
2. Match `basement_legend` to existing `03_CONTENT_CATALOG.json` identity; do not insert duplicate collectible records or bypass unlock conditions.
3. Retain approved wooden/gold card framework, exact official logos as standalone overlays where required, and dynamically render labels, rarity, effects, stats, evolution, progress and rewards from Flutter state. Baked decorative progress graphics in the source are visual guides only.
4. Museum: implement actual touch targets/semantics/navigation and responsive layers as new standalone exports or Flutter widgets, with independent locked/empty/favorite/exhibit interactions and reduced motion support; do not stretch flattened mockup as interactive UI.
5. Preserve all gameplay, save schema, existing canon, and V1 spoiler firewall. QA on isolated S24 device before claiming deployment.

**No need to modify or interrupt active Issue #27** which is the Cloud Bomb performance optimization.
