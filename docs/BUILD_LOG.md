# Cloud Kingdom Build Log

## 2026-11-07 — GitHub Issue #5 isolated Android QA

Added per-cell accessibility semantics/actions to the Flame Match-3 board and regression tests for semantic gameplay, victory rewards, persisted save round-trip, Home return, and large-text Settings. Board semantics report canonical tile names, specials/conditions, and row/column; blocker cells are announced but disabled. Existing Flame touch behavior remains active.

QA used mocked SharedPreferences and the disposable API 36 emulator. Full suite: 51/51 tests passed; formatter check clean; analyzer clean; split arm64-v8a Android debug APK build succeeded. Emulator gameplay reached Level 1 score 800; first-clear +100 coins/+1 star/+6 XP appeared. Home displayed Level 2/100 coins/1 star, and force-stop/relaunch followed by Continue restored that state. Native semantics exposed all 64 cell controls; landscape, 2× system text, cutout, and background/resume smoke showed no overflow/fatal logs. Existing domain/widget tests cover blocker/special/sticky/fog/objective/reward/migration/evolution/milestone behavior. Warm Flutter profile-mode `watchPerformance` captured 122 frames: average/p90 build 0.456/0.663 ms (0 build-budget misses); raster 2.024/2.513 ms (1 raster-budget miss). This is emulator evidence only. APK size 116,586,303 bytes; SHA-256 `7798B9D55D4164B172EAE42D24BA6C52DA7B5869273D282C885DBA5CB661967D`. S24 Ultra `R5CX156CZNF` was `unauthorized`; it was not used or changed.

This log records verified implementation checkpoints and meaningful orchestration changes. It is not a substitute for Git history.

## 2026-11-02 — Phase 1 verified baseline

Historical checkpoint before Phase 2 work:
- Flutter 3.47.7
- Dart 3.13.5
- Flame 1.38.2
- Android application ID `com.mrweeds.cloudkingdom`
- 10 authored levels
- 24 automated tests passing
- catalog/save/debug-build verification passed
- historical checkpoint noted as `718b4c9`

## 2026-11-02 — Phase 2A accepted

Phase 2A added the Cloud House/world, collection, character, and story foundation while preserving Phase 1 behavior.

Verified outcomes included:
- Cloud House hub and exterior
- Lounge world state/customization
- initial 10-card collection flow
- favorites/detail/shelf display
- evolution metadata foundation
- Chapter 1 playable with Chapter 2/3 teasers
- unmarked workshop mystery clue
- save migration foundation
- 34 tests passing
- `flutter analyze` clean

No Phase 2B implementation was started at this checkpoint.

## 2026-11-02 — GitHub synchronization checkpoint

Authoritative local/Codex working project synchronized into `Nvisioned38/MrWeedsCloudKingdom`.

Commit: `1a96490a0843b9181f28d5ff7d39a41afea7a16e`

Verification reported from synchronized checkout:
- `flutter pub get` passed
- `flutter test` passed: 34/34
- `flutter analyze` passed with no issues
- existing debug APK left untouched
- debug APK SHA-256 remained `D444A1F4BBBBC8D75C1648E4164EE7D457DC714449753FD7E4CCE525B26A6059`
- no merge conflicts

This commit is the authoritative Phase 2A engineering baseline for subsequent work.

## 2026-11-02 — Phase 2B orchestration released

Repository-native Phase 2B execution specification added as `06_CODEX_PHASE_2B_PROGRESSION_STORY_BUILD_PROMPT.md` and roadmap added at `docs/ROADMAP.md`.

Phase 2B is authorized to execute from the synchronized baseline. Coding agents should append verified checkpoints below as implementation proceeds.

## 2026-11-02 — Phase 2B verified complete

Completed the approved progression/story slice from the synchronized Phase 2A baseline. The implementation extends the runtime catalog to Levels 1–30; makes Chapters 2 and 3 playable; adds deterministic Sticky Syrup and Fog mechanics; expands the collectible catalog to 30; and implements persisted collection XP/evolution, one equipped collectible, and a Cloud Nine +150 starting-score perk. Schema 2 saves migrate to schema 3. Level 20 unlocks the Kitchen milestone, and Level 30 awards its milestone/key and previews the Higher Art Gallery without presenting the full Gallery as complete. Existing Keefler mystery continuity is preserved without revealing the elves or their deeper connection.

