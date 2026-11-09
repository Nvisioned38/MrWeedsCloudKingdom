# Issue #19 — event-driven Match-3 motion and FX checkpoint

**Branch:** `animation/issue-19-stage-a`  
**Scope:** smooth tile movement and tying the already integrated Issue #4 effect layers to observed Match-3 resolver events. New animation-sheet crops were not used.

## Implementation

The Flame presentation now sends each active `MatchWaveTrace` to the artwork renderer as a short-lived `BoardTurnEffectFrame`. It carries the actual cleared cells, created/triggered specials, blocker and tile-condition changes, previous/current wave snapshots, gravity/clear phase, and phase progress. It is never saved and cannot affect engine outcomes.

- Match clear: smoke and sparkles follow the current wave’s cleared pieces.
- Created special: sparkles appear at the resolver-reported special anchor.
- Torch: a directional warm trail follows the actually cleared row or column.
- Prism: a restrained family-color pulse follows the matching family in the wave snapshot.
- Cloud Bomb: localized white smoke appears at its actual trigger cell.
- Cascade: combo ring and gravity streak are tied to later cascade waves.
- Crate damage/break, Fog reveal, and Sticky Syrup removal receive feedback only where the trace records a state change.
- Reduced Motion keeps a brief static sparkle cue and omits travel/burst FX.

Cloud Cup vaporizer FX remains absent because the V1 resolver has no corresponding player action; no booster mechanic or logo placement was invented.

## Verification

- `dart format`: changed files formatted.
- `flutter analyze`: no issues.
- `flutter test`: **74/74 passed**; Issue #14 render fixture now verifies phase-progress smoke, cascade layer, Reduced Motion and a triggered Cloud Bomb event.
- Approved Issue #4 artwork manifest: **37/37** hashes and dimensions pass.
- QA APK: `com.mrweeds.cloudkingdom.qa`, arm64 debug, version 0.1.0 (2001), SHA-256 `6f4b1f23764fdc9ae71a6e8ffacc2b89ba937253c289e7b078abdd9dbc2cd84d`.
- S24 install: the verified QA APK replaced only the existing package under Android user 0 using `-r`. The saved progress payload remained byte-for-byte equal to checkpoint hash `90823d16ca76a7c993a653213c7e8eeae967b237fda5b0349cedafb854122579`.
- **S24 animation visual QA: NOT TESTED.** The handset is currently at its lock screen. No keyguard bypass was attempted. APK install and save-preservation are verified; actual interaction, screen recording, and frame pacing await the unlocked handset.

## Locked animation-sheet intake

`Cloud_Kingdom_Animation_FX_Batch2_APPROVED_LOCKED.zip` was found in Downloads and its archive SHA-256 matches the handoff (`d9d520219cc9097641e350151bcb7e07250765479b09d4b8747db279e9420eb1`). All eight gravity/refill candidate crop hashes and dimensions matched the package manifest. Visual/boundary QA rejected them for runtime: sampled nontransparent pixels occupied **78.1–93.9% of frame-edge samples** across the set, with the purple/blue glow visibly cut at the crop borders. They remain unimported; do not use them until clean standalone frame exports are available. The original approved sheets were not altered. The Batch 1 approved source ZIP was not found in the inspected Downloads/Desktop/OneDrive locations. Existing Issue #4 FX layers were used byte-exactly.

**Gate:** event-driven code implementation and automated/build checks pass. S24 visual acceptance for this checkpoint is pending; Issue #19 and V1 remain open.
