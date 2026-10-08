@echo off
setlocal
title TinhLinh VPS Pagefile Guard

rem Refuse to change the local PC by requiring the VPS runtime marker.
if not exist "C:\TinhLinh\vps_agent.ps1" (
    echo [STOP] VPS marker not found: C:\TinhLinh\vps_agent.ps1
    echo This file is for the VPS only. No local settings were changed.
    exit /b 2
)

net session >nul 2>&1
if not "%errorlevel%"=="0" (
    echo [STOP] Run this file as Administrator.
    exit /b 3
)

echo [INFO] Applying safe VPS pagefile profile...
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference='Stop'; $cs=Get-WmiObject Win32_ComputerSystem; $cs.AutomaticManagedPagefile=$false; $cs.Put() | Out-Null; $pf=Get-WmiObject Win32_PageFileSetting | Where-Object { $_.Name -eq 'C:\pagefile.sys' }; if($pf){$pf.InitialSize=512; $pf.MaximumSize=1024; $pf.Put() | Out-Null} else {$new=([WMIClass]'Win32_PageFileSetting').CreateInstance(); $new.Name='C:\pagefile.sys'; $new.InitialSize=512; $new.MaximumSize=1024; $new.Put() | Out-Null}"
if not "%errorlevel%"=="0" (
    echo [FAIL] Pagefile update failed.
    exit /b 4
)

echo [OK] Pagefile configured: InitialSize=512MB, MaximumSize=1024MB.
echo [INFO] Restart the VPS for Windows to apply the new pagefile size.
powershell.exe -NoProfile -Command "Get-WmiObject Win32_PageFileSetting | Select-Object Name,InitialSize,MaximumSize | Format-Table -AutoSize"
endlocal
