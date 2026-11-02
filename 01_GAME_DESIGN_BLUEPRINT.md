# 01 — Game Design Blueprint

## Core loop
**PLAY → EARN → BUILD → COLLECT → DISCOVER → PLAY**

### 1. Play
Complete a 60–120 second Match-3 level or a short mini-game.

### 2. Earn
Typical rewards:
- Coins
- Stars
- Collection XP
- Keys on milestone levels
- Rare mystery drops

### 3. Build
Stars restore or expand the world. Coins purchase normal cosmetic choices.

### 4. Collect
Unlock strain cards, artwork, decor, character souvenirs, event trophies, and rare curios.

### 5. Discover
Completed sets, unusual level outcomes, exploration, and hidden interactions reveal secrets.

## Game mix target
- 60% Match-3
- 15% collection
- 10% decorating
- 10% mini-games
- 5% story/exploration

## World structure

### Area 1 — Cloud House
The starting hub and visual proof of player progression.
Rooms:
- Front Porch
- Lounge
- Kitchen
- Game Room
- Secret Basement

### Area 2 — Higher Art Gallery
A visible collection museum and art restoration space.
Functions:
- Display unlocked art
- Display rare collectibles
- Collection-set rewards
- Art puzzle mini-game

### Area 3 — Festival Grounds
The live-event and seasonal expansion zone.
Functions:
- Seasonal maps
- Limited challenges
- Event trophies
- Community meters later

## Characters
1. **Mr. Weed** — guide, wildcard specialist, story anchor.
2. **Chef Blaze** — High Cuisine challenges and food mini-games.
3. **Dr. Cloud** — experimental puzzle modifiers and booster tutorials.
4. **Mona Chromatic** — Higher Art curator and visual collection quests.
5. **Riff** — festival promoter and event host.
6. **The Collector** — rare-set tracker, secret missions, mystery-room access.

## Match-3 fundamentals
### Board
- Default: 8×8
- Allowed variants: 7×7, 8×8, 9×9
- 5 base tile families at launch
- 6th tile family introduced only on selected later levels

### Matching
- 3: normal clear
- 4 line: directional Cloud Rocket
- 5 line: Prism Bud, clears all tiles of a selected family
- T/L shape: Cloud Bomb, area blast
- Special + special combinations create stronger interactions

### Level objectives
- Score target
- Clear blockers
- Collect target tiles
- Drop objects to exits
- Spread/clear cloud zones
- Multi-stage boss objective

### Launch blockers
1. Crate — one hit
2. Reinforced Crate — two hits
3. Sticky Syrup — tile cannot move until cleared adjacent
4. Fog — hides tile identity until adjacent match
5. Chain — tile fixed until hit
6. Ice — layered blocker
7. Portal — reroutes falling pieces
8. Locked Display Case — key objective interaction

### Fairness rules
- Never intentionally create unwinnable starting boards.
- Board must always contain at least one legal move.
- If no legal move exists, shuffle automatically with no penalty.
- Difficulty may rise through objective interaction, not through deliberately hostile RNG.
- Failure offers replay first. Purchases are never required.

## Boosters
Earnable through play.
1. **Cloud Hammer** — clears one tile/blocker.
2. **Rocket Tap** — clears selected row or column.
3. **Prism Puff** — removes one tile family.
4. **Shuffle Shake** — reshuffles board.
5. **Mr. Weed Wildcard** — converts one tile to chosen family.
6. **Extra Moves** — earned/rewarded option, never mandatory.

## Economy
### Coins
Earned from normal play.
Used for:
- regular decor
- cosmetic variants
- low-tier booster purchases
- non-critical world personalization

### Stars
Earned from first-time level completion.
Used for:
- story restoration
- area unlock milestones
- room restoration

### Cloud Tokens
Premium/rare currency.
Used for:
- premium cosmetic themes
- special decor bundles
- cosmetic character variants

Cloud Tokens must not gate normal progression.

### Keys
Milestone collectible.
Used for:
- secret doors
- special chapters
- rare collection vaults

## Collection system
Collectibles belong to visible sets. Completing a set should do something.

### Strain card fields
- id
- display_name
- collection
- class
- rarity
- puzzle_ability
- ability_level
- evolution_stage
- lore
- art_asset
- discovered
- favorite

### Evolution
No cultivation simulation.
Cards evolve through collection XP and play milestones:
1. Seedling
2. Bud
3. Frosted
4. Legendary

Evolution changes:
- card frame
- animation
- puzzle perk strength
- display pedestal

## Collection Museum
Unlocked collectibles physically appear somewhere in the world.
Examples:
- strain cards become animated display cases,
- art appears on gallery walls,
- trophies fill shelves,
- seasonal objects remain as historical proof of participation.

The museum is the player's visible history, not a spreadsheet.

## Decorating
Player choices must be real.

Each restoration node can have:
- 3–5 style options
- optional recolors
- later repositioning where practical

Launch themes:
- Classic Cloud
- Psychedelic
- 1970s Lounge
- Neon Future
- Haunted
- Chicago-inspired

Decorating is cosmetic and never reduces puzzle capability.

## Mini-games

### High Cuisine Rush
Short assembly/sorting game.
- Select correct ingredients
- Sequence steps
- Beat the clock
- No real infused-food dosage or drug-use instructions

### Higher Art Restore
Reassemble fragmented art or solve rotation/tile puzzles.

### Cloud Cup Fill
Timing/precision arcade game based on filling a stylized fantasy cloud meter.

Future:
- Bud Drop physics puzzle
- Memory Match
- Festival Cleanup
- Terp Trails path puzzle

## Secrets
Discovery rules are intentionally non-obvious but fair.
Examples:
- Tap a specific prop several times.
- Finish a chapter with every level at 3 stars.
- Complete a named collection set.
- Finish a challenge with exactly a target number of moves.
- Assemble art fragments into a hidden map.

Secrets should unlock cosmetics, lore, rooms, or collectibles, not required progression.

## Daily/weekly retention
Daily:
- one rotating challenge
- one optional reward chest
- one visitor interaction

Weekly:
- themed challenge chain
- collection bonus
- decoration reward

Avoid punitive streak loss. Missing a day should not feel like a tax.

## Monetization principles
Allowed:
- cosmetic bundles
- optional Cloud Tokens
- optional rewarded ads
- seasonal cosmetic passes if content volume eventually supports them

Avoid:
- forced interstitial ads
- energy systems that stop normal play
- purchase-only level completion
- random paid loot boxes
- fake difficulty designed to sell moves

## Story chapters 1–10
1. **Welcome to the Clouds** — restore the porch and lounge.
2. **Kitchen Catastrophe** — meet Chef Blaze.
3. **The Missing Collection** — first strain-card mystery.
4. **Gallery in the Fog** — unlock Higher Art Gallery.
5. **Riff's Big Idea** — Festival Grounds preview.
6. **Basement Door** — keys and secret-room system.
7. **Cloud Lab** — advanced blockers and experimental boards.
8. **Festival Fever** — event-rule tutorial.
9. **The Collector Calls** — rare-set hunt.
10. **Kingdom Rising** — launch-era finale and next-region tease.
