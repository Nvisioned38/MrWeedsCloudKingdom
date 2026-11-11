# Issue #24 — Samsung S24 Ultra FrameTiming QA

- **Branch:** `qa/issue-24-s24-frame-timing`
- **PR:** #25 (draft; not merged)
- **Device:** Samsung Galaxy S24 Ultra (`SM-S928U`, serial `R5CX156CZNF`)
- **App under test:** `com.mrweeds.cloudkingdom.qa`, Android user 0, build 0.1.0 (2001)
- **Capture date:** 2026-11-10
- **Display mode:** 120 Hz; refresh interval 8.333 ms

## Safety and method

ADB authorization and Android user 0 were verified before testing. Device package identity was checked against the QA application. The owner confirmed the QA app was available for profiling. The test APK was installed using replace-only `adb install -r --user 0`; no uninstall, data clear, downgrade fallback, profile change, or production-app operation was performed. Production was not installed, launched, queried, or modified.

The owner reported playing the QA app concurrently during an earlier observation. The QA preferences hash changed from `d871…b9a0` to `bf7…2b90`; the owner confirmed the change was theirs. Testing stopped at the time and the current save was left as-is. Subsequent replay profiles started and ended at the owner-updated baseline; each logged `levelEnded:false`. No test level was completed and no progress was reset. Reduced Motion was temporarily enabled only for its profile and restored to its original off state; the setting and preferences hash returned to the current baseline.

The QA-only Flutter `FrameTiming` logger collected 3,000 delivered frames per scenario (minimum accepted sample count: 300) during an approximately 25-second active capture window. Statistics below are per-app build, raster, and total frame spans emitted by Flutter; missed-frame counts use the active 120 Hz budget and the conventional 16.67 ms threshold. Each scenario is backed by its raw `CK_FRAME_TIMING` line in the adjacent `.log` file. Screen recording was not active during the clean timing captures.

## Physical S24 profiles

Times are milliseconds. “Budget misses” counts samples over 8.333 ms; the following column counts samples over 16.67 ms. Each scenario had 3,000 samples.

| Scenario | Gameplay evidence in captured events | Build p50 / p90 / p99 / max | Raster p50 / p90 / p99 / max | Total p50 / p90 / p99 / max | 8.333 ms misses | >16.67 ms |
|---|---|---:|---:|---:|---:|---:|
| Normal Match-3 | 1 swap, 1 match wave, 3 clears, 3 gravity drops, 3 refills, rocket created | 1.729 / 1.860 / 1.963 / 3.884 | 4.292 / 4.463 / 4.753 / 6.072 | 7.192 / 7.479 / 7.796 / 11.783 | 6 (0.2%) | 0 |
| Long cascade + Prism | 2 swaps, 6 waves, 45 clears, 53 drops, 45 refills, Prism created and triggered, max cascade depth 3 | 1.736 / 1.883 / 2.161 / 5.119 | 4.368 / 4.575 / 5.115 / 9.868 | 7.266 / 7.605 / 8.441 / 16.281 | 35 (1.2%) | 0 |
| Torch | 6 swaps, 8 waves, 29 clears, 12 drops, 29 refills, rocket created and triggered | 1.712 / 1.879 / 2.165 / 5.260 | 4.179 / 4.412 / 4.905 / 12.346 | 7.055 / 7.511 / 8.276 / 17.789 | 24 (0.8%) | 2 |
| Prism | 2 swaps, 6 waves, 45 clears, 53 drops, 45 refills, Prism created and triggered, max cascade depth 3 | 1.707 / 1.837 / 1.941 / 2.626 | 4.154 / 4.380 / 4.636 / 7.306 | 6.993 / 7.390 / 7.807 / 19.311 | 7 (0.2%) | 1 |
| Cloud Bomb — repeat 1 | 3 swaps, 4 waves, 20 clears, 11 drops, 22 refills, 2 blocker changes, Cloud Bomb created and triggered | 1.670 / 1.829 / 1.949 / 2.221 | 5.464 / 6.042 / 6.537 / 7.315 | 8.229 / 9.067 / 9.628 / 15.523 | 1,370 (45.7%) | 0 |
| Cloud Bomb — repeat 2 | Same event counts as repeat 1 | 1.686 / 1.862 / 2.078 / 5.014 | 5.517 / 6.090 / 6.596 / 9.753 | 8.332 / 9.128 / 9.712 / 14.425 | 1,500 (50.0%) | 0 |
| Reduced Motion | Reduced mode; 1 swap, 1 wave, 3 clears, 3 drops, 3 refills, rocket created | 1.731 / 1.861 / 1.983 / 4.140 | 4.275 / 4.452 / 5.185 / 17.649 | 7.170 / 7.465 / 8.033 / 21.934 | 15 (0.5%) | 2 |

