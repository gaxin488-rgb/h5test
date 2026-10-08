@echo off
setlocal
title TinhLinh Lite VPS 260x160

if not exist "C:\TinhLinh\vps_agent.ps1" (
    echo [STOP] VPS marker not found: C:\TinhLinh\vps_agent.ps1
    echo This launcher is for the VPS only. No local game was started.
    exit /b 2
)

if not exist "C:\TinhLinh\jre\bin\java.exe" (
    echo [STOP] Bundled Java runtime not found.
    exit /b 3
)

if not exist "C:\TinhLinh\TinhLinh-Lite-1GB-260x160.jar" (
    echo [STOP] Latest Lite JAR not found:
    echo C:\TinhLinh\TinhLinh-Lite-1GB-260x160.jar
    exit /b 4
)

cd /d "C:\TinhLinh"
echo [INFO] Starting TinhLinh Lite 260x160...
"C:\TinhLinh\jre\bin\java.exe" -Xms16m -Xmx64m -XX:+UseSerialGC -XX:MaxMetaspaceSize=64m -XX:ReservedCodeCacheSize=32m -Dfile.encoding=UTF-8 -jar "C:\TinhLinh\TinhLinh-Lite-1GB-260x160.jar"
set "EXIT_CODE=%ERRORLEVEL%"
echo [INFO] JAR exited with code %EXIT_CODE%.
endlocal & exit /b %EXIT_CODE%
