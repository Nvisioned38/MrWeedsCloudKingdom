# Issue #26 — Samsung S24 Ultra QA

**Date:** 2026-11-11  
**Device:** Samsung Galaxy S24 Ultra, model SM-S928U, serial `R5CX156CZNF`  
**Android user:** 0  
**Application:** `com.mrweeds.cloudkingdom.qa`, version `0.1.0` / code 2001  
**Build SHA-256:** `be111d028caa4cf1cd922ad2b4eb775afa768ac72cdc3895f5fee0c9d3098239`

## Safety and saved data

ADB reported the device authorized; active user was 0; the exact QA package was present under user 0 and the QA app was foregrounded during visual checks. The existing QA APK was updated only with `tools/build_qa_apk.ps1 -Action InstallQa`, which uses signature/version/package checks and `adb install -r --user 0`. The installer reported success and confirmed no data clear/uninstall.

The QA app `FlutterSharedPreferences.xml` SHA-256 was `687d0c95680855530c13f0a320990feca04f6bb7ce68a43713546ca3767cac03` before installation, immediately after installation, after preview navigation, and after the story-fixture run. Only the isolated QA package was launched. The production application and its data were not queried or changed.

## Physical results

| Check | Result | Evidence / notes |
|---|---|---|
| QA title and isolated preview entry | PASS | `s24_welcome.png`; QA-only preview button visible. |
| Mona Chromatic full-body hero | PASS | `s24_preview_top.png`; transparent hero preserves hair, palette and clothing edges. |
| Mona round/square UI icons | PASS | `s24_preview_top.png`; both variants render independently. |
| Mona eight dialogue expressions | PASS | `s24_preview_top.png`; all eight approved framed exports display. |
| Mona mapped story portrait and line | PASS | `s24_preview_safearea.png`; card uses the approved thinking portrait and Chapter 3 line. |
| Riff full-body hero | PASS | `s24_preview_safearea.png`; Cloud Guitar and full silhouette are visible. |
| Riff round/square UI icons | PASS | `s24_preview_safearea.png`. |
| Riff eight dialogue expressions | PASS | `s24_preview_safearea.png`; all eight approved framed exports display. |
| Riff mapped story portrait and line | PASS | `s24_preview_safearea.png`; card uses the playful expression and Chapter 2 line. |
| Portrait frame/background preservation | PASS | Dialogue portrait cards render the full approved gold frame uncropped. |
| Navigation safe-area handling | PASS after fix | Final Riff story card is fully visible above Android navigation. |
| Chapter 2 gate before Riff (Level 15 fixture) | PASS | In-memory fixture seeded through Level 14 shows `1 of 3 story beats available`; Riff is absent. `s24_ch2_level15_fixture.png`. |
| Riff beat unlock at Level 16 | PASS | In-memory fixture seeded through Level 15 shows `2 of 3 story beats available`; Level 16 fixture opens the actual Chapter 2 dialogue sequence and Riff's playful framed portrait/line. `s24_ch2_level16_riff_unlocked.png`, `s24_riff_level16_dialogue.png`. |
| Chapter 3 gate before Mona (Level 25 fixture) | PASS | In-memory fixture seeded through Level 24 shows `1 of 3 story beats available`; the newly unlocked beat is still Collector-only. `s24_ch3_level25_mona_locked.png`. |
| Mona beat unlock at Level 26 | PASS | In-memory fixture seeded through Level 25 shows `2 of 3 story beats available`; Level 26 fixture opens the actual Chapter 3 dialogue sequence and Mona's thinking framed portrait/line. `s24_ch3_level26_mona_unlocked.png`, `s24_mona_level26_dialogue.png`. |
| Dialogue progression, speaker/portrait switching, close/navigation | PASS | S24 moved through dialogue pages to Riff and Mona, rendered each mapped expression, and `Close Story` returned to its chapter list. Fixture flags were discarded on leaving their screen. |
| Completion flags and duplicate/persist behavior | NOT TESTED physically; PASS automated | S24 fixtures use a no-op persist callback and are intentionally disposable. Widget tests verify story-seen/known flags, completion gates at Levels 20/30, persistence callback count and unchanged chapter completion before its required level. |
| 1×/2× text, portrait/landscape, Android insets | PASS automated; partial physical | Widget tests cover 1× and 2× portrait/landscape viewports and safe-area insets without overflow. S24 screenshots cover normal text in portrait with status/navigation areas visible. Physical 2× and rotated S24 checks are NOT TESTED. |
| Track B characters | NOT TESTED | No unapproved Chef Blaze, Dr. Cloud or Collector candidate was runtime-imported. |

The story fixture explicitly creates isolated in-memory progress and a no-op persistence callback; no Level 15 owner progress was changed. No gameplay move, replay, reward claim, chapter completion, production app access, Secure Folder access or save reset occurred. The physical fixtures test authored beat gates; they do not change the real Cloud House progress.

## Known issues

The preview initially placed its last story card behind the bottom system navigation area. It now wraps the preview list in `SafeArea`; the updated S24 capture confirms the card clears the navigation inset. This change is isolated to the QA-only preview screen.

This is character-art preview QA, not V1 final visual approval. Track B still requires owner approval and locked standalone export hashes. The PR remains draft.
