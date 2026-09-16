#!/bin/bash
set -euo pipefail

PATH=/usr/lib/erlang/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PATH
HOME=${HOME:-/root}
export HOME

ERL_BIN=/usr/lib/erlang/bin/erl
EPMD_BIN=/usr/lib/erlang/bin/epmd
DB_HOST=127.0.0.1
DB_PORT=3306
START_TIMEOUT=90
SCREEN_TIMEOUT=15
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

beam_running() {
  local node=$1
  pgrep -af beam.smp 2>/dev/null | grep -F -- "-name ${node}" >/dev/null 2>&1
}

screen_running() {
  local session=$1
  screen -ls 2>/dev/null | grep -F -- ".${session}" >/dev/null 2>&1
}

resolve_epmd() {
  if [[ -x "$EPMD_BIN" ]]; then
    return 0
  fi

  EPMD_BIN=$(command -v epmd 2>/dev/null || true)
  [[ -n "$EPMD_BIN" && -x "$EPMD_BIN" ]]
}

static_preflight() {
  local i dir resolved_erl

  [[ ${#INSTANCES[@]} -eq ${#NODES[@]} ]] || fail 'instance/node mapping length mismatch'
  [[ -n "$HOME" && -d "$HOME" ]] || fail "HOME is invalid or missing: '$HOME'"
  [[ -x "$ERL_BIN" ]] || fail "required Erlang binary is missing or not executable: $ERL_BIN"
  resolve_epmd || fail 'epmd is not available from /usr/lib/erlang/bin or PATH'
  command -v screen >/dev/null 2>&1 || fail 'screen is not available in PATH'
  command -v pgrep >/dev/null 2>&1 || fail 'pgrep is not available in PATH'

  resolved_erl=$(command -v erl || true)
  [[ "$resolved_erl" == "$ERL_BIN" ]] || fail "erl resolves to '$resolved_erl' instead of '$ERL_BIN'"

  for i in "${!INSTANCES[@]}"; do
    dir=$(instance_dir "${INSTANCES[$i]}")
    [[ -d "$dir" ]] || fail "instance directory is missing: $dir"
    [[ -f "$dir/ctl.sh" ]] || fail "ctl.sh is missing: $dir/ctl.sh"
    [[ -r "$dir/ctl.sh" ]] || fail "ctl.sh is not readable: $dir/ctl.sh"
    [[ -d "$dir/dets" ]] || fail "instance is not fully installed (dets missing): $dir"
  done
}

check_beam_runtime() {
  local output
  log "verifying Erlang VM through $ERL_BIN (HOME=$HOME)"
  if ! output=$("$ERL_BIN" -noshell -eval 'io:format("~s", [erlang:system_info(system_version)]), halt(0).' 2>&1); then
    printf '%s\n' "$output" >&2
    fail 'Erlang executable exists but the BEAM VM could not start'
  fi
  [[ -n "$output" ]] || fail 'Erlang VM self-test returned no runtime information'
  log "Erlang VM self-test passed: $output"
}

ensure_epmd() {
  resolve_epmd || fail 'epmd is unavailable'

  if "$EPMD_BIN" -names >/dev/null 2>&1; then
    log 'epmd is already running'
    return 0
  fi

  log "starting epmd via $EPMD_BIN -daemon"
  "$EPMD_BIN" -daemon
  sleep 1
  "$EPMD_BIN" -names >/dev/null 2>&1 || fail 'epmd did not become ready after -daemon'
  log 'epmd is running'
}

runtime_check() {
  static_preflight
  check_beam_runtime
  ensure_epmd
  log 'runtime check passed'
}

wait_for_db() {
  local elapsed=0
  log "waiting for database ${DB_HOST}:${DB_PORT}"
  while (( elapsed < DB_TIMEOUT )); do
    if (exec 3<>"/dev/tcp/${DB_HOST}/${DB_PORT}") 2>/dev/null; then
      exec 3>&-
      exec 3<&-
      log 'database is reachable'
      return 0
    fi
    sleep 1
    ((elapsed += 1))
  done
  return 1
}

wait_for_screen() {
  local node=$1 elapsed=0
  while (( elapsed < SCREEN_TIMEOUT )); do
    if screen_running "$node"; then
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
    if beam_running "$node"; then
      return 0
    fi
    if ! screen_running "$node"; then
      return 2
    fi
    sleep 1
    ((elapsed += 1))
  done
  return 1
}

wait_until_stopped() {
  local node=$1 elapsed=0
  while (( elapsed < STOP_TIMEOUT )); do
    if ! beam_running "$node" && ! screen_running "$node"; then
      return 0
    fi
    sleep 1
    ((elapsed += 1))
  done
  return 1
}

dump_instance_diagnostics() {
  local instance=$1 node=$2 dir
  dir=$(instance_dir "$instance")

  log "diagnostics for $instance ($node)"
  echo '--- epmd -names ---' >&2
  "$EPMD_BIN" -names >&2 2>&1 || true
  echo '--- screen -ls ---' >&2
  screen -ls >&2 2>&1 || true
  echo '--- erl/beam processes ---' >&2
  ps -ef | grep -E '[b]eam\.smp|[e]rl([[:space:]]|$)' >&2 || true
  echo '--- generated start.sh ---' >&2
  if [[ -f "$dir/start.sh" ]]; then
    sed -n '1,120p' "$dir/start.sh" >&2 || true
  else
    echo '(missing)' >&2
  fi
  echo '--- screenlog.0 tail ---' >&2
  if [[ -f "$dir/screenlog.0" ]]; then
    tail -n 100 "$dir/screenlog.0" >&2 || true
  else
    echo '(missing)' >&2
  fi
}

start_instance() {
  local instance=$1 node=$2 dir rc
  dir=$(instance_dir "$instance")

  if beam_running "$node" && screen_running "$node"; then
    log "$instance already running; leaving it untouched"
    return 2
  fi

  if beam_running "$node" || screen_running "$node"; then
    log "ERROR: $instance has an inconsistent runtime state before start" >&2
    dump_instance_diagnostics "$instance" "$node"
    return 1
  fi

  log "starting $instance via ctl.sh"
  if ! (cd "$dir" && bash ./ctl.sh start); then
    log "ERROR: ctl.sh start failed for $instance" >&2
    dump_instance_diagnostics "$instance" "$node"
    return 1
  fi

  if ! wait_for_screen "$node"; then
    log "ERROR: $instance did not create a screen session within ${SCREEN_TIMEOUT}s" >&2
    dump_instance_diagnostics "$instance" "$node"
    return 1
  fi

  set +e
  wait_until_running "$node"
  rc=$?
  set -e
  case "$rc" in
    0)
      log "$instance is running (screen + beam)"
      return 0
      ;;
    2)
      log "ERROR: $instance screen session exited before BEAM became ready" >&2
      ;;
    *)
      log "ERROR: $instance BEAM node did not become ready within ${START_TIMEOUT}s" >&2
      ;;
  esac

  dump_instance_diagnostics "$instance" "$node"
  return 1
}