Verification from the synchronized checkout:
- `flutter pub get` — passed.
- `dart format lib test` — applied.
- `flutter analyze` — passed, no issues found.
- `flutter test` — passed, 43/43 tests.
- `flutter build apk --debug` — passed; artifact at `build/app/outputs/flutter-apk/app-debug.apk`.
- Schema migration, progression/evolution, equipment/perk behavior, New Game reset, levels, blockers, story gates, and milestones are covered by tests.

The debug build logged an Android SDK XML version compatibility warning, then completed successfully. Phase 2C remains planned and unapproved; no work from that phase was started. See Git history for the implementation and documentation commits.

## 2026-11-06 — First polished Android V1 prioritized

Planning/coordination only. The verified Phase 2B code head remains `10ca8a5b0bdcb086c294785544d40732a16ef524` with 43 tests and the previously recorded debug APK SHA. This entry records **no new code build or test**.

The owner authorized Phase 2C with priority on original approved brand/game art, Match-3 presentation, Cloud House/Lounge/Kitchen, collection UI, Home → Match-3 → Victory → Cloud House, and an Android debug APK for Samsung S24 Ultra testing.

Added `07_CODEX_PHASE_2C_V1_IMPLEMENTATION.md`, `docs/V1_ASSET_INTAKE.md`, `docs/V1_QA_CHECKLIST.md`; updated `AGENTS.md`, `docs/ROADMAP.md`, and `docs/CURRENT_STATE.md`. The v9 asset review workbook and original art bytes are not in the GitHub checkout; no artificial replacements are permitted.

GitHub Issue #1 was still open at the handoff and is the first engineering fix. Remaining unblocked 2C work should proceed autonomously with verified incremental commits.

## 2026-11-06 — v9 + Game Art ZIP verified intake

Read and audited the owner's full v9 tracker and original Game Art ZIP (77 PNG images and three nested archives). Full mapping and source-hash summary are at `docs/V1_V9_ZIP_INTAKE_AUDIT.md`. Created a separate v9-with-audit Excel workbook and curated V1-safe ZIP outside GitHub. **No source images or v9 workbook binary have yet been committed to GitHub.**

Exact standalone Mr. Weed's and Cloud Cup logos remain missing. Most approved Match-3 icon/board designs still need individual transparent production exports. Later story reveal images are excluded from the curated V1 import set.

Phase 2C implementation remains pending Codex pickup and original-art import. No new Flutter test, analyzer, APK build or device QA has been run in this intake step.

## 2026-11-07 — Phase 2C technical preview implementation

Pulled latest `main` (`edcf151`), which includes the GitHub Issue #1 finale-gate fix. Added regression/art-manifest/renderer tests and implemented the Phase 2C foundation: 80 stable art keys, validated manifest and pending-art visibility, board renderer/effects interfaces, non-leaf technical fallback silhouettes, theme, accessibility affordances, reduced-motion and haptic settings wiring, and room-art presentation. Integrated seven intact room/preview images with source hashes and intake traceability. The available `Game Art.zip` SHA-256 is `4a1824f098c498ffeebdfa1c90ab697f039ecc06cccdecccee29216978935739`; it is not the documented consolidated handoff package, and the v9 workbook was not found. Unverified logo/composite candidates remain pending and are not represented as approved production assets.

Verification: `flutter pub get` passed; formatting passed; `flutter analyze` clean; `flutter test` passed 48/48; `git diff --check` passed; `flutter build apk --debug --target-platform android-arm64` passed. The legacy leaf-family identity is rendered as a flower-shaped Mystic Bloom to comply with the no-visible-leaves guardrail. Final APK SHA-256: `FEEEEC74227290089EAB57B56D82E3611375C7614A46C7B5FCAC12E8EC13DEA4`, copied to the owner's Desktop build folder as a technical preview. Samsung S24 Ultra ADB serial `R5CX156CZNF` remains `unauthorized`; no install/manual QA or final visual sign-off is claimed. P0 canonical logos and isolated production gameplay sprites, v9 row verification and device QA remain open. Phase 3 was not started.

## 2026-11-07 — v10 approved branding and Samsung smoke

