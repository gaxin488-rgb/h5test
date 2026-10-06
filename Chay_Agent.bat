@echo off
title ANTIGRAVITY MASTER WATCHDOG 24/7
color 0A
cls
cd /d "%~dp0"

echo ========================================================
echo   KHOI DONG ANTIGRAVITY MASTER WATCHDOG DAEMON 24/7
echo ========================================================
echo [*] Don dep tien trinh cu va giai phong port 8765...
taskkill /F /IM cloudflared.exe >nul 2>&1

echo [*] Tu dong cap nhat ban moi nhat tu GitHub...
powershell -NoProfile -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $wc = New-Object Net.WebClient; $wc.Headers.Add('User-Agent', 'Mozilla/5.0'); try { $wc.DownloadFile('https://raw.githubusercontent.com/gaxin488-rgb/h5test/main/MCP_Daemon.ps1', '%~dp0MCP_Daemon.ps1') } catch {}; try { $wc.DownloadFile('https://raw.githubusercontent.com/gaxin488-rgb/h5test/main/vps_agent.ps1', '%~dp0vps_agent.ps1') } catch {}" >nul 2>&1

:DAEMON_LOOP
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0MCP_Daemon.ps1"
echo.
echo [-] Daemon tam ngung hoac khoi dong lai sau 3 giay...
timeout /t 3 /nobreak >nul
goto DAEMON_LOOP
