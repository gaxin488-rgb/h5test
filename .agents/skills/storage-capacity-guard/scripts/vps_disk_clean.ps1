<#
.SYNOPSIS
    VPS Storage Hygiene & Emergency Disk Cleanup Script
.DESCRIPTION
    Tự động giải phóng dung lượng ổ C: trên VPS Windows Server,
    dọn dẹp cache, báo cáo lỗi WER, thùng rác và xoay vòng log bot game.
#>

[CmdletBinding()]
param()

$ErrorActionPreference = "SilentlyContinue"

function Get-CDiskFreeGB {
    $drive = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Name -eq "C" }
    if ($drive) {
        return [math]::Round($drive.Free / 1GB, 2)
    }
    return 0
}

$startFree = Get-CDiskFreeGB
Write-Host "[*] [Storage-Guard] Bat dau don dep o C:. Dung luong trong hien tai: $startFree GB" -ForegroundColor Cyan

# 1. Don dep Temp thu muc nguoi dung va Windows
$tempPaths = @(
    $env:TEMP,
    "C:\Windows\Temp",
    "C:\Users\Administrator\AppData\Local\Temp"
)
foreach ($tp in $tempPaths) {
    if (Test-Path $tp) {
        Get-ChildItem -Path $tp -Recurse -Force -ErrorAction SilentlyContinue |
            Where-Object { $_.LastWriteTime -lt (Get-Date).AddHours(-1) } |
            Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# 2. Xoa cache cap nhat Windows (SoftwareDistribution\Download)
$sdPath = "C:\Windows\SoftwareDistribution\Download"
if (Test-Path $sdPath) {
    Get-ChildItem -Path $sdPath -Recurse -Force -ErrorAction SilentlyContinue |
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
}

# 3. Xoa bao cao loi Windows Error Reporting (WER)
$werPaths = @(
    "C:\ProgramData\Microsoft\Windows\WER\ReportQueue",
    "C:\ProgramData\Microsoft\Windows\WER\ReportArchive"
)
foreach ($wp in $werPaths) {
    if (Test-Path $wp) {
        Get-ChildItem -Path $wp -Recurse -Force -ErrorAction SilentlyContinue |
            Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# 4. Xoa file crash dump
Get-ChildItem -Path "C:\Windows\Minidump", "C:\Windows\MEMORY.DMP" -Force -ErrorAction SilentlyContinue |
    Remove-Item -Force -ErrorAction SilentlyContinue

# 5. Xoa Thung Rac (Recycle Bin)
try {
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
} catch {}

# 6. Cat tia log bot game Tinh Linh (autofarm_log.txt) neu > 5MB
$gameLogs = @(
    "C:\TinhLinh\TinhLinh_Lite\Acc1\autofarm_log.txt",
    "C:\TinhLinh\TinhLinh_Lite\Acc2\autofarm_log.txt",
    "C:\Users\Administrator\Desktop\TinhLinh_Lite\TinhLinh_Lite\Acc1\autofarm_log.txt",
    "C:\Users\Administrator\Desktop\TinhLinh_Lite\TinhLinh_Lite\Acc2\autofarm_log.txt"
)
foreach ($log in $gameLogs) {
    if (Test-Path $log) {
        $item = Get-Item $log
        if ($item.Length -gt 5MB) {
            Write-Host "[*] [Storage-Guard] Cat tia log $log ($([math]::Round($item.Length/1MB, 1)) MB)..." -ForegroundColor Yellow
            $tail = Get-Content $log -Tail 2000
            Set-Content -Path $log -Value $tail -Force
        }
    }
}

$endFree = Get-CDiskFreeGB
$diffGB = [math]::Round($endFree - $startFree, 2)
Write-Host "[V] [Storage-Guard] Hoan tat don dep! Dung luong trong moi: $endFree GB (Giai phong thanh cong: $diffGB GB)" -ForegroundColor Green
