#!/usr/bin/env python3
"""Validate SSZG incremental hot-update manifests before publishing.

The client appends `.g` to each manifest `file` value. Therefore manifest
`file` values must be extensionless. This validator also checks that each
referenced blob exists in the same logical asset directory and that its byte
size matches the manifest metadata.

Usage:
  python scripts/validate_incver_manifest.py /path/to/inc_ver.lua
  python scripts/validate_incver_manifest.py /path/to/inc_ver.lua --blob-root /path/to/inc_ver/70

Exit code 0 means the manifest is safe to publish. Exit code 2 means one or
more validation errors were found.
"""

from __future__ import annotations

import argparse
import os
import re
import sys
from pathlib import Path

ENTRY_RE = re.compile(
    r"\['([^']+)'\]\s*=\s*\{\s*file='([^']+)'\s*,\s*size=(\d+)\s*,\s*ver=(\d+)\s*\}"
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("manifest", type=Path, help="Path to inc_ver.lua")
    parser.add_argument(
        "--blob-root",
        type=Path,
        default=None,
        help="Root containing the hashed .g blobs; defaults to the manifest directory",
    )
    parser.add_argument(
        "--allow-missing-blobs",
        action="store_true",
        help="Only validate manifest semantics; do not fail on missing blob files",
    )
    parser.add_argument(
        "--skip-size-check",
        action="store_true",
        help="Do not compare blob byte size with manifest size metadata",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    manifest = args.manifest.resolve()
    blob_root = (args.blob_root or manifest.parent).resolve()

    if not manifest.is_file():
        print(f"ERROR manifest does not exist: {manifest}", file=sys.stderr)
        return 2

    raw = manifest.read_bytes()
    text = raw.decode("utf-8", "replace")
    rows = ENTRY_RE.findall(text)
    if not rows:
        print("ERROR manifest contains no parsable entries", file=sys.stderr)
        return 2

    errors: list[str] = []
    seen_assets: set[str] = set()
    expected_blobs: set[Path] = set()
    total_declared = 0
    exact_size_refs = 0

    for asset, file_value, size_text, version_text in rows:
        declared_size = int(size_text)
        total_declared += declared_size

        if asset in seen_assets:
            errors.append(f"DUPLICATE_ASSET asset={asset}")
        seen_assets.add(asset)

        if file_value.endswith(".g"):
            errors.append(
                f"FILE_FIELD_HAS_G asset={asset} file={file_value} "
                "(client appends .g; this would request .g.g)"
            )

        if "/" in file_value or "\\" in file_value:
            errors.append(f"FILE_FIELD_HAS_PATH_SEPARATOR asset={asset} file={file_value}")

        logical_dir = os.path.dirname(asset)
        blob_name = file_value + ".g"
        blob_path = (blob_root / logical_dir / blob_name).resolve()
        expected_blobs.add(blob_path)

        try:
            blob_path.relative_to(blob_root)
        except ValueError:
            errors.append(f"BLOB_PATH_ESCAPES_ROOT asset={asset} path={blob_path}")
            continue

        if not blob_path.is_file():
            if not args.allow_missing_blobs:
                errors.append(f"MISSING_BLOB asset={asset} path={blob_path}")
            continue

        if not args.skip_size_check:
            actual_size = blob_path.stat().st_size
            if actual_size != declared_size:
                errors.append(
                    f"SIZE_MISMATCH asset={asset} declared={declared_size} "
                    f"actual={actual_size} path={blob_path}"
                )
            else:
                exact_size_refs += 1

    print(f"MANIFEST={manifest}")
    print(f"BLOB_ROOT={blob_root}")
    print(f"ENTRIES={len(rows)}")
    print(f"UNIQUE_ASSETS={len(seen_assets)}")
    print(f"UNIQUE_EXPECTED_BLOBS={len(expected_blobs)}")
    print(f"DECLARED_BYTES={total_declared}")
    print(f"EXACT_SIZE_REFS={exact_size_refs}")
    print(f"ERRORS={len(errors)}")

    if errors:
        for item in errors[:500]:
            print(f"ERROR {item}", file=sys.stderr)
        if len(errors) > 500:
            print(f"ERROR ... {len(errors) - 500} additional errors omitted", file=sys.stderr)
        return 2

    print("INCVER_MANIFEST_VALIDATION_OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
