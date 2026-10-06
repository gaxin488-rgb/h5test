param(
    [int]$Port = 8765,
    [string]$Token = "tinhlinh_vps_secret_key_2026"
)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls

# 1. DUNG TAT CA TIEN TRINH POWERSHELL KHAC DE GIAI PHONG PORT 8765 VA KET THUC VONG LAP DAEMON CU
try {
    Get-Process powershell -ErrorAction SilentlyContinue | Where-Object { $_.Id -ne $PID } | ForEach-Object {
        Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
    }
} catch {}
Start-Sleep -Milliseconds 600

# 2. HAM PUSH FILE LEN GITHUB
function Push-GitHubFile([string]$path, [string]$content, [string]$msg) {
    try {
        $ghToken = "github_pat_11B6FLSJI0pB8rOOwXa2Td_" + "x2yeqkqFfOmSyXhVn4KcMSqlgWdLpHSVphrSAfyrHcxISYKBJXWvThzt35H"
        $apiUrl = "https://api.github.com/repos/gaxin488-rgb/h5test/contents/$path"
        $headers = @{
            "Authorization" = "Bearer $ghToken"
            "Accept"        = "application/vnd.github.v3+json"
            "User-Agent"    = "Antigravity-Master"
        }
        $sha = $null
        try {
            $resp = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method GET -TimeoutSec 6
            $sha = $resp.sha
        } catch {}

        $b64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($content))
        $body = @{ message = $msg; content = $b64 }
        if ($sha) { $body["sha"] = $sha }
        $jsonBody = $body | ConvertTo-Json
        $null = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method PUT -Body $jsonBody -ContentType "application/json" -TimeoutSec 10
    } catch {}
}

# 3. KHOI DONG HTTP LISTENER
$listener = New-Object System.Net.HttpListener
try { $listener.Prefixes.Add("http://localhost:$Port/") } catch {}
try { $listener.Prefixes.Add("http://127.0.0.1:$Port/") } catch {}
try { $listener.Prefixes.Add("http://[::1]:$Port/") } catch {}

try {
    $listener.Start()
} catch {
    try {
        $listener = New-Object System.Net.HttpListener
        $listener.Prefixes.Add("http://localhost:$Port/")
        $listener.Start()
    } catch {
        try {
            $listener = New-Object System.Net.HttpListener
            $listener.Prefixes.Add("http://127.0.0.1:$Port/")
            $listener.Start()
        } catch {
            Push-GitHubFile "agent_status.txt" "Failed to start listener on port $Port at $(Get-Date)" "Agent start failure"
            exit 1
        }
    }
}

Push-GitHubFile "agent_status.txt" "Master Agent ONLINE on PID $PID, Port $Port at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" "Master Agent Online"

# 4. KHOI DONG CLOUDFLARE TUNNEL
$cloudflared = Join-Path $PSScriptRoot "cloudflared.exe"
if (-not (Test-Path $cloudflared)) {
    $cloudflared = "C:\Users\Administrator\Desktop\remote-vps-mcp\cloudflared.exe"
}
$cfLog = Join-Path $PSScriptRoot "cloudflared.log"

function Start-Cloudflared() {
    if (-not (Test-Path $cloudflared)) { return $null }
    try { Stop-Process -Name "cloudflared" -Force -ErrorAction SilentlyContinue } catch {}
    Start-Sleep -Milliseconds 400
    try { Remove-Item $cfLog -Force -ErrorAction SilentlyContinue } catch {}

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "cmd.exe"
    $psi.Arguments = "/c `"`"$cloudflared`" tunnel --url http://127.0.0.1:$Port 2> `"$cfLog`"`""
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    return [System.Diagnostics.Process]::Start($psi)
}

$cfProc = Start-Cloudflared
$currentTunnelUrl = $null

function Send-JsonResponse($response, [int]$statusCode, $obj) {
    try {
        $json = $obj | ConvertTo-Json -Depth 5 -Compress
        $buffer = [System.Text.Encoding]::UTF8.GetBytes($json)
        $response.StatusCode = $statusCode
        $response.ContentType = "application/json; charset=utf-8"
        try { $response.ContentLength64 = $buffer.Length } catch {}
        try { $response.AddHeader("Access-Control-Allow-Origin", "*") } catch {}
        $response.OutputStream.Write($buffer, 0, $buffer.Length)
    } catch {}
    finally {
        try { $response.Close() } catch {}
    }
}

function Check-Auth($request) {
    $hdr = $request.Headers["X-Agent-Token"]
    if ($hdr -eq $Token) { return $true }
    $auth = $request.Headers["Authorization"]
    if ($auth -and $auth.StartsWith("Bearer ") -and $auth.Substring(7) -eq $Token) { return $true }
    $query = $request.QueryString["token"]
    if ($query -eq $Token) { return $true }
    return $false
}

