@echo off
title BAT LAI AUTO LOGIN - TINH LINH LITE
color 0A
cd /d "%~dp0"

echo ============================================================
echo      BAT LAI AUTO LOGIN - TINH LINH LITE
echo ============================================================

if exist "%~dp0tat_auto_login.txt" del /f /q "%~dp0tat_auto_login.txt" >nul 2>&1
if exist "%~dp0no_auto_login.txt" del /f /q "%~dp0no_auto_login.txt" >nul 2>&1
echo Bat Auto Login > "%~dp0bat_auto_login.txt"

if exist "%USERPROFILE%\Desktop\TinhLinh_Acc2\tat_auto_login.txt" del /f /q "%USERPROFILE%\Desktop\TinhLinh_Acc2\tat_auto_login.txt" >nul 2>&1
if exist "%USERPROFILE%\Desktop\TinhLinh_Acc2\no_auto_login.txt" del /f /q "%USERPROFILE%\Desktop\TinhLinh_Acc2\no_auto_login.txt" >nul 2>&1

echo.
echo ============================================================
echo   [THANH CONG] DA BAT LAI AUTO LOGIN!
echo ============================================================
echo   Bot se tu dong ket noi va dang nhap binh thuong khi vao game.
echo ============================================================
echo.
pause
