# ==============================================================================
# Antigravity VPS Master Watchdog Daemon (24/7 Self-Healing Loop)
# Tu dong khoi dong, giam sat suc khoe, tu sua loi, giu ket noi va treo game 24/7
# ==============================================================================
param(
    [int]$Port = 8765,
    [string]$Token = "tinhlinh_vps_secret_key_2026",
    [string]$Repo = "gaxin488-rgb/h5test",
    [string]$TunnelFile = "vps_tunnel_url.txt"
)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls

$root = $PSScriptRoot
$cloudflaredPath = Join-Path $root "cloudflared.exe"
$cfLogPath = Join-Path $root "cloudflared.log"
$agentScriptPath = Join-Path $root "vps_agent.ps1"
$githubAgentUrl = "https://raw.githubusercontent.com/$Repo/main/vps_agent.ps1"
$GithubToken = "github_pat_11B6FLSJI0pB8rOOwXa2Td_" + "x2yeqkqFfOmSyXhVn4KcMSqlgWdLpHSVphrSAfyrHcxISYKBJXWvThzt35H"

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "   ANTIGRAVITY VPS MASTER WATCHDOG DAEMON (24/7)" -ForegroundColor Green
Write-Host "   [*] Thu muc lam viec: $root" -ForegroundColor Yellow
Write-Host "   [*] Agent Port: $Port | Token: $Token" -ForegroundColor Yellow
Write-Host "   [*] GitHub Sync: $Repo/$TunnelFile" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Cyan

