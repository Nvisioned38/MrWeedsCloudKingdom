# Issue #24 — S24 FrameTiming QA

**Status: INCOMPLETE — a valid physical S24 FrameTiming sample is still required.** This report distinguishes checks completed on the handset from automated checks. A locked-screen screenshot produced during device discovery was discarded and is not evidence.

## Physical S24 Ultra checks

Device: Samsung Galaxy S24 Ultra, model `SM-S928U`, serial `R5CX156CZNF`, Android user `0`.

| Check/scenario | Result | Evidence or reason |
|---|---|---|
| ADB authorization and device identity | PASS | `adb devices -l` returned the S24 as `device`, model `SM-S928U`. |
| Active Android user | PASS | `am get-current-user` returned `0`. |
| QA package identity/version | PASS | Only `com.mrweeds.cloudkingdom.qa` was inspected; version `0.1.0` / code `2001`, user-0 `base.apk` confirmed. Production package and Secure Folder were not accessed. |
| QA profile APK build and package check | PASS | Profile APK SHA-256 `b4a0f0b2ac4e93caac293a61bb6201853aff9fa9d7ab09fb3a5d7432314038c9`; signer SHA-256 `bbcc9ce1f3ab98be310e5ffb30d7978a011b48b154f275907b02ae2e13bc9a6f`; package verified as QA. |
| Safe profile replacement | PASS | `tools/build_qa_apk.ps1 -Action InstallProfileQa -DeviceSerial R5CX156CZNF` used its user-0, version, signer, staged-hash, and QA-package checks. It performed `install -r`; no uninstall or data-clear fallback. |
| Existing QA preferences preservation | PASS | SHA-256 before and after the profile replacement was identical: `bc2cc112dad557f49ac60f672cacb3f1e8086f39458dc18058b0ca24f04b99ac` (1,478 bytes). No level was played or completed. Production was not queried or changed. |
| Display state | PASS | Physical size `1080×2340`, active mode reported as `60.000004 Hz`; the panel supports 120 Hz. Budget for this capture state is therefore `16.667 ms`. The active mode was observed, not changed. |
| Normal Match-3, >=300 Flutter frames | NOT TESTED | The phone displayed its lock screen after launch. No input was sent to bypass it; waiting for owner unlock before interactive profiling. |
| Long cascade | NOT TESTED | Requires an unlocked interactive board and an observed qualifying cascade. |
| Torch | NOT TESTED | Requires an unlocked board and a reproducible real Torch trigger. |
| Prism | NOT TESTED | Requires an unlocked board and a reproducible real Prism trigger. |
| Cloud Bomb | NOT TESTED | Requires an unlocked board and a reproducible real Cloud Bomb trigger. |
| Reduced Motion | NOT TESTED | The owner's saved Reduced Motion choice was not changed. An unlocked board capture is pending. |
| Screenshot/video and frame pacing | NOT TESTED | No valid board capture was produced. No SurfaceFlinger or `gfxinfo` values are substituted for Flutter `FrameTiming`. |

The phone currently showed the Android lock screen. No swipe, PIN entry, profile switch, or security bypass was attempted. The original QA save was left in place. The QA profile APK remains installed; no game session was completed.

## Automated-only checks

