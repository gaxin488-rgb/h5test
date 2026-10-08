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

function Invoke-BoundedProcess {
    param(
        [string]$FilePath,
        [string[]]$Arguments,
        [int]$TimeoutSeconds = 10
    )
    try {
        $p = Start-Process -FilePath $FilePath -ArgumentList $Arguments -PassThru -WindowStyle Hidden
        if (-not $p.WaitForExit($TimeoutSeconds * 1000)) {
            try { $p.Kill() } catch {}
            return $false
        }
        return ($p.ExitCode -eq 0)
    } catch {
        return $false
    }
}

Write-Host "`n========================================================" -ForegroundColor Cyan
Write-Host "   CAI DAT TINHLINH VPS AGENT 24/7 (ZERO DISK LOGS)" -ForegroundColor Cyan
Write-Host "========================================================`n" -ForegroundColor Cyan

# 0. Khac phuc su co Mang & DNS tren VPS (Set DNS Google & Cloudflare)
Write-Host "[0/5] Sua loi DNS va thiet lap DNS 8.8.8.8, 1.1.1.1..." -ForegroundColor Yellow
try {
    Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Up' } | ForEach-Object {
        Set-DnsClientServerAddress -InterfaceIndex $_.ifIndex -ServerAddresses ('8.8.8.8', '1.1.1.1', '8.8.4.4') -ErrorAction SilentlyContinue
    }
    & ipconfig.exe /flushdns *>$null
} catch {}

# 1. Day-Zero OS Hardening (Thu hoi 2-3GB cho o C:)
Write-Host "[1/5] Toi uu hoa he dieu hanh cho o dia 15GB..." -ForegroundColor Yellow

# A. Tat Hibernation (thu hoi hiberfil.sys 1GB - 2GB)
& powercfg.exe -h off *>$null

# B. Co dinh Pagefile 512MB - 1024MB (giu dung luong cho VPS 15GB)
try {
    Set-CimInstance -Query "Select * from Win32_ComputerSystem" -Property @{AutomaticManagedPagefile=$False} -ErrorAction SilentlyContinue
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name 'PagingFiles' -Value @('C:\pagefile.sys 512 1024') -Type MultiString -Force -ErrorAction SilentlyContinue
    $class = [wmiclass]"Win32_PageFileSetting"
    $pf = $class.CreateInstance()
    $pf.Name = "C:\pagefile.sys"
    $pf.InitialSize = 512
    $pf.MaximumSize = 1024
    $null = $pf.Put()
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
[void](Invoke-BoundedProcess -FilePath "vssadmin.exe" -Arguments @("resize", "shadowstorage", "/for=c:", "/on=c:", "/maxsize=400mb"))
[void](Invoke-BoundedProcess -FilePath "vssadmin.exe" -Arguments @("delete", "shadows", "/all", "/quiet"))
if (Get-Command Clear-RecycleBin -ErrorAction SilentlyContinue) { Clear-RecycleBin -Force -ErrorAction SilentlyContinue }
Remove-Item "$env:TEMP\*", "C:\Windows\Temp\*", "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue

# 2. Khoi tao thu muc C:\TinhLinh & don dep file rac cu
Write-Host "[2/5] Khoi tao thu muc C:\TinhLinh & don dep log cu..." -ForegroundColor Yellow
$dir = "C:\TinhLinh"
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }

# Xoa sach file trung gian/log cu tren VPS
Remove-Item (Join-Path $dir "*.log"), (Join-Path $dir "*.tmp"), (Join-Path $dir "*.cmd"), (Join-Path $dir "vps_watchdog.ps1") -Force -ErrorAction SilentlyContinue

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

# 4. Dang ky 1 Task Scheduler (Agent tu khoi phuc moi phut neu bi dung)
Write-Host "[4/5] Dang ky 1 Task Scheduler (Agent 24/7)..." -ForegroundColor Yellow
foreach ($t in @("TinhLinhAgent", "TinhLinhAgent_Boot", "TinhLinhAgent_Watchdog", "TinhLinhMCP_Boot", "TinhLinhMCP_Logon", "TinhLinhMCP_Watchdog", "Antigravity_MCP_Daemon")) {
    & schtasks.exe /Delete /TN $t /F *>$null
}

# Dung tien trinh cu
Get-Process cloudflared -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -like "*vps_agent.ps1*" } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }

# Một task duy nhất. Mutex trong vps_agent.ps1 chặn instance trùng.
$agentRun = "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$agentDest`""
& schtasks.exe /Create /TN "TinhLinhAgent" /TR "$agentRun" /SC MINUTE /MO 1 /RU "SYSTEM" /RL HIGHEST /F *>$null

# 5. Khoi dong Agent ngay lap tuc
Write-Host "[5/5] Khoi chay Agent..." -ForegroundColor Yellow
Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$agentDest`"" -WorkingDirectory $dir

$freeGB = [math]::Round(((Get-PSDrive C -ErrorAction SilentlyContinue).Free / 1GB), 2)
Write-Host "`n========================================================" -ForegroundColor Green
Write-Host ">>> CAI DAT THANH CONG! KHONG SINH BAT KY FILE LOG TRUNG GIAN <<<" -ForegroundColor Green
Write-Host ">>> Dung luong o C: con trong: $freeGB GB <<<" -ForegroundColor Green
Write-Host "========================================================`n" -ForegroundColor Green
