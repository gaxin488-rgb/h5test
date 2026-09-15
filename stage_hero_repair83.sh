#!/usr/bin/env bash
set -Eeuo pipefail

# Stage-only repair builder for the H5 hero namespace.
# It NEVER modifies the active update namespace or url_config_demo.lua.
# Output is written under /root/h5_hero_repair83_stage_<timestamp>.

BASE_NS="${BASE_NS:-/data/dev_www/web/www/update/update_android_sszg}"
HERO_NS="${HERO_NS:-/data/dev_www/web/www/update/update_android_sszg_hero}"
CFG="${CFG:-/data/dev_www/web/www/update/config/url_config_demo.lua}"
EXPECTED_BASE82_SHA="${EXPECTED_BASE82_SHA:-dae2b3079a00b0882eb8c82864987d6f838b9d83533f1f0050dc3530fa6e4615}"
EXPECTED_CUSTOM82_SHA="${EXPECTED_CUSTOM82_SHA:-2c7b8f3aef99d2b6fcc193f2339161f1243a3bac1eb11563e55a224a75f666cb}"
EXPECTED_CUSTOM_FILES="${EXPECTED_CUSTOM_FILES:-73}"
EXPECTED_H105170_FILES="${EXPECTED_H105170_FILES:-24}"
EXPECTED_H6615511_FILES="${EXPECTED_H6615511_FILES:-49}"
VERIFY_CHAIN_FULL="${VERIFY_CHAIN_FULL:-1}"

BASE82="$BASE_NS/zip/assets82.zip"
CUSTOM82="$HERO_NS/zip/assets82.zip"
STAMP="$(date +%Y%m%d_%H%M%S)"
STAGE="/root/h5_hero_repair83_stage_${STAMP}"
mkdir -p "$STAGE"
REPORT="$STAGE/hero_repair83_stage_report.txt"

exec > >(tee "$REPORT") 2>&1

fail() {
  echo "FATAL: $*"
  echo "STAGE_ABORTED=1"
  exit 1
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "required command not found: $1"
}

sha256_file() {
  sha256sum "$1" | awk '{print tolower($1)}'
}

filesize() {
  stat -c '%s' "$1"
}

zip_list_files() {
  unzip -Z1 "$1" | tr -d '\r' | sed '/\/$/d' | LC_ALL=C sort -u
}

zip_raw_entry_count() {
  unzip -Z1 "$1" | tr -d '\r' | wc -l | awk '{print $1}'
}

zip_file_count() {
  unzip -Z1 "$1" | tr -d '\r' | sed '/\/$/d' | wc -l | awk '{print $1}'
}

zip_duplicate_count() {
  unzip -Z1 "$1" | tr -d '\r' | sed '/\/$/d' | LC_ALL=C sort | uniq -d | wc -l | awk '{print $1}'
}

zip_entry_sha256() {
  local z="$1"
  local p="$2"
  unzip -p "$z" "$p" | sha256sum | awk '{print tolower($1)}'
}

for c in awk basename cmp comm cp date df find grep head mkdir mv sed sha256sum sort stat tee tr uniq unzip wc zip; do
  need_cmd "$c"
done

[[ -d "$BASE_NS" ]] || fail "baseline namespace missing: $BASE_NS"
[[ -d "$HERO_NS" ]] || fail "hero namespace missing: $HERO_NS"
[[ -f "$CFG" ]] || fail "config missing: $CFG"
[[ -f "$BASE82" ]] || fail "baseline assets82 missing: $BASE82"
[[ -f "$CUSTOM82" ]] || fail "hero assets82 missing: $CUSTOM82"

cat <<EOF
==================================================
H5 HERO REPAIR 83 - STAGE ONLY
==================================================
DATE=$(date '+%F %T %z')
HOST=$(hostname 2>/dev/null || true)
BASE_NS=$BASE_NS
HERO_NS=$HERO_NS
CFG=$CFG
STAGE=$STAGE
ACTIVE_FILES_MODIFIED=0

==================================================
ACTIVE STATE PRECHECK
==================================================
EOF

