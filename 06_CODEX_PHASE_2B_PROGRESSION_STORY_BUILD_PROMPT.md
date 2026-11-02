# Codex Phase 2B — Progression + Story Build

## Authorization

Phase 2B is approved to begin from synchronized baseline commit:

`1a96490a0843b9181f28d5ff7d39a41afea7a16e`

Read `AGENTS.md` and `docs/CURRENT_STATE.md` before changing code. Preserve all verified Phase 1 and Phase 2A behavior.

## Goal

Turn the Phase 2A foundation into a meaningful early-game progression slice by extending playable content through Level 30, making Chapters 2 and 3 playable, deepening the collection system, and adding the first small collectible-to-puzzle gameplay connection.

This phase is systems/content progression work. It is not the final visual-art pass.

## Required scope

### 1. Playable Levels 11–30

Extend the detailed runtime level catalog from Levels 1–10 through Levels 1–30.

Use `04_LEVELS_001_100.json` as the canonical pacing/chapter reference, but adapt entries into the detailed runtime `LevelSpec` schema used by the verified game. Do not pretend unsupported objective types are implemented. If a new gameplay rule is required, implement and test it rather than encoding dead data.

Requirements:
- Levels 1–10 remain behaviorally stable.
- Levels 11–20 belong to Chapter 2: **Kitchen Catastrophe**.
- Levels 21–30 belong to Chapter 3: **The Missing Collection**.
- Level 20 is the Chapter 2 finale and produces a visible Kitchen milestone.
- Level 30 is the Chapter 3 finale, awards/persists its milestone reward, and produces a visible Higher Art Gallery preview/mystery milestone.
- Each authored level is deterministic from its seed.
- Each starting board is playable and respects existing fairness rules.
- Difficulty should rise through objective/blocker interaction, not hostile RNG.

### 2. New blocker mechanics

Implement engine support for:

**Sticky Syrup**
- A tile affected by Sticky Syrup cannot be swapped/moved until the syrup is cleared by an adjacent qualifying clear.
- Behavior must be deterministic and testable.
- Rendering must clearly distinguish the blocked state without relying only on color.

**Fog**
- Fog hides the identity of the underlying tile until revealed by an adjacent qualifying clear.
- Hidden tile identity must remain stable and deterministic while fogged.
- Revealing fog must not reroll or replace the underlying tile.
- Rendering must clearly communicate hidden vs revealed state.

The master 1–100 level map may reserve primary use of Fog for the following chapter. Phase 2B must implement and test the mechanic now so the system is ready. Do not silently rewrite the master map merely to force a blocker into a chapter where it does not belong.

Preserve Crate and Reinforced Crate behavior.

### 3. Chapters 2 and 3 become playable

Update story data and presentation so Chapters 2 and 3 are real playable chapters rather than teaser cards.

#### Chapter 2 — Kitchen Catastrophe
- Feature **Chef Blaze**.
- Introduce the Kitchen as a visible Cloud House progression milestone.
- Story beats should bracket or meaningfully react to the Chapter 2 progression and finale.
- Keep High Cuisine references fictional/game-oriented. Do not add real cannabis infusion, dosing, or cultivation instructions.

#### Chapter 3 — The Missing Collection
- Feature **The Collector**.
- Build a light mystery around missing/scattered collection pieces.
- Level 30 should resolve the chapter enough to feel complete while opening the next mystery.
- The Higher Art Gallery may become visibly previewed/teased at the Level 30 milestone, but Phase 2B does not need to build the full Gallery system.

### 4. Keefler mystery continuity

Preserve the existing unmarked-workshop clue and `keefler_mystery_seen` continuity.

Phase 2B may add subtle mystery clues that are compatible with the future Keefler Elves arc, but:
- do **not** name or explicitly reveal the Keefler Elves yet;
- do **not** explain the Cloud Cup/CannaTapper connection yet;
- do **not** convert the workshop into a playable area yet.

The reveal belongs to a later story arc.

### 5. Expand collectible catalog to 30 cards

Expand `assets/data/collectibles.json` from 10 cards to the full 30-card launch catalog represented by `03_CONTENT_CATALOG.json`.

Requirements:
- Preserve stable IDs for the existing 10 cards.
- Reconcile naming, collection membership, rarity/class/category, ability text, lore, and art keys without breaking existing save identities.
- No medical claims or cultivation instructions.
- Placeholder art slots are acceptable where final art does not yet exist.
- Collection filtering/favorites/details must continue to work with 30 cards.

