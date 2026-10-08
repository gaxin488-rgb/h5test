@echo off
setlocal EnableExtensions
title Tinh Linh (Bản Gốc - Baseline)
echo ========================================================
echo   KHOI CHAY GAME TINH LINH (BAN GOC - BASELINE)
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

set "OPENGL_OPT="
if exist "%~dp0opengl32.dll" (
    echo [i] Phat hien OpenGL Mesa: %~dp0opengl32.dll
    set "OPENGL_OPT=-Dorg.lwjgl.opengl.libname=%~dp0opengl32.dll"
)

echo [i] Java %JAVA_VERSION%: %JAVA_BIN%
"%JAVA_BIN%" -Xms32m -Xmx256m %OPENGL_OPT% -Dfile.encoding=UTF-8 -jar "%~dp0TinhLinh.jar"
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [!] Tien trinh game da dung voi ma thoat: %ERRORLEVEL%
    pause
)
