"""Verify the 24 locked Issue #26 character exports in the Flutter bundle."""
from __future__ import annotations

import csv
import hashlib
import struct
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "art_production/characters/batch_g_three_trolls_2026_11_11/approved_export_manifest.csv"
RUNTIME = ROOT / "assets/art/characters/batch_g_three_trolls_2026_11_11"
PNG_SIGNATURE = b"\x89PNG\r\n\x1a\n"


def main() -> None:
    seen: set[str] = set()
    count = 0
    with MANIFEST.open(newline="", encoding="utf-8-sig") as handle:
        for row in csv.DictReader(handle):
            if row["approval"] != "APPROVED_LOCKED_2026-11-11":
                raise SystemExit(f"Unexpected approval state: {row['filename']}")
            relative = Path(row["filename"])
            filename = relative.name
            target = RUNTIME / row["character"] / filename
            if str(target) in seen:
                raise SystemExit(f"Duplicate target: {target}")
            seen.add(str(target))
            data = target.read_bytes()
            if hashlib.sha256(data).hexdigest() != row["sha256"]:
                raise SystemExit(f"SHA-256 mismatch: {target}")
            if data[:8] != PNG_SIGNATURE:
                raise SystemExit(f"Invalid PNG signature: {target}")
            width, height, bit_depth, color_type = struct.unpack(">IIBB", data[16:26])
            expected_width, expected_height = map(int, row["dimensions"].split("x"))
            if (width, height) != (expected_width, expected_height):
                raise SystemExit(f"Dimensions mismatch: {target}: {width}x{height}")
            if bit_depth != 8 or color_type != 6:
                raise SystemExit(f"Expected 8-bit RGBA PNG: {target}")
            count += 1
    if count != 24:
        raise SystemExit(f"Expected 24 locked PNGs; verified {count}")
    print(f"PASS: {count}/24 locked PNG hashes, dimensions, and RGBA channels verified")


if __name__ == "__main__":
    main()