Updated the source of truth to the owner's v10 Standalone Assets workbook (SHA-256 `a9256d1d2802226782ab0a4ab23268c0e6eb62309c5a075052925cc03808e3c0`). Prepared BR-005/006 standalone PNG exports from the locked BR-001/002 canonical masters by trimming alpha=0 padding only; exact RGBA pixels were verified against the master region. Both source alpha bounds cover the full canvas, so no image pixels/dimensions were removed. Integrated the approved BR-003 v1 title treatment unchanged. The title treatment and Cloud Cup mark are visible on the title screen; the standalone Mr. Weed's mark is in the app shell. Updated seven room/preview approvals to their v10 rows. v10 M3-002 calls for a green organic spiral bloom; the technical renderer now uses a green flower/spiral while preserving the legacy domain/save ID and displaying no leaf silhouette.

Verification after v10 integration: `dart format --set-exit-if-changed lib test` — 0 changes; `flutter test` — 48/48 pass; `flutter analyze` — no issues; `flutter build apk --debug --target-platform android-arm64` — pass. Samsung S24 Ultra `R5CX156CZNF` became ADB-authorized. The updated APK was installed in place with `adb install -r`; app data was retained. Cold launch/title, Cloud House and the existing Level 3 board rendered in portrait; the existing Level 3/210 coins/2 stars were visible; no move was made. Pixel-exact BR-005/006 exports subsequently passed bundle tests and a final APK update installed. The phone was locked by the last capture, so that export-only rebuild was not visually recaptured. No Flutter asset-load/fatal log was found. Final APK SHA-256: `33D2FBBD856ECD5E59BA00D7205424B9DC7196033D37ADC2C670DC204174A339`; path is recorded in `docs/V1_QA_CHECKLIST.md`.

Remaining: isolated P0 Match-3 sprites and modular board/HUD art, Mr. Weed character art, collection exports, full on-device play/win/reward flow, accessibility/performance checks and owner final visual sign-off remain open. V1 spoiler boundary is preserved; Phase 3 did not start.
# 2026-11-07 — v10-approved Mr. Weed portrait build

Added the standalone v10-approved Mr. Weed CS-001 portrait copied unchanged from the Game Art archive. Updated manifest approval/source/export provenance, runtime asset registration and manifest coverage. The corresponding export matrix records why approved Match-3 concept sheets, composites and character sheets cannot be substituted for isolated production assets.

Verification: `flutter pub get` passed; `flutter test` passed 48/48; `flutter analyze` reported no issues; Android arm64 debug APK build passed. APK SHA-256: `AED184E6BA0A234AA22B6A0B86ECED2D6BAE273837432C043A78B9204614FD1B`. Installed with `adb install -r` on Samsung S24 Ultra `R5CX156CZNF`, preserving app data. Title, Home and Story catalog screens were checked; current home save state remained Level 3 / 210 coins / 2 stars. No gameplay turn or story beat was advanced. Phase 3 not started.

## 2026-11-07 — S24 separate QA application touch validation

Codex committed the isolated Android QA and board-accessibility changes at `dda1104933c5f06b45dd28c945355008172f3bd8`, which passed GitHub Actions at https://github.com/Nvisioned38/MrWeedsCloudKingdom/actions/runs/42428249531. Earlier documented QA verifies isolated emulator victory/reward and completed-progression persistence after relaunch, alongside 51 passing Flutter tests.

In a subsequent owner-reported QA run, ADB authorized the real Samsung S24 Ultra. A temporary `com.mrweeds.cloudkingdom.qa` app was installed separately from the owner's production game. The 64-cell labeled board accepted a legal physical swipe/touch swap, progressing score 0 → 30 and moves 18 → 17. Device log checks showed no recent fatal exceptions. Force-stop/relaunch returned to intro because the test level was not completed. Production save and package remained untouched.

**No new source-code QA change or new APK was built in this documentation-only update.** Remaining Issue #5 scope is full isolated phone victory/rewards/save relaunch and genuine TalkBack/performance/accessibility/lifecycle tests. Issue #4 still blocks final P0 artwork; V1 is a technical preview, not fully visually signed off.

## 2026-11-07 — Samsung S24 Ultra Issue #5 completion

Completed a clean Level 1 play-through on the Samsung SM-S928U (Android API 37) using only com.mrweeds.cloudkingdom.qa. Five legal swaps reached 1,020 points; Victory awarded +100 coins, +1 star, and +6 Collection XP. Cloud House displayed Level 2 / 100 coins / 1 star. After force-stop/relaunch, Continue restored that progression. Haptics off and Reduced motion on persisted in the QA package.

S24 accessibility checks exposed 64 labeled/clickable board cells with row/column hints. At temporary 2× system font scale, all cells and the Level 2 objective remained visible; original scale 0.9 was restored. Settings switches were labeled/clickable. TalkBack service was disabled, so speech output was not assessed.

