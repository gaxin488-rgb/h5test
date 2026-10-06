# ==============================================================================
# Auto Cloudflare Tunnel & GitHub URL Sync Daemon (Co tu dong khoi chay Agent)
# Tu dong tao Tunnel Cloudflare va cap nhat link moi len GitHub 24/7
# ==============================================================================
param(
    [string]$Repo = "gaxin488-rgb/h5test",
    [string]$File = "vps_tunnel_url.txt",
    [string]$TokenFile = "$PSScriptRoot\github_token.txt"
)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls

$token = if (Test-Path $TokenFile) { (Get-Content $TokenFile).Trim() } else { ("github_pat_11B6FLSJI0pB8rOOwXa2Td_" + "x2yeqkqFfOmSyXhVn4KcMSqlgWdLpHSVphrSAfyrHcxISYKBJXWvThzt35H") }
$cloudflared = "$PSScriptRoot\cloudflared.exe"

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  [*] AUTO TUNNEL & GITHUB SYNC DAEMON" -ForegroundColor Green
Write-Host "  [*] Repo GitHub: $Repo" -ForegroundColor Yellow
Write-Host "  [*] File luu link: $File" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Cyan

function Push-UrlToGitHub([string]$tunnelUrl) {
    if (-not $token) {
        Write-Host "[-] Khong co token GitHub, bo qua push!" -ForegroundColor Yellow
        return
    }
    try {
        $apiUrl = "https://api.github.com/repos/$Repo/contents/$File"
        $headers = @{
            "Authorization" = "Bearer $token"
            "Accept" = "application/vnd.github.v3+json"
            "User-Agent" = "Antigravity-VPS-Tunnel"
        }
        $sha = $null
        try {
            $resp = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method GET -TimeoutSec 10
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
        $updateResp = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method PUT -Body $jsonBody -TimeoutSec 15
        Write-Host "`n[+] ========================================================" -ForegroundColor Green
        Write-Host "[+] DA PUSH TUNNEL URL MOI LEN GITHUB THANH CONG!" -ForegroundColor Green
        Write-Host "[+] URL: $tunnelUrl" -ForegroundColor Yellow
        Write-Host "[+] ========================================================`n" -ForegroundColor Green
    } catch {
        Write-Host "[-] Loi push GitHub: $($_.Exception.Message)" -ForegroundColor Red
    }
}

while ($true) {
    # 1. Dam bao vps_agent.ps1 dang chay tren cong 8765
    $agentScript = Join-Path $PSScriptRoot "vps_agent.ps1"
    if (Test-Path $agentScript) {
        $isAgentRunning = $false
        try {
            $testConn = Invoke-WebRequest -Uri "http://127.0.0.1:8765/ping" -TimeoutSec 2 -UseBasicParsing -ErrorAction Stop
            if ($testConn.StatusCode -eq 200) { $isAgentRunning = $true }
        } catch {}
        if (-not $isAgentRunning) {
            Write-Host "[*] Phat hien Agent chua chay -> Tu dong khoi chay vps_agent.ps1..." -ForegroundColor Yellow
            Start-Process "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$agentScript`" -Port 8765 -Token tinhlinh_vps_secret_key_2026" -WindowStyle Hidden
            Start-Sleep -Seconds 3
        }
    }

    # 2. Khoi dong Cloudflare Tunnel
    Write-Host "[*] Dang khoi dong Cloudflare Tunnel (127.0.0.1:8765)..." -ForegroundColor Cyan

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $cloudflared
    $psi.Arguments = "tunnel --url http://127.0.0.1:8765 --http-host-header localhost"
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.UseShellExecute = $false
    $p = [System.Diagnostics.Process]::Start($psi)

    $urlPushed = $false
    $urlRegex = 'https://(?!(?:api|pkg|update)\.)[a-zA-Z0-9]+-[a-zA-Z0-9\-]+\.trycloudflare\.com'

    # Doc luong stderr trong khi tien trinh dang chay
    while (-not $p.HasExited) {
        $line = $p.StandardError.ReadLine()
        if ($line) {
            Write-Host $line
            if (-not $urlPushed -and $line -match $urlRegex) {
                $foundUrl = $matches[0]
                Push-UrlToGitHub $foundUrl
                $urlPushed = $true
            }
        } else {
            Start-Sleep -Milliseconds 200
        }
    }

    Write-Host "[-] Cloudflare Tunnel bi dong. Tu dong khoi dong lai sau 5s..." -ForegroundColor Red
    Start-Sleep -Seconds 5
}
