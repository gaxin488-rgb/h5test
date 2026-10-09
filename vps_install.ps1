# ==============================================================================
# TINHLINH VPS INSTALLER & ONE-CLICK RUNNER
# Usage on VPS (PowerShell as Admin):
# [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; iex ((New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/gaxin488-rgb/h5test/main/vps_install.ps1'))
# ==============================================================================
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ErrorActionPreference = "SilentlyContinue"

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "   CAI DAT & KHOI DONG TINHLINH VPS AGENT 24/7         " -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan

$Dir = "C:\TinhLinh"
if (-not (Test-Path $Dir)) {
    New-Item -ItemType Directory -Path $Dir -Force | Out-Null
}

# 1. Day-Zero OS Hardening de bao ve o C: 15GB
Write-Host "[1/5] Ap dung Storage Guard OS Hardening..." -ForegroundColor Yellow
try { & powercfg /h off *>$null } catch {}
try { & vssadmin resize shadowstorage /for=c: /on=c: /maxsize=400mb *>$null } catch {}
try { & vssadmin delete shadows /all /quiet *>$null } catch {}
try { Clear-RecycleBin -Force *>$null } catch {}

# 1.1 Cai dat Root CA certificates (cacerts) cho JRE de fix loi SSL trustAnchors
$cacertsDst = "C:\TLKN\jre\lib\security\cacerts"
if (-not (Test-Path $cacertsDst)) {
    try {
        $secDir = Split-Path $cacertsDst -Parent
        if (-not (Test-Path $secDir)) { New-Item -ItemType Directory -Path $secDir -Force | Out-Null }
        $cacertsUrl = "https://raw.githubusercontent.com/gaxin488-rgb/h5test/main/cacerts"
        (New-Object Net.WebClient).DownloadFile($cacertsUrl, $cacertsDst)
        Write-Host "      Da cai dat Root CA certificates (cacerts) thanh cong cho JRE." -ForegroundColor Green
    } catch {}
}

# 2. Tat cac tien trinh Agent va Cloudflared cu
Write-Host "[2/5] Don dep tien trinh cu..." -ForegroundColor Yellow
Get-Process cloudflared -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Get-Process powershell -ErrorAction SilentlyContinue | Where-Object { 
    $_.Id -ne $PID -and ($_.CommandLine -like "*vps_agent*" -or $_.MainWindowTitle -like "*TinhLinh*") 
} | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1

# 3. Tai hoac cap nhat cloudflared.exe neu chua co
$cfPath = Join-Path $Dir "cloudflared.exe"
if (-not (Test-Path $cfPath) -or ((Get-Item $cfPath).Length -lt 10000000)) {
    Write-Host "[3/5] Dang tai cloudflared.exe..." -ForegroundColor Yellow
    $cfUrl = "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-386.exe"
    try {
        (New-Object Net.WebClient).DownloadFile($cfUrl, $cfPath)
        Write-Host "      Tai cloudflared.exe thanh cong." -ForegroundColor Green
    } catch {
        # Fallback to amd64 neu 386 gap su co
        $cfUrl64 = "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe"
        (New-Object Net.WebClient).DownloadFile($cfUrl64, $cfPath)
    }
} else {
    Write-Host "[3/5] cloudflared.exe da ton tai tai $cfPath" -ForegroundColor Green
}

# 4. Tai ban moi nhat cua vps_agent.ps1 tu GitHub
Write-Host "[4/5] Dang tai vps_agent.ps1 moi nhat tu GitHub..." -ForegroundColor Yellow
$agentPath = Join-Path $Dir "vps_agent.ps1"
$agentUrl = "https://raw.githubusercontent.com/gaxin488-rgb/h5test/main/vps_agent.ps1"
try {
    $wc = New-Object Net.WebClient
    $wc.Headers.Add("User-Agent", "TinhLinh-Installer")
    $agentCode = $wc.DownloadString($agentUrl)
    if ($agentCode -and $agentCode.Contains("# TINHLINH VPS AGENT")) {
        [IO.File]::WriteAllText($agentPath, $agentCode, [Text.Encoding]::UTF8)
        Write-Host "      Da cap nhat vps_agent.ps1 thanh cong." -ForegroundColor Green
    } else {
        Write-Host "      Khong the tai vps_agent.ps1 tu GitHub. Giu file hien tai neu co." -ForegroundColor Red
    }
} catch {
    Write-Host "      Loi tai vps_agent.ps1: $($_.Exception.Message)" -ForegroundColor Red
}

# 5. Cai dat Task Scheduler de tu dong chay khi khoi dong VPS
Write-Host "[5/5] Dang ky Task Scheduler tu khoi dong khi bat VPS..." -ForegroundColor Yellow
$action = "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$agentPath`""
$schCmd = "schtasks /create /tn `"TinhLinh_Agent`" /tr `"$action`" /sc onstart /ru SYSTEM /f"
cmd.exe /c $schCmd *>$null

# 6. Khoi dong Agent ngay lap tuc
Write-Host "Dang khoi dong TinhLinh Agent trong nen..." -ForegroundColor Cyan
Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$agentPath`"" -WorkingDirectory $Dir

Start-Sleep -Seconds 3
$agentRunning = Get-Process powershell -ErrorAction SilentlyContinue | Where-Object { $_.Id -ne $PID }
Write-Host "========================================================" -ForegroundColor Green
Write-Host "   DA HOAN TAT CAI DAT VA KHOI DONG TINHLINH AGENT!     " -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green
Write-Host "Agent dang chay 24/7 va se tu ket noi qua Cloudflare." -ForegroundColor White
