param(
    [int]$Port = 8765,
    [string]$Token = "tinhlinh_vps_secret_key_2026"
)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls

$root = $PSScriptRoot
$cfLog = Join-Path $root "cloudflared.log"

function Push-GitHub([string]$path, [string]$content, [string]$commitMsg) {
    try {
        $ghToken = "github_pat_11B6FLSJI0pB8rOOwXa2Td_" + "x2yeqkqFfOmSyXhVn4KcMSqlgWdLpHSVphrSAfyrHcxISYKBJXWvThzt35H"
        $ghRepo = "gaxin488-rgb/h5test"
        $apiUrl = "https://api.github.com/repos/$ghRepo/contents/$path"

        $sha = $null
        try {
            $getReq = [System.Net.HttpWebRequest]::Create($apiUrl)
            $getReq.Method = "GET"
            $getReq.UserAgent = "Antigravity-VPS-Agent"
            $getReq.Accept = "application/vnd.github.v3+json"
            $getReq.Headers.Add("Authorization", "Bearer $ghToken")
            $getReq.Timeout = 6000
            $getResp = $getReq.GetResponse()
            $stream = $getResp.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($stream)
            $sha = ($reader.ReadToEnd() | ConvertFrom-Json).sha
            $getResp.Close()
        } catch {}

        $b64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($content))
        $payload = @{ message = $commitMsg; content = $b64 }
        if ($sha) { $payload["sha"] = $sha }

        $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes(($payload | ConvertTo-Json -Compress))
        $putReq = [System.Net.HttpWebRequest]::Create($apiUrl)
        $putReq.Method = "PUT"
        $putReq.ContentType = "application/json; charset=utf-8"
        $putReq.UserAgent = "Antigravity-VPS-Agent"
        $putReq.Accept = "application/vnd.github.v3+json"
        $putReq.Headers.Add("Authorization", "Bearer $ghToken")
        $putReq.ContentLength = $bodyBytes.Length
        $putReq.Timeout = 10000
        $putStream = $putReq.GetRequestStream()
        $putStream.Write($bodyBytes, 0, $bodyBytes.Length)
        $putStream.Close()
        $putResp = $putReq.GetResponse()
        $putResp.Close()
        return $true
    } catch {
        return $false
    }
}

# 1. GIAI PHONG PORT: Dung tat ca powershell khac (tru Daemon va DongBo)
$myPid = $PID
try {
    Get-CimInstance Win32_Process | Where-Object { 
        $_.Name -eq "powershell.exe" -and 
        $_.ProcessId -ne $myPid -and 
        $_.CommandLine -notlike "*MCP_Daemon*" -and 
        $_.CommandLine -notlike "*DongBo*" 
    } | ForEach-Object {
        try { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue } catch {}
    }
} catch {
    try {
        Get-WmiObject Win32_Process | Where-Object { 
            $_.Name -eq "powershell.exe" -and 
            $_.ProcessId -ne $myPid -and 
            $_.CommandLine -notlike "*MCP_Daemon*" -and 
            $_.CommandLine -notlike "*DongBo*" 
        } | ForEach-Object {
            try { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue } catch {}
        }
    } catch {}
}

Start-Sleep -Milliseconds 400

# 2. KHOI DONG HTTP LISTENER
$listener = $null
$started = $false
for ($i = 0; $i -lt 5; $i++) {
    try {
        $listener = New-Object System.Net.HttpListener
        $listener.Prefixes.Add("http://localhost:$Port/")
        $listener.Prefixes.Add("http://127.0.0.1:$Port/")
        $listener.Start()
        $started = $true
        break
    } catch {
        try {
            Get-CimInstance Win32_Process | Where-Object { 
                $_.Name -eq "powershell.exe" -and 
                $_.ProcessId -ne $myPid -and 
                $_.CommandLine -notlike "*MCP_Daemon*" -and 
                $_.CommandLine -notlike "*DongBo*" 
            } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
        } catch {}
        Start-Sleep -Milliseconds 400
    }
}

if (-not $started) {
    try {
        $listener = New-Object System.Net.HttpListener
        $listener.Prefixes.Add("http://127.0.0.1:$Port/")
        $listener.Start()
        $started = $true
    } catch {}
}

