@echo off
setlocal
title Tinh Linh (Bản Gốc - Baseline)
echo ========================================================
echo   KHOI CHAY GAME TINH LINH (BAN GOC - BASELINE)
echo ========================================================
java -Xms32m -Xmx256m -Dfile.encoding=UTF-8 -jar "%~dp0TinhLinh.jar"
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [!] Tien trinh game da dung voi ma thoat: %ERRORLEVEL%
    pause
)
