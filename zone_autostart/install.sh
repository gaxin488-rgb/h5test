#!/bin/bash
set -euo pipefail

SOURCE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
LAUNCHER_SRC="$SOURCE_DIR/sszg-autostart.sh"
UNIT_SRC="$SOURCE_DIR/sszg-game.service"
LAUNCHER_DST=/usr/local/sbin/sszg-autostart
UNIT_DST=/etc/systemd/system/sszg-game.service
SERVICE=sszg-game.service

log() {
  printf '[install-sszg-autostart] %s\n' "$*"
}

fail() {
  log "ERROR: $*" >&2
  exit 1
}

[[ ${EUID:-$(id -u)} -eq 0 ]] || fail 'run this installer as root'
[[ -f "$LAUNCHER_SRC" ]] || fail "missing source file: $LAUNCHER_SRC"
[[ -f "$UNIT_SRC" ]] || fail "missing source file: $UNIT_SRC"
command -v systemctl >/dev/null 2>&1 || fail 'systemctl is not available'

log 'running runtime preflight before changing systemd'
bash "$LAUNCHER_SRC" preflight

# Abort instead of layering a second boot mechanism on top of a legacy hook.
legacy_hits=''
for candidate in /etc/rc.local /etc/rc.d/rc.local /etc/crontab /etc/cron.d/*; do
  [[ -f "$candidate" ]] || continue
  hits=$(grep -nE '/data/zone/sszg_.*(ctl\.sh[[:space:]]+start|start\.sh)|sszg_.*ctl\.sh[[:space:]]+start' "$candidate" 2>/dev/null || true)
  if [[ -n "$hits" ]]; then
    legacy_hits+=$'\n'"$candidate"$'\n'"$hits"
  fi
done

for tree in /etc/init.d /etc/systemd/system /usr/lib/systemd/system; do
  [[ -d "$tree" ]] || continue
  hits=$(grep -R -nE '/data/zone/sszg_.*(ctl\.sh[[:space:]]+start|start\.sh)|sszg_.*ctl\.sh[[:space:]]+start' "$tree" 2>/dev/null || true)
  if [[ -n "$hits" ]]; then
    legacy_hits+=$'\n'"$tree"$'\n'"$hits"
  fi
done

if [[ -n "$legacy_hits" ]]; then
  printf '%s\n' "$legacy_hits" >&2
  fail 'legacy boot hook detected; remove/migrate it before installing this systemd service'
fi

log "installing $LAUNCHER_DST"
install -o root -g root -m 0755 "$LAUNCHER_SRC" "$LAUNCHER_DST"
log "installing $UNIT_DST"
install -o root -g root -m 0644 "$UNIT_SRC" "$UNIT_DST"

systemctl daemon-reload
systemctl enable "$SERVICE"

log 'starting service and verifying all configured instances'
if ! systemctl start "$SERVICE"; then
  systemctl status "$SERVICE" --no-pager -l || true
  journalctl -u "$SERVICE" -n 100 --no-pager || true
  systemctl disable "$SERVICE" || true
  fail 'service start failed; service was disabled to avoid an unverified boot-time start'
fi

if ! "$LAUNCHER_DST" status; then
  systemctl status "$SERVICE" --no-pager -l || true
  systemctl disable "$SERVICE" || true
  fail 'post-install runtime verification failed; service was disabled'
fi

systemctl is-enabled "$SERVICE" >/dev/null
systemctl is-active "$SERVICE" >/dev/null
log 'installation verified: service is enabled and all configured instances are running'