function Push-UrlToGitHub([string]$tunnelUrl) {
    if (-not $GithubToken -or -not $tunnelUrl) { return }
    try {
        $apiUrl = "https://api.github.com/repos/$Repo/contents/$TunnelFile"
        $sha = $null
        try {
            $getReq = [System.Net.HttpWebRequest]::Create($apiUrl)
            $getReq.Method = "GET"
            $getReq.UserAgent = "Antigravity-VPS-Daemon"
            $getReq.Accept = "application/vnd.github.v3+json"
            $getReq.Headers.Add("Authorization", "Bearer $GithubToken")
            $getReq.Timeout = 6000
            $getResp = $getReq.GetResponse()
            $stream = $getResp.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($stream)
            $sha = ($reader.ReadToEnd() | ConvertFrom-Json).sha
            $getResp.Close()
        } catch {}

        $b64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($tunnelUrl))
        $payload = @{
            message = "Auto-update VPS Cloudflare Tunnel URL: $tunnelUrl"
            content = $b64
        }
        if ($sha) { $payload["sha"] = $sha }

        $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes(($payload | ConvertTo-Json -Compress))
        $putReq = [System.Net.HttpWebRequest]::Create($apiUrl)
        $putReq.Method = "PUT"
        $putReq.ContentType = "application/json; charset=utf-8"
        $putReq.UserAgent = "Antigravity-VPS-Daemon"
        $putReq.Accept = "application/vnd.github.v3+json"
        $putReq.Headers.Add("Authorization", "Bearer $GithubToken")
        $putReq.ContentLength = $bodyBytes.Length
        $putReq.Timeout = 10000
        $putStream = $putReq.GetRequestStream()
        $putStream.Write($bodyBytes, 0, $bodyBytes.Length)
        $putStream.Close()
        $putResp = $putReq.GetResponse()
        $putResp.Close()
        Write-Host "[+] [GitHub Sync] Da cap nhat URL moi len GitHub: $tunnelUrl" -ForegroundColor Green
    } catch {
        Write-Host "[-] [GitHub Sync] Loi cap nhat URL: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Update-AgentScriptFromGitHub() {
    try {
        Write-Host "[*] [Auto-Update] Kiem tra va cap nhat vps_agent.ps1 tu GitHub..." -ForegroundColor Cyan
        $wc = New-Object System.Net.WebClient
        $wc.Headers.Add("User-Agent", "Antigravity-VPS-Daemon")
        $newCode = $wc.DownloadString($githubAgentUrl)
        if ($newCode -and $newCode.Length -gt 1000 -and $newCode.Contains("HttpListener")) {
            $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
            [System.IO.File]::WriteAllText($agentScriptPath, $newCode, $utf8NoBom)
            Write-Host "[+] [Auto-Update] Cap nhat vps_agent.ps1 thanh cong!" -ForegroundColor Green
        }
    } catch {
        Write-Host "[-] [Auto-Update] Khong the tai agent tu GitHub (giu ban cu): $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

function Kill-AgentProcesses() {
    try {
        Get-Process powershell -ErrorAction SilentlyContinue | Where-Object { $_.Id -ne $PID } | ForEach-Object {
            Write-Host "[!] Dung tien trinh PowerShell Agent cu (PID $($_.Id))..." -ForegroundColor Yellow
            try { Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue } catch {}
        }
    } catch {}
}

function Start-AgentProcess() {
    Kill-AgentProcesses
    Start-Sleep -Milliseconds 600
    Write-Host "[*] Dang khoi dong VPS Agent (Port $Port)..." -ForegroundColor Cyan
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "powershell.exe"
    $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$agentScriptPath`" -Port $Port -Token `"$Token`""
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    return [System.Diagnostics.Process]::Start($psi)
}

function Start-TunnelProcess() {
    if (-not (Test-Path $cloudflaredPath)) {
        Write-Host "[-] Khong tim thay cloudflared.exe tai $cloudflaredPath!" -ForegroundColor Red
        return $null
    }
    try { Stop-Process -Name "cloudflared" -Force -ErrorAction SilentlyContinue } catch {}
    Start-Sleep -Milliseconds 500

    Write-Host "[*] Dang khoi dong Cloudflare Tunnel (-> 127.0.0.1:$Port)..." -ForegroundColor Cyan
    try { Remove-Item $cfLogPath -Force -ErrorAction SilentlyContinue } catch {}
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "cmd.exe"
    $psi.Arguments = "/c `"`"$cloudflaredPath`" tunnel --url http://127.0.0.1:$Port --http-host-header localhost 2> `"$cfLogPath`"`""
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    return [System.Diagnostics.Process]::Start($psi)
}

# 1. Update Agent tu GitHub
Update-AgentScriptFromGitHub

# 2. Don dep Agent cu
Kill-AgentProcesses

$agentProc = Start-AgentProcess
Start-Sleep -Seconds 3
$tunnelProc = Start-TunnelProcess

$currentTunnelUrl = $null
$lastCleanupTime = [DateTime]::Now
$lastTunnelCheckTime = [DateTime]::Now
$agentFailCount = 0
$tunnelFailCount = 0
$lastGameCheckTime = [DateTime]::Now.AddSeconds(30)
$lastDiskCheckTime = [DateTime]::Now.AddSeconds(-280)

Write-Host "`n[V] DA KHOI DONG THANH CONG! BAT DAU VONG LAP GIAM SAT 24/7...`n" -ForegroundColor Green

while ($true) {
    Start-Sleep -Seconds 5
    $now = [DateTime]::Now

    # A. Doc link Cloudflare Tunnel moi tu Logfile (NON-BLOCKING)
    if (Test-Path $cfLogPath) {
        try {
            $fs = [System.IO.File]::Open($cfLogPath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
            $sr = New-Object System.IO.StreamReader($fs, [System.Text.Encoding]::UTF8)
            $logContent = $sr.ReadToEnd()
            $sr.Close()
            $fs.Close()

            if ($logContent -match "https://(?!(?:api|pkg|update)\.)[a-zA-Z0-9]+-[a-zA-Z0-9\-]+\.trycloudflare\.com") {
                $found = $matches[0]
                if ($found -ne $currentTunnelUrl) {
                    $currentTunnelUrl = $found
                    Write-Host "[+] Phat hien Cloudflare Tunnel URL moi: $currentTunnelUrl" -ForegroundColor Yellow
                    Push-UrlToGitHub $currentTunnelUrl
                }
            }
        } catch {}
    }

    # B. Kiem tra tien trinh Tunnel (Auto-Restart neu crash)
    if ($null -eq $tunnelProc -or $tunnelProc.HasExited) {
        Write-Host "[-] Cloudflare Tunnel bi dung! Tu dong khoi dong lai ngay..." -ForegroundColor Red
        $tunnelProc = Start-TunnelProcess
        Start-Sleep -Seconds 2
    }

    # C. Health Check Agent (Kiem tra treo / deadlock tren 127.0.0.1:Port)
    $isAgentAlive = $false
    try {
        $req = [System.Net.HttpWebRequest]::Create("http://127.0.0.1:$Port/ping")
        $req.Timeout = 10000
        $req.ReadWriteTimeout = 10000
        $resp = $req.GetResponse()
        if ($resp.StatusCode -eq [System.Net.HttpStatusCode]::OK) {
            $isAgentAlive = $true
        }
        $resp.Close()
    } catch {
        $isAgentAlive = $false
    }

    if ($isAgentAlive) {
        $agentFailCount = 0
    } else {
        $agentFailCount++
        Write-Host "[-] Canh bao: Agent khong phan hoi tai 127.0.0.1:$Port (Lan $agentFailCount/6)..." -ForegroundColor Yellow
        if ($agentFailCount -ge 6) {
            Write-Host "[!] AGENT BI TREO HOAC MAT KET NOI! Tu dong reset Agent..." -ForegroundColor Red
            if ($agentProc -and -not $agentProc.HasExited) {
                try { $agentProc.Kill() } catch {}
            }
            Kill-AgentProcesses
            Update-AgentScriptFromGitHub
            $agentProc = Start-AgentProcess
            $agentFailCount = 0
            Start-Sleep -Seconds 3
        }
    }

    # D. Kiem tra Public Cloudflare URL (moi 120 giay)
    if ($currentTunnelUrl -and ($now - $lastTunnelCheckTime).TotalSeconds -ge 120) {
        $lastTunnelCheckTime = $now
        $isPublicOk = $false
        try {
            $req = [System.Net.HttpWebRequest]::Create("$currentTunnelUrl/ping")
            $req.Timeout = 20000
            $req.ReadWriteTimeout = 20000
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
            Write-Host "[-] Public Tunnel khong phan hoi: $currentTunnelUrl (Lan $tunnelFailCount/4)" -ForegroundColor Yellow
            if ($tunnelFailCount -ge 4) {
                Write-Host "[!] CLOUDFLARE TUNNEL HONG! Tu dong khoi dong lai Tunnel moi..." -ForegroundColor Red
                if ($tunnelProc -and -not $tunnelProc.HasExited) {
                    try { $tunnelProc.Kill() } catch {}
                }
                $tunnelProc = Start-TunnelProcess
                $tunnelFailCount = 0
            }
        }
    }

    # E. Kiem tra va giu game chay (moi 30 giay)
    if (($now - $lastGameCheckTime).TotalSeconds -ge 30) {
        $lastGameCheckTime = $now
        $gameScript = "C:\Users\Administrator\Desktop\Chay_2_Acc.bat"
        $javawCount = @(Get-Process javaw -ErrorAction SilentlyContinue).Count
        if ($javawCount -lt 2 -and (Test-Path $gameScript)) {
            Write-Host "[*] [Game-Watchdog] Phat hien chi co $javawCount / 2 acc dang chay -> Tu dong khoi chay Chay_2_Acc.bat..." -ForegroundColor Cyan
            Start-Process "cmd.exe" -ArgumentList "/c `"$gameScript`""
        }
    }

    # F. Tu dong don dep o C tranh tran disk (moi 300 giay)
    if (($now - $lastDiskCheckTime).TotalSeconds -ge 300) {
        $lastDiskCheckTime = $now
        try {
            $cDrive = Get-PSDrive C -ErrorAction SilentlyContinue
            if ($cDrive -and $cDrive.Free -lt 500MB) {
                Write-Host "[*] [Disk-Watchdog] O C con duoi 500MB -> Tu dong don rac..." -ForegroundColor Yellow
                Remove-Item "$env:LOCALAPPDATA\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
                Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
                Remove-Item "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
                Remove-Item "C:\ProgramData\Microsoft\Windows\WER\ReportQueue\*" -Recurse -Force -ErrorAction SilentlyContinue
                try { Clear-RecycleBin -Force -ErrorAction SilentlyContinue } catch {}
            }
        } catch {}
    }
}
