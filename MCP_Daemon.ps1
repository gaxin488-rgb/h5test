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
$cfLogPath = Join-Path $root "cloudflared.log"
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
    if (-not $GithubToken) { return }
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
        Get-WmiObject Win32_Process | Where-Object {
            $_.Name -eq "powershell.exe" -and $_.ProcessId -ne $PID -and ($_.CommandLine -like "*vps_agent.ps1*")
        } | ForEach-Object {
            Write-Host "[!] Dung tien trinh PowerShell Agent cu (PID $($_.ProcessId))..." -ForegroundColor Yellow
            try { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue } catch {}
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
    # Dung tat ca tien trinh cloudflared cu de tranh xung dot
    try { Stop-Process -Name "cloudflared" -Force -ErrorAction SilentlyContinue } catch {}
    Start-Sleep -Milliseconds 500

    Write-Host "[*] Dang khoi dong Cloudflare Tunnel (-> 127.0.0.1:$Port)..." -ForegroundColor Cyan
    try { Remove-Item $cfLogPath -Force -ErrorAction SilentlyContinue } catch {}
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $cloudflaredPath
    $psi.Arguments = "tunnel --url http://127.0.0.1:$Port --http-host-header localhost --logfile `"$cfLogPath`""
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
$lastRamTrimTime = [DateTime]::Now
$lastTunnelCheckTime = [DateTime]::Now
$agentFailCount = 0
$tunnelFailCount = 0
$lastGameCheckTime = [DateTime]::Now.AddSeconds(30)

Write-Host "`n[V] DA KHOI DONG THANH CONG! BAT DAU VONG LAP GIAM SAT 24/7...`n" -ForegroundColor Green

while ($true) {
    Start-Sleep -Seconds 5
    $now = [DateTime]::Now

    # A. Doc link Cloudflare Tunnel moi tu Logfile (NON-BLOCKING)
    if (Test-Path $cfLogPath) {
        try {
            $lines = Get-Content -Path $cfLogPath -Tail 40 -ErrorAction SilentlyContinue
            foreach ($line in $lines) {
                if ($line -match "https://(?!(?:api|pkg|update)\.)[a-zA-Z0-9]+-[a-zA-Z0-9\-]+\.trycloudflare\.com") {
                    $found = $matches[0]
                    if ($found -ne $currentTunnelUrl) {
                        $currentTunnelUrl = $found
                        Write-Host "[+] Phat hien Cloudflare Tunnel URL moi: $currentTunnelUrl" -ForegroundColor Yellow
                        Push-UrlToGitHub $currentTunnelUrl
                    }
                    break
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
        $req.Timeout = 15000
        $req.ReadWriteTimeout = 15000
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
        Write-Host "[-] Canh bao: Agent khong phan hoi tai 127.0.0.1:$Port (Lan $agentFailCount/10)..." -ForegroundColor Yellow
        if ($agentFailCount -ge 10) {
            Write-Host "[!] AGENT BI TREO HOAC MAT KET NOI (50s)! Tu dong reset Agent..." -ForegroundColor Red
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
                Write-Host "[*] [Auto-RAM-Trim] Da toi uu hoa RAM cho $trimmedCount tien trinh game javaw.exe" -ForegroundColor Green
            }
        } catch {}
    }

    # F. Tu dong kiem tra va khoi dong 2 Acc Game (moi 60 giay)
    if (($now - $lastGameCheckTime).TotalSeconds -ge 60) {
        $lastGameCheckTime = $now
        $gameScript = "C:\Users\Administrator\Desktop\Chay_2_Acc.bat"
        $javawCount = @(Get-Process javaw -ErrorAction SilentlyContinue).Count
        if ($javawCount -lt 2 -and (Test-Path $gameScript)) {
            Write-Host "[*] [Game-Watchdog] Phat hien chi co $javawCount / 2 acc dang chay -> Tu dong khoi chay Chay_2_Acc.bat..." -ForegroundColor Cyan
            Start-Process "cmd.exe" -ArgumentList "/c `"$gameScript`"" -WindowStyle Minimized
            $lastGameCheckTime = [DateTime]::Now.AddSeconds(45)
        }
    }
}
