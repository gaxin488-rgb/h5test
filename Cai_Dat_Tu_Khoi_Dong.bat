@echo off
title CAI DAT TU KHOI DONG MCP CHO WINDOWS
color 0B
cls
cd /d "%~dp0"

echo ========================================================
echo   CAI DAT TU DONG KHOI DONG MCP DAEMON (ZERO USER TOUCH)
echo ========================================================
echo.

set TARGET=%~dp0Start_MCP_Daemon.bat

:: 1. Dang ky Windows Task Scheduler khi khoi dong may
echo [*] [1/3] Dang tao Task Scheduler khi khoi dong Windows...
schtasks /Create /TN "Antigravity_MCP_Daemon" /TR "\"%TARGET%\"" /SC ONLOGON /RL HIGHEST /F >nul 2>&1
schtasks /Create /TN "Antigravity_MCP_Boot" /TR "\"%TARGET%\"" /SC ONSTART /RU "SYSTEM" /RL HIGHEST /F >nul 2>&1

:: 2. Sao chep vao thu muc Windows Startup (All Users & Current User)
echo [*] [2/3] Dang tao Shortcut trong thu muc Startup...
if exist "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Startup" (
    echo @echo off > "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Startup\Start_Antigravity_MCP.bat"
    echo start "" "%TARGET%" >> "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Startup\Start_Antigravity_MCP.bat"
)
if exist "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup" (
    echo @echo off > "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\Start_Antigravity_MCP.bat"
    echo start "" "%TARGET%" >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\Start_Antigravity_MCP.bat"
)

:: 3. Dang ky Registry Run
echo [*] [3/3] Dang ky vao Windows Registry Run Key...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "AntigravityMCPDaemon" /t REG_SZ /d "\"%TARGET%\"" /f >nul 2>&1

echo.
echo ========================================================
echo [V] CAI DAT THANH CONG!
echo     - Tu nay moi khi VPS khoi dong lai hoac dang nhap,
echo       MCP Daemon se TU DONG CHAY ngam 24/7!
echo     - Nguoi dung KHONG CAN thao tac thu cong nao nua!
echo ========================================================
echo.
pause
