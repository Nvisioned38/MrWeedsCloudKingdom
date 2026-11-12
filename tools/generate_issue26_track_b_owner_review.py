"""Generate a hash-addressed, review-only handoff for Issue #26 Track B."""

from __future__ import annotations

import csv
import hashlib
import json
import zipfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
ISSUE = ROOT / "art_production" / "issue26"
TRACK = ISSUE / "track_b_review"
REVIEW = TRACK / "review"
AUDIT = REVIEW / "candidate_image_audit.csv"
OUT = REVIEW / "TRACK_B_OWNER_REVIEW.md"
PACKAGE = ISSUE / "BATCH_G_Character_Review_Package_ReviewOnly_v2.zip"

DETAILS = {
    "chef_blaze": {
        "display": "Chef Blaze",
        "source": "chef_blaze_LOCKED_SOURCE.png",
        "identity": "Moss-gray stone skin; ember-orange hair; mustache and goatee; teal/gold chef uniform; cream apron; skillet.",
        "review": "The candidate hero matches the locked chef face, hair, uniform and apron, but is cut off at the bottom by the expression-panel edge and includes part of the title panel. The expression crops retain labels, gold frames and sheet backgrounds; the UI crop includes the branded title area.",
    },
    "dr_cloud": {
        "display": "Dr. Cloud",
        "source": "dr_cloud_LOCKED_SOURCE.png",
        "identity": "Moss-gray/olive stone skin; pale lavender-gray hair; bronze goggles; teal-blue lab coat; open-top pear-shaped Cloud Glass with white smoke.",
        "review": "The hero crop shows the locked goggles, coat, hair and open Cloud Glass presentation, but retains the painted sheet background and a neighboring panel edge. Expression crops retain their labels and frames; the UI crop contains surrounding panel artwork.",
    },
    "the_collector": {
        "display": "The Collector",
        "source": "the_collector_LOCKED_SOURCE.png",
        "identity": "Moss-gray stone skin; charcoal-purple hair; spectacles; plum/gold curator outfit; watch chain; satchel.",
        "review": "The hero crop visibly matches the locked spectacles, hair, plum/gold outfit, chain and satchel, with the full shoes visible, but includes the painted sheet background and neighboring panel edge. Expression crops retain their labels and frames; the UI crop contains surrounding panel artwork.",
    },
}


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def main() -> None:
    rows = list(csv.DictReader(AUDIT.open(encoding="utf-8-sig", newline="")))
    if len(rows) != 30:
        raise SystemExit(f"Expected 30 candidate rows, found {len(rows)}")

    sections: list[str] = [
        "# Issue #26 — Track B owner visual review (review only)",
        "",
        "**Superseded package:** the exact 30 crop proposals listed below are old composition references only and are not the approved deliverables. Latest main now records the owner's lock for 24 standalone exports with per-file hashes in `docs/BATCH_G_THREE_TROLLS_STANDALONE_LOCK_2026-11-11.md` and `art_production/characters/batch_g_three_trolls_2026_11_11/approved_export_manifest.csv`. No new artwork approval or redesign is needed. Codex must receive and verify the exact approved ZIP before runtime import; do not substitute these crop proposals.",
        "",
        "## Status and safety",
        "",
        "| Character | Canonical design direction | Standalone export approval | Runtime readiness | S24 character QA |",
        "|---|---|---|---|---|",
        "| Riff | Approved/locked | 11 exports approved and hash-verified | Imported | PASS — S24 in-memory Level 15/16 fixtures; Riff playful portrait and Close Story navigation |",
        "| Mona Chromatic | Approved/locked | 11 exports approved and hash-verified | Imported | PASS — S24 in-memory Level 25/26 fixtures; Mona thinking portrait and Close Story navigation |",
        "| Chef Blaze | Approved/locked | 8 standalone exports approved and hash-locked | NOT IMPORTED — exact approved ZIP not found locally | NOT TESTED |",
        "| Dr. Cloud | Approved/locked | 8 standalone exports approved and hash-locked | NOT IMPORTED — exact approved ZIP not found locally | NOT TESTED |",
        "| The Collector | Approved/locked | 8 standalone exports approved and hash-locked | NOT IMPORTED — exact approved ZIP not found locally | NOT TESTED |",
        "",
        "Riff and Mona statuses reflect the current Issue #26 branch and S24 story-fixture record. Chef Blaze, Dr. Cloud and The Collector have approved standalone exports per latest main, but their exact ZIP is absent from the searched local Downloads and Batch G handoff/intake folders; none is in runtime yet. This older review-only Track B package is not a substitute. No production app, Secure Folder, saved game, level, Match-3 rule, animation, Cloud Bomb optimization, branding or schema was changed for this package.",
        "",
        "## File-level visual and alpha findings",
        "",
        "The 30 PNGs are rectangular crops from the unchanged canonical sheets. The source sheets and candidate crops were visually compared side by side in `BATCH_G_OWNER_VISUAL_REVIEW.html`. All 30 candidate PNGs have **zero fully transparent pixels**. Chef Blaze crops have partial alpha values throughout but no zero-alpha pixels; Dr. Cloud and The Collector crops are fully opaque. They therefore retain their source-sheet backgrounds, labels, frames or adjacent panel content. An exterior transparent-edge halo check is **NOT TESTED** because no standalone alpha extraction exists. Dimensions and SHA-256 below are verified against the current review files in `candidate_image_audit.csv`.",
        "",
        "| Character | Visual comparison to locked details | Clipping / crop contamination | Transparency / halo |",
        "|---|---|---|---|",
        "| Chef Blaze | Face, ember hair, mustache/goatee, teal/gold uniform, cream apron and skillet are visible and consistent with the source sheet. | Hero crop is clipped at bottom and includes the title-panel edge. Expression labels/frames and UI title area remain. | 0 transparent pixels; partial alpha only. Halo NOT TESTED. |",
        "| Dr. Cloud | Pale hair, bronze goggles, teal coat and open Cloud Glass with white smoke are visible and consistent with the source sheet. | Hero retains background and neighboring panel edge. Expressions and UI retain panel labels/framing. | 0 transparent pixels; fully opaque. Halo NOT TESTED. |",
        "| The Collector | Gray stone skin, dark purple hair, spectacles, plum/gold outfit, watch chain and satchel are visible and consistent with the source sheet. | Hero retains background and neighboring panel edge. Expressions and UI retain panel labels/framing. | 0 transparent pixels; fully opaque. Halo NOT TESTED. |",
        "",
        "These checks establish visual correspondence only. The crop files are not suitable for Flutter import. No character identity or artwork pixels were regenerated, repainted, recolored or altered during this review update.",
        "",
        "## Exact review images",
        "",
        "The hashes below identify only these superseded review-crop references; they are not the approved files and must not be imported. The approved standalone exports and exact per-file hashes are defined by the latest main manifest. Runtime import is blocked only until the exact approved ZIP bytes are received and verified.",
        "",
    ]

    by_character: dict[str, list[dict[str, str]]] = {}
    for row in rows:
        by_character.setdefault(row["Character"], []).append(row)

    for character_id, details in DETAILS.items():
        source = TRACK / "canonical_sources" / details["source"]
        notes_path = TRACK / "candidates" / character_id / "review_notes.json"
        notes = json.loads(notes_path.read_text(encoding="utf-8"))
        actual_source_hash = sha256(source)
        if actual_source_hash != notes["sourceSha256"]:
            raise SystemExit(f"Canonical source SHA mismatch for {character_id}")

        sections.extend(
            [
                f"### {details['display']}",
                "",
                f"Canonical source: `{details['source']}` — SHA-256 `{actual_source_hash}`.",
                f"\nLocked identity details reviewed: {details['identity']}",
                f"\nVisual review: {details['review']}",
                "",
                "| Candidate review file | Dimensions | Alpha counts (transparent / partial / opaque) | Review-file SHA-256 | Status |",
                "|---|---:|---:|---|---|",
            ]
        )
        for row in sorted(by_character.get(character_id, []), key=lambda item: item["File"]):
            candidate = TRACK / "candidates" / character_id / row["File"]
            actual_hash = sha256(candidate)
            if actual_hash != row["Sha256"].lower():
                raise SystemExit(f"Candidate SHA mismatch: {candidate}")
            if int(row["TransparentPixels"]) != 0:
                raise SystemExit(f"Unexpected zero-alpha pixels in {candidate}")
            alpha = " / ".join(
                row[key]
                for key in ("TransparentPixels", "PartialAlphaPixels", "OpaquePixels")
            )
            sections.append(
                f"| `{row['File']}` | {row['Width']} × {row['Height']} | {alpha} | `{actual_hash}` | REVIEW ONLY; not a final export |"
            )
        sections.append("")

    sections.extend(
        [
            "## Approved archive receipt required before runtime",
            "",
        "Do not approve or use these 30 crop references for runtime. The separately approved standalone exports are listed in the latest main manifest; no reapproval is requested:",
            "",
            "- Chef Blaze: `hero_candidate.png`, `expression_01_candidate.png` through `expression_08_candidate.png`, and `ui_candidate.png`.",
            "- Dr. Cloud: `hero_candidate.png`, `expression_01_candidate.png` through `expression_08_candidate.png`, and `ui_candidate.png`.",
            "- The Collector: `hero_candidate.png`, `expression_01_candidate.png` through `expression_08_candidate.png`, and `ui_candidate.png`.",
            "",
        "The 30 filenames above describe old crop proposals, not the approved filenames. Use the 24 entries in the authoritative latest-main export manifest only after the owner-approved ZIP is received and its expected archive SHA-256 and included verifier both pass.",
            "",
            "## Package contents",
            "",
            "- `BATCH_G_OWNER_VISUAL_REVIEW.html`: canonical reference next to hero, eight expression and UI crop proposals for each character.",
            "- `candidate_image_audit.csv`: per-file dimensions, alpha pixel counts, corner alpha, SHA-256 and review status.",
            "- `character_approval_runtime_status.csv`: separate source approval, export approval, runtime readiness and device QA states.",
            "- `../canonical_sources/` and `../candidates/`: unchanged sources and review-only crop proposals.",
            "",
        ]
    )

    OUT.write_text("\n".join(sections), encoding="utf-8")

    included = sorted(path for path in TRACK.rglob("*") if path.is_file())
    with zipfile.ZipFile(PACKAGE, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=6) as archive:
        for path in included:
            archive.write(path, path.relative_to(TRACK.parent))

    print(f"Validated 3 canonical source hashes and 30 review-crop hashes.")
    print(f"Wrote {OUT}")
    print(f"Wrote review-only ZIP {PACKAGE} ({PACKAGE.stat().st_size} bytes; SHA-256 {sha256(PACKAGE)})")


if __name__ == "__main__":
    main()