CFG_MAX="$(sed -n 's/^[[:space:]]*UPDATE_VERSION_MAX[[:space:]]*=[[:space:]]*\([0-9][0-9]*\).*/\1/p' "$CFG" | head -n1)"
CFG_ZIP_URL="$(sed -n 's/^[[:space:]]*ZIP_URL[[:space:]]*=[[:space:]]*CDN_URL[[:space:]]*\.\.[[:space:]]*"\([^"]*\)".*/\1/p' "$CFG" | head -n1)"
HERO_VERSION2="$(tr -d '\r\n[:space:]' < "$HERO_NS/version2.txt" 2>/dev/null || true)"
BASE_VERSION2="$(tr -d '\r\n[:space:]' < "$BASE_NS/version2.txt" 2>/dev/null || true)"

echo "CFG_UPDATE_VERSION_MAX=$CFG_MAX"
echo "CFG_ZIP_URL=$CFG_ZIP_URL"
echo "HERO_VERSION2=$HERO_VERSION2"
echo "BASE_VERSION2=$BASE_VERSION2"

[[ "$CFG_MAX" == "82" ]] || fail "active UPDATE_VERSION_MAX changed; expected 82, got '$CFG_MAX'"
[[ "$CFG_ZIP_URL" == "/update/update_android_sszg_hero" ]] || fail "active ZIP_URL changed; got '$CFG_ZIP_URL'"
[[ "$HERO_VERSION2" == "82" ]] || fail "hero version2.txt changed; expected 82, got '$HERO_VERSION2'"

cat <<EOF

==================================================
ZIP INTEGRITY + IDENTITY
==================================================
EOF

unzip -tq "$BASE82" >/dev/null || fail "baseline assets82 failed unzip test"
unzip -tq "$CUSTOM82" >/dev/null || fail "custom assets82 failed unzip test"

BASE82_SHA="$(sha256_file "$BASE82")"
CUSTOM82_SHA="$(sha256_file "$CUSTOM82")"
BASE82_SIZE="$(filesize "$BASE82")"
CUSTOM82_SIZE="$(filesize "$CUSTOM82")"
BASE82_RAW_COUNT="$(zip_raw_entry_count "$BASE82")"
CUSTOM82_RAW_COUNT="$(zip_raw_entry_count "$CUSTOM82")"
BASE82_FILE_COUNT="$(zip_file_count "$BASE82")"
CUSTOM82_FILE_COUNT="$(zip_file_count "$CUSTOM82")"
BASE82_DUP_COUNT="$(zip_duplicate_count "$BASE82")"
CUSTOM82_DUP_COUNT="$(zip_duplicate_count "$CUSTOM82")"

echo "BASE82_SIZE=$BASE82_SIZE"
echo "BASE82_SHA256=$BASE82_SHA"
echo "BASE82_RAW_ENTRIES=$BASE82_RAW_COUNT"
echo "BASE82_FILE_ENTRIES=$BASE82_FILE_COUNT"
echo "BASE82_DUPLICATE_PATHS=$BASE82_DUP_COUNT"
echo "CUSTOM82_SIZE=$CUSTOM82_SIZE"
echo "CUSTOM82_SHA256=$CUSTOM82_SHA"
echo "CUSTOM82_RAW_ENTRIES=$CUSTOM82_RAW_COUNT"
echo "CUSTOM82_FILE_ENTRIES=$CUSTOM82_FILE_COUNT"
echo "CUSTOM82_DUPLICATE_PATHS=$CUSTOM82_DUP_COUNT"

[[ "$BASE82_SHA" == "$EXPECTED_BASE82_SHA" ]] || fail "baseline assets82 SHA changed"
[[ "$CUSTOM82_SHA" == "$EXPECTED_CUSTOM82_SHA" ]] || fail "custom assets82 SHA changed"
[[ "$CUSTOM82_FILE_COUNT" == "$EXPECTED_CUSTOM_FILES" ]] || fail "custom assets82 file count changed"
[[ "$BASE82_DUP_COUNT" == "0" ]] || fail "baseline assets82 contains duplicate file paths"
[[ "$CUSTOM82_DUP_COUNT" == "0" ]] || fail "custom assets82 contains duplicate file paths"

BASE_LIST="$STAGE/base82_files.txt"
CUSTOM_LIST="$STAGE/custom82_files.txt"
COLLISIONS="$STAGE/collision_paths.txt"
BASE_ONLY="$STAGE/repair83_paths.txt"
CUSTOM_ONLY="$STAGE/custom_only_paths.txt"
UNION_LIST="$STAGE/final_union_paths.txt"
COLLISION_REPORT="$STAGE/collision_sha256.tsv"

zip_list_files "$BASE82" > "$BASE_LIST"
zip_list_files "$CUSTOM82" > "$CUSTOM_LIST"
comm -12 "$BASE_LIST" "$CUSTOM_LIST" > "$COLLISIONS"
comm -23 "$BASE_LIST" "$CUSTOM_LIST" > "$BASE_ONLY"
comm -13 "$BASE_LIST" "$CUSTOM_LIST" > "$CUSTOM_ONLY"
cat "$BASE_LIST" "$CUSTOM_LIST" | LC_ALL=C sort -u > "$UNION_LIST"

COLLISION_COUNT="$(wc -l < "$COLLISIONS" | awk '{print $1}')"
BASE_ONLY_COUNT="$(wc -l < "$BASE_ONLY" | awk '{print $1}')"
CUSTOM_ONLY_COUNT="$(wc -l < "$CUSTOM_ONLY" | awk '{print $1}')"
UNION_COUNT="$(wc -l < "$UNION_LIST" | awk '{print $1}')"
H105170_COUNT="$(grep -c '^assets/res/spine/H105170/' "$CUSTOM_LIST" || true)"
H6615511_COUNT="$(grep -c '^assets/res/spine/H6615511/' "$CUSTOM_LIST" || true)"
OUTSIDE_TARGET_COUNT="$(grep -Ev '^assets/res/spine/(H105170|H6615511)/' "$CUSTOM_LIST" | sed '/^[[:space:]]*$/d' | wc -l | awk '{print $1}')"

echo "H105170_FILES=$H105170_COUNT"
echo "H6615511_FILES=$H6615511_COUNT"
echo "CUSTOM_PATHS_OUTSIDE_TARGET_HERO_DIRS=$OUTSIDE_TARGET_COUNT"
[[ "$H105170_COUNT" == "$EXPECTED_H105170_FILES" ]] || fail "H105170 file count changed"
[[ "$H6615511_COUNT" == "$EXPECTED_H6615511_FILES" ]] || fail "H6615511 file count changed"
[[ "$OUTSIDE_TARGET_COUNT" == "0" ]] || fail "custom82 has files outside the two approved hero spine folders"

cat <<EOF

==================================================
SET ANALYSIS: full82 U custom73
==================================================
BASE_FILES=$BASE82_FILE_COUNT
CUSTOM_FILES=$CUSTOM82_FILE_COUNT
COLLISIONS=$COLLISION_COUNT
BASE_ONLY_FILES=$BASE_ONLY_COUNT
CUSTOM_ONLY_FILES=$CUSTOM_ONLY_COUNT
FINAL_UNION_FILES=$UNION_COUNT
EOF

: > "$COLLISION_REPORT"
SAME_COLLISIONS=0
DIFF_COLLISIONS=0
if [[ "$COLLISION_COUNT" -gt 0 ]]; then
  printf 'path\tbaseline_sha256\tcustom_sha256\tstatus\n' > "$COLLISION_REPORT"
  while IFS= read -r p; do
    [[ -n "$p" ]] || continue
    bsha="$(zip_entry_sha256 "$BASE82" "$p")"
    csha="$(zip_entry_sha256 "$CUSTOM82" "$p")"
    if [[ "$bsha" == "$csha" ]]; then
      status="same"
      SAME_COLLISIONS=$((SAME_COLLISIONS + 1))
    else
      status="custom_override"
      DIFF_COLLISIONS=$((DIFF_COLLISIONS + 1))
    fi
    printf '%s\t%s\t%s\t%s\n' "$p" "$bsha" "$csha" "$status" >> "$COLLISION_REPORT"
  done < "$COLLISIONS"
fi

echo "COLLISIONS_SAME_CONTENT=$SAME_COLLISIONS"
echo "COLLISIONS_CUSTOM_OVERRIDE=$DIFF_COLLISIONS"

cat <<EOF

==================================================
HERO NAMESPACE CHAIN CHECK <= 81
==================================================
EOF

MISSING_CHAIN_FILES=0
DIFF_CHAIN_FILES=0
CHECKED_CHAIN_FILES=0
if [[ "$VERIFY_CHAIN_FULL" == "1" ]]; then
  for src in "$BASE_NS"/zip/assets*.zip; do
    [[ -f "$src" ]] || continue
    name="$(basename "$src")"
    ver="${name#assets}"
    ver="${ver%.zip}"
    [[ "$ver" =~ ^[0-9]+$ ]] || continue
    if (( ver <= 81 )); then
      CHECKED_CHAIN_FILES=$((CHECKED_CHAIN_FILES + 1))
      dst="$HERO_NS/zip/$name"
      if [[ ! -f "$dst" ]]; then
        echo "CHAIN_MISSING=$name"
        MISSING_CHAIN_FILES=$((MISSING_CHAIN_FILES + 1))
      elif ! cmp -s "$src" "$dst"; then
        echo "CHAIN_DIFF=$name BASE_SHA=$(sha256_file "$src") HERO_SHA=$(sha256_file "$dst")"
        DIFF_CHAIN_FILES=$((DIFF_CHAIN_FILES + 1))
      fi
    fi
  done
else
  echo "CHAIN_COMPARE_SKIPPED=1"
fi

echo "CHAIN_FILES_CHECKED=$CHECKED_CHAIN_FILES"
echo "CHAIN_FILES_MISSING=$MISSING_CHAIN_FILES"
echo "CHAIN_FILES_DIFFERENT=$DIFF_CHAIN_FILES"
[[ "$MISSING_CHAIN_FILES" == "0" ]] || fail "hero namespace is missing one or more baseline update zips <=81"
[[ "$DIFF_CHAIN_FILES" == "0" ]] || fail "hero namespace differs from baseline chain <=81"

VERSION_FILE_MISSING=0
VERSION_FILE_DIFF=0
for src in "$BASE_NS"/version*.txt; do
  [[ -f "$src" ]] || continue
  name="$(basename "$src")"
  [[ "$name" == "version2.txt" ]] && continue
  digits="$(printf '%s' "$name" | sed -n 's/^version\([0-9][0-9]*\)\.txt$/\1/p')"
  [[ -n "$digits" ]] || continue
  if (( digits <= 81 )); then
    dst="$HERO_NS/$name"
    if [[ ! -f "$dst" ]]; then
      echo "VERSION_FILE_MISSING=$name"
      VERSION_FILE_MISSING=$((VERSION_FILE_MISSING + 1))
    elif ! cmp -s "$src" "$dst"; then
      echo "VERSION_FILE_DIFF=$name"
      VERSION_FILE_DIFF=$((VERSION_FILE_DIFF + 1))
    fi
  fi
done

echo "VERSION_FILES_MISSING=$VERSION_FILE_MISSING"
echo "VERSION_FILES_DIFFERENT=$VERSION_FILE_DIFF"
[[ "$VERSION_FILE_MISSING" == "0" ]] || fail "hero namespace is missing one or more version files <=81"
[[ "$VERSION_FILE_DIFF" == "0" ]] || fail "hero namespace version files <=81 differ from baseline"

cat <<EOF

==================================================
SLOT 83 CURRENT STATE (READ ONLY)
==================================================
EOF

if [[ -f "$HERO_NS/zip/assets83.zip" ]]; then
  echo "ACTIVE_SLOT83_ZIP_EXISTS=1"
  echo "ACTIVE_SLOT83_ZIP_SIZE=$(filesize "$HERO_NS/zip/assets83.zip")"
  echo "ACTIVE_SLOT83_ZIP_SHA256=$(sha256_file "$HERO_NS/zip/assets83.zip")"
else
  echo "ACTIVE_SLOT83_ZIP_EXISTS=0"
fi
if [[ -f "$HERO_NS/version83.txt" ]]; then
  echo "ACTIVE_SLOT83_VERSION_FILE_EXISTS=1"
  echo "ACTIVE_SLOT83_VERSION_VALUE=$(tr -d '\r\n[:space:]' < "$HERO_NS/version83.txt")"
else
  echo "ACTIVE_SLOT83_VERSION_FILE_EXISTS=0"
fi

cat <<EOF

==================================================
BUILD STAGED REPAIR assets83.zip
==================================================
EOF

FREE_KB="$(df -Pk "$STAGE" | awk 'NR==2 {print $4}')"
REQUIRED_KB=$(( (BASE82_SIZE + 268435456 + 1023) / 1024 ))
echo "FREE_KB=$FREE_KB"
echo "REQUIRED_KB=$REQUIRED_KB"
(( FREE_KB >= REQUIRED_KB )) || fail "not enough free disk space for staged repair zip"

REPAIR83="$STAGE/assets83.zip"
cp -p "$BASE82" "$REPAIR83"

# v82 already installed the custom files. v83 must supply only the baseline files
# that were not present in custom82. Removing collisions preserves the custom v82
# content and prevents baseline data from overwriting it.
if [[ "$COLLISION_COUNT" -gt 0 ]]; then
  while IFS= read -r p; do
    [[ -n "$p" ]] || continue
    zip -q -d "$REPAIR83" "$p" >/dev/null
  done < "$COLLISIONS"
fi

unzip -tq "$REPAIR83" >/dev/null || fail "staged assets83 failed unzip test"
REPAIR_LIST="$STAGE/repair83_actual_paths.txt"
zip_list_files "$REPAIR83" > "$REPAIR_LIST"
if ! cmp -s "$BASE_ONLY" "$REPAIR_LIST"; then
  echo "REPAIR_PATH_SET_MISMATCH=1"
  echo "ONLY_EXPECTED:"
  comm -23 "$BASE_ONLY" "$REPAIR_LIST" | head -n 50 || true
  echo "ONLY_ACTUAL:"
  comm -13 "$BASE_ONLY" "$REPAIR_LIST" | head -n 50 || true
  fail "staged repair path set is not exactly baseline minus custom collisions"
fi

REPAIR83_SHA="$(sha256_file "$REPAIR83")"
REPAIR83_SIZE="$(filesize "$REPAIR83")"
REPAIR83_FILES="$(zip_file_count "$REPAIR83")"
REPAIR83_DUP_COUNT="$(zip_duplicate_count "$REPAIR83")"

echo "STAGED_REPAIR83=$REPAIR83"
echo "REPAIR83_SIZE=$REPAIR83_SIZE"
echo "REPAIR83_SHA256=$REPAIR83_SHA"
echo "REPAIR83_FILE_ENTRIES=$REPAIR83_FILES"
echo "REPAIR83_DUPLICATE_PATHS=$REPAIR83_DUP_COUNT"
[[ "$REPAIR83_DUP_COUNT" == "0" ]] || fail "staged repair83 contains duplicate paths"
[[ "$REPAIR83_FILES" == "$BASE_ONLY_COUNT" ]] || fail "staged repair83 file count mismatch"

cat <<EOF

==================================================
FINAL STAGE VERDICT
==================================================
ACTIVE_FILES_MODIFIED=0
SAFE_TO_REVIEW=1
DEPLOY_PERFORMED=0
STAGE_DIR=$STAGE
REPORT=$REPORT
BASE_LIST=$BASE_LIST
CUSTOM_LIST=$CUSTOM_LIST
COLLISION_PATHS=$COLLISIONS
COLLISION_SHA256_REPORT=$COLLISION_REPORT
CUSTOM_ONLY_PATHS=$CUSTOM_ONLY
REPAIR83_PATHS=$BASE_ONLY
FINAL_UNION_PATHS=$UNION_LIST
STAGED_REPAIR83=$REPAIR83

IMPORTANT_NEXT_STEP:
Do not bump UPDATE_VERSION_MAX and do not replace active slot 83 until this report is reviewed.
If slot 83 already exists, deployment must back it up and atomically replace both assets83.zip and version83.txt before changing version2/config to 83.
==================================================
EOF