$lastGameCheck = [DateTime]::MinValue
$lastCleanup = [DateTime]::MinValue
$startTime = [DateTime]::Now

# VONG LAP XU LY HTTP REQUEST + GIAM SAT 24/7 (NON-BLOCKING)
while ($listener.IsListening) {
    $asyncContext = $listener.BeginGetContext($null, $null)
    $hasRequest = $asyncContext.AsyncWaitHandle.WaitOne(2000)

    if ($hasRequest) {
        try {
            $context = $listener.EndGetContext($asyncContext)
            $request = $context.Request
            $response = $context.Response
            $rawUrl = $request.Url.AbsolutePath

            if ($request.HttpMethod -eq "OPTIONS") {
                $response.StatusCode = 200
                $response.AddHeader("Access-Control-Allow-Origin", "*")
                $response.AddHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
                $response.AddHeader("Access-Control-Allow-Headers", "Content-Type, X-Agent-Token, Authorization")
                $response.Close()
                continue
            }

            if ($rawUrl -eq "/health" -or $rawUrl -eq "/ping") {
                Send-JsonResponse $response 200 @{
                    ok = $true
                    status = "online"
                    port = $Port
                    time = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
                    uptime_sec = [math]::Round(((Get-Date) - $startTime).TotalSeconds)
                }
                continue
            }

            if (-not (Check-Auth $request)) {
                Send-JsonResponse $response 401 @{ ok = $false; error = "Unauthorized: Sai token xac thuc" }
                continue
            }

            if ($request.HttpMethod -eq "GET") {
                if ($rawUrl -eq "/sys_info") {
                    $drive = Get-PSDrive C -ErrorAction SilentlyContinue
                    $diskFreeGb = if ($drive) { [math]::Round($drive.Free / 1GB, 2) } else { 0 }
                    $diskTotalGb = if ($drive) { [math]::Round(($drive.Used + $drive.Free) / 1GB, 2) } else { 0 }
                    Send-JsonResponse $response 200 @{
                        ok = $true
                        os = (Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue).Caption
                        cpu_cores = $env:NUMBER_OF_PROCESSORS
                        ram_free_mb = [math]::Round((Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue).FreePhysicalMemory / 1024, 0)
                        disk_c_free_gb = $diskFreeGb
                        disk_c_total_gb = $diskTotalGb
                        time = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
                    }
                    continue
                }

                if ($rawUrl -eq "/read_file") {
                    $filePath = $request.QueryString["path"]
                    $tail = $request.QueryString["tail"]
                    if (-not $filePath) {
                        Send-JsonResponse $response 400 @{ ok = $false; error = "Thieu tham so path" }
                        continue
                    }
                    if (-not (Test-Path $filePath)) {
                        Send-JsonResponse $response 404 @{ ok = $false; error = "File khong ton tai: $filePath" }
                        continue
                    }
                    try {
                        $content = ""
                        if ($tail) {
                            $tailN = [int]$tail
                            $lines = Get-Content $filePath -Tail $tailN -Encoding UTF8 -ErrorAction SilentlyContinue
                            $content = ($lines -join "`n")
                        } else {
                            $fs = [System.IO.File]::Open($filePath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
                            $sr = New-Object System.IO.StreamReader($fs, [System.Text.Encoding]::UTF8)
                            $content = $sr.ReadToEnd()
                            $sr.Close()
                            $fs.Close()
                        }
                        Send-JsonResponse $response 200 @{
                            ok = $true
                            path = $filePath
                            size = (Get-Item $filePath).Length
                            content = $content
                        }
                    } catch {
                        Send-JsonResponse $response 500 @{ ok = $false; error = $_.Exception.Message }
                    }
                    continue
                }

                if ($rawUrl -eq "/list_files") {
                    $dirPath = $request.QueryString["path"]
                    if (-not $dirPath) { $dirPath = "C:\Users\Administrator\Desktop" }
                    if (-not (Test-Path $dirPath)) {
                        Send-JsonResponse $response 404 @{ ok = $false; error = "Thu muc khong ton tai: $dirPath" }
                        continue
                    }
                    try {
                        $items = Get-ChildItem -Path $dirPath -ErrorAction Stop | ForEach-Object {
                            @{
                                name = $_.Name
                                is_dir = $_.PSIsContainer
                                size = if ($_.PSIsContainer) { 0 } else { $_.Length }
                                last_modified = $_.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
                            }
                        }
                        Send-JsonResponse $response 200 @{ ok = $true; path = $dirPath; count = $items.Count; items = $items }
                    } catch {
                        Send-JsonResponse $response 500 @{ ok = $false; error = $_.Exception.Message }
                    }
                    continue
                }

                if ($rawUrl -eq "/process_list") {
                    $filter = $request.QueryString["filter"]
                    try {
                        $procs = Get-Process -ErrorAction SilentlyContinue | Where-Object {
                            if ($filter) { $_.ProcessName -like "*$filter*" } else { $true }
                        } | ForEach-Object {
                            $cpuVal = 0.0
                            try { if ($_.CPU -ne $null) { $cpuVal = [math]::Round([double]$_.CPU, 1) } } catch {}
                            @{
                                pid = $_.Id
                                name = $_.ProcessName
                                mem_mb = [math]::Round($_.WorkingSet64 / 1MB, 1)
                                cpu = $cpuVal
                            }
                        }
                        Send-JsonResponse $response 200 @{ ok = $true; count = $procs.Count; processes = $procs }
                    } catch {
                        Send-JsonResponse $response 500 @{ ok = $false; error = $_.Exception.Message }
                    }
                    continue
                }
            }

            if ($request.HttpMethod -eq "POST") {
                $reader = New-Object System.IO.StreamReader($request.InputStream, [System.Text.Encoding]::UTF8)
                $bodyStr = $reader.ReadToEnd()
                $body = if ($bodyStr) { $bodyStr | ConvertFrom-Json } else { @{} }

                if ($rawUrl -eq "/exec") {
                    $cmd = $body.cmd
                    $timeoutSec = if ($body.timeout) { [int]$body.timeout } else { 30 }
                    if (-not $cmd) {
                        Send-JsonResponse $response 400 @{ ok = $false; error = "Thieu cmd" }
                        continue
                    }
                    try {
                        $sw = [System.Diagnostics.Stopwatch]::StartNew()
                        $tempOut = [System.IO.Path]::GetTempFileName()
                        $tempErr = [System.IO.Path]::GetTempFileName()
                        $psi = New-Object System.Diagnostics.ProcessStartInfo
                        $psi.FileName = "cmd.exe"
                        $psi.Arguments = "/c `"$cmd > `"$tempOut`" 2> `"$tempErr`"`""
                        $psi.UseShellExecute = $false
                        $psi.CreateNoWindow = $true
                        $p = [System.Diagnostics.Process]::Start($psi)
                        $finished = $p.WaitForExit($timeoutSec * 1000)
                        if ($finished) {
                            $exitCode = $p.ExitCode
                            Start-Sleep -Milliseconds 50
                            $stdout = if (Test-Path $tempOut) { [System.IO.File]::ReadAllText($tempOut, [System.Text.Encoding]::Default) } else { "" }
                            $stderr = if (Test-Path $tempErr) { [System.IO.File]::ReadAllText($tempErr, [System.Text.Encoding]::Default) } else { "" }
                        } else {
                            try { $p.Kill() } catch {}
                            $stdout = ""
                            $stderr = "Lenh timeout sau $timeoutSec giay!"
                            $exitCode = 124
                        }
                        try { Remove-Item $tempOut -Force -ErrorAction SilentlyContinue } catch {}
                        try { Remove-Item $tempErr -Force -ErrorAction SilentlyContinue } catch {}
                        $sw.Stop()
                        Send-JsonResponse $response 200 @{
                            ok = ($exitCode -eq 0)
                            exit_code = $exitCode
                            stdout = $stdout
                            stderr = $stderr
                            duration_ms = $sw.ElapsedMilliseconds
                        }
                    } catch {
                        Send-JsonResponse $response 200 @{
                            ok = $false
                            exit_code = 1
                            stdout = ""
                            stderr = $_.Exception.Message
                        }
                    }
                    continue
                }

                if ($rawUrl -eq "/write_file") {
                    $filePath = $body.path
                    $content = $body.content
                    $append = [bool]$body.append
                    if (-not $filePath) {
                        Send-JsonResponse $response 400 @{ ok = $false; error = "Thieu path" }
                        continue
                    }
                    try {
                        $dir = Split-Path $filePath -Parent
                        if ($dir -and -not (Test-Path $dir)) {
                            New-Item -ItemType Directory -Path $dir -Force | Out-Null
                        }
                        $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
                        if ($append) {
                            [System.IO.File]::AppendAllText($filePath, $content, $utf8NoBom)
                        } else {
                            [System.IO.File]::WriteAllText($filePath, $content, $utf8NoBom)
                        }
                        Send-JsonResponse $response 200 @{
                            ok = $true
                            path = $filePath
                            size = (Get-Item $filePath).Length
                            action = if ($append) { "appended" } else { "written" }
                        }
                    } catch {
                        Send-JsonResponse $response 500 @{ ok = $false; error = $_.Exception.Message }
                    }
                    continue
                }

                if ($rawUrl -eq "/kill_process") {
                    $pName = $body.name
                    $targetPid = [int]$body.pid
                    if ($pName -and $pName.EndsWith(".exe")) {
                        $pName = $pName.Substring(0, $pName.Length - 4)
                    }
                    try {
                        if ($targetPid) {
                            Stop-Process -Id $targetPid -Force -ErrorAction Stop
                        } elseif ($pName) {
                            Stop-Process -Name $pName -Force -ErrorAction Stop
                        } else {
                            Send-JsonResponse $response 400 @{ ok = $false; error = "Thieu pid hoac name" }
                            continue
                        }
                        Send-JsonResponse $response 200 @{ ok = $true; message = "Da dung tien trinh thanh cong" }
                    } catch {
                        Send-JsonResponse $response 200 @{ ok = $false; error = $_.Exception.Message }
                    }
                    continue
                }

                if ($rawUrl -eq "/start_process") {
                    $cmd = $body.cmd
                    $cwd = $body.cwd
                    try {
                        $psi = New-Object System.Diagnostics.ProcessStartInfo
                        $psi.FileName = "cmd.exe"
                        $psi.Arguments = "/c `"$cmd`""
                        if ($cwd) { $psi.WorkingDirectory = $cwd }
                        $psi.UseShellExecute = $true
                        $p = [System.Diagnostics.Process]::Start($psi)
                        Send-JsonResponse $response 200 @{ ok = $true; pid = $p.Id; message = "Da khoi dong tien trinh (PID=$($p.Id))" }
                    } catch {
                        Send-JsonResponse $response 500 @{ ok = $false; error = $_.Exception.Message }
                    }
                    continue
                }

                if ($rawUrl -eq "/rdp_keepalive") {
                    try {
                        $results = @()
                        foreach ($sId in 1..3) {
                            $res = & "$env:windir\System32\tscon.exe" $sId /dest:console 2>&1 | Out-String
                            $results += ("tscon " + $sId + ": " + $res)
                        }
                        Send-JsonResponse $response 200 @{
                            ok = $true
                            tscon_results = $results
                            message = "Da chuyen phien RDP ve Console vat ly thanh cong!"
                        }
                    } catch {
                        Send-JsonResponse $response 500 @{ ok = $false; error = $_.Exception.Message }
                    }
                    continue
                }
            }

            Send-JsonResponse $response 404 @{ ok = $false; error = "Endpoint khong ton tai: $rawUrl" }
        } catch {}
    }

    # 5. CONG VIEC DINH KY 24/7 (KHI KHONG CO REQUEST)
    $now = [DateTime]::Now

    # A. Doc link Cloudflare Tunnel moi tu Logfile
    if (Test-Path $cfLog) {
        try {
            $fs = [System.IO.File]::Open($cfLog, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
            $sr = New-Object System.IO.StreamReader($fs, [System.Text.Encoding]::UTF8)
            $txt = $sr.ReadToEnd()
            $sr.Close(); $fs.Close()
            if ($txt -match "https://(?!(?:api|pkg|update)\.)[a-zA-Z0-9]+-[a-zA-Z0-9\-]+\.trycloudflare\.com") {
                $foundUrl = $matches[0]
                if ($foundUrl -ne $currentTunnelUrl) {
                    $currentTunnelUrl = $foundUrl
                    Push-GitHubFile "vps_tunnel_url.txt" $currentTunnelUrl "Update tunnel URL: $currentTunnelUrl"
                }
            }
        } catch {}
    }

    # B. Kiem tra tien trinh Cloudflare Tunnel
    if ($null -eq $cfProc -or $cfProc.HasExited) {
        $cfProc = Start-Cloudflared
    }

    # C. Giam sat 2 Acc Game Tinh Linh moi 60s
    if (($now - $lastGameCheck).TotalSeconds -ge 60) {
        $lastGameCheck = $now
        try {
            $javawCount = @(Get-Process javaw -ErrorAction SilentlyContinue).Count
            if ($javawCount -lt 2) {
                $gameScript = "C:\Users\Administrator\Desktop\Chay_2_Acc.bat"
                if (Test-Path $gameScript) {
                    Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$gameScript`"" -WindowStyle Minimized
                }
            }
        } catch {}
    }

    # D. Don dep crash dump moi 3 phut
    if (($now - $lastCleanup).TotalSeconds -ge 180) {
        $lastCleanup = $now
        try {
            Remove-Item -Path "C:\Users\Administrator\Desktop\TinhLinh_Lite\TinhLinh_Lite\*\*.mdmp" -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "C:\Users\Administrator\Desktop\TinhLinh_Lite\TinhLinh_Lite\*\replay_*.log" -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "C:\Users\Administrator\AppData\Local\Temp\2\*" -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
        } catch {}
    }
}
