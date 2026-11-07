# AGENTS.md — Mr. Weed's: Cloud Kingdom

This file defines the operating rules for Codex and other coding agents working in this repository.

## Primary objective

Continue development of **Mr. Weed's: Cloud Kingdom** from the newest verified state documented in `docs/CURRENT_STATE.md`, while preserving product intent, architecture quality, test coverage, and brand/story continuity.

## Source-of-truth order

Before modifying code, read in this order:

1. `AGENTS.md`
2. `docs/CURRENT_STATE.md`
3. `docs/ROADMAP.md`
4. The current approved phase execution specification (currently `07_CODEX_PHASE_2C_V1_IMPLEMENTATION.md`)
5. `docs/V1_ASSET_INTAKE.md` and `docs/V1_QA_CHECKLIST.md`
6. `00_PROJECT_CHARTER.md`
7. `01_GAME_DESIGN_BLUEPRINT.md`
8. `02_TECHNICAL_ARCHITECTURE.md`
9. Existing code, catalogs, and tests
10. `docs/BUILD_LOG.md` for checkpoint history

If documentation and implementation differ, do not silently guess. Prefer the newest verified implementation state, then update documentation to reflect reality unless the conflict materially changes product direction.

## Current execution directive

**Phase 2B is VERIFIED COMPLETE. Phase 2C V1 visual integration and Android playable polish are OWNER-AUTHORIZED.**

Start from verified Phase 2B commit `10ca8a5b0bdcb086c294785544d40732a16ef524`. Execute `07_CODEX_PHASE_2C_V1_IMPLEMENTATION.md` and use `docs/V1_ASSET_INTAKE.md` and `docs/V1_QA_CHECKLIST.md`.