Profile-mode integration timing on S24 captured 123 frames: build avg/p90/p99 1.275/2.295/5.882 ms (0 budget misses); raster avg/p90/p99 3.290/5.399/8.450 ms (0 budget misses). Every mutating ADB command targeted the QA package; the production app save was not targeted. The production Gradle application ID was restored after temporary QA builds.

## 2026-11-08 — Issue #4 approved Match-3 art integration and CI build

Integrated all 37 owner-approved Batch A/B/C standalone exports into the board sprite renderer, objective/move/score HUD, victory/reward panels and action buttons. Added an informational specials guide with normal/pressed/selected/disabled visual states; it does not create or change gameplay mechanics. The Cloud Cup vaporizer is logo-free art with the exact canonical Cloud Cup logo separately overlaid. Dynamic values/labels remain Flutter content. Updated approval provenance/manifests and V1 status records. Existing domain/save identifiers, deterministic rules, schema 3 persistence, and all 30 authored levels are retained. Batch D remains review-only and excluded.

The first CI run identified three assertion issues (a legacy `Moves 18` text expectation and two image-finder assumptions); these were corrected in commit `17695bab0914eb4802b6a46ecf8fb6199aef3554`. Successful GitHub Actions run: https://github.com/Nvisioned38/MrWeedsCloudKingdom/actions/runs/42441154111. `tools/verify_issue4_art.py` passed 37/37. Formatting ran on 20 Dart files (5 files normalized in the CI workspace). `flutter analyze` reported no issues. Full Flutter suite passed 53/53. Android debug APK built successfully as artifact `cloud-kingdom-android-debug-32`; APK SHA-256 `f58b2bc3938f2f90e15db15b888edebb2cd45fccd541884e0bdb0add34192d9b`; artifact ZIP digest `76424969b1cced3b392a6c4395cd830bd1f5426dacda241308b94a6cf4563889`. The run built the PR merge ref (head commit `17695bab`, merge build commit `8a7a7459592a94511c6193925284d5f1a9d8f0d0`).

The current integrated APK has **not** been installed or visually/gameplay-tested on the S24 Ultra. The active desktop session has no Flutter/Dart/ADB tools. Earlier S24 QA used pre-Integration code, so the new-art home→board→victory/reward→Cloud House→relaunch loop remains NOT TESTED. Production app/save was not modified. V1 remains a technical preview; Phase 3 remains unstarted.

## 2026-11-08 — Issue #15 objectives panel sizing

