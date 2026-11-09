# Match-3 FX sprite sheet approval and Codex handoff

**Owner approval (2026-11-08):** Eight newly created animation FX **source sheets** are approved and locked visually; do not change original pixels. Their hashes and IDs are in [`approved_fx_source_manifest.csv`](../../art_production/match3_fx/approved_fx_source_manifest.csv).

**Binary archive:** `Cloud_Kingdom_Animation_FX_Batch1_APPROVED_LOCKED.zip`, sha256 `4dce3273ec8993f380445de4bb0fd353316eff01ed631e70a1e46a476055dc60`, prepared in the artwork conversation; includes 8 source sheets and 64 independent candidate frame crops with a second SHA-256 manifest. **This text-only GitHub commit does not include those PNG bytes**. Codex needs the actual ZIP to import.

## Exact handoff rules
- Original 8 sheet files are **approved**, byte-for-byte; the 64 4×2 grid crops are **candidate drafts** only. Check effect halo clipping at cell edges, grid seams, idle/scale anchoring, color halos, true transparent alpha, and source staging/order before selecting an in-game sequence.
- Reject overview poster concepts as assets; no baked-up names, HUD, FX dialogs or invented official logo/character modifications.
- Prioritize [Issue #19](https://github.com/Nvisioned38/MrWeedsCloudKingdom/issues/19): code/tween controlled valid tile swaps and rollback, falling and refilling, cascading, then overlay art sequences for Torch, Cloud Cup white smoke, Bomb, Prism, Fog/Syrup and MW crates. Use preexisting approved tile art without regenerating.
- Reuse the existing [Issue #4](https://github.com/Nvisioned38/MrWeedsCloudKingdom/issues/4) FX where possible, don't visually overwrite or swap them without tested new visual sign-off.
- Block game inputs during animation as appropriate, keep deterministic board and schema-3 save data intact. Test S24 Ultra game loop and reduced motion, Android large text/TalkBack, pause/resume, and realistic frame budget.
- Current status is visual source approval; **no runtime art import, animation feature implementation, or device QA is claimed**.

**Tracking workbook:** `Mr_Weeds_Cloud_Kingdom_Asset_Review_v13_Animation_FX_LOCKED.xlsx` prepared for user handoff; not yet imported into this GitHub repository.
