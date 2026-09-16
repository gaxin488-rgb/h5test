#!/usr/bin/env bash
set -euo pipefail

PROD="/data/sszg_code/v200408/server/ebin/gift_data.beam"
PATCH="${1:-/tmp/gift_data_39053_patch_test_5887.beam}"
EXPECTED_PROD_SHA="2da4dedd1fa3a21246490efe0bd49a4f17a408b5743679532e47040e2d166360"
EXPECTED_PATCH_SHA="c3ad26bb9dcb917be9ffe80ff610f67dc6796bc132c2a2d1bfb44c9e0cbb9a8a"
STAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP="${PROD}.bak.gift39053.${STAMP}"
NEW="${PROD}.new.gift39053.$$"
ERL="/opt/erlang/otp19.2/bin/erl"

log() { printf '%s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
sha256() { sha256sum "$1" | awk '{print $1}'; }
cleanup() { rm -f -- "$NEW"; }
trap cleanup EXIT INT TERM

if [[ ! -x "$ERL" ]]; then
  ERL="$(command -v erl || true)"
fi
[[ -n "$ERL" && -x "$ERL" ]] || die "erl executable not found"
[[ -f "$PROD" ]] || die "production BEAM not found: $PROD"
[[ -f "$PATCH" ]] || die "validated patch BEAM not found: $PATCH"

verify_semantics() {
  local beam="$1"
  PATCH_BEAM="$beam" "$ERL" -noshell -eval '
    Path = os:getenv("PATCH_BEAM"),
    {ok, Bin} = file:read_file(Path),
    case code:load_binary(gift_data, Path, Bin) of
        {module, gift_data} -> ok;
        LoadOther -> io:format("LOAD_FAIL=~p~n", [LoadOther]), halt(41)
    end,
    case gift_data:get(39053) of
        {gift_data,39053,_,[],[{22,1000000}],[],0,0,0,0,[],0} ->
            io:format("GET_39053_OK~n", []);
        Value ->
            io:format("GET_39053_BAD=~p~n", [Value]), halt(42)
    end,
    halt(0).
  '
}

CURRENT_SHA="$(sha256 "$PROD")"
PATCH_SHA="$(sha256 "$PATCH")"
log "PROD_SHA_BEFORE=$CURRENT_SHA"
log "PATCH_SHA=$PATCH_SHA"

[[ "$PATCH_SHA" == "$EXPECTED_PATCH_SHA" ]] || die "patch SHA mismatch; refusing deployment"
verify_semantics "$PATCH" || die "patch semantic verification failed; refusing deployment"

if [[ "$CURRENT_SHA" == "$EXPECTED_PATCH_SHA" ]]; then
  verify_semantics "$PROD" || die "production hash matches patch but semantic verification failed"
  log "GIFT_39053_ALREADY_DEPLOYED"
  exit 0
fi

[[ "$CURRENT_SHA" == "$EXPECTED_PROD_SHA" ]] || die "production SHA drift detected; refusing deployment"

cp -a -- "$PROD" "$BACKUP"
[[ "$(sha256 "$BACKUP")" == "$EXPECTED_PROD_SHA" ]] || die "backup verification failed"
log "BACKUP_OK=$BACKUP"

# Build the replacement in the same directory so mv is atomic on the target filesystem.
cp -p -- "$PROD" "$NEW"
cat -- "$PATCH" > "$NEW"
chmod --reference="$PROD" "$NEW"
chown --reference="$PROD" "$NEW"
[[ "$(sha256 "$NEW")" == "$EXPECTED_PATCH_SHA" ]] || die "staged replacement SHA mismatch"

sync "$NEW" 2>/dev/null || sync
mv -f -- "$NEW" "$PROD"
sync "$PROD" 2>/dev/null || sync

FINAL_SHA="$(sha256 "$PROD")"
if [[ "$FINAL_SHA" != "$EXPECTED_PATCH_SHA" ]]; then
  log "POST_REPLACE_SHA_BAD=$FINAL_SHA"
  cp -p -- "$BACKUP" "$NEW"
  mv -f -- "$NEW" "$PROD"
  sync "$PROD" 2>/dev/null || sync
  die "post-replace verification failed; production file rolled back"
fi

if ! verify_semantics "$PROD"; then
  cp -p -- "$BACKUP" "$NEW"
  mv -f -- "$NEW" "$PROD"
  sync "$PROD" 2>/dev/null || sync
  die "post-replace semantic verification failed; production file rolled back"
fi

log "PROD_SHA_AFTER=$FINAL_SHA"
log "GIFT_39053_DISK_DEPLOY_OK"
log "LIVE_RUNTIME_NOT_RELOADED=1"
log "BACKUP_RETAINED=$BACKUP"
