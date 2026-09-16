#!/bin/bash
set -euo pipefail

PATH=/usr/lib/erlang/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PATH

ERL_BIN=/usr/lib/erlang/bin/erl
DB_HOST=127.0.0.1
DB_PORT=3306
START_TIMEOUT=90
STOP_TIMEOUT=60
DB_TIMEOUT=90
CENTER_SETTLE_SECONDS=5

INSTANCES=(
  sszg_center_0
  sszg_symlf_1
  sszg_symlf_2
  sszg_symlf_3
  sszg_symlf_4
)

NODES=(
  'sszg_center_0@127.0.0.1'
  'sszg_local_1@127.0.0.1'
  'sszg_local_2@127.0.0.1'
  'sszg_local_3@127.0.0.1'
  'sszg_local_4@127.0.0.1'
)

log() {
  printf '[sszg-autostart] %s\n' "$*"
}

fail() {
  log "ERROR: $*" >&2
  exit 1
}

instance_dir() {
  printf '/data/zone/%s' "$1"
}

is_running() {
  local node=$1
  pgrep -af beam.smp 2>/dev/null | grep -F -- "-name ${node}" >/dev/null 2>&1
}

preflight() {
  local i dir

  [[ ${#INSTANCES[@]} -eq ${#NODES[@]} ]] || fail 'instance/node mapping length mismatch'
  [[ -x "$ERL_BIN" ]] || fail "required Erlang binary is missing or not executable: $ERL_BIN"
  command -v screen >/dev/null 2>&1 || fail 'screen is not available in PATH'
  command -v pgrep >/dev/null 2>&1 || fail 'pgrep is not available in PATH'

  for i in "${!INSTANCES[@]}"; do
    dir=$(instance_dir "${INSTANCES[$i]}")
    [[ -d "$dir" ]] || fail "instance directory is missing: $dir"
    [[ -f "$dir/ctl.sh" ]] || fail "ctl.sh is missing: $dir/ctl.sh"
    [[ -r "$dir/ctl.sh" ]] || fail "ctl.sh is not readable: $dir/ctl.sh"
    [[ -d "$dir/dets" ]] || fail "instance is not fully installed (dets missing): $dir"
  done

  local resolved_erl
  resolved_erl=$(command -v erl || true)
  [[ "$resolved_erl" == "$ERL_BIN" ]] || fail "erl resolves to '$resolved_erl' instead of '$ERL_BIN'"
}

wait_for_db() {
  local elapsed=0
  log "waiting for database ${DB_HOST}:${DB_PORT}"
  while (( elapsed < DB_TIMEOUT )); do
    if (exec 3<>"/dev/tcp/${DB_HOST}/${DB_PORT}") 2>/dev/null; then
      log 'database is reachable'
      return 0
    fi
    sleep 1
    ((elapsed += 1))
  done
  return 1
}

wait_until_running() {
  local node=$1 elapsed=0
  while (( elapsed < START_TIMEOUT )); do
    if is_running "$node"; then
      return 0
    fi
    sleep 1
    ((elapsed += 1))
  done
  return 1
}

wait_until_stopped() {
  local node=$1 elapsed=0
  while (( elapsed < STOP_TIMEOUT )); do
    if ! is_running "$node"; then
      return 0
    fi
    sleep 1
    ((elapsed += 1))
  done
  return 1
}

start_instance() {
  local instance=$1 node=$2 dir
  dir=$(instance_dir "$instance")

  if is_running "$node"; then
    log "$instance already running; leaving it untouched"
    return 2
  fi

  log "starting $instance via ctl.sh"
  (cd "$dir" && bash ./ctl.sh start)

  if wait_until_running "$node"; then
    log "$instance is running"
    return 0
  fi

  log "ERROR: $instance did not become ready within ${START_TIMEOUT}s" >&2
  return 1
}

stop_instance() {
  local instance=$1 node=$2 dir
  dir=$(instance_dir "$instance")

  if ! is_running "$node"; then
    log "$instance already stopped"
    return 0
  fi

  log "stopping $instance via ctl.sh"
  if ! (cd "$dir" && bash ./ctl.sh stop); then
    log "ERROR: ctl.sh stop failed for $instance" >&2
    return 1
  fi

  if wait_until_stopped "$node"; then
    log "$instance stopped"
    return 0
  fi

  log "ERROR: $instance is still running after ${STOP_TIMEOUT}s" >&2
  return 1
}

rollback_started() {
  local -a started_indices=("$@")
  local pos idx
  log 'startup failed; rolling back only instances started by this invocation'
  for (( pos=${#started_indices[@]}-1; pos>=0; pos-- )); do
    idx=${started_indices[$pos]}
    stop_instance "${INSTANCES[$idx]}" "${NODES[$idx]}" || true
  done
}

start_all() {
  local i rc
  local -a started_indices=()

  preflight
  wait_for_db || fail "database ${DB_HOST}:${DB_PORT} did not become reachable within ${DB_TIMEOUT}s"

  for i in "${!INSTANCES[@]}"; do
    set +e
    start_instance "${INSTANCES[$i]}" "${NODES[$i]}"
    rc=$?
    set -e

    case "$rc" in
      0)
        started_indices+=("$i")
        ;;
      2)
        ;;
      *)
        rollback_started "${started_indices[@]}"
        return 1
        ;;
    esac

    if (( i == 0 )); then
      sleep "$CENTER_SETTLE_SECONDS"
    fi
  done

  log 'all configured SSZG instances are running'
}

stop_all() {
  local i failed=0
  preflight

  for (( i=${#INSTANCES[@]}-1; i>=0; i-- )); do
    stop_instance "${INSTANCES[$i]}" "${NODES[$i]}" || failed=1
  done

  (( failed == 0 )) || return 1
  log 'all configured SSZG instances are stopped'
}

status_all() {
  local i failed=0
  for i in "${!INSTANCES[@]}"; do
    if is_running "${NODES[$i]}"; then
      printf '%-20s RUNNING  %s\n' "${INSTANCES[$i]}" "${NODES[$i]}"
    else
      printf '%-20s STOPPED  %s\n' "${INSTANCES[$i]}" "${NODES[$i]}"
      failed=1
    fi
  done
  return "$failed"
}

usage() {
  echo "Usage: $0 {start|stop|restart|status|preflight}"
}

case "${1:-}" in
  start)
    start_all
    ;;
  stop)
    stop_all
    ;;
  restart)
    stop_all
    start_all
    ;;
  status)
    status_all
    ;;
  preflight)
    preflight
    log 'preflight passed'
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac
