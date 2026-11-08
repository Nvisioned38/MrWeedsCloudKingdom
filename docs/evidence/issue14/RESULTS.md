# Issue #14 — Isolated V1 QA fixtures

**Baseline:** latest `main` after PR #13 merge, `8cd09011dcd33fab612d5bc27279bed0a00bad2b`
**Scope:** QA-only Flutter fixtures; no authored production level changes, device save reset, production package action, Phase 3 work, or story additions.

## Fixture results

| Case | Result | Evidence |
|---|---|---|
| Fog hides underlying tile identity | **PASS — automated render fixture** | Pixel output for Fog over Cloud Puff equals Fog over Golden Nugget, so hidden identity is not revealed. |
| Sticky Syrup alpha and z-order over Fog | **PASS — automated render fixture** | Actual approved PNG composition differs from Fog-only output, proving Syrup is composited above the concealment layer. |
| Reinforced MW crate damage cue | **PASS — automated render fixture** | Intact and one-hit damaged renders differ using approved sprites plus the crack overlay. |
| Torch horizontal/vertical row/column direction | **PASS — automated render fixture** | Actual approved image renders differ for horizontal and vertical rocket direction. Existing domain coverage verifies rocket clears its row/column. |
| Prism and Cloud Bomb guide/special art | **PASS — automated widget fixture** | Active fixture board contains Torch, Prism and Cloud Bomb; guide assets render. Canonical Cloud Cup logo remains a separate overlay on the logo-free vaporizer. |
| Booster normal, pressed, selected and disabled states | **PASS — automated widget fixture** | State-specific approved button images and enabled/selected/onTap semantics are asserted. |
| White-smoke frame sequence | **PASS — automated render fixture** | Two animation progress samples render distinct smoke frames. |
| Cascade/combo overlay | **PASS — automated render fixture** | A cascade count above one adds the approved combo ring and cascade streak. |
| Reduced Motion alternative | **PASS — automated render fixture** | Reduced Motion produces the static sparkle alternative and differs from normal combo effects. |
| Missing image fallback, no crash/blank board/lost controls | **PASS — injected resolver fixture** | A deterministic Cloud Puff load failure leaves the game on the vector fallback; all 64 cell semantics remain present and a QA screen tap still selects its cell. No signed APK asset was removed or modified. |
| Fresh first-clear reward and restoration | **PASS — isolated data fixture** | A new in-memory `ProgressState` grants +100 coins, +1 star and +6 Collection XP; JSON restoration retains these values and replay grants none again while best score updates. No device or shared save store is reset. |
| Device execution of the Issue #14 optional states | **NOT TESTED** | These states were tested in deterministic Flutter QA fixtures, not on the S24. The S24 saved Level 10, 1,295 coins and 9 stars was preserved. |

All rendering fixtures use the actual approved PNGs. `tools/verify_issue4_art.py` passed all **37/37** SHA-256, dimensions and RGBA checks. The Issue #14 fixtures are in `test/qa/issue14_targeted_fixtures_test.dart`; the injectable resolver is used by test code and no debug navigation/cheat screen is added to production.

## Verification

- Full Flutter suite: **71 passed**.
- `flutter analyze`: **clean**.
- Changed Dart files: `dart format --set-exit-if-changed` **clean**.
- Android QA arm64 debug build: **PASS**, exact ID `com.mrweeds.cloudkingdom.qa`.
- Android production-ID arm64 debug build: **PASS**, exact ID `com.mrweeds.cloudkingdom`; it was built but not installed.
- Final QA APK: `build/qa/app/outputs/flutter-apk/app-arm64-v8a-debug.apk`, 117,584,746 bytes, SHA-256 `5cdb0d40f9e60791ba93fcba4177285d8b091f6db5048719b493071e0c9e1a67`; version `0.1.0` (2001), minSdk 24, built from commit `87bc709120dca4eb3bd7f017018cbf98eecddcf5`. The exact package ID was confirmed by `aapt` and the APK is installed in QA user 0.
- Production-ID debug APK: `build/app/outputs/flutter-apk/app-arm64-v8a-debug.apk`, 117,584,726 bytes, SHA-256 `00ff322974afcd34626e701fd8d1b50619ffab8084c98e29d0b79b1db66ab664`; exact ID `com.mrweeds.cloudkingdom`. It was built, identity-checked and not installed.
- QA-only physical S24 install for Issue #15 used the checked user-0 `-r` path; data remained intact. No production app command was issued.

TalkBack spoken output remains **NOT TESTED** and open under Issue #6. Owner visual approval remains a separate V1 release gate. These fixture results do not declare V1 final.
