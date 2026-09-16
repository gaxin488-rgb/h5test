#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
PROD="/data/sszg_code/v200408/server/ebin/gift_data.beam"
BUILDER="$SCRIPT_DIR/gift_39053_build_patch.escript"
DEPLOY="$SCRIPT_DIR/gift_39053_deploy_verified.sh"
ESCRIPT="/opt/erlang/otp19.2/bin/escript"
EXPECTED_PROD_SHA="2da4dedd1fa3a21246490efe0bd49a4f17a408b5743679532e47040e2d166360"
EXPECTED_PATCH_SHA="c3ad26bb9dcb917be9ffe80ff610f67dc6796bc132c2a2d1bfb44c9e0cbb9a8a"
PATCH="/tmp/gift_data_39053_patch_rebuilt_$$.beam"

sha256() { sha256sum "$1" | awk '{print $1}'; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
cleanup() { rm -f -- "$PATCH"; }
trap cleanup EXIT INT TERM

[[ -f "$PROD" ]] || die "production BEAM not found: $PROD"
[[ -f "$BUILDER" ]] || die "builder not found: $BUILDER"
[[ -f "$DEPLOY" ]] || die "deploy script not found: $DEPLOY"
[[ -x "$ESCRIPT" ]] || ESCRIPT="$(command -v escript || true)"
[[ -n "$ESCRIPT" && -x "$ESCRIPT" ]] || die "escript executable not found"

CURRENT_SHA="$(sha256 "$PROD")"
printf 'PROD_SHA_PREBUILD=%s\n' "$CURRENT_SHA"

if [[ "$CURRENT_SHA" == "$EXPECTED_PATCH_SHA" ]]; then
  printf 'GIFT_39053_ALREADY_DEPLOYED_ON_DISK\n'
  bash "$DEPLOY" "$PROD"
  exit 0
fi

[[ "$CURRENT_SHA" == "$EXPECTED_PROD_SHA" ]] || die "production SHA drift detected before build"

"$ESCRIPT" "$BUILDER" "$PROD" "$PATCH"
[[ -f "$PATCH" ]] || die "builder returned without creating patch"
PATCH_SHA="$(sha256 "$PATCH")"
printf 'REBUILT_PATCH_SHA=%s\n' "$PATCH_SHA"
[[ "$PATCH_SHA" == "$EXPECTED_PATCH_SHA" ]] || die "rebuilt patch SHA mismatch; refusing deployment"

bash "$DEPLOY" "$PATCH"
printf 'GIFT_39053_BUILD_AND_DEPLOY_OK\n'