Do not implement all 30 puzzle abilities in this phase.

### 6. Collection XP and evolution

Implement persisted collection XP and working evolution progression:

**Seedling → Bud → Frosted → Legendary**

Requirements:
- Collection XP earned from level rewards is actually persisted.
- Evolution thresholds are deterministic and centralized, not scattered through UI code.
- At least one unlocked card can visibly advance evolution stage through normal testable progression.
- Existing Phase 2A save data migrates forward without data loss.
- New Game resets the new progression fields correctly.
- Evolution state remains stable across relaunch/save round-trip.

Use a new save schema version if required and provide migration tests.

### 7. One equipped collectible + one deterministic puzzle perk

Add a minimal equipment system:
- the player may equip one unlocked collectible card;
- the equipped card ID persists;
- collection/detail UI clearly shows which card is equipped;
- only **one** puzzle perk needs to be functional in Phase 2B.

Choose a small deterministic perk consistent with the canonical ability data in `03_CONTENT_CATALOG.json`. The selected effect must:
- be easy to understand;
- be reproducible under a fixed seed;
- never make a level unwinnable;
- not require implementing the complete future ability framework;
- have focused domain tests proving its effect.

Document which card/perk was selected and why. Other cards may continue to display future ability text without active gameplay behavior.

### 8. World progression milestones

Update `world_nodes.json` and runtime state rules so:
- Kitchen unlock/progression is tied to the Chapter 2 / Level 20 milestone.
- Higher Art Gallery receives a visible preview/teaser milestone at Level 30 without falsely presenting the full Gallery as complete.
- Existing Lounge progression is preserved.
- Secret Basement, Festival Grounds, and unmarked workshop remain future content unless needed only as unchanged teasers.

### 9. Progress/save integrity

Preserve:
- completed levels;
- best scores;
- stars;
- coins;
- Lounge restoration/style;
- collectible discovery/unlock/favorite state;
- current story/world state;
- settings.

Add persistence for:
- collection XP;
- evolved card stages if not derivable safely;
- equipped collectible ID;
- new Chapter 2/3 flags and world milestone state.

Migration from the verified Phase 2A schema must be covered by tests.

## Architecture rules

- Keep gameplay rules in the domain layer, not embedded in widgets.
- Flame/presentation code should render state, not become the source of progression truth.
- Preserve deterministic RNG behavior.
- Avoid broad rewrites of working Phase 1/2A systems.
- Prefer extending current models/catalogs over creating parallel competing systems.
- Do not add networking, commerce, PvP, chat, cloud sync, ads, account systems, or real-world cannabis instructional content in this phase.

## Verification gate

Before Phase 2B is considered complete:

1. `dart format`/Flutter formatting is clean.
2. `flutter analyze` reports no issues.
3. `flutter test` passes in full.
4. Add tests for Levels 11–30 catalog validity and stable identities.
5. Add focused tests for Sticky Syrup.
6. Add focused tests for Fog reveal stability.
7. Add tests for collection XP/evolution thresholds.
8. Add tests for equipped-card persistence and the selected deterministic perk.
9. Add save migration/round-trip tests from Phase 2A schema.
10. Verify Chapters 2 and 3 are marked/playable at the correct progression points.
11. Verify Kitchen Level-20 and Gallery Level-30 milestones.
12. Build a debug APK if the environment supports it without requiring owner credentials.

Do not delete or weaken existing tests to make the gate pass.

## Documentation and checkpoints

Before implementation:
- record the synchronized baseline commit in `docs/BUILD_LOG.md`.

During/after implementation:
- update `docs/CURRENT_STATE.md` with verified facts only;
- append meaningful implementation checkpoints to `docs/BUILD_LOG.md`;
- keep `docs/ROADMAP.md` current;
- create logical commits rather than one opaque mega-commit.

## Autonomy / stopping rule

Work through all Phase 2B requirements without asking for approval between ordinary engineering decisions.

If one item is complete and verified, continue automatically to the next Phase 2B item.

Stop only for a blocker defined in `AGENTS.md`, or after the entire Phase 2B verification gate passes.

When finished, report:
- final commit SHA;
- feature summary;
- test count/results;
- analyzer result;
- APK/build result if available;
- save migration/schema result;
- selected equipped-card perk;
- any genuine blockers;
- recommended next roadmap item.
