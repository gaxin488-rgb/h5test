@echo off
title ANTIGRAVITY VPS MASTER WATCHDOG (24/7 SELF-HEALING)
color 0A
cls
cd /d "%~dp0"

echo ========================================================
echo   KHOI DONG ANTIGRAVITY MASTER WATCHDOG DAEMON 24/7
echo ========================================================
echo [*] Tu dong khoi chay Agent & Cloudflare Tunnel
echo [*] Tu dong phuc hoi neu bi treo hoac mat ket noi
echo [*] Tu dong cap nhat link len GitHub khong can copy
echo [*] Tu dong toi uu RAM (Trim Working Set) moi 4 phut
echo ========================================================
echo.

:WATCHDOG_LOOP
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0MCP_Daemon.ps1"
echo.
echo [-] Daemon tam ngung hoac khoi dong lai sau 3 giay...
timeout /t 3 /nobreak >nul
goto WATCHDOG_LOOP