| Check | Result | Details |
|---|---|---|
| FrameTiming percentile math | PASS | Synthetic unit cases cover odd/even sample counts and microseconds-to-milliseconds conversion. |
| Refresh-budget threshold math | PASS | Strict over-budget cases exercise `8.333 ms` and `16.670 ms` thresholds. |
| Batch ingestion, cap, warmup, start/stop | PASS | Widget tests inject synthetic `FrameTiming` objects, verify the `3000` sample cap, callback detach, and summary output. These are unit-test timings, not device measurements. |
| Insufficient-sample classification | PASS | A 2-sample capture reports `insufficient`, never a performance PASS. |
| Instrumentation opt-in disabled by default | PASS | Normal test/debug construction without the QA profiling define collects and logs nothing. Runtime package check is covered by Android implementation/build identity; the production app is never instrumented by the QA script. |
| Engine event summary | PASS | A constructed trace verifies aggregate counts for accepted swaps, waves, clears, gravity, refill, conditions, blockers and special creation/trigger. Cell coordinates are not retained or emitted. |
| Full Flutter suite | PASS | `flutter test`: **83 tests passed**. |
| Flutter analyzer | PASS | `flutter analyze`: no issues. |
| Formatting | PASS | `dart format` on changed Dart files; clean after formatting. |
| Approved artwork integrity | PASS | `python tools/verify_issue4_art.py`: **37/37 owner-approved PNGs** matched the supplied hash manifests byte-for-byte. The tool also reports 50 unrelated manifest references pending; those are pre-existing and out of Issue #24 scope. |
| QA installer safety tests | PASS | Same-version replacement and upgrades accepted; downgrade, signer mismatch, production identity and non-user-0 targets refused. |
| Android arm64 QA profile build | PASS | `com.mrweeds.cloudkingdom.qa`, profile mode, instrumentation define on. SHA-256 above. |
| Production-ID Android debug build | PASS | `com.mrweeds.cloudkingdom`, SHA-256 `54d8daccadcf918a34034425c05a87921b429e98be0b222ff507249f2432037e`. Built locally and not installed. |`n| Android arm64 QA debug build | PASS | Package `com.mrweeds.cloudkingdom.qa`; SHA-256 `90e50528682816c00182ab35ad4750e1995c8c37b2e90954bcb7337951c76f13`. Not installed over the profile APK. |

No valid performance statistics are available yet. Accordingly, p50/p90/p99, max tail, refresh-rate misses, >16.67 ms misses, and sample counts for gameplay scenarios are **NOT TESTED**, not zero. The historical 123-frame S24 Flutter sample in `docs/CURRENT_STATE.md` used another build and capture; it is not directly comparable and is not treated as a baseline result for this change.

## Instrumentation and safe reproduction

The profile-only Dart define `CLOUD_KINGDOM_QA_FRAME_TIMING=true` is added only by `BuildProfileQa` / `InstallProfileQa`. The collector additionally asks Android for the running application ID and refuses to start unless it is exactly `com.mrweeds.cloudkingdom.qa`. Normal/debug and production builds omit the define. The Android channel returns only package identity and an allow-listed scenario label.

After the board opens, capture begins after a two-second warmup. `SchedulerBinding.addTimingsCallback` counts delivered `FrameTiming` records, with a cap of 3,000. Background windows detach the callback and resume only after another warmup. Exiting the board detaches it and writes one bounded `CK_FRAME_TIMING` JSON summary to local Flutter logcat. The summary includes actual active sample count, active window and wall window, mode, device refresh rate/budget, build/raster/total p50/p90/p99/max, refresh-budget and >16.67 ms misses, and aggregate engine-event counts. Under 300 frames is classified `insufficient`. No raw per-frame positions, level IDs, player IDs, progress or preferences are written.

Safe build/install from the repository root:

```powershell
.
tools\build_qa_apk.ps1 -Action BuildProfileQa
.
tools\build_qa_apk.ps1 -Action InstallProfileQa -DeviceSerial R5CX156CZNF
```

The installer fails closed unless ADB is authorized, user 0 is active, the existing QA package is present, package/version/signer are compatible, and the staged APK SHA matches. It only executes `cmd package install -r --user 0` for the QA package. Never use `flutter drive` or an uninstall/data-clear fallback.

For each capture, start the QA activity with one of the allow-listed labels (`normal_match3`, `long_cascade`, `torch`, `prism`, `cloud_bomb`, `reduced_motion`) using the `CK_FRAME_SCENARIO` intent extra, open a seeded/replay board, wait at least 2 seconds, perform only the labeled event, then exit before a terminal victory. A valid run must yield at least 300 actual app-delivered timings. Retrieve summaries with `adb logcat -d -v time -s flutter` and retain the `CK_FRAME_TIMING` lines. Record mode from the summary and independently confirm active refresh with `adb shell dumpsys display`. Hash the QA preferences before and after; do not clear or reset them.

## Comparability and remaining gate

This device attempt has **no `FrameTiming` sample**, so it cannot be compared numerically with the historical 123-frame S24 measurement (build mean/p90/p99 `1.275/2.295/5.882 ms`, raster `3.290/5.399/8.450 ms`). That earlier run predates current Stage B and is a different capture. SurfaceFlinger/gfxinfo results are a separate metric and are excluded.

Issue #24 remains open until an unlocked S24 produces at least one normal-motion profile-mode run with 300 or more active Flutter timings and the scenario table contains truthful per-run results. Other special captures may remain `NOT TESTED` if their seeded state cannot be reached without changing saved progress.
