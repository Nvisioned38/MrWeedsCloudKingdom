# Issue #26 — Samsung S24 Ultra QA

**Date:** 2026-11-11  
**Device:** Samsung Galaxy S24 Ultra, model SM-S928U, serial `R5CX156CZNF`  
**Android user:** 0  
**Application:** `com.mrweeds.cloudkingdom.qa`, version `0.1.0` / code 2001  
**Build SHA-256:** `629185e3c35482f6807a593253da22a08e98099a87c656d2e3b2a7677552e9fd`

## Safety and saved data

ADB reported the device authorized; active user was 0; the exact QA package was present under user 0 and the QA app was foregrounded during visual checks. The existing QA APK was updated only with `tools/build_qa_apk.ps1 -Action InstallQa`, which uses signature/version/package checks and `adb install -r --user 0`. The installer reported success and confirmed no data clear/uninstall.

The QA app `FlutterSharedPreferences.xml` SHA-256 was `687d0c95680855530c13f0a320990feca04f6bb7ce68a43713546ca3767cac03` before installation, immediately after installation, and after preview navigation. Only the isolated QA package was launched. The production application and its data were not queried or changed.

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
| Actual Chapter 2/3 story navigation | NOT TESTED | The saved game was at Level 15; Riff and Mona beats unlock at Levels 16 and 26. Story navigation was not advanced or persisted to preserve existing progress. Read-only preview used the actual catalog lines and expression mappings. |
| Track B characters | NOT TESTED | No unapproved Chef Blaze, Dr. Cloud or Collector candidate was runtime-imported. |

No gameplay move, replay, reward claim, chapter completion or save reset occurred. The welcome screen showed the existing Level 15 progress in Cloud House during the session.

## Known issues

The preview initially placed its last story card behind the bottom system navigation area. It now wraps the preview list in `SafeArea`; the updated S24 capture confirms the card clears the navigation inset. This change is isolated to the QA-only preview screen.

This is character-art preview QA, not V1 final visual approval. Track B still requires owner approval and locked standalone export hashes. The PR remains draft.
