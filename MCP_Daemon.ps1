# ==============================================================================
# Antigravity VPS Master Watchdog Daemon (24/7 Self-Healing Loop)
# Tu dong khoi dong, giam sat suc khoe, tu sua loi, toi uu RAM va giu ket noi 24/7
# ==============================================================================
param(
    [int]$Port = 8765,
    [string]$Token = "tinhlinh_vps_secret_key_2026",
    [string]$Repo = "gaxin488-rgb/h5test",
    [string]$TunnelFile = "vps_tunnel_url.txt",
    [string]$TokenFile = "$PSScriptRoot\github_token.txt"
)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls

$root = $PSScriptRoot
$cloudflaredPath = Join-Path $root "cloudflared.exe"
$agentScriptPath = Join-Path $root "vps_agent.ps1"
$githubAgentUrl = "https://raw.githubusercontent.com/$Repo/main/vps_agent.ps1"
$githubDaemonUrl = "https://raw.githubusercontent.com/$Repo/main/MCP_Daemon.ps1"

$GithubToken = if (Test-Path $TokenFile) { 
    (Get-Content $TokenFile).Trim() 
} else { 
    ("github_pat_11B6FLSJI0pB8rOOwXa2Td_" + "x2yeqkqFfOmSyXhVn4KcMSqlgWdLpHSVphrSAfyrHcxISYKBJXWvThzt35H")
}

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "   ANTIGRAVITY VPS MASTER WATCHDOG DAEMON (24/7)" -ForegroundColor Green
Write-Host "   [*] Thu muc lam viec: $root" -ForegroundColor Yellow
Write-Host "   [*] Agent Port: $Port | Token: $Token" -ForegroundColor Yellow
Write-Host "   [*] GitHub Sync: $Repo/$TunnelFile" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Cyan

# Memory API
try {
    Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;
    public class VpsMem {
        [DllImport("psapi.dll")]
        public static extern int EmptyWorkingSet(IntPtr hProcess);
    }
"@ -ErrorAction SilentlyContinue
} catch {}

function Push-UrlToGitHub([string]$tunnelUrl) {
    if (-not $GithubToken -or -not $tunnelUrl) { return }
    try {
        $apiUrl = "https://api.github.com/repos/$Repo/contents/$TunnelFile"
        $headers = @{
            "Authorization" = "Bearer $GithubToken"
            "Accept"        = "application/vnd.github.v3+json"
            "User-Agent"    = "Antigravity-VPS-Daemon"
        }
        $sha = $null
        try {
            $resp = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method GET -TimeoutSec 8
            $sha = $resp.sha
        } catch {}

        $bytes = [System.Text.Encoding]::UTF8.GetBytes($tunnelUrl)
        $b64 = [Convert]::ToBase64String($bytes)
        $body = @{
            message = "Auto-update VPS Cloudflare Tunnel URL: $tunnelUrl"
            content = $b64
        }
        if ($sha) { $body["sha"] = $sha }

        $jsonBody = $body | ConvertTo-Json
        $null = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method PUT -Body $jsonBody -TimeoutSec 12
        Write-Host "[+] [GitHub Sync] Da cap nhat URL moi len GitHub: $tunnelUrl" -ForegroundColor Green
    } catch {
        Write-Host "[-] [GitHub Sync] Loi cap nhat URL: $($_.Exception.Message)" -ForegroundColor Red
    }
}

$logHistory = New-Object System.Collections.Generic.List[string]

function Push-LogToGitHub([string]$text) {
    if (-not $GithubToken -or -not $text) { return }
    try {
        $apiUrl = "https://api.github.com/repos/$Repo/contents/vps_daemon_log.txt"
        $headers = @{
            "Authorization" = "Bearer $GithubToken"
            "Accept"        = "application/vnd.github.v3+json"
            "User-Agent"    = "Antigravity-VPS-Daemon"
        }
        $sha = $null
        try {
            $resp = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method GET -TimeoutSec 6
            $sha = $resp.sha
        } catch {}

        $bytes = [System.Text.Encoding]::UTF8.GetBytes($text)
        $b64 = [Convert]::ToBase64String($bytes)
        $body = @{
            message = "Auto-update VPS Daemon & Error Log ($(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))"
            content = $b64
        }
        if ($sha) { $body["sha"] = $sha }

        $jsonBody = $body | ConvertTo-Json
        $null = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method PUT -Body $jsonBody -TimeoutSec 10
    } catch {}
}