All requested physical profiles were captured. The long-cascade/Prism profile reached a 3-wave cascade. Cloud Bomb pacing is a **reproducible performance concern**: two runs exceed the 120 Hz budget on 45.7% and 50.0% of samples, with raster time dominating. Neither run exceeded 16.67 ms. The low 120 Hz miss rates in the other profiles are recorded as measurements, not a blanket pass against an acceptance threshold that Issue #24 does not define.

### Recommended follow-up

Profile the Cloud Bomb raster/GPU/compositing path, especially overlapping translucent smoke/effect layers and repeated per-frame draw work. Evaluate batching, caching, or reducing redundant overlap while preserving approved artwork, animation timing, and game rules. No timing, artwork, gameplay, or save-schema changes were made as part of this instrumentation task. Keep Issue #24 open and PR #25 draft until the owner reviews the performance finding and the follow-up is addressed or explicitly accepted.

## Evidence index

Raw timing records:

- [`normal_match3_frame_timing.log`](normal_match3_frame_timing.log)
- [`long_cascade_frame_timing.log`](long_cascade_frame_timing.log)
- [`torch_frame_timing.log`](torch_frame_timing.log)
- [`prism_frame_timing.log`](prism_frame_timing.log)
- [`cloud_bomb_frame_timing.log`](cloud_bomb_frame_timing.log) (both repetitions)
- [`reduced_motion_frame_timing.log`](reduced_motion_frame_timing.log)

Selected physical captures:

- [Original Reduced Motion setting](04_s24_settings_original.png)
- [Full 8×8 board](06_s24_normal_board.png)
- [Normal match resolved](08_s24_normal_match_resolved.png)
- [Torch created](16_s24_torch_special_created.png) and [Torch fired](17_s24_torch_fired.png)
- [Prism created](29_s24_long_cascade_prism_created.png) and [Prism triggered in the cascade](30_s24_long_cascade_prism_triggered.png)
- [Cloud Bomb resolved](23_s24_cloud_bomb_resolved.png) and [repeat capture](31_s24_cloud_bomb_repeat.png)
- [Reduced Motion feedback](25_s24_reduced_match_feedback.png) and [setting restored](26_s24_reduced_motion_restored.png)

## Verification status

The latest source/Android/asset verification at branch head `61ccf5175ac95ce8b4fde9d8e386f86f9eb91233` passed in GitHub Actions run [42760424795](https://github.com/Nvisioned38/MrWeedsCloudKingdom/actions/runs/42760424795): formatting, analyzer, full Flutter suite (83 tests), approved-art verification (37/37 SHA/dimensions/RGBA), QA install-safety tests, arm64 QA profile/debug builds, and production-ID debug build. No implementation source changed during the physical profiling/documentation follow-up; docs/evidence updates are to be revalidated by CI after push.

The profiled QA APK SHA-256 is `32d9dcaabb3d70737fb1c52f5c54f564e69c83599f9eaa33d2b63c73533c4c71`; signing certificate SHA-256 is `bbcc9ce1f3ab98be310e5ffb30d7978a011b48b154f275907b02ae2e13bc9a6f`.

## Comparison with earlier S24 benchmark

`docs/CURRENT_STATE.md` contains a historical 123-frame capture with average/p90/p99 build times 1.275/2.295/5.882 ms and raster times 3.290/5.399/8.450 ms. That capture used a different build and method and was recorded at 60 Hz. It is **not a controlled before/after comparison** with these 120 Hz, 3,000-frame, per-app Flutter profiles; no performance improvement or regression versus that benchmark is claimed.

Issue #24 remains open pending review and Cloud Bomb performance follow-up. PR #25 remains draft. iOS, spoken accessibility, Batch 5 collectibles and Phase 3 remain paused.
