#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
PROD="/data/sszg_code/v200408/server/ebin/gift_data.beam"
PATCH="${1:-}"
EXPECTED_PROD_SHA="2da4dedd1fa3a21246490efe0bd49a4f17a408b5743679532e47040e2d166360"
VERIFIER="$SCRIPT_DIR/gift_39053_verify_patch.escript"
ESCRIPT="/opt/erlang/otp19.2/bin/escript"
STAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP="${PROD}.bak.gift39053.${STAMP}"
NEW="${PROD}.new.gift39053.$$"

log() { printf '%s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
sha256() { sha256sum "$1" | awk '{print $1}'; }
cleanup() { rm -f -- "$NEW"; }
rollback() {
  cp -p -- "$BACKUP" "$NEW"
  mv -f -- "$NEW" "$PROD"
  sync "$PROD" 2>/dev/null || sync
}
trap cleanup EXIT INT TERM

[[ $# -eq 1 ]] || die "usage: gift_39053_deploy_verified.sh <validated-patch.beam>"
[[ -f "$PROD" ]] || die "production BEAM not found: $PROD"
[[ -f "$PATCH" ]] || die "candidate patch BEAM not found: $PATCH"
[[ -f "$VERIFIER" ]] || die "structural verifier not found: $VERIFIER"
[[ -x "$ESCRIPT" ]] || ESCRIPT="$(command -v escript || true)"
[[ -n "$ESCRIPT" && -x "$ESCRIPT" ]] || die "escript executable not found"

CURRENT_SHA="$(sha256 "$PROD")"
PATCH_SHA="$(sha256 "$PATCH")"
log "PROD_SHA_BEFORE=$CURRENT_SHA"
log "PATCH_SHA=$PATCH_SHA"

[[ "$CURRENT_SHA" == "$EXPECTED_PROD_SHA" ]] || die "production SHA drift detected; refusing deployment"

"$ESCRIPT" "$VERIFIER" "$PROD" "$PATCH" </dev/null || die "candidate structural/semantic verification failed; refusing deployment"
log "PRE_DEPLOY_STRUCTURAL_VERIFY_OK=1"

cp -a -- "$PROD" "$BACKUP"
[[ "$(sha256 "$BACKUP")" == "$EXPECTED_PROD_SHA" ]] || die "backup verification failed"
log "BACKUP_OK=$BACKUP"

# Stage the exact validated candidate in the production directory so mv is atomic.
cp -- "$PATCH" "$NEW"
chmod --reference="$PROD" "$NEW"
chown --reference="$PROD" "$NEW"
[[ "$(sha256 "$NEW")" == "$PATCH_SHA" ]] || die "staged replacement SHA mismatch"

sync "$NEW" 2>/dev/null || sync
mv -f -- "$NEW" "$PROD"
sync "$PROD" 2>/dev/null || sync

FINAL_SHA="$(sha256 "$PROD")"
if [[ "$FINAL_SHA" != "$PATCH_SHA" ]]; then
  log "POST_REPLACE_SHA_BAD=$FINAL_SHA"
  rollback
  die "post-replace byte verification failed; production file rolled back"
fi

if ! "$ESCRIPT" "$VERIFIER" "$BACKUP" "$PROD" </dev/null; then
  rollback
  die "post-replace structural/semantic verification failed; production file rolled back"
fi

log "POST_DEPLOY_STRUCTURAL_VERIFY_OK=1"
log "PROD_SHA_AFTER=$FINAL_SHA"
log "GIFT_39053_DISK_DEPLOY_OK"
log "LIVE_RUNTIME_NOT_RELOADED=1"
log "BACKUP_RETAINED=$BACKUP"
