@echo off
title KHOI DONG TOAN BO VPS AGENT 24/7 CHO ANTIGRAVITY
color 0A
cls
cd /d "%~dp0"

echo ========================================================
echo   KHOI DONG VPS AGENT VA AUTO RESTART CHO ANTIGRAVITY
echo ========================================================
echo [*] Don dep tat ca tien trinh cu bi treo tren port 8765...
taskkill /F /IM cloudflared.exe >nul 2>&1
powershell -NoProfile -Command "Get-Process powershell -ErrorAction SilentlyContinue | Where-Object { $_.Id -ne $PID } | Stop-Process -Force -ErrorAction SilentlyContinue" >nul 2>&1

echo [*] Tu dong tai ban vps_agent.ps1 moi nhat tu GitHub...
powershell -NoProfile -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; try { (New-Object Net.WebClient).DownloadFile('https://raw.githubusercontent.com/gaxin488-rgb/h5test/main/vps_agent.ps1', '%~dp0vps_agent.ps1') } catch {}" >nul 2>&1

echo [*] Tu dong tao Cloudflare Tunnel ra Internet...
start "CLOUDFLARE TUNNEL (ANTIGRAVITY)" powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (New-Object Net.WebClient).DownloadFile('https://raw.githubusercontent.com/gaxin488-rgb/h5test/main/Auto_Tunnel_GitHub.ps1', '%~dp0Auto_Tunnel_GitHub.ps1'); & '%~dp0Auto_Tunnel_GitHub.ps1'"

:AGENT_LOOP
echo.
echo [*] Dang khoi dong Agent tren cong 8765...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0vps_agent.ps1" -Port 8765 -Token "tinhlinh_vps_secret_key_2026"
echo.
echo [-] Agent tam ngung hoac khoi dong lai sau 3 giay...
timeout /t 3 /nobreak >nul
goto AGENT_LOOP
