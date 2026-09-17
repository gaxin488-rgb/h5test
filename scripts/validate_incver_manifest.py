#!/usr/bin/env python
"""Validate SSZG incremental hot-update manifests before publishing.

The client appends `.g` to each manifest `file` value. Therefore manifest
`file` values must be extensionless. This validator also checks that each
referenced blob exists in the same logical asset directory and that its byte
size matches the manifest metadata.

Compatible with Python 2.7 and Python 3.

Usage:
  python scripts/validate_incver_manifest.py /path/to/inc_ver.lua
  python scripts/validate_incver_manifest.py /path/to/inc_ver.lua --blob-root /path/to/inc_ver/70

Exit code 0 means the manifest is safe to publish. Exit code 2 means one or
more validation errors were found.
"""

from __future__ import print_function

import argparse
import os
import re
import sys

ENTRY_RE = re.compile(
    r"\['([^']+)'\]\s*=\s*\{\s*file='([^']+)'\s*,\s*size=(\d+)\s*,\s*ver=(\d+)\s*\}"
)


def parse_args():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("manifest", help="Path to inc_ver.lua")
    parser.add_argument(
        "--blob-root",
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


def inside_root(path, root):
    path = os.path.realpath(path)
    root = os.path.realpath(root)
    return path == root or path.startswith(root.rstrip(os.sep) + os.sep)


def main():
    args = parse_args()
    manifest = os.path.realpath(args.manifest)
    blob_root = os.path.realpath(args.blob_root or os.path.dirname(manifest))

    if not os.path.isfile(manifest):
        print("ERROR manifest does not exist: %s" % manifest, file=sys.stderr)
        return 2

    raw = open(manifest, "rb").read()
    try:
        text = raw.decode("utf-8", "replace")
    except AttributeError:
        text = raw
    rows = ENTRY_RE.findall(text)
    if not rows:
        print("ERROR manifest contains no parsable entries", file=sys.stderr)
        return 2

    errors = []
    seen_assets = set()
    expected_blobs = set()
    total_declared = 0
    exact_size_refs = 0

    for asset, file_value, size_text, version_text in rows:
        declared_size = int(size_text)
        total_declared += declared_size

        if asset in seen_assets:
            errors.append("DUPLICATE_ASSET asset=%s" % asset)
        seen_assets.add(asset)

        if file_value.endswith(".g"):
            errors.append(
                "FILE_FIELD_HAS_G asset=%s file=%s "
                "(client appends .g; this would request .g.g)" % (asset, file_value)
            )

        if "/" in file_value or "\\" in file_value:
            errors.append("FILE_FIELD_HAS_PATH_SEPARATOR asset=%s file=%s" % (asset, file_value))

        logical_dir = os.path.dirname(asset)
        blob_name = file_value + ".g"
        blob_path = os.path.realpath(os.path.join(blob_root, logical_dir, blob_name))
        expected_blobs.add(blob_path)

        if not inside_root(blob_path, blob_root):
            errors.append("BLOB_PATH_ESCAPES_ROOT asset=%s path=%s" % (asset, blob_path))
            continue

        if not os.path.isfile(blob_path):
            if not args.allow_missing_blobs:
                errors.append("MISSING_BLOB asset=%s path=%s" % (asset, blob_path))
            continue

        if not args.skip_size_check:
            actual_size = os.path.getsize(blob_path)
            if actual_size != declared_size:
                errors.append(
                    "SIZE_MISMATCH asset=%s declared=%d actual=%d path=%s"
                    % (asset, declared_size, actual_size, blob_path)
                )
            else:
                exact_size_refs += 1

    print("MANIFEST=%s" % manifest)
    print("BLOB_ROOT=%s" % blob_root)
    print("ENTRIES=%d" % len(rows))
    print("UNIQUE_ASSETS=%d" % len(seen_assets))
    print("UNIQUE_EXPECTED_BLOBS=%d" % len(expected_blobs))
    print("DECLARED_BYTES=%d" % total_declared)
    print("EXACT_SIZE_REFS=%d" % exact_size_refs)
    print("ERRORS=%d" % len(errors))

    if errors:
        for item in errors[:500]:
            print("ERROR %s" % item, file=sys.stderr)
        if len(errors) > 500:
            print("ERROR ... %d additional errors omitted" % (len(errors) - 500), file=sys.stderr)
        return 2

    print("INCVER_MANIFEST_VALIDATION_OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