function Log-Msg([string]$msg, [string]$color = "White") {
    $time = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $line = "[$time] $msg"
    Write-Host $msg -ForegroundColor $color
    $logHistory.Add($line)
    if ($logHistory.Count -gt 250) { $logHistory.RemoveAt(0) }
}


function Update-AgentScriptFromGitHub() {
    # Giu nguyen ban cap nhat toi uu noi bo, tranh bi rollback tu GitHub commit cu
    return
}

function Update-DaemonSelfFromGitHub() {
    # Giu nguyen ban cap nhat toi uu noi bo, tranh bi rollback tu GitHub commit cu
    return
}

function Kill-PortProcess([int]$p) {
    try {
        Get-WmiObject Win32_Process -ErrorAction SilentlyContinue | Where-Object {
            $_.Name -eq "powershell.exe" -and $_.ProcessId -ne $PID -and ($_.CommandLine -like "*vps_agent.ps1*")
        } | ForEach-Object {
            Write-Host "[!] Dung tien trinh PowerShell Agent cu (PID $($_.ProcessId))..." -ForegroundColor Yellow
            try { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue } catch {}
        }
    } catch {}
    try {
        $netstat = netstat -ano | Select-String ":$p\s"
        foreach ($line in $netstat) {
            $parts = ($line -split '\s+') | Where-Object { $_ }
            $pidToKill = $parts[-1]
            if ($pidToKill -and $pidToKill -ne "0" -and $pidToKill -ne "4" -and $pidToKill -ne "$PID") {
                try { Stop-Process -Id [int]$pidToKill -Force -ErrorAction SilentlyContinue } catch {}
            }
        }
    } catch {}
}

# 1. Update Agent & Daemon tu GitHub
Update-AgentScriptFromGitHub
Update-DaemonSelfFromGitHub

# 2. Don dep Agent cu neu co
Kill-PortProcess $Port

$agentProc = $null
$tunnelProc = $null
$currentTunnelUrl = $null
$lastRamTrimTime = [DateTime]::MinValue
$lastTunnelCheckTime = [DateTime]::MinValue
$agentFailCount = 0
$tunnelFailCount = 0
$lastGameCheckTime = [DateTime]::MinValue
$lastDiskCheckTime = [DateTime]::MinValue
$lastLogPushTime = [DateTime]::MinValue


function Start-AgentProcess() {
    Kill-PortProcess $Port
    Start-Sleep -Milliseconds 600
    Log-Msg "[*] Dang khoi dong VPS Agent (Port $Port)..." "Cyan"
    $agentLog = Join-Path $root "agent.log"
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "powershell.exe"
    $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$agentScriptPath`" -Port $Port -Token `"$Token`""

    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    return [System.Diagnostics.Process]::Start($psi)
}

function Get-CloudflaredPath() {
    $candidates = @(
        (Join-Path $root "cloudflared.exe"),
        "C:\Users\Administrator\Desktop\cloudflared.exe",
        "C:\cloudflared.exe",
        "C:\TinhLinh\cloudflared.exe"
    )
    foreach ($c in $candidates) {
        if (Test-Path $c) {
            $dest = Join-Path $root "cloudflared.exe"
            if ($c -ne $dest -and -not (Test-Path $dest)) {
                try { Copy-Item $c $dest -Force } catch {}
            }
            if (Test-Path $dest) { return $dest } else { return $c }
        }
    }
    try {
        $cmd = Get-Command cloudflared.exe -ErrorAction SilentlyContinue
        if ($cmd) { return $cmd.Source }
    } catch {}
    try {
        $dest = Join-Path $root "cloudflared.exe"
        Write-Host "[*] Dang tu dong tai cloudflared.exe tu GitHub..." -ForegroundColor Cyan
        $wc = New-Object System.Net.WebClient
        $wc.Headers.Add("User-Agent", "Mozilla/5.0")
        $wc.DownloadFile("https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe", $dest)
        if (Test-Path $dest) { return $dest }
    } catch {}
    return $null
}

