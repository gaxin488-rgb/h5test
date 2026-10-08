# ==============================================================================
# TINHLINH VPS 1-CLICK INSTALLER (ZERO-INTERMEDIATE / 100% GITHUB TRACKED)
# ==============================================================================
[CmdletBinding()]
param(
    [string]$Repo = "gaxin488-rgb/h5test",
    [string]$Branch = "main"
)

$ErrorActionPreference = "SilentlyContinue"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Write-Host "`n========================================================" -ForegroundColor Cyan
Write-Host "   CAI DAT TINHLINH VPS AGENT 24/7 (ZERO DISK LOGS)" -ForegroundColor Cyan
Write-Host "========================================================`n" -ForegroundColor Cyan

# 1. Day-Zero OS Hardening (Thu hoi 2-3GB cho o C:)
Write-Host "[1/5] Toi uu hoa he dieu hanh cho o dia 15GB..." -ForegroundColor Yellow

# A. Tat Hibernation (thu hoi hiberfil.sys 1GB - 2GB)
& powercfg.exe -h off *>$null

# B. Toi uu Pagefile 1536MB - 3072MB (chong tran commit memory/OOM native cho Java & Agent)
try {
    Set-CimInstance -Query "Select * from Win32_ComputerSystem" -Property @{AutomaticManagedPagefile=$False} -ErrorAction SilentlyContinue
    $pf = Get-CimInstance Win32_PageFileSetting -ErrorAction SilentlyContinue
    if ($pf) { $pf | Remove-CimInstance -ErrorAction SilentlyContinue }
    New-CimInstance -ClassName Win32_PageFileSetting -Property @{Name="C:\pagefile.sys"; InitialSize=1536; MaximumSize=3072} -ErrorAction SilentlyContinue | Out-Null
} catch {}

# C. Vo hieu hoa Windows Update ngam & WER Crash Dumps
Stop-Service wuauserv -Force -ErrorAction SilentlyContinue
Set-Service wuauserv -StartupType Disabled -ErrorAction SilentlyContinue
reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t REG_DWORD /d 1 /f *>$null
reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting\LocalDumps" /v "DumpCount" /t REG_DWORD /d 0 /f *>$null

# D. Kich hoat kenh WinRM Remote Management & Tuong lua
try {
    Enable-PSRemoting -Force -SkipNetworkProfileCheck -ErrorAction SilentlyContinue
    Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force -ErrorAction SilentlyContinue
    Set-Item WSMan:\localhost\Service\AllowUnencrypted -Value $true -Force -ErrorAction SilentlyContinue
    Set-Item WSMan:\localhost\Service\Auth\Basic -Value $true -Force -ErrorAction SilentlyContinue
    netsh advfirewall firewall add rule name="WinRM-HTTP-5985" dir=in action=allow protocol=TCP localport=5985 *>$null
} catch {}

# E. Gioi han Shadow Storage & don dep ban dau
& vssadmin.exe resize shadowstorage /for=c: /on=c: /maxsize=400mb *>$null
& vssadmin.exe delete shadows /all /quiet *>$null
Clear-RecycleBin -Force -ErrorAction SilentlyContinue
Remove-Item "$env:TEMP\*", "C:\Windows\Temp\*", "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue

# 2. Khoi tao thu muc C:\TinhLinh & don dep file rac cu
Write-Host "[2/5] Khoi tao thu muc C:\TinhLinh & don dep log cu..." -ForegroundColor Yellow
$dir = "C:\TinhLinh"
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }

# Xoa sach bat ky file trung gian/log cu nao tren dia VPS (agent.log, tunnel.log, vps_watchdog.cmd,...)
Remove-Item (Join-Path $dir "*.log"), (Join-Path $dir "*.tmp"), (Join-Path $dir "*.cmd") -Force -ErrorAction SilentlyContinue

# 3. Tai cac file can thiet tu GitHub (Chi gom vps_agent.ps1 & cloudflared.exe)
Write-Host "[3/5] Tai ma nguon truc tiep tu GitHub..." -ForegroundColor Yellow
$wc = New-Object Net.WebClient
$wc.Headers.Add("User-Agent", "Mozilla/5.0")

# Tai vps_agent.ps1
$agentDest = Join-Path $dir "vps_agent.ps1"
$wc.DownloadFile("https://raw.githubusercontent.com/$Repo/$Branch/vps_agent.ps1", $agentDest)

# Tai cloudflared.exe neu chua co
$cfDest = Join-Path $dir "cloudflared.exe"
if (-not (Test-Path $cfDest)) {
    Write-Host "[*] Dang tai cloudflared.exe..." -ForegroundColor Yellow
    $wc.DownloadFile("https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe", $cfDest)
}

# 4. Dang ky Task Scheduler (Boot + Watchdog 24/7)
Write-Host "[4/5] Dang ky 2 Task Scheduler (Boot & Watchdog 24/7)..." -ForegroundColor Yellow
foreach ($t in @("TinhLinhAgent", "TinhLinhAgent_Boot", "TinhLinhAgent_Watchdog", "TinhLinhMCP_Boot", "TinhLinhMCP_Logon", "TinhLinhMCP_Watchdog", "Antigravity_MCP_Daemon")) {
    & schtasks.exe /Delete /TN $t /F *>$null
}

# Dung tien trinh cu
Get-Process cloudflared -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -like "*vps_agent.ps1*" } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }

# Task 1: Chay khi khoi dong he thong
$bootRun = "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$agentDest`""
& schtasks.exe /Create /TN "TinhLinhAgent_Boot" /TR "$bootRun" /SC ONSTART /RU "SYSTEM" /RL HIGHEST /F *>$null

# Task 2: Watchdog tu dong khoi dong lai MCP khi mat ket noi (kiem tra ping moi 1 phut)
$watchdogRun = 'powershell.exe -w hidden -c \"try { $r = (Invoke-WebRequest -Uri http://127.0.0.1:8765/ping -TimeoutSec 3 -UseBasicParsing).StatusCode; if ($r -ne 200) { throw } } catch { Stop-Process -Name cloudflared -Force -ea 0; Get-CimInstance Win32_Process -Filter \"\"CommandLine like ''%vps_agent.ps1%''\"\" -ea 0 | Stop-Process -Force -ea 0; Start-Process powershell \"\"-nop -w hidden -f C:\TinhLinh\vps_agent.ps1\"\" -WorkingDirectory C:\TinhLinh }\"'
& schtasks.exe /Create /TN "TinhLinhAgent_Watchdog" /TR $watchdogRun /SC MINUTE /MO 1 /RU "SYSTEM" /RL HIGHEST /F *>$null

# 5. Khoi dong Agent ngay lap tuc
Write-Host "[5/5] Khoi chay Agent..." -ForegroundColor Yellow
Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$agentDest`"" -WorkingDirectory $dir

$freeGB = [math]::Round(((Get-PSDrive C -ErrorAction SilentlyContinue).Free / 1GB), 2)
Write-Host "`n========================================================" -ForegroundColor Green
Write-Host ">>> CAI DAT THANH CONG! KHONG SINH BAT KY FILE LOG TRUNG GIAN <<<" -ForegroundColor Green
Write-Host ">>> Dung luong o C: con trong: $freeGB GB <<<" -ForegroundColor Green
Write-Host "========================================================`n" -ForegroundColor Green
