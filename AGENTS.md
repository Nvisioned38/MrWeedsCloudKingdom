# AGENTS.md — Mr. Weed's: Cloud Kingdom

This file defines the operating rules for Codex and other coding agents working in this repository.

## Primary objective

Continue development of **Mr. Weed's: Cloud Kingdom** from the newest verified state documented in `docs/CURRENT_STATE.md`, while preserving product intent, architecture quality, test coverage, and brand/story continuity.

## Source-of-truth order

Before modifying code, read in this order:

1. `AGENTS.md`
2. `docs/CURRENT_STATE.md`
3. `00_PROJECT_CHARTER.md`
4. `01_GAME_DESIGN_BLUEPRINT.md`
5. `02_TECHNICAL_ARCHITECTURE.md`
6. Existing code, catalogs, and tests

If documentation and implementation differ, do not silently guess. Prefer the newest verified implementation state, then update documentation to reflect reality unless the conflict materially changes product direction.

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
- continue automatically to the next highest-priority unblocked roadmap item when verification passes

Do **not** stop merely because a single feature or ticket is complete. Current owner instructions still bound this autonomy; the owner has paused new feature development after Phase 2A, so wait for an explicit instruction before starting Phase 2B.

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
10. Append a concise entry to `docs/BUILD_LOG.md`; create that log when the first implementation entry is ready if it does not exist.
11. Continue to the next highest-priority unblocked roadmap item.

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

- Do not replace the verified app with a freshly generated Flutter project if the expected source has not yet been pushed.
- Do not rewrite large working areas solely for stylistic preference.
- Do not delete tests to make builds pass.
- Do not weaken analysis/lint settings to hide failures unless an explicit architecture decision requires it.
- Do not commit secrets, signing keys, tokens, or private credentials.
- Preserve stable save-data identities and migration behavior unless a migration is explicitly designed and tested.
- Preserve Android application ID `com.mrweeds.cloudkingdom` unless the owner explicitly changes it.

## Quality gate

A roadmap item is not complete until applicable checks pass. The verified Phase 1 baseline previously passed:

- `flutter pub get`
- formatting
- static analysis with no issues
- Flutter automated tests
- catalog validation
- save-data round-trip verification
- debug build verification

When source is present, maintain or improve this gate.

## Product guardrails

Cloud Kingdom is a casual game and story world, not a cannabis commerce application. Gameplay may use Mr. Weed's fictionalized brand universe, strain-themed characters/cards, Cloud Cup/CannaTapper lore, humor, and fantasy elements, but implementation should preserve the intended entertainment/game framing.

The Keefler Elves are an important future story arc. Their storyline should preserve the established premise that Mr. Weed saves the displaced original Keefler Elves, gives them a new home and purpose, and reveals their deeper connection to Cloud Cup/CannaTapper magic. The arc should be designed so it can naturally bridge into a possible standalone Keefler Elves spin-off game.

## Communication style for agent summaries

After a substantial run, report:

- what was completed
- verification performed and results
- files/systems materially changed
- next roadmap item
- only genuine blockers requiring human input

Do not ask for approval between ordinary implementation steps.

## Owner-directed pause and synchronization

The automatic continuation authorization above applies only while it remains consistent with the owner's current task. A direct owner instruction to pause new development, stop after a bounded task, or wait for further direction overrides automatic continuation. Do not start another roadmap phase after completing such a task.

For source synchronization, treat the current authoritative working implementation as the source of truth for code, tests, assets, and project configuration. Reconcile existing repository control documents in place; preserve their useful charter and history while updating stale status claims to match verified implementation facts.
