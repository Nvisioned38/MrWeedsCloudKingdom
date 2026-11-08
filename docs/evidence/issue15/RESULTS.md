# Issue #15 — Content-aware objectives panel

## Implementation

The former objectives panel stretched a fixed ornamental backing at ordinary text sizes and swapped to a different plain backing at enlarged sizes. The panel now uses one content-sized, high-contrast Flutter frame at every scale. Its natural height follows wrapped objective text and the number of objective rows; progress values remain inside the frame. The 30-move counter scales its digits down within its existing approved counter art. No approved image files, manifests, brands, game rules, saves or authored levels were changed.

## Results

| Check | Result | Evidence |
|---|---|---|
| 1, 2 and 3 objectives | **PASS — automated** | Heights increase to fit each added row; every title, long localized-like label, and value stays inside the frame. |
| Text scale 0.9×, 1×, 1.5× and 2× | **PASS — automated** | Objective presentation/widget fixtures cover all four scales. |
| Three-objective Level 10-style panel with 30 moves | **PASS — automated and S24** | S24 Level 10 at text 0.9× and 2× shows all rows and the 30-move counter within the panel/backing. |
| Board area and input cells | **PASS — automated and S24** | At 0.9×/1×/1.5×/2×, first and last labeled cells and the board frame remain visible; the S24 2× capture shows the complete 8×8 grid. No move was made. |
| Existing QA save | **PASS — preserved** | User-0 `.qa` update used verified replace install. Level 10 / Lounge Rescue, 1,295 coins and 9 stars remained visible. No app data clear/reset or production app access occurred. |
| Original system font scale | **PASS — restored** | Read as 0.9 before the temporary 2× check and returned to 0.9 immediately afterward. |

### Samsung S24 Ultra evidence

- Normal 0.9× board: [03-board-0_9x.png](03-board-0_9x.png)
- Enlarged 2× board: [04-board-2x.png](04-board-2x.png)
- Current Cloud House showing the retained progress: [02-cloud-house-current.png](02-cloud-house-current.png)
- Earlier pre-fix board capture from Issue #12 for comparison: [../issue12/03-board-aligned.png](../issue12/03-board-aligned.png)

The issue-specific regression tests are in `test/presentation/match3_art_widgets_test.dart` and `test/widget_test.dart`. Full Flutter results and current APK/package hashes are recorded in the root build log / Issue #14 verification after the final commit.
