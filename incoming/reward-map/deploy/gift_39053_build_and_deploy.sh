#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
PROD="/data/sszg_code/v200408/server/ebin/gift_data.beam"
BUILDER="$SCRIPT_DIR/gift_39053_build_patch.escript"
VERIFIER="$SCRIPT_DIR/gift_39053_verify_patch.escript"
DEPLOY="$SCRIPT_DIR/gift_39053_deploy_verified.sh"
ESCRIPT="/opt/erlang/otp19.2/bin/escript"
EXPECTED_PROD_SHA="2da4dedd1fa3a21246490efe0bd49a4f17a408b5743679532e47040e2d166360"
PATCH="/tmp/gift_data_39053_patch_rebuilt_$$.beam"

sha256() { sha256sum "$1" | awk '{print $1}'; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
cleanup() { rm -f -- "$PATCH"; }
trap cleanup EXIT INT TERM

[[ -f "$PROD" ]] || die "production BEAM not found: $PROD"
[[ -f "$BUILDER" ]] || die "builder not found: $BUILDER"
[[ -f "$VERIFIER" ]] || die "structural verifier not found: $VERIFIER"
[[ -f "$DEPLOY" ]] || die "deploy script not found: $DEPLOY"
[[ -x "$ESCRIPT" ]] || ESCRIPT="$(command -v escript || true)"
[[ -n "$ESCRIPT" && -x "$ESCRIPT" ]] || die "escript executable not found"

CURRENT_SHA="$(sha256 "$PROD")"
printf 'PROD_SHA_PREBUILD=%s\n' "$CURRENT_SHA"
[[ "$CURRENT_SHA" == "$EXPECTED_PROD_SHA" ]] || die "production SHA drift detected before build"

"$ESCRIPT" "$BUILDER" "$PROD" "$PATCH" </dev/null
[[ -f "$PATCH" ]] || die "builder returned without creating patch"
PATCH_SHA="$(sha256 "$PATCH")"
printf 'REBUILT_PATCH_SHA=%s\n' "$PATCH_SHA"

"$ESCRIPT" "$VERIFIER" "$PROD" "$PATCH" </dev/null || die "rebuilt patch structural/semantic verification failed; refusing deployment"
printf 'REBUILT_PATCH_STRUCTURAL_VERIFY_OK=1\n'

bash "$DEPLOY" "$PATCH"
printf 'GIFT_39053_BUILD_AND_DEPLOY_OK\n'
