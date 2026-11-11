# Issue #27 — S24 Cloud Bomb performance comparison

**Branch:** `performance/issue-27-cloud-bomb`
**PR:** [#28 (draft)](https://github.com/Nvisioned38/MrWeedsCloudKingdom/pull/28)
**Base:** `main` at `fbf0dce1b7e1c2b540fe9a52da5d8b0e2ddd4703`; main CI run 42930607499 passed before work began.
**Device:** Samsung Galaxy S24 Ultra `R5CX156CZNF`, Android user 0; display mode 120.00001 Hz.
**Package:** isolated `com.mrweeds.cloudkingdom.qa` only.

## Finding and code change

Four comparable 3,000-sample Level 8 runs show the renderer allocated 64 per-piece/blocker `saveLayer`s on each idle board frame and each Cloud Bomb frame before the change. The board's idle pieces are fully opaque, so these offscreen layers added no visual work. Cloud Bomb frames added 24 translucent image draws, including eight smoke-plume draws, and one vector pulse; those draw counts and all effect code were unchanged by the optimization.

`CloudBoardGame` now skips the per-piece and blocker `saveLayer` only when opacity is at least 1. Faded draws keep their existing layer and alpha. This reduces per-frame `saveLayer` calls from 64 to 0 at idle and from 64 to 8 during the Cloud Bomb phases, while preserving the effect's smoke, colors, 3×3 coverage, particles and timing.

## Controlled S24 results

Each run used the same saved Level 8 board and inputs: select `r2c5`, select `r3c5` to create the Cloud Bomb; select `r4c6`, then `r4c5` to trigger it. Both runs produced 2 accepted swaps, 7 match waves, 34 cleared tiles, 32 gravity drops, 36 refills, 2 blocker changes, one Cloud Bomb created and triggered, one Rocket created, and maximum cascade depth 4. No run completed the level.

All captures have 3,000 samples at 120 Hz and approximately 24,960 ms of active sampling. Each has 2,750 `board_idle` samples, 32 `board_transition`, 78 `clear_effect`, 119 `gravity_effect`, and 13 Cloud Bomb frames (3 onset, 7 midpoint, 3 fade). Per-phase Cloud Bomb samples are small; use the repeated direction as diagnostic evidence and do not treat individual phase percentiles as high-confidence estimates.

| Run | Overall raster p50 / p90 / p99 / max (ms) | Overall total span p50 / p90 / p99 / max (ms) | Samples over 8.333 ms | Samples over 16.67 ms |
|---|---:|---:|---:|---:|
| Before 1 | 5.044 / 5.397 / 6.035 / 9.352 | 8.125 / 8.647 / 9.535 / 14.426 | 904 / 3,000 | 0 |
| Before 2 | 5.080 / 5.490 / 6.115 / 14.857 | 8.191 / 8.754 / 9.671 / 21.027 | 1,065 / 3,000 | 1 |
| After 1 | 3.987 / 4.193 / 5.372 / 9.177 | 6.442 / 6.804 / 8.176 / 12.288 | 23 / 3,000 | 0 |
| After 2 | 4.032 / 4.234 / 4.869 / 14.476 | 6.497 / 6.837 / 7.901 / 19.854 | 19 / 3,000 | 1 |

Idle raster p90 averaged **5.406 ms before** and **4.196 ms after** (22.4% lower). Idle total-span p90 averaged **8.650 ms before** and **6.784 ms after** (21.6% lower). Combined total-span samples over the 8.333 ms refresh interval fell from **1,969/6,000 (32.8%)** to **42/6,000 (0.7%)**. Samples over 16.67 ms were **1/6,000 both before and after**, so this change did not reduce that rare outlier count.

Cloud Bomb phase raster p90, before → after (ms):

| Phase (samples per run) | Run 1 | Run 2 |
|---|---:|---:|
| Onset (3) | 8.445 → 8.330 | 6.755 → 6.644 |
| Midpoint (7) | 6.286 → 5.919 | 6.448 → 5.547 |
| Fade (3) | 6.511 → 5.162 | 6.211 → 3.821 |

Scene composition was stable across both before/after runs: idle `imageDraws=64`; Cloud Bomb `imageDraws=88`, `translucentImageDraws=24`, `cloudBombSmokeDraws=8`, and `vectorDraws=1`. Save layers changed from 64 to 0 for idle, and 64 to 8 for Cloud Bomb. The remaining eight are alpha-faded layers and were intentionally retained.

## Visual and save verification

- The same starting Level 8 board was captured before and after. In the board crop (1,050,600 pixels), **0 pixels** differed by more than 2 RGB levels; maximum channel difference was 0.
- Before/after active-cascade screenshots show the same Level 8 objective state, score and Cascade ×3. The screenshots were captured at slightly different animation instants, so moving-frame pixels are not claimed as an exact image diff. No effect asset, draw order, alpha, geometry or timing code changed.
- QA `FlutterSharedPreferences.xml` SHA-256 before install and after all four runs: `bf7f8095e9781e59fad2879a8fab50142d3764c255af7a369d31cfe46fca2b90`.
- Every gameplay action stayed inside user-0 QA app. Production app, Secure Folder, level completion, first-clear rewards and saved progression were not touched.
- Device screenshots: [before start](s24_level8_run1_start.png), [earlier pre-optimization cascade](s24_cloud_bomb_trigger.png), [after start](s24_issue27_after_board_start.png), [after active cascade](s24_issue27_after_run2_active.png). The cascade shots are illustrative and were captured at different instants; exact pixel parity is asserted only for the static board crop.

## Complete device records

The logger now keeps the aggregate `CK_FRAME_TIMING` JSON within the Android log-line limit and emits one complete `CK_FRAME_TIMING_SCENE` JSON record per scene. These four files contain the parsed, complete aggregate and scene records for each 3,000-frame run:

- [Before run 1](s24_cloud_bomb_run1.log)
- [Before run 2](s24_cloud_bomb_run2.log)
- [After run 1](s24_cloud_bomb_after_run1.log)
- [After run 2](s24_cloud_bomb_after_run2.log)

## Verification

- Focused profiler tests: **8/8 passed**.
- Full Flutter suite: **85/85 passed**.
- `flutter analyze`: **clean**.
- Approved Issue #4 artwork: **37/37** SHA-256, PNG signature, dimensions and 8-bit RGBA checks passed.
- QA replace-install safety checks passed; APK package, signer and version verified before installation. No uninstall or data-clear fallback was used.
- Isolated QA profile APK SHA-256: `02e41c868506597269cab309020a58478880e3ab5993a859a8d4d0b5fd3e2f1c`.
- Isolated QA debug APK SHA-256: `fd16e339e2ba1c24b4ec33e6720eb1c29d9fd2b2a5214a60728e756a8af4c58d`.
- GitHub Actions run 42949403043 for commit `6b19733a689e706f51e7ce6dfb889260ec5c2bcb` passed formatting, static analysis, Flutter tests, Android debug APK build, and isolated QA profile APK build/checksum verification. PR #28 remains draft.

The measured improvement is consistent across idle and effect scenes and comes from removing fully opaque offscreen layers. The effect-specific additional translucent draws remain; their short phases still warrant caution in interpreting p90. No further renderer optimization is proposed without a new controlled comparison.
