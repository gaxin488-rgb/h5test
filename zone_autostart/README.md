# SSZG boot autostart

This directory contains the single boot-time startup mechanism for the SSZG runtime discovered in the September 16, 2026 diagnostics.

## Managed instances

Startup order is deliberate:

1. `sszg_center_0` (`sszg_center_0@127.0.0.1`)
2. `sszg_symlf_1` (`sszg_local_1@127.0.0.1`)
3. `sszg_symlf_2` (`sszg_local_2@127.0.0.1`)
4. `sszg_symlf_3` (`sszg_local_3@127.0.0.1`)
5. `sszg_symlf_4` (`sszg_local_4@127.0.0.1`)

Shutdown runs in reverse order.

The launcher does not execute generated `start.sh` files directly. It keeps the existing lifecycle contract by invoking each instance's `ctl.sh start` / `ctl.sh stop`, while exporting a deterministic PATH whose first Erlang location is `/usr/lib/erlang/bin`.

## Safety behavior

- Preflight validates Erlang, `screen`, `pgrep`, every instance directory, `ctl.sh`, and `dets` before any process is started.
- Startup waits for local MySQL on port 3306.
- Existing running instances are left untouched.
- If a startup step fails, only instances started by that invocation are rolled back.
- The installer refuses to layer this service over matching legacy `rc.local`, cron, init.d, or systemd boot hooks.
- If initial service start or verification fails, the installer disables the service instead of leaving an unverified boot configuration enabled.

## Install on the game VM

Run as root from this directory:

```bash
bash ./install.sh
```

Verification commands:

```bash
systemctl status sszg-game.service --no-pager -l
/usr/local/sbin/sszg-autostart status
journalctl -u sszg-game.service -n 100 --no-pager
```

The service is enabled for `multi-user.target`; after a successful installation it will run automatically on later boots.