On latest `main` `8cd0901` (after PR #13 merge), replaced the fixed-height ornamental objectives backing behavior with a content-sized high-contrast Flutter frame. The frame adapts across 1–3 rows and scales; objective labels wrap, values remain contained, and the 30-move counter scales inside its backing. The approved image exports and their manifest bytes were left unchanged. Added regressions for 0.9×, 1×, 1.5×, 2×, long localized-like labels, three objective rows, and 64-cell board visibility. Focused widget tests passed (12/12); analyzer and formatter passed. Full test/build gates follow after Issue #14 fixtures.

## 2026-11-08 — Issues #15 and #14 QA follow-up

Issue #15: content-aware objective panel/Flutter frame, wrapped labels and contained counters; verified 1–3 objective fixtures with localized-like long text at 0.9×/1×/1.5×/2×, plus complete board visibility. S24 QA-only Level 10 screenshots at 0.9× and 2× pass; saved progress was not reset, and system scale returned to 0.9.

Issue #14: added test-only approved-art render/UI fixtures for Fog, Syrup, reinforced crate damage, Torch direction, booster states/semantics, smoke sequence, combo/cascade, Reduced Motion, missing-image fallback with selectable 64-cell board, and fresh isolated first-clear rewards after restoration/replay. Optional states were automated-only, not claimed as S24 physical passes.

Gate: 71/71 Flutter tests, analyzer clean, changed-file format clean, 37/37 art hash/dimensions/RGBA verifier, QA and production-ID arm64 debug APK builds passed. QA app was updated only with user-0 `-r`; production was not installed or accessed. Issue #6 and owner final visual sign-off remain open; no Phase 3.

Final artifacts from committed Issue #15/#14 source `87bc709120dca4eb3bd7f017018cbf98eecddcf5`: QA arm64 debug (`com.mrweeds.cloudkingdom.qa`) 117,584,746 bytes, SHA-256 `5cdb0d40f9e60791ba93fcba4177285d8b091f6db5048719b493071e0c9e1a67`; installed on S24 user 0 by replace-only verified script. Production-ID arm64 debug (`com.mrweeds.cloudkingdom`) 117,584,726 bytes, SHA-256 `00ff322974afcd34626e701fd8d1b50619ffab8084c98e29d0b79b1db66ab664`; built and identity-verified, not installed.

## 2026-11-09 — Issue #19 Stage A implementation checkpoint

Added the optional immutable animation trace to the actual engine pipeline, exact gravity/refill lineage and snapshot timeline, Reduced Motion path, touch/semantic resolution gate, one-shot delayed result callback and lifecycle cancellation/reconciliation. Added deterministic trace parity/cascade tests and widget busy/lifecycle coverage. See `docs/evidence/issue19/STAGE_A_QA.md` for exact implementation and verification.

Verification: 27-file Dart format check clean; `flutter analyze` clean; full suite **74/74**; approved-art validation **37/37**; isolated user-0 QA APK built, identity/hash verified, and replace-installed. See the device verification update below.

## 2026-11-09 — Issue #19 Stage A S24 verification

On the unlocked S24 Ultra, installed/tested only `com.mrweeds.cloudkingdom.qa` as Android user 0. Captured normal-motion four-tile match/cascade video and settled board; a valid swap advanced score 0→30 and moves 18→17. Captured the original Reduced Motion on state, selected-cell feedback, normal/Reduced Motion settings, and Cloud House.

Profile-mode SurfaceFlinger TimeStats ran for five seconds around a valid match: 609 QA SurfaceView frames, 0 dropped, 0 late-acquire and 0 bad-desired-present frames. FrameTimeline jank counters were unavailable (`totalTimelineFrames=0`), so no app jank percentile is claimed. Device-wide legacy stats counted 34 missed frames among 613; this includes non-game/system layers. The sample is partial and directional relative to the historical Issue #5 Flutter frame benchmark because the timing sources differ. Raw sample and handset recordings are under `docs/evidence/issue19/`.

A Flutter Driver attempt initially produced a profile APK with code 1, below the installed QA code 2001; its downgrade fallback uninstalled only the QA app and the performance test then failed to connect to the VM timeline service. The exact pre-run QA progress JSON had been read and hash-recorded. It was restored to the QA package and the original SHA-256 (`90823d16ca76a7c993a653213c7e8eeae967b237fda5b0349cedafb854122579`) verified after relaunch and final debug `-r` replacement. A split arm64 profile APK with the correct QA identity/code was subsequently installed with explicit user-0 replace semantics for the SurfaceFlinger sample. No production package was installed, launched, queried, or modified.

Final debug QA artifact remains `build/qa/app/outputs/flutter-apk/app-arm64-v8a-debug.apk`, package `com.mrweeds.cloudkingdom.qa`, version 0.1.0 (2001), SHA-256 `ea7ee13d0a58a91c51705a6edc5c8ab537c5c48591d8a6090940599738ba176d`. Stage A physical evidence is recorded; keep Stage B paused pending owner visual review.
## 2026-11-09 — Issue #19 event-driven Match-3 FX checkpoint

The owner authorized continued tile-motion and effect wiring after Stage A. Replaced global turn-progress effect drawing with per-wave rendering based on actual clear, gravity, special-trigger, blocker, Fog/Syrup and special-creation trace events. Existing 37 approved standalone art bytes remain unchanged; the approved smoke, sparkle, combo, Torch, Prism and Bomb layers now animate only at their matching events. Prism carries the exact engine-selected family in the trace, never an inferred family. Reduced Motion uses a brief static cue. No Cloud Cup action was added because the resolver has no corresponding booster mechanic.

Verification passed: Dart format, clean `flutter analyze`, full Flutter suite **74/74**, approved-art hash check **37/37**, QA arm64 build and safe replace-install on S24 user 0. QA progress SHA-256 stayed exactly `90823d16ca76a7c993a653213c7e8eeae967b237fda5b0349cedafb854122579`. APK SHA-256: `d2ec5b504514b64ce1fa626fdbd528e7f1d510066fa8e95d569b75e4ef4c3d33`. The handset is currently at its lock screen; event-FX physical visual/frame-pacing QA is pending and no lock bypass was used. See `docs/evidence/issue19/EVENT_DRIVEN_FX_CHECKPOINT.md`.
