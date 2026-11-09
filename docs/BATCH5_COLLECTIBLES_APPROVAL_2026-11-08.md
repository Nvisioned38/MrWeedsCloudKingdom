# Batch 5 collectibles: owner approval and Codex import contract

**Approval date:** 2026-11-08
**Visual status:** Approved and locked, all ten original PNG artworks unchanged.
**Integration status:** **Pending binary asset import, runtime wiring, and device QA.** GitHub text manifests are not proof the artwork PNGs have arrived in the repo.

## Source
Owner-approved handoff ZIP: `Cloud_Kingdom_Batch5_10_Cards_APPROVED_LOCKED.zip` (23.36 MiB in ChatGPT workspace). The ZIP contains ten RGB 1024x1536 full-card composite PNGs, an artwork SHA-256 manifest, review sheet, and instructions. The downloadable ZIP is shared in the artwork conversation; it is **not** uploaded to GitHub by this approval-only commit.

Machine-readable approval data: [`art_production/collection/batch5/approval_manifest.csv`](../../art_production/collection/batch5/approval_manifest.csv).

## Integration instructions (Codex)

1. Obtain the actual approved ZIP from the user / connected development handoff. Do not substitute poster crops or regenerate artwork.
2. Verify all ten PNG SHA-256 checksums against the committed manifest before copying anything to runtime assets.
3. Preserve the exact IDs in `03_CONTENT_CATALOG.json`: `black_truffle`, `blueberry_pancakes`, `uncle_snoop`, `chimera`, `green_cheese`, `minute_man_og`, `mamba`, `ghosts_graveyard`, `cloud_nine`, `neon_nugget`.
4. Use artwork as approved. These PNGs are *full-card RGB composites* with blank title, info, rarity, and effect areas, **not** separate transparent overlays; Flutter supplies real dynamic names/rarity/effects/stats and cannot treat baked decorative stat bars as actual gameplay state. If this conflicts with modular card layout, escalate the exact integration issue rather than silently repainting it.
5. Maintain locked wood-and-gold framing and canonical branding; no story spoilers or unapproved new protagonists. Preserve save schema, level content, and current collection unlock states.
6. Mark `art_received`, `hash_verified`, `integrated`, and `S24_visual_QA` as separate evidence-backed states. Keep the catalog at 30 launch collectibles. No claims of V1 release complete until device QA.
7. Follow up with reduced-motion and screen-size checks for card discovery and evolution transitions.

## Next art / engineering sprint: Match-3 animation polish

Implement motion using Flutter/Flame state/tween rendering where possible. Priority one is smooth valid tile swap, invalid-swap rollback, falling tiles, spawning, cascades and combo timing without altering deterministic engine logic; priority two is art-directed power-up effects (butane torch horizontal/vertical fire, Cloud Cup white-smoke vaporize, Prism color pulse, Cloud Bomb puff, crates hit/break, Fog and syrup clear), preferably reusing the previously approved `fx_white_smoke_01..03`, `fx_cascade_streak`, `fx_combo_ring`, and `fx_magic_sparkles` layers. Export incremental alpha PNG frames only when animation cannot be accomplished cleanly by tween/particle/scale/opacity/color effects.

Guardrails: keep visual leaves outside Secret Basement absent; avoid crowns, logo redrawing, new save semantics, later Troll/Nave/Keefler story reveals. Reduced-motion fallback required.

**Owner approval records are not a claim of app deployment.**