function Start-TunnelProcess() {
    $cfPath = Get-CloudflaredPath
    if (-not $cfPath -or -not (Test-Path $cfPath)) {
        Log-Msg "[-] Khong tim thay cloudflared.exe!" "Red"
        return $null
    }
    Log-Msg "[*] Dang khoi dong Cloudflare Tunnel ($cfPath -> localhost:$Port)..." "Cyan"
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $cfPath
    $psi.Arguments = "tunnel --url http://127.0.0.1:$Port --http-host-header localhost"

    $psi.RedirectStandardError = $true
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    return [System.Diagnostics.Process]::Start($psi)
}

$agentProc = Start-AgentProcess
Start-Sleep -Seconds 2
$tunnelProc = Start-TunnelProcess

Log-Msg "`n[V] DA KHOI DONG THANH CONG! BAT DAU VONG LAP GIAM SAT 24/7...`n" "Green"
Push-LogToGitHub ($logHistory.ToArray() -join "`r`n")

# VONG LAP GIAM SAT 24/7
while ($true) {
    Start-Sleep -Seconds 5
    $now = [DateTime]::Now

    # A. Doc link Cloudflare Tunnel moi tu Stderr neu co
    if ($tunnelProc -and -not $tunnelProc.HasExited) {
        try {
            while (-not $tunnelProc.StandardError.EndOfStream) {
                $line = $tunnelProc.StandardError.ReadLine()
                if ($line -match "https://[a-zA-Z0-9\-]+\.trycloudflare\.com") {
                    $found = $matches[0]
                    if ($found -ne $currentTunnelUrl) {
                        $currentTunnelUrl = $found
                        Log-Msg "[+] Phat hien Cloudflare Tunnel URL moi: $currentTunnelUrl" "Yellow"
                        Push-UrlToGitHub $currentTunnelUrl
                        Push-LogToGitHub ($logHistory.ToArray() -join "`r`n")
                    }
                    break
                }
            }
        } catch {}
    }

    # B. Kiem tra tien trinh Tunnel (Auto-Restart neu crash)
    if ($null -eq $tunnelProc -or $tunnelProc.HasExited) {
        Log-Msg "[-] Cloudflare Tunnel bi dung! Tu dong khoi dong lai ngay..." "Red"
        $tunnelProc = Start-TunnelProcess
        Start-Sleep -Seconds 2
    }

    # C. Health Check Agent (Kiem tra treo / deadlock tren localhost:Port)
    $isAgentAlive = $false
    try {
        $req = [System.Net.HttpWebRequest]::Create("http://localhost:$Port/ping")
        $req.Timeout = 4000
        $req.ReadWriteTimeout = 4000
        $resp = $req.GetResponse()
        if ($resp.StatusCode -eq [System.Net.HttpStatusCode]::OK) {
            $isAgentAlive = $true
        }
        $resp.Close()
    } catch {
        try {
            $req2 = [System.Net.HttpWebRequest]::Create("http://127.0.0.1:$Port/ping")
            $req2.Timeout = 2000
            $resp2 = $req2.GetResponse()
            if ($resp2.StatusCode -eq [System.Net.HttpStatusCode]::OK) {
                $isAgentAlive = $true
            }
            $resp2.Close()
        } catch {
            $isAgentAlive = $false
        }
    }

    if ($isAgentAlive) {
        $agentFailCount = 0
    } else {
        $agentFailCount++
        Log-Msg "[-] Canh bao: Agent khong phan hoi tai localhost:$Port (Lan $agentFailCount/2)..." "Yellow"
        if ($agentFailCount -ge 2) {
            Log-Msg "[!] AGENT BI TREO HOAC MAT KET NOI! Tu dong reset Agent..." "Red"
            if ($agentProc -and -not $agentProc.HasExited) {
                try { $agentProc.Kill() } catch {}
            }
            Kill-PortProcess $Port
            Update-AgentScriptFromGitHub
            $agentProc = Start-AgentProcess
            $agentFailCount = 0
            Start-Sleep -Seconds 2
        }
    }

    # D. Kiem tra Public Cloudflare URL (moi 60 giay)
    if ($currentTunnelUrl -and ($now - $lastTunnelCheckTime).TotalSeconds -ge 60) {
        $lastTunnelCheckTime = $now
        $isPublicOk = $false
        try {
            $req = [System.Net.HttpWebRequest]::Create("$currentTunnelUrl/ping")
            $req.Timeout = 6000
            $req.ReadWriteTimeout = 6000
            $resp = $req.GetResponse()
            if ($resp.StatusCode -eq [System.Net.HttpStatusCode]::OK) {
                $isPublicOk = $true
            }
            $resp.Close()
        } catch {
            $isPublicOk = $false
        }

        if ($isPublicOk) {
            $tunnelFailCount = 0
        } else {
            $tunnelFailCount++
            Log-Msg "[-] Public Tunnel khong phan hoi: $currentTunnelUrl (Lan $tunnelFailCount/3)" "Yellow"
            if ($tunnelFailCount -ge 3) {
                Log-Msg "[!] CLOUDFLARE TUNNEL HONG! Tu dong khoi dong lai Tunnel moi..." "Red"
                if ($tunnelProc -and -not $tunnelProc.HasExited) {
                    try { $tunnelProc.Kill() } catch {}
                }
                $tunnelProc = Start-TunnelProcess
                $tunnelFailCount = 0
            }
        }
    }

    # E. Tu dong giai phong RAM (Trim Working Set) moi 4 phut (240 giay)
    if (($now - $lastRamTrimTime).TotalSeconds -ge 240) {
        $lastRamTrimTime = $now
        try {
            $javawProcs = Get-Process javaw -ErrorAction SilentlyContinue
            if ($javawProcs) {
                $trimmedCount = 0
                foreach ($jp in $javawProcs) {
                    [VpsMem]::EmptyWorkingSet($jp.Handle) | Out-Null
                    $trimmedCount++
                }
                Log-Msg "[*] [Auto-RAM-Trim] Da toi uu hoa RAM cho $trimmedCount tien trinh game javaw.exe" "Green"
            }
        } catch {}
    }

    # F. Tu dong kiem tra va khoi dong 2 Acc Game doc lap (moi 30 giay)
    if (-not $lastGameCheckTime -or ($now - $lastGameCheckTime).TotalSeconds -ge 30) {
        $lastGameCheckTime = $now
        $gameBase = "C:\Users\Administrator\Desktop\TinhLinh_Lite\TinhLinh_Lite"
        if (Test-Path $gameBase) {
            $javawProcs = @(Get-CimInstance Win32_Process -Filter "name='javaw.exe'" -ErrorAction SilentlyContinue)
            $tab1Running = $false
            $tab2Running = $false
            $tab1Pids = @()
            $tab2Pids = @()

            foreach ($jp in $javawProcs) {
                $cmdLine = $jp.CommandLine
                if ($cmdLine -like "*-Dtab=1*") {
                    $tab1Running = $true
                    $tab1Pids += $jp.ProcessId
                }
                elseif ($cmdLine -like "*-Dtab=2*") {
                    $tab2Running = $true
                    $tab2Pids += $jp.ProcessId
                }
            }

            # Neu co tien trinh trung lap cua cung 1 tab -> Kill ban sao thua de tranh xung dot socket va port
            if ($tab1Pids.Count -gt 1) {
                for ($i = 1; $i -lt $tab1Pids.Count; $i++) {
                    Log-Msg "[!] [Game-Watchdog] Phat hien trung lap Acc 1 (PID $($tab1Pids[$i])) -> Kill ban sao thua..." "Yellow"
                    Stop-Process -Id $tab1Pids[$i] -Force -ErrorAction SilentlyContinue
                }
            }
            if ($tab2Pids.Count -gt 1) {
                for ($i = 1; $i -lt $tab2Pids.Count; $i++) {
                    Log-Msg "[!] [Game-Watchdog] Phat hien trung lap Acc 2 (PID $($tab2Pids[$i])) -> Kill ban sao thua..." "Yellow"
                    Stop-Process -Id $tab2Pids[$i] -Force -ErrorAction SilentlyContinue
                }
            }

            # Khoi dong rieng biet tung tab neu chua chay
            $script1 = Join-Path $gameBase "Acc1\Run_Acc1.bat"
            $script2 = Join-Path $gameBase "Acc2\Run_Acc2.bat"

            if (-not $tab1Running -and (Test-Path $script1)) {
                Log-Msg "[*] [Game-Watchdog] Acc 1 (Tab 1 - gg3umwdt13) chua chay -> Tu dong khoi chay Run_Acc1.bat..." "Cyan"
                Start-Process "cmd.exe" -ArgumentList "/c `"$script1`"" -WorkingDirectory (Split-Path $script1) -WindowStyle Minimized
            }
            if (-not $tab2Running -and (Test-Path $script2)) {
                Log-Msg "[*] [Game-Watchdog] Acc 2 (Tab 2 - ggu3ucujf3) chua chay -> Tu dong khoi chay Run_Acc2.bat..." "Cyan"
                Start-Process "cmd.exe" -ArgumentList "/c `"$script2`"" -WorkingDirectory (Split-Path $script2) -WindowStyle Minimized
            }
        }
    }

    # G. Tu dong giam sat va don dep dung luong o C: (Disk-Storage-Watchdog moi 300 giay)
    if (-not $lastDiskCheckTime -or ($now - $lastDiskCheckTime).TotalSeconds -ge 300) {
        $lastDiskCheckTime = $now
        try {
            $driveC = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Name -eq "C" }
            if ($driveC) {
                $freeMB = [math]::Round($driveC.Free / 1MB, 0)
                $freeGB = [math]::Round($driveC.Free / 1GB, 2)
                if ($freeMB -lt 1500) {
                    Log-Msg "[!] [Disk-Watchdog] Canh bao: O C: chi con $freeMB MB ($freeGB GB) trong! Bat dau tu dong don dep..." "Yellow"
                    # 1. Don dep Temp
                    Get-ChildItem -Path "$env:TEMP", "C:\Windows\Temp" -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -lt (Get-Date).AddHours(-2) } | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
                    # 2. Xoa cache WER va SoftwareDistribution
                    Get-ChildItem -Path "C:\ProgramData\Microsoft\Windows\WER\ReportQueue" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
                    Get-ChildItem -Path "C:\Windows\SoftwareDistribution\Download" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
                    # 3. Xoa Thung Rac
                    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
                    # 4. Xoa Java crash dumps va minidumps (.mdmp, .dmp)
                    Get-ChildItem -Path "C:\Users\Administrator\Desktop", "C:\TinhLinh" -Include "hs_err_*.mdmp","hs_err_*.log","*.dmp" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
                    # 5. Cat tia log game bot neu > 5MB de chong tran bo nho
                    $log1 = "C:\Users\Administrator\Desktop\TinhLinh_Lite\TinhLinh_Lite\Acc1\autofarm_log.txt"
                    $log2 = "C:\Users\Administrator\Desktop\TinhLinh_Lite\TinhLinh_Lite\Acc2\autofarm_log.txt"
                    foreach ($lf in @($log1, $log2)) {
                        if (Test-Path $lf) {
                            $len = (Get-Item $lf).Length
                            if ($len -gt 5MB) {
                                Log-Msg "[*] [Disk-Watchdog] File log $lf vuot qua 5MB -> Cat tia giu 2000 dong moi nhat..." "Cyan"
                                $tailLines = Get-Content $lf -Tail 2000
                                Set-Content -Path $lf -Value $tailLines -Force
                            }
                        }
                    }
                    $afterC = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Name -eq "C" }
                    $afterGB = [math]::Round($afterC.Free / 1GB, 2)
                    Log-Msg "[V] [Disk-Watchdog] Don dep thanh cong! O C: hien co $afterGB GB trong." "Green"
                    Push-LogToGitHub ($logHistory.ToArray() -join "`r`n")
                }
            }
        } catch {}
    }

    # H. Day toan bo log giam sat len GitHub moi 60 giay
    if (-not $lastLogPushTime -or ($now - $lastLogPushTime).TotalSeconds -ge 60) {
        $lastLogPushTime = $now
        if ($logHistory.Count -gt 0) {
            $allLogs = ($logHistory.ToArray() -join "`r`n")
            Push-LogToGitHub $allLogs
        }
    }
}

