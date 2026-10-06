@echo off
title ANTIGRAVITY VPS MASTER DAEMON 24/7
color 0A
cls
cd /d "%~dp0"

echo ========================================================
echo   KHOI DONG ANTIGRAVITY MASTER WATCHDOG DAEMON 24/7
echo ========================================================
echo [*] Tu dong khoi chay Agent, Tunnel, Auto-Restart va Disk-Watchdog...


:: Dam bao thu muc ton tai
if not exist "%~dp0" mkdir "%~dp0"

:: Tai MCP_Daemon.ps1 tu GitHub bang User-Agent hop le
powershell -NoProfile -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; try { $wc = New-Object Net.WebClient; $wc.Headers.Add('User-Agent', 'Mozilla/5.0'); $wc.DownloadFile('https://raw.githubusercontent.com/gaxin488-rgb/h5test/main/MCP_Daemon.ps1', '%~dp0MCP_Daemon.ps1') } catch {}" >nul 2>&1

:DAEMON_LOOP
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0MCP_Daemon.ps1"
echo.
echo [-] Daemon tam ngung hoac khoi dong lai sau 3 giay...
timeout /t 3 /nobreak >nul
goto DAEMON_LOOP
