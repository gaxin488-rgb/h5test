@echo off
title KET NOI VPS VOI ANTIGRAVITY (CLOUDFLARE TUNNEL AUTO-SYNC GITHUB)
color 0B
cls
cd /d "%~dp0"

echo ========================================================
echo    MO DUONG TRUYEN KET NOI CHO GOOGLE ANTIGRAVITY
echo ========================================================
echo [*] Tu dong tao Cloudflare Tunnel va dong bo link len GitHub!
echo [*] Tu dong bat Agent va giu ket noi 24/7!
echo ========================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Auto_Tunnel_GitHub.ps1"
pause
