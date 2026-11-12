#!/usr/bin/env python3
"""Verify the 22 locked Riff/Mona PNG exports against the approval manifest."""

from __future__ import annotations

import argparse
import csv
import hashlib
import struct
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "art_production/issue26/Batch_G_Riff_Mona_approved_manifest.csv"


def png_info(path: Path) -> tuple[int, int, int]:
    with path.open("rb") as stream:
        header = stream.read(26)
    if header[:8] != b"\x89PNG\r\n\x1a\n" or header[12:16] != b"IHDR":
        raise ValueError(f"not a valid PNG: {path}")
    width, height = struct.unpack(">II", header[16:24])
    color_type = header[25]
    return width, height, color_type


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=ROOT)
    parser.add_argument("--manifest", type=Path, default=MANIFEST)
    args = parser.parse_args()
    errors: list[str] = []
    rows = [
        row
        for row in csv.DictReader(args.manifest.open(encoding="utf-8-sig", newline=""))
        if row.get("asset_type") != "layout_sheet"
    ]
    if len(rows) != 22:
        errors.append(f"expected 22 approval rows, found {len(rows)}")
    for row in rows:
        if row.get("status") != "APPROVED_LOCKED_2026-11-09":
            errors.append(f"{row.get('path')}: approval status is not locked")
            continue
        filename = Path(row["path"]).name
        path = args.root / "assets/art/characters" / filename
        if not path.is_file():
            errors.append(f"missing runtime copy: {path}")
            continue
        actual_hash = sha256(path)
        if actual_hash != row["sha256"]:
            errors.append(f"{filename}: SHA-256 mismatch {actual_hash}")
        try:
            width, height, color_type = png_info(path)
        except ValueError as error:
            errors.append(str(error))
            continue
        if (width, height) != (int(row["width"]), int(row["height"])):
            errors.append(f"{filename}: dimensions {width}x{height} != manifest")
        if row["mode"] == "RGBA" and color_type != 6:
            errors.append(f"{filename}: expected PNG RGBA (color type 6), got {color_type}")
        print(f"PASS {row['character']}: {filename} {width}x{height} RGBA sha256={actual_hash}")
    if errors:
        print("ISSUE #26 ART VERIFICATION FAILED", file=sys.stderr)
        for error in errors:
            print(f"ERROR: {error}", file=sys.stderr)
        return 1
    print(f"Issue #26 locked export verification passed: {len(rows)}/22 files")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
