# Issue #4 — approved standalone artwork

Owner approval authority: v10 Standalone Assets tracker plus subsequent owner approval in the artwork conversation. On 2026-11-08, the owner approved visual integration of all 37 newly authored Batch A + B/C exports. This approval supersedes older archive README/manifest fields that say “review required.”

The integrated runtime bytes match the supplied independent-export manifests exactly. The combined handoff `Cloud_Kingdom_All_37_Approved_Art.zip` has SHA-256 `84bc61e2155c89db11927239b4b477c8599ddc63a262bb01e757a9beb30712d7`. Batch A is checked against `approved_A_manifest.csv`; B/C is checked against `approved_BC_manifest.csv`. `tools/verify_issue4_art.py` validates all 37 export SHA-256 values, PNG dimensions and 8-bit RGBA alpha-capable format.

The separate, logo-free Cloud Cup vaporizer uses the exact canonical `assets/art/brand/cloud_cup_logo.png` as a distinct overlay. The logo bytes are not altered or redrawn. Objectives, counters, scores, rewards, and button labels remain dynamic. Engine identifiers, deterministic gameplay, schema-3 saves, all 30 authored levels, and the V1 story firewall are preserved.

Approval for visual integration does not imply device QA or V1 completion. Final Samsung S24 visual/device QA and remaining release gates are tracked in `docs/V1_QA_CHECKLIST.md`. Batch D was supplied as a review package only and is not included in these 37 runtime exports.
