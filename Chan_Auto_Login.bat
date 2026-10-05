@echo off
title CHAN AUTO LOGIN - TINH LINH LITE
color 0C
cd /d "%~dp0"

echo ============================================================
echo      CONG TAC CHAN AUTO LOGIN - TINH LINH LITE
echo ============================================================
echo  Chuc nang:
echo  - Chan bot khong tu dong dang nhap vao tai khoan cu.
echo  - Giup game dung yen o man hinh dang nhap de lay LINK LOGIN.
echo  - Xoa cache session cu (.prefs\account).
echo ============================================================
echo.

:: 1. Tao file co tat auto login trong thu muc hien tai
echo Tat Auto Login > "%~dp0tat_auto_login.txt"
echo Tat Auto Login > "%~dp0no_auto_login.txt"
if exist "%~dp0bat_auto_login.txt" del /f /q "%~dp0bat_auto_login.txt" >nul 2>&1

:: 2. Xoa saved_account.txt trong thu muc nay neu co
if exist "%~dp0saved_account.txt" (
    echo [*] Dang sao luu va xoa saved_account.txt cu...
    copy /y "%~dp0saved_account.txt" "%~dp0saved_account.txt.bak" >nul 2>&1
    del /f /q "%~dp0saved_account.txt" >nul 2>&1
)

:: 3. Sao luu va xoa cache session LibGDX tren he thong
if exist "%USERPROFILE%\.prefs\account" (
    echo [*] Dang sao luu cache session he thong .prefs\account...
    copy /y "%USERPROFILE%\.prefs\account" "%USERPROFILE%\.prefs\account.bak" >nul 2>&1
    del /f /q "%USERPROFILE%\.prefs\account" >nul 2>&1
)

:: 4. Neu co thu muc TinhLinh_Acc2 tren Desktop thi cung chan luon
if exist "%USERPROFILE%\Desktop\TinhLinh_Acc2" (
    echo Tat Auto Login > "%USERPROFILE%\Desktop\TinhLinh_Acc2\tat_auto_login.txt"
    echo Tat Auto Login > "%USERPROFILE%\Desktop\TinhLinh_Acc2\no_auto_login.txt"
    if exist "%USERPROFILE%\Desktop\TinhLinh_Acc2\saved_account.txt" del /f /q "%USERPROFILE%\Desktop\TinhLinh_Acc2\saved_account.txt" >nul 2>&1
)

echo.
echo ============================================================
echo   [THANH CONG] DA CHAN AUTO LOGIN TRIET DE 100%!
echo ============================================================
echo   Bay gio ban hay mo Game len:
echo   - Game se DUNG YEN tai man hinh dang nhap.
echo   - Khong con tu dong vao Acc 1 nua.
echo   - Ban hay bam nut Dang Nhap de lay LINK LOGIN cho Acc 2!
echo.
echo   (Sau khi login Acc 2 xong, ban chi can chay file
echo    Bat_Lai_Auto_Login.bat tren Desktop la xong)
echo ============================================================
echo.
pause
