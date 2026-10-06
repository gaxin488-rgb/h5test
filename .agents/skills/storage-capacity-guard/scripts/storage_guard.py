#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Storage & Capacity Guard: VPS & Local Machine Storage Hygiene Utility
Monitors disk usage, enforces zero-spam rules, rotates logs, and cleans temporary artifacts.
"""

import os
import sys
import shutil
import glob
import subprocess
from pathlib import Path

# Safe utf-8 output handling
if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

def get_local_disk_info():
    """Returns local drives and free space in GB."""
    drives = []
    if sys.platform == "win32":
        for letter in ["C", "D", "E", "G"]:
            drive_path = f"{letter}:\\"
            if os.path.exists(drive_path):
                try:
                    usage = shutil.disk_usage(drive_path)
                    drives.append({
                        "drive": f"{letter}:",
                        "free_gb": round(usage.free / (1024**3), 2),
                        "total_gb": round(usage.total / (1024**3), 2),
                        "percent_free": round((usage.free / usage.total) * 100, 1)
                    })
                except Exception:
                    pass
    return drives

def clean_local_workspace(workspace_dir=r"d:\tinhlinh", dry_run=False):
    """
    Cleans accumulated throwaway test files, scratch scripts, and temporary build dumps.
    """
    workspace = Path(workspace_dir)
    if not workspace.exists():
        return []

    # Patterns for throwaway files
    spam_patterns = [
        "temp_*.*",
        "test_*.*",
        "deploy_*.*",
        "check_*.*",
        "%~dp0*.*",
        "temp_cls*.class",
        "orig_*.class",
        "real_*.class",
        "AutoReconnect_*.class",
        "AutoReconnect*.b64",
        "DesktopLauncher.b64",
        "diff_*.py",
        "parse_cp*.py",
        "search_*.py",
        "find_*.py",
        "trigger_run.py",
        "launch_ps_clean.py",
        "launch_both_fixed.py",
        "monitor_vps_sync.py",
        "read_both_logs.py",
        "push_*.py",
        "update_github_*.py",
        "upload_launcher.py"
    ]

    # Explicit whitelist: NEVER delete these
    whitelist = {
        "vps_cli.py",
        "clean_restart_2acc.py",
        "cleanup_vps_disk.py",
        "patch_game.py",
        "patch_vps_game.py",
        "storage_guard.py",
        "game.jar",
        "cfr.jar",
        "AutoReconnect.java",
        "AutoReconnect.class",
        "DesktopLauncher.java",
        "DesktopLauncher.class",
        "DesktopLauncher_lite.class",
        "AGENTS.md",
        "GEMINI.md"
    }

    removed = []
    for pattern in spam_patterns:
        for file_path in workspace.glob(pattern):
            if file_path.is_file() and file_path.name not in whitelist:
                removed.append(file_path.name)
                if not dry_run:
                    try:
                        file_path.unlink()
                    except Exception as e:
                        print(f"Error removing {file_path.name}: {e}")

    return removed

def print_status():
    print("=" * 60)
    print("[STORAGE & CAPACITY GUARD: SYSTEM HEALTH REPORT]")
    print("=" * 60)
    
    # 1. Local Drives
    print("\n[1] LOCAL MACHINE DISK STATUS:")
    for d in get_local_disk_info():
        status = "[SAFE]" if d["free_gb"] > 10 else "[WARNING]" if d["free_gb"] > 3 else "[CRITICAL]"
        print(f"  - Drive {d['drive']} : {d['free_gb']} GB free / {d['total_gb']} GB total ({d['percent_free']}%) -> {status}")
        
    print("\n[2] LOCAL WORKSPACE HYGIENE (d:\\tinhlinh):")
    spam_files = clean_local_workspace(dry_run=True)
    if spam_files:
        print(f"  - Phat hien {len(spam_files)} file rac/file test can don dep:")
        for name in spam_files[:10]:
            print(f"    * {name}")
        if len(spam_files) > 10:
            print(f"    ... va {len(spam_files) - 10} file khac.")
    else:
        print("  - Thu muc du an hoan toan sach se, khong co file spam.")

if __name__ == "__main__":
    if "--clean-local" in sys.argv:
        cleaned = clean_local_workspace(dry_run=False)
        print(f"[OK] Da don dep triet de {len(cleaned)} file rac tai workspace d:\\tinhlinh.")
    else:
        print_status()