**Immediately prioritize Phase 2C-0 (fix still-open GitHub Issue #1 and retest), then 2C-1 (audit, brand/theme/asset framework).** Move into approved P0/P1 art integration only when the real source files and the v9 tracker approval evidence are accessible; missing originals block those particular assets, not other engineering tasks. Deliver a technical preview APK if final artwork is missing, never claim final V1 visual acceptance without evidence.

No routine requests for ordinary engineering decisions. Work through all unblocked current-phase items with tests, incremental commits, updates to the build log/current state/roadmap, and a consolidated blockers report. Do **not** start Phase 3 or later story arcs.

## Autonomy granted

You are authorized to:

- implement approved roadmap items
- create supporting classes, systems, tests, fixtures, utilities, and docs
- refactor when necessary for maintainability
- fix bugs discovered during implementation
- improve accessibility, performance, and resilience when changes do not alter approved product behavior
- run Flutter, Dart, Flame, and repository tooling
- add or update tests for changed behavior
- update documentation after each implementation unit
- continue automatically to the next highest-priority unblocked item within the currently approved phase when verification passes

Do **not** stop merely because a single feature or ticket is complete.

## Mandatory implementation loop

For each implementation unit:

1. Inspect relevant architecture and tests.
2. Make the smallest maintainable change that satisfies the requirement.
3. Add or update tests.
4. Run formatting.
5. Run static analysis.
6. Run relevant automated tests.
7. Run broader regression tests when the change can affect shared systems.
8. Fix regressions before continuing.
9. Update `docs/CURRENT_STATE.md` when verified state changes.
10. Append a concise entry to `docs/BUILD_LOG.md` for meaningful verified checkpoints.
11. Keep `docs/ROADMAP.md` status current.
12. Continue to the next highest-priority unblocked item in the approved phase.

## Stop and request human input only when

Stop only if one or more of the following is true:

1. A decision would materially change the approved game concept, monetization model, target audience, or core gameplay loop.
2. Two or more plausible implementations have meaningfully different product consequences and the existing docs do not resolve the choice.
3. A destructive or irreversible migration is required.
4. Credentials, signing keys, paid services, purchases, external account access, or legal agreements are required.
5. Official Mr. Weed's branding, character identity, or locked visual assets would need to be altered or reinterpreted.
6. A legal, compliance, platform-policy, age-gating, cannabis-regulation, privacy, or safety question requires owner judgment.
7. Required information or assets are unavailable and progress is genuinely blocked.
8. Tests reveal a pre-existing critical defect whose repair would require a substantial product or architecture change outside the approved roadmap.

Ordinary engineering decisions are **not** blockers.

## Repository safety rules

- Do not replace the verified app with a freshly generated Flutter project.
- Do not rewrite large working areas solely for stylistic preference.
- Do not delete tests to make builds pass.
- Do not weaken analysis/lint settings to hide failures unless an explicit architecture decision requires it.
- Do not commit secrets, signing keys, tokens, or private credentials.
- Preserve stable save-data identities and migration behavior unless a migration is explicitly designed and tested.
- Preserve Android application ID `com.mrweeds.cloudkingdom` unless the owner explicitly changes it.
- Treat `1a96490a0843b9181f28d5ff7d39a41afea7a16e` as the synchronized Phase 2A engineering baseline, not as disposable scaffolding.

## Quality gate

A roadmap item is not complete until applicable checks pass. Maintain or improve the existing gate:

- `flutter pub get`
- formatting
- static analysis with no issues
- Flutter automated tests
- catalog validation
- save-data migration/round-trip verification
- debug build verification when supported by the environment

Phase-specific verification requirements in the current execution specification are additive to this gate.

## Product guardrails

Cloud Kingdom is a casual game and story world, not a cannabis commerce application. Gameplay may use Mr. Weed's fictionalized brand universe, strain-themed characters/cards, Cloud Cup/CannaTapper lore, humor, and fantasy elements, but implementation should preserve the intended entertainment/game framing.

Do not add real cannabis cultivation instructions, dosing instructions, unsupported medical claims, or commerce flows as part of normal game development.

The Keefler Elves are an important future story arc. Their storyline should preserve the established premise that Mr. Weed saves the displaced original Keefler Elves, gives them a new home and purpose, and later reveals their deeper connection to Cloud Cup/CannaTapper magic. The arc should be designed so it can naturally bridge into a possible standalone Keefler Elves spin-off game.

Until a later approved story phase explicitly authorizes the reveal, preserve the current mysterious workshop clues without naming the Keefler Elves or explaining their connection.

## Visual/brand guardrails

Final visual asset integration is a separate roadmap phase unless a current task explicitly includes it.

When official branding assets are introduced:
- do not redraw, restyle, recolor, or substitute the locked official Cloud Cup logo;
- preserve the approved Mr. Weed character identity;
- preserve approved Cloud Kingdom/Cloudcrafted Fantasy art direction when documented;
- Cloud Cup smoke should remain white unless a specific asset direction explicitly says otherwise.

**Source-image rule:** tracker v9: Brand and V1 Priorities controls final asset approvals, but its original workbook must be obtained before row-by-row sign-off can be asserted. The repository currently has no `assets/art/` files. Never replace a locked visual with generated approximations, assume reference mockups are production sprites, or claim a placeholder has passed final V1 QA.

Cloudcrafted Fantasy is dimensional 2.5D with approved cloudglass/purple cloudstone/brass materials. **No crowns and no visible cannabis leaves outside the Secret Basement.** Preserve existing Dart internal identifiers and save data even when applying approved visual replacements (e.g. torch visual for rocket special, non-leaf art for legacy tile family). Canonical original Mr. Weed and Cloud Cup logos remain unchanged.

**Narrative firewall:** five Troll characters are friendly at this stage. Do not reveal betrayal, Lord Nave Von Elrekce, Copycat Cloud Co., the rival Cloud Bottle, or the Keefler Elves arc in V1. Preserve the unmarked-workshop teaser only.

Placeholder art is acceptable only as an explicitly unfinished technical fallback during V1 preparation, never as a claimed approved production asset.

## Communication style for agent summaries

After a substantial run, report:

- what was completed
- verification performed and results
- files/systems materially changed
- current phase status
- next roadmap item
- only genuine blockers requiring human input

Do not ask for approval between ordinary implementation steps.

## Owner-directed pause and synchronization

The automatic continuation authorization above applies only while it remains consistent with the owner's current task and the roadmap's approved phase status. A direct owner instruction to pause new development, stop after a bounded task, or wait for further direction overrides automatic continuation.

When an approved phase is complete, do not cross into a later phase marked planned/unapproved. Continue cleanup, verification, documentation, and defect repair needed to satisfy the current phase gate, then report completion.
