# Approved animation FX Batch 2: Gravity/Refill and Victory

**Owner visual approval:** 2026-11-08. **Status:** Two source sheets APPROVED & LOCKED, no changes allowed to approved source PNG bytes.

- `FX-ANIM-009`: Gravity/refill landing (Cloud Puff), original `glossy_magical_cloud_tile_animation.png`, SHA-256 `465bd4fa8fcb72bd89d3d068ffe672f28e53cf85b12626e0e9689c2a4225b559`.
- `FX-ANIM-010`: Golden star victory celebration, original `magical_star_victory_celebration_spritesheet.png`, SHA-256 `701436a705e35c068ee774ed06ee2f92f40b5ac4b3aae9f4e4ebb275f7ef5a1e`.

Download package available from artwork conversation: `Cloud_Kingdom_Animation_FX_Batch2_APPROVED_LOCKED.zip`, archive SHA-256 `d9d520219cc9097641e350151bcb7e07250765479b09d4b8747db279e9420eb1`. Contains two preserved 1774×887 RGBA original PNG sheets, 16 cropped **candidate** frames, separate hash manifests, 2 animation preview GIFs, and README. **No PNG bytes have been committed to GitHub by this approval record.**

Updated owner asset tracker: `Mr_Weeds_Cloud_Kingdom_Asset_Review_v14_Animation_FX_Batch2_LOCKED.xlsx`; updated IDs and candidate frame tracking are in that user-downloadable workbook.

## Codex intake + gameplay restrictions

1. Obtain user-approved ZIP, verify source hashes, and retain exact source sheets unchanged.
2. All 16 candidate frame crops (4×2 each) require **seam, alpha halo, anchoring and continuity QA**; generated overview posters are not valid production exports.
3. Gravity and refill **must use engine-state-driven position tweens** (see `docs/MATCH3_ANIMATION_TIMING_SPEC.md`), keeping deterministic board and V2 tile sprites. The Cloud Puff source sheet may supply an FX overlay if it passes verification, not substitute the tile art.
4. Victory sequence may decorate the win screen but star counts, score, progress and MW rewards must remain dynamic and accessible; no baked star totals or reward claims.
5. Test reduced motion, pause/resume, device performance and real S24 visual acceptance. Integration and runtime acceptance are **not** implied by owner design approval.

Track coding in Issue #19 and S24 visual QA in Issue #12. Do not introduce future story spoilers, crowns, logo redraws or cannabis leaves outside the Secret Basement.
