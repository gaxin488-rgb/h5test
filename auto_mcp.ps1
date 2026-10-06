# Setup and Auto-Start MCP Daemon & Storage Guard for VPS 24/7
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ErrorActionPreference = "SilentlyContinue"

Write-Host "`n========================================================" -ForegroundColor Cyan
Write-Host "   CAI DAT AUTO MCP & STORAGE GUARD CHO VPS 24/7" -ForegroundColor Cyan
Write-Host "========================================================`n" -ForegroundColor Cyan

# 1. Giai phong dung luong o C: khan cap
Write-Host "[*] Dang don dep o C: (xoa Temp, cache WER, Thung rac)..." -ForegroundColor Yellow
Clear-RecycleBin -Force -ErrorAction SilentlyContinue
Get-ChildItem -Path "$env:TEMP", "C:\Windows\Temp" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
Get-ChildItem -Path "C:\ProgramData\Microsoft\Windows\WER\ReportQueue" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
Get-ChildItem -Path "C:\Windows\SoftwareDistribution\Download" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

$driveC = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Name -eq "C" }
$freeGB = [math]::Round($driveC.Free / 1GB, 2)
Write-Host "[+] Dung luong o C: sau khi don dep: $freeGB GB trong!" -ForegroundColor Green

# 2. Tao thu muc cai dat
$dir = "C:\Users\Administrator\Desktop\remote-vps-mcp"
if (-not (Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
}

# 3. Tai cac file can thiet tu GitHub voi User-Agent hop le
$wc = New-Object Net.WebClient
$wc.Headers.Add("User-Agent", "Mozilla/5.0")

$cfDesk = "C:\Users\Administrator\Desktop\cloudflared.exe"
$cfDest = Join-Path $dir "cloudflared.exe"
if ((Test-Path $cfDesk) -and -not (Test-Path $cfDest)) {
    Copy-Item $cfDesk $cfDest -Force
}
$files = @("Chay_Agent.bat", "MCP_Daemon.ps1", "vps_agent.ps1")
foreach ($f in $files) {
    Write-Host "[*] Dang tai $f tu GitHub..." -ForegroundColor Cyan
    $dest = Join-Path $dir $f
    try {
        $wc.DownloadFile("https://raw.githubusercontent.com/gaxin488-rgb/h5test/main/$f", $dest)
        Write-Host "  -> Da tai $f thanh cong!" -ForegroundColor Green
    } catch {
        Write-Host "  [-] Loi tai $($f) - $($_.Exception.Message)" -ForegroundColor Red
    }

}

# 4. Cai dat tu khoi dong khi bat may / dang nhap
$batPath = Join-Path $dir "Chay_Agent.bat"

# A. Registry Run
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "AntigravityMCPDaemon" /t REG_SZ /d "`"$batPath`"" /f | Out-Null
Write-Host "[V] Da cai dat Registry Run thanh cong!" -ForegroundColor Green

# B. Task Scheduler
schtasks /Create /TN "Antigravity_MCP_Daemon" /TR "`"$batPath`"" /SC ONLOGON /RL HIGHEST /F | Out-Null
Write-Host "[V] Da cai dat Task Scheduler thanh cong!" -ForegroundColor Green

# 5. Khoi dong MCP Daemon ngay lap tuc
Write-Host "`n[*] Dang khoi dong Agent & Cloudflare Tunnel..." -ForegroundColor Yellow
Get-Process cloudflared -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Process -FilePath $batPath -WorkingDirectory $dir

Write-Host "`n========================================================" -ForegroundColor Green
Write-Host ">>> AUTO MCP & STORAGE GUARD DA KHOI CHAY THANH CONG! <<<" -ForegroundColor Green
Write-Host "========================================================`n" -ForegroundColor Green