stop_instance() {
  local instance=$1 node=$2 dir
  dir=$(instance_dir "$instance")

  if ! beam_running "$node" && ! screen_running "$node"; then
    log "$instance already stopped"
    return 0
  fi

  if ! beam_running "$node" && screen_running "$node"; then
    log "warning: $instance has a screen session but no BEAM process; closing stale screen"
    screen -S "$node" -X quit >/dev/null 2>&1 || true
    if wait_until_stopped "$node"; then
      log "$instance stale screen removed"
      return 0
    fi
    dump_instance_diagnostics "$instance" "$node"
    return 1
  fi

  log "stopping $instance via ctl.sh"
  if ! (cd "$dir" && bash ./ctl.sh stop); then
    log "ERROR: ctl.sh stop failed for $instance" >&2
    dump_instance_diagnostics "$instance" "$node"
    return 1
  fi

  if wait_until_stopped "$node"; then
    log "$instance stopped"
    return 0
  fi

  log "ERROR: $instance is still running after ${STOP_TIMEOUT}s" >&2
  dump_instance_diagnostics "$instance" "$node"
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
  local i rc started_count=0
  local -a started_indices=()

  runtime_check
  wait_for_db || fail "database ${DB_HOST}:${DB_PORT} did not become reachable within ${DB_TIMEOUT}s"

  for i in "${!INSTANCES[@]}"; do
    set +e
    start_instance "${INSTANCES[$i]}" "${NODES[$i]}"
    rc=$?
    set -e

    case "$rc" in
      0)
        started_indices[$started_count]=$i
        started_count=$((started_count + 1))
        ;;
      2)
        ;;
      *)
        if (( started_count > 0 )); then
          rollback_started "${started_indices[@]}"
        else
          log 'startup failed before any new instance was started; nothing to roll back'
        fi
        return 1
        ;;
    esac

    if (( i == 0 )); then
      sleep "$CENTER_SETTLE_SECONDS"
    fi
  done

  log 'all configured SSZG instances are running with screen + BEAM'
}

stop_all() {
  local i failed=0
  static_preflight
  ensure_epmd

  for (( i=${#INSTANCES[@]}-1; i>=0; i-- )); do
    stop_instance "${INSTANCES[$i]}" "${NODES[$i]}" || failed=1
  done

  (( failed == 0 )) || return 1
  log 'all configured SSZG instances are stopped'
}

status_all() {
  local i failed=0 beam_state screen_state
  for i in "${!INSTANCES[@]}"; do
    if beam_running "${NODES[$i]}"; then
      beam_state=UP
    else
      beam_state=DOWN
      failed=1
    fi

    if screen_running "${NODES[$i]}"; then
      screen_state=UP
    else
      screen_state=DOWN
      failed=1
    fi

    printf '%-20s SCREEN=%-4s BEAM=%-4s %s\n' \
      "${INSTANCES[$i]}" "$screen_state" "$beam_state" "${NODES[$i]}"
  done
  return "$failed"
}

usage() {
  echo "Usage: $0 {start|stop|restart|status|preflight|runtime-check}"
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
    static_preflight
    log 'static preflight passed'
    ;;
  runtime-check)
    runtime_check
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac
