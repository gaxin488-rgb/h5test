@echo off
setlocal EnableExtensions
title Tinh Linh (Auto Login & Watchdog 24/7)
cd /d "%~dp0"

echo ========================================================
echo   KHOI CHAY GAME TINH LINH (AUTO LOGIN & WATCHDOG 24/7)
echo ========================================================

set "JAVA_BIN="
if exist "%~dp0jre\bin\java.exe" set "JAVA_BIN=%~dp0jre\bin\java.exe"
if not defined JAVA_BIN if exist "C:\TLKN\jre\bin\java.exe" set "JAVA_BIN=C:\TLKN\jre\bin\java.exe"
if not defined JAVA_BIN if exist "D:\TLKN\jre\bin\java.exe" set "JAVA_BIN=D:\TLKN\jre\bin\java.exe"
if not defined JAVA_BIN if defined JAVA_HOME if exist "%JAVA_HOME%\bin\java.exe" set "JAVA_BIN=%JAVA_HOME%\bin\java.exe"
if not defined JAVA_BIN (
    where java >nul 2>&1
    if not errorlevel 1 set "JAVA_BIN=java"
)

if not defined JAVA_BIN (
    echo [!] Khong tim thay Java. Cai JRE/JDK 17+ hoac dat JAVA_HOME.
    pause
    exit /b 1
)

set "JAVA_VERSION="
set "JAVA_VERSION_FILE=%TEMP%\tinhlinh-java-version-%RANDOM%.tmp"
"%JAVA_BIN%" -version > "%JAVA_VERSION_FILE%" 2>&1
set "JAVA_VERSION_LINE="
set /p JAVA_VERSION_LINE=<"%JAVA_VERSION_FILE%"
del /q "%JAVA_VERSION_FILE%" >nul 2>&1
for /f "tokens=3" %%V in ("%JAVA_VERSION_LINE%") do set "JAVA_VERSION=%%~V"
for /f "tokens=1 delims=." %%V in ("%JAVA_VERSION%") do set "JAVA_MAJOR=%%V"

if not defined JAVA_MAJOR (
    echo [!] Khong doc duoc phien ban cua Java: %JAVA_BIN%
    pause
    exit /b 1
)
if %JAVA_MAJOR% LSS 17 (
    echo [!] Java %JAVA_VERSION% qua cu. Game yeu cau Java 17+.
    echo     Java dang dung: %JAVA_BIN%
    echo     Cai Java 17+ hoac dat JAVA_HOME dung thu muc.
    pause
    exit /b 1
)

set "LIBGL_ALWAYS_SOFTWARE=1"
set "MESA_LOADER_DRIVER_OVERRIDE=llvmpipe"
set "GALLIUM_DRIVER=llvmpipe"

echo [i] Java %JAVA_VERSION%: %JAVA_BIN%
echo [i] Watchdog san sang. De tat, tao file tat_tu_khoi_dong.txt hoac bam Ctrl+C.

rem --- Single-Instance Guard: Ngan chan chay trung lap nhieu watchdog ---
set "LOCK_FILE=%TEMP%\tinhlinh_watchdog.pid"
powershell.exe -NoProfile -Command "$lf = '%LOCK_FILE%'; if (Test-Path $lf) { $p = Get-Content $lf -ErrorAction SilentlyContinue; if ($p -and (Get-Process -Id ([int]$p) -ErrorAction SilentlyContinue)) { Write-Host ('[Watchdog] Da co tien trinh watchdog PID {0} dang chay. Thoat instance moi.' -f $p) -ForegroundColor Yellow; exit 42 } }; [IO.File]::WriteAllText($lf, $PID.ToString())"
if errorlevel 42 (
    echo [Watchdog] Da co mot phien watchdog khac dang hoat dong. Cua so nay se dong.
    timeout /t 5 >nul
    exit /b 0
)

set /a RESTART_COUNT=0

:watchdog_loop
set /a RESTART_COUNT+=1
echo.
echo ========================================================
echo  [WATCHDOG] Phien chay #%RESTART_COUNT% - %DATE% %TIME%
echo ========================================================

rem --- Storage & Capacity Guard: Don dep pgame-sdk temp va cat tia log truoc khi khoi chay ---
powershell.exe -NoProfile -Command "Get-ChildItem -Path '$env:TEMP\pgame-sdk*', 'C:\Users\*\AppData\Local\Temp\pgame-sdk*', '$env:TEMP\hs_err*.log' -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue; if (Test-Path '%~dp0autofarm_log.txt') { if ((Get-Item '%~dp0autofarm_log.txt').Length -gt 3MB) { $t = Get-Content '%~dp0autofarm_log.txt' -Tail 1500 -Encoding UTF8; Set-Content '%~dp0autofarm_log.txt' -Value $t -Encoding UTF8 -Force; Write-Host '[StorageGuard] Da cat tia autofarm_log.txt ve 1500 dong (<3MB).' -ForegroundColor Yellow } }"

rem --- Don dep thu muc temp neu o C: duoi 1500MB ---
powershell.exe -NoProfile -Command "$freeMB = [math]::Round(((Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -like '*C:*' }).Free / 1MB), 0); if ($freeMB -lt 1500) { Clear-RecycleBin -Force -ErrorAction SilentlyContinue; Remove-Item -Path \"$env:TEMP\tinhlinh*\", \"C:\Users\*\AppData\Local\Temp\pgame-sdk*\" -Recurse -Force -ErrorAction SilentlyContinue; Write-Host ('[StorageGuard] Canh bao dung luong o C: con {0}MB -> Da don dep temp va RecycleBin.' -f $freeMB) -ForegroundColor Yellow }"

rem --- Khoi chay game (Chan triet de crash dump hs_err_*.mdmp de bao ve o C: 15GB) ---
"%JAVA_BIN%" -Xms16m -Xmx96m -XX:+UseSerialGC -XX:-CreateCoredumpOnCrash -XX:ErrorFile=NUL -Dfile.encoding=UTF-8 -jar "%~dp0TinhLinh.jar"
set "EXIT_CODE=%ERRORLEVEL%"

echo [WATCHDOG] Tien trinh game da dung (Ma thoat: %EXIT_CODE%) tai %DATE% %TIME%.

rem --- Kiem tra neu nguoi dung muon tat han ---
if exist "%~dp0tat_tu_khoi_dong.txt" (
    echo [WATCHDOG] Phat hien file tat_tu_khoi_dong.txt -> Dung han Watchdog.
    if exist "%LOCK_FILE%" del /q "%LOCK_FILE%" >nul 2>&1
    pause
    exit /b 0
)
if exist "%~dp0stop_game.txt" (
    echo [WATCHDOG] Phat hien file stop_game.txt -> Dung han Watchdog.
    if exist "%LOCK_FILE%" del /q "%LOCK_FILE%" >nul 2>&1
    pause
    exit /b 0
)

rem --- Post-Run Emergency Storage Cleanup ---
powershell.exe -NoProfile -Command "Get-ChildItem -Path '$env:TEMP\pgame-sdk*', 'C:\Users\*\AppData\Local\Temp\pgame-sdk*' -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue; if (Test-Path '%~dp0autofarm_log.txt') { if ((Get-Item '%~dp0autofarm_log.txt').Length -gt 3MB) { $t = Get-Content '%~dp0autofarm_log.txt' -Tail 1500 -Encoding UTF8; Set-Content '%~dp0autofarm_log.txt' -Value $t -Encoding UTF8 -Force } }; [GC]::Collect()"

echo [WATCHDOG] Tu dong khoi dong lai game sau 5 giay...
timeout /t 5 /nobreak >nul
goto watchdog_loop

