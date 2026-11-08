"""Verify immutable owner-approved Issue #4 Match-3 RGBA sprites.

The two per-asset approval manifests are authoritative for byte-level exports.
This deliberately fails if a PNG has been remade, resized, renamed or replaced.
"""
from __future__ import annotations

import csv
import hashlib
import struct
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFESTS = (
    ROOT / 'art_production/issue4/approved_A_manifest.csv',
    ROOT / 'art_production/issue4/approved_BC_manifest.csv',
)
PNG_SIGNATURE = b'\x89PNG\r\n\x1a\n'


def main() -> None:
    verified = 0
    seen: set[str] = set()
    for manifest_path in MANIFESTS:
        with manifest_path.open(newline='', encoding='utf-8') as handle:
            for record in csv.DictReader(handle):
                path = record.get('runtime_path') or record['target_runtime_path']
                if path in seen:
                    raise AssertionError(f'Duplicate runtime path: {path}')
                seen.add(path)
                if not path.startswith('assets/art/match3/') or not path.endswith('.png'):
                    raise AssertionError(f'Unexpected export destination: {path}')
                file = ROOT / path
                raw = file.read_bytes()
                sha = hashlib.sha256(raw).hexdigest()
                expected_sha = record['export_sha256'].lower()
                if sha != expected_sha:
                    raise AssertionError(f'{path}: SHA-256 mismatch ({sha} != {expected_sha})')
                if not raw.startswith(PNG_SIGNATURE) or raw[12:16] != b'IHDR':
                    raise AssertionError(f'{path}: invalid PNG signature or IHDR')
                width, height = struct.unpack('>II', raw[16:24])
                exp_width, exp_height = (int(x) for x in record['export_dimensions'].split('x'))
                if (width, height) != (exp_width, exp_height):
                    raise AssertionError(f'{path}: dimensions differ from approved export')
                if raw[24] != 8 or raw[25] != 6:
                    raise AssertionError(f'{path}: expected 8-bit RGBA PNG')
                verified += 1
    if verified != 37:
        raise AssertionError(f'Expected 37 exports, found {verified}')
    print(f'Verified {verified} independent owner-approved PNG exports, byte-exact to SHA-256 manifests.')


if __name__ == '__main__':
    try:
        main()
    except (AssertionError, OSError, KeyError, ValueError) as err:
        print(f'Issue #4 art verification FAILED: {err}', file=sys.stderr)
        sys.exit(1)