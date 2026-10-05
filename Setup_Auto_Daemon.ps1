# ==============================================================================
# Setup & Auto-Start Installer for Antigravity VPS MCP Daemon
# Cai dat 1 cham - Tu dong chay ngam 24/7 khong can nguoi dung thao tac
# ==============================================================================
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  [*] DANG CAI DAT HE THONG TU DONG MCP CHO GOOGLE ANTIGRAVITY" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan

$destDir = "C:\Users\Administrator\Desktop\remote-vps-mcp"
if (-not (Test-Path $destDir)) {
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
}

# 1. Dung cac tien trinh cu
Write-Host "[1/6] Dang don dep cac tien trinh cu..." -ForegroundColor Yellow
Stop-Process -Name "cloudflared" -Force -ErrorAction SilentlyContinue
try {
    $lines = netstat -ano | Select-String ":8765\s"
    foreach ($l in $lines) {
        $parts = ($l.ToString().Trim() -split "\s+")
        if ($parts.Length -ge 5) {
            $pidToKill = [int]$parts[-1]
            if ($pidToKill -gt 0 -and $pidToKill -ne $PID) {
                Stop-Process -Id $pidToKill -Force -ErrorAction SilentlyContinue
            }
        }
    }
} catch {}

# 2. Tai ve cac tep moi nhat tu GitHub
Write-Host "[2/6] Dang tai ban moi nhat tu GitHub..." -ForegroundColor Cyan
$repo = "gaxin488-rgb/h5test"
$files = @("vps_agent.ps1", "MCP_Daemon.ps1", "Start_MCP_Daemon.bat", "Cai_Dat_Tu_Khoi_Dong.bat", "Auto_Tunnel_GitHub.ps1")
$wc = New-Object System.Net.WebClient
foreach ($f in $files) {
    try {
        $url = "https://raw.githubusercontent.com/$repo/main/$f"
        $target = Join-Path $destDir $f
        $wc.DownloadFile($url, $target)
        Write-Host "   [+] Da tai: $f" -ForegroundColor Green
    } catch {
        Write-Host "   [-] Loi tai $f: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 3. Kiem tra cloudflared.exe
$cfExe = Join-Path $destDir "cloudflared.exe"
if (-not (Test-Path $cfExe)) {
    Write-Host "[3/6] Dang tai cloudflared.exe..." -ForegroundColor Cyan
    try {
        $wc.DownloadFile("https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe", $cfExe)
        Write-Host "   [+] Da tai cloudflared.exe thanh cong!" -ForegroundColor Green
    } catch {
        Write-Host "   [-] Loi tai cloudflared: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "[3/6] cloudflared.exe da co san!" -ForegroundColor Green
}

# 4. Tao shortcut ngoai Desktop
Write-Host "[4/6] Tao Shortcut tren Desktop..." -ForegroundColor Cyan
$launcherPath = Join-Path $destDir "Start_MCP_Daemon.bat"
$desktopLauncher = "C:\Users\Administrator\Desktop\KHOI_DONG_MCP_247.bat"
"@echo off`r`nstart `"`" `"$launcherPath`"`r`n" | Set-Content -Path $desktopLauncher -Encoding ASCII

# 5. Cai dat tu khoi dong khi Boot & Logon
Write-Host "[5/6] Dang ky tu khoi dong Windows (Task Scheduler + Startup)..." -ForegroundColor Cyan
schtasks /Create /TN "Antigravity_MCP_Daemon" /TR "`"$launcherPath`"" /SC ONLOGON /RL HIGHEST /F >nul 2>&1
schtasks /Create /TN "Antigravity_MCP_Boot" /TR "`"$launcherPath`"" /SC ONSTART /RU "SYSTEM" /RL HIGHEST /F >nul 2>&1

$startupDir = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
if (Test-Path $startupDir) {
    "@echo off`r`nstart `"`" `"$launcherPath`"`r`n" | Set-Content -Path (Join-Path $startupDir "Start_Antigravity_MCP.bat") -Encoding ASCII
}
$commonStartup = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
if (Test-Path $commonStartup) {
    "@echo off`r`nstart `"`" `"$launcherPath`"`r`n" | Set-Content -Path (Join-Path $commonStartup "Start_Antigravity_MCP.bat") -Encoding ASCII
}

# 6. Khoi chay Daemon ngay lap tuc
Write-Host "[6/6] Dang khoi chay Watchdog Daemon..." -ForegroundColor Green
Start-Process -FilePath $launcherPath

Write-Host "============================================================" -ForegroundColor Green
Write-Host "[V] HOAN TAT! MCP DAEMON DANG CHAY VA TU DONG HOAT DONG 24/7!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
