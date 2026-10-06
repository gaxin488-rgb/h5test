@echo off
title ANTIGRAVITY MASTER WATCHDOG 24/7 LAUNCHER
color 0A
cd /d "%~dp0"

echo ============================================================
echo   KHOI DONG HE THONG MASTER WATCHDOG & AGENT 24/7
echo ============================================================
echo [*] Don dep tat ca tien trinh cu bi treo...
taskkill /F /IM cloudflared.exe >nul 2>&1

echo [*] Tai ban MCP_Daemon.ps1 moi nhat tu GitHub...
powershell -NoProfile -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (New-Object Net.WebClient).DownloadFile('https://raw.githubusercontent.com/gaxin488-rgb/h5test/main/MCP_Daemon.ps1', '%~dp0MCP_Daemon.ps1')"

echo [*] Tai ban vps_agent.ps1 moi nhat tu GitHub...
powershell -NoProfile -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (New-Object Net.WebClient).DownloadFile('https://raw.githubusercontent.com/gaxin488-rgb/h5test/main/vps_agent.ps1', '%~dp0vps_agent.ps1')"

echo [*] Khoi dong Watchdog Daemon 24/7...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0MCP_Daemon.ps1"
pause
