param(
    [int]$Port = 8765,
    [string]$Token = "tinhlinh_vps_secret_key_2026"
)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls

# 1. AUTO-UPGRADE MCP_DAEMON.PS1 TU GITHUB VA RESTART NEU CO BAN MOI
try {
    $daemonFile = Join-Path $PSScriptRoot "MCP_Daemon.ps1"
    $wcSync = New-Object System.Net.WebClient
    $wcSync.Headers.Add("User-Agent", "Antigravity-Sync")
    $newDaemonCode = $wcSync.DownloadString("https://raw.githubusercontent.com/gaxin488-rgb/h5test/main/MCP_Daemon.ps1")
    if ($newDaemonCode -and $newDaemonCode.Length -gt 1000 -and $newDaemonCode.Contains("ANTIGRAVITY VPS MASTER WATCHDOG")) {
        $oldDaemonCode = if (Test-Path $daemonFile) { [System.IO.File]::ReadAllText($daemonFile) } else { "" }
        if ($oldDaemonCode.Trim() -ne $newDaemonCode.Trim()) {
            $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
            [System.IO.File]::WriteAllText($daemonFile, $newDaemonCode, $utf8NoBom)
            Write-Host "[*] [Auto-Sync] Da cap nhat MCP_Daemon.ps1 moi tu GitHub!" -ForegroundColor Green
            # Stop MCP_Daemon cu de Start_MCP_Daemon.bat tu dong nap ban moi sau 3s!
            Get-WmiObject Win32_Process | Where-Object {
                $_.Name -eq "powershell.exe" -and $_.ProcessId -ne $PID -and ($_.CommandLine -like "*MCP_Daemon.ps1*")
            } | ForEach-Object {
                Write-Host "[!] Dung tien trinh MCP_Daemon cu (PID $($_.ProcessId)) de nap ban moi..." -ForegroundColor Magenta
                try { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue } catch {}
            }
        }
    }
} catch {}

# 2. KHOI DONG HTTP LISTENER
$listener = New-Object System.Net.HttpListener
try {
    $listener.Prefixes.Add("http://127.0.0.1:$Port/")
    $listener.Prefixes.Add("http://localhost:$Port/")
    $listener.Start()
} catch {
    try {
        $listener.Prefixes.Clear()
        $listener.Prefixes.Add("http://*:$Port/")
        $listener.Start()
    } catch {
        $listener.Prefixes.Clear()
        $listener.Prefixes.Add("http://+:$Port/")
        $listener.Start()
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
            Send-JsonResponse $response 200 @{ ok = $true; status = "online"; time = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") }
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

                Send-JsonResponse $response 200 @{
                    ok = $true
                    data = @{
                        os = "Windows Server 2012 R2"
                        arch = $env:PROCESSOR_ARCHITECTURE
                        hostname = $env:COMPUTERNAME
                        time = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
                        disk_c_free_gb = $diskFreeGb
                    }
                }
                continue
            }


            if ($rawUrl -eq "/read_file") {
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

            if ($rawUrl -eq "/list_files") {
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

            if ($rawUrl -eq "/processes") {
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