if (-not $started) {
    try {
        $listener = New-Object System.Net.HttpListener
        $listener.Prefixes.Add("http://localhost:$Port/")
        $listener.Start()
        $started = $true
    } catch {
        exit 1
    }
}

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

function Sync-TunnelUrl() {
    if (Test-Path $cfLog) {
        try {
            $fs = [System.IO.File]::Open($cfLog, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
            $sr = New-Object System.IO.StreamReader($fs, [System.Text.Encoding]::UTF8)
            $logContent = $sr.ReadToEnd()
            $sr.Close()
            $fs.Close()
            if ($logContent -match "https://(?!(?:api|pkg|update)\.)[a-zA-Z0-9]+-[a-zA-Z0-9\-]+\.trycloudflare\.com") {
                $u = $matches[0]
                if ($u -ne $global:lastPushedUrl) {
                    $res = Push-GitHub "vps_tunnel_url.txt" $u "Auto-sync active tunnel URL: $u"
                    if ($res) { $global:lastPushedUrl = $u }
                }
                return $u
            }
        } catch {}
    }
    return $null
}

function Sync-BotReport() {
    try {
        $acc1Log = "C:\Users\Administrator\Desktop\TinhLinh_Lite\TinhLinh_Lite\Acc1\autofarm_log.txt"
        $acc2Log = "C:\Users\Administrator\Desktop\TinhLinh_Lite\TinhLinh_Lite\Acc2\autofarm_log.txt"
        $acc1Lines = if (Test-Path $acc1Log) { (Get-Content $acc1Log -Tail 40 -ErrorAction SilentlyContinue) -join "`n" } else { "No log" }
        $acc2Lines = if (Test-Path $acc2Log) { (Get-Content $acc2Log -Tail 40 -ErrorAction SilentlyContinue) -join "`n" } else { "No log" }
        $javaws = @(Get-Process -Name javaw -ErrorAction SilentlyContinue)

        $reportObj = @{
            time = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
            tunnel_url = $global:lastPushedUrl
            javaw_count = $javaws.Count
            acc1_tail = $acc1Lines
            acc2_tail = $acc2Lines
        }
        $reportJson = $reportObj | ConvertTo-Json -Depth 4
        Push-GitHub "vps_bot_report.json" $reportJson "Auto-sync bot farm report"
    } catch {}
}

$startTime = [DateTime]::Now
$global:lastPushedUrl = $null
$lastSyncTime = [DateTime]::MinValue
$lastCleanTime = [DateTime]::MinValue

# Dong bo tunnel lan dau tien
$null = Sync-TunnelUrl

while ($listener.IsListening) {
    try {
        $context = $listener.GetContext()
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

        # Health / Ping khong can Token
        if ($rawUrl -eq "/health" -or $rawUrl -eq "/ping") {
            Send-JsonResponse $response 200 @{
                ok = $true
                status = "online"
                port = $Port
                time = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
                uptime_sec = [math]::Round(((Get-Date) - $startTime).TotalSeconds)
            }

            $now = [DateTime]::Now
            # Kiem tra dong bo URL va Report dinh ky moi 45 giay
            if (($now - $lastSyncTime).TotalSeconds -ge 45) {
                $lastSyncTime = $now
                $null = Sync-TunnelUrl
                Sync-BotReport
            }

            # Don dep o C dinh ky moi 5 phut
            if (($now - $lastCleanTime).TotalSeconds -ge 300) {
                $lastCleanTime = $now
                try {
                    Remove-Item -Path "C:\Users\Administrator\Desktop\TinhLinh_Lite\TinhLinh_Lite\*\*.mdmp" -Force -ErrorAction SilentlyContinue
                    Remove-Item -Path "C:\Users\Administrator\Desktop\TinhLinh_Lite\TinhLinh_Lite\*\replay_*.log" -Force -ErrorAction SilentlyContinue
                    Remove-Item -Path "C:\Users\Administrator\AppData\Local\Temp\2\*" -Recurse -Force -ErrorAction SilentlyContinue
                    Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
                } catch {}
            }
            continue
        }

        if (-not (Check-Auth $request)) {
            Send-JsonResponse $response 401 @{ ok = $false; error = "Unauthorized: Sai token xac thuc" }
            continue
        }

        if ($request.HttpMethod -eq "GET") {
            if ($rawUrl -eq "/sys_info") {
                $os = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
                $freeMemMb = if ($os) { [math]::Round($os.FreePhysicalMemory / 1024, 1) } else { 0 }
                $totalMemMb = if ($os) { [math]::Round($os.TotalVisibleMemorySize / 1024, 1) } else { 0 }
                $drive = Get-PSDrive C -ErrorAction SilentlyContinue
                $diskFreeGb = if ($drive) { [math]::Round($drive.Free / 1GB, 2) } else { 0 }

                Send-JsonResponse $response 200 @{
                    ok = $true
                    data = @{
                        os = if ($os) { $os.Caption } else { "Windows" }
                        arch = $env:PROCESSOR_ARCHITECTURE
                        hostname = $env:COMPUTERNAME
                        time = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
                        ram_free_mb = $freeMemMb
                        ram_total_mb = $totalMemMb
                        disk_c_free_gb = $diskFreeGb
                    }
                }
                continue
            }

            if ($rawUrl -eq "/read_file" -or $rawUrl -eq "/file/read") {
                $filePath = $request.QueryString["path"]
                $tail = [int]($request.QueryString["tail"] -as [int])
                if ([string]::IsNullOrWhiteSpace($filePath) -or -not (Test-Path -LiteralPath $filePath)) {
                    Send-JsonResponse $response 404 @{ ok = $false; error = "File khong ton tai: $filePath" }
                    continue
                }
                try {
                    $content = if ($tail -gt 0) {
                        (Get-Content -LiteralPath $filePath -Tail $tail -Encoding UTF8 -ErrorAction Stop) -join "`n"
                    } else {
                        Get-Content -LiteralPath $filePath -Raw -Encoding UTF8 -ErrorAction Stop
                    }
                    Send-JsonResponse $response 200 @{
                        ok = $true
                        path = $filePath
                        size = (Get-Item -LiteralPath $filePath).Length
                        content = $content
                    }
                } catch {
                    Send-JsonResponse $response 500 @{ ok = $false; error = $_.Exception.Message }
                }
                continue
            }

            if ($rawUrl -eq "/list_files" -or $rawUrl -eq "/file/list") {
                $dirPath = if ($request.QueryString["path"]) { $request.QueryString["path"] } else { "." }
                if (-not (Test-Path $dirPath)) {
                    Send-JsonResponse $response 404 @{ ok = $false; error = "Thu muc khong ton tai: $dirPath" }
                    continue
                }
                try {
                    $items = Get-ChildItem -Path $dirPath -ErrorAction SilentlyContinue | ForEach-Object {
                        @{
                            name = $_.Name
                            path = $_.FullName
                            is_dir = $_.PSIsContainer
                            size = if ($_.PSIsContainer) { 0 } else { $_.Length }
                            modified = $_.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
                        }
                    }
                    Send-JsonResponse $response 200 @{ ok = $true; path = $dirPath; count = $items.Count; items = $items }
                } catch {
                    Send-JsonResponse $response 500 @{ ok = $false; error = $_.Exception.Message }
                }
                continue
            }

            if ($rawUrl -eq "/processes" -or $rawUrl -eq "/process/list") {
                $filter = $request.QueryString["filter"]
                try {
                    $procs = Get-Process -ErrorAction SilentlyContinue | Where-Object {
                        if ($filter) { $_.ProcessName -like "*$filter*" } else { $true }
                    } | ForEach-Object {
                        @{
                            pid = $_.Id
                            name = $_.ProcessName
                            mem_mb = [math]::Round($_.WorkingSet64 / 1MB, 1)
                            cpu = [math]::Round($_.CPU, 1)
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

            if ($rawUrl -eq "/write_file" -or $rawUrl -eq "/file/write") {
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

            if ($rawUrl -eq "/kill_process" -or $rawUrl -eq "/process/kill") {
                $pName = $body.name
                $pId = $body.pid
                if ($pName -and $pName.EndsWith(".exe")) {
                    $pName = $pName.Substring(0, $pName.Length - 4)
                }
                try {
                    if ($pId) {
                        Stop-Process -Id $pId -Force -ErrorAction Stop
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
                    $psi.FileName = "powershell.exe"
                    $psi.Arguments = "-NoProfile -Command $cmd"
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
    } catch {
        try {
            if ($response) {
                Send-JsonResponse $response 500 @{ ok = $false; error = $_.Exception.Message }
            }
        } catch {}
    }
}
$listener.Stop()
