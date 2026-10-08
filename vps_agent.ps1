# ==============================================================================
# TINHLINH VPS AGENT - 100% IN-MEMORY RUNTIME (ZERO DISK LOGS / ZERO INTERMEDIATE)
# Runs HTTP Server on 8765, Cloudflare Tunnel & Storage Guard 24/7 without disk wear
# ==============================================================================
[CmdletBinding()]
param(
    [int]$Port = 8765,
    [string]$Token = "tinhlinh_vps_secret_key_2026",
    [string]$Repo = "gaxin488-rgb/h5test",
    [string]$Branch = "main"
)

$ErrorActionPreference = "SilentlyContinue"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$Dir = Split-Path -Parent $MyInvocation.MyCommand.Definition
if (-not $Dir) { $Dir = "C:\TinhLinh" }
$CloudflaredPath = Join-Path $Dir "cloudflared.exe"
$GithubToken = [Environment]::GetEnvironmentVariable("TINHLINH_GITHUB_TOKEN", "Machine")
if (-not $GithubToken) { $GithubToken = [Environment]::GetEnvironmentVariable("TINHLINH_GITHUB_TOKEN", "Process") }

$global:LatestTunnelUrl = ""
$script:TunnelProbeFailures = 0
$script:AgentMutex = New-Object -TypeName System.Threading.Mutex -ArgumentList @($false, "Global\TinhLinhAgent8765")
try {
    if (-not $script:AgentMutex.WaitOne(0)) { exit 0 }
} catch [System.Threading.AbandonedMutexException] {}

function Write-Log([string]$msg) {
    Write-Host "[$((Get-Date).ToString('HH:mm:ss'))] $msg"
}

function Send-Response($res, [int]$code, $obj) {
    try {
        $json = $obj | ConvertTo-Json -Depth 6 -Compress
        $bytes = [Text.Encoding]::UTF8.GetBytes($json)
        $res.StatusCode = $code
        $res.ContentType = "application/json; charset=utf-8"
        $res.ContentLength64 = $bytes.Length
        $res.AddHeader("Access-Control-Allow-Origin", "*")
        $res.OutputStream.Write($bytes, 0, $bytes.Length)
    } catch {} finally {
        try { $res.Close() } catch {}
    }
}

function Get-Body($req) {
    if (-not $req.HasEntityBody) { return @{} }
    $reader = New-Object IO.StreamReader($req.InputStream, [Text.Encoding]::UTF8)
    try {
        $raw = $reader.ReadToEnd()
        if ($raw) { return ($raw | ConvertFrom-Json) }
        return @{}
    } finally {
        $reader.Dispose()
    }
}

function Optimize-MemoryAndPagefile {
    try {
        [GC]::Collect()
        [GC]::WaitForPendingFinalizers()
        Get-Process javaw, powershell, cloudflared -ErrorAction SilentlyContinue | ForEach-Object {
            try {
                $_.MinWorkingSet = [IntPtr]::Zero
                $_.MaxWorkingSet = [IntPtr]::Zero
            } catch {}
        }
    } catch {}
}

function Exec-Cmd([string]$cmd, [int]$timeout = 30) {
    try {
        $psi = New-Object Diagnostics.ProcessStartInfo
        $psi.FileName = "powershell.exe"
        $encodedCommand = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($cmd))
        $psi.Arguments = "-NoProfile -NonInteractive -ExecutionPolicy Bypass -EncodedCommand $encodedCommand"
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $psi.UseShellExecute = $false
        $psi.CreateNoWindow = $true

        $p = [Diagnostics.Process]::Start($psi)
        $outTask = $p.StandardOutput.ReadToEndAsync()
        $errTask = $p.StandardError.ReadToEndAsync()

        $sw = [Diagnostics.Stopwatch]::StartNew()
        while (-not $p.HasExited -and ($sw.ElapsedMilliseconds -lt ($timeout * 1000))) {
            [Threading.Thread]::Sleep(100)
        }

        if ($p.HasExited) {
            [Threading.Tasks.Task]::WaitAll(@($outTask, $errTask), 1200) | Out-Null
            $stdout = if ($outTask.IsCompleted) { $outTask.Result } else { "" }
            $stderr = if ($errTask.IsCompleted) { $errTask.Result } else { "" }
            return @{ ok = ($p.ExitCode -eq 0); stdout = $stdout; stderr = $stderr; exit_code = $p.ExitCode }
        } else {
            try { $p.Kill() } catch {}
            $stdout = if ($outTask.IsCompleted) { $outTask.Result } else { "" }
            return @{ ok = $false; stdout = $stdout; stderr = "Command timeout sau ${timeout}s"; exit_code = 124 }
        }
    } catch {
        return @{ ok = $false; stdout = ""; stderr = "Exec exception: $($_.Exception.Message)"; exit_code = 1 }
    }
}

function Sync-TunnelUrl([string]$url) {
    if (-not $GithubToken) {
        Write-Log "GitHub URL sync skipped: TINHLINH_GITHUB_TOKEN is not configured."
        return
    }
    Write-Log "Syncing Tunnel URL to GitHub: $url"
    try {
        $apiUrl = "https://api.github.com/repos/$Repo/contents/vps_tunnel_url.txt"
        $headers = @{
            "Authorization" = "Bearer $GithubToken"
            "Accept" = "application/vnd.github+json"
            "User-Agent" = "TinhLinh-FreshAgent"
        }
        $sha = $null
        try {
            $cur = Invoke-RestMethod -Uri $apiUrl -Headers $headers -TimeoutSec 6
            $sha = $cur.sha
        } catch {}

        $body = @{
            message = "Update tunnel URL: $url"
            content = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($url))
            branch = $Branch
        }
        if ($sha) { $body.sha = $sha }
        Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Put -Body ($body | ConvertTo-Json -Compress) -ContentType "application/json" -TimeoutSec 10 | Out-Null
        Write-Log "GitHub sync successful: $url"
    } catch {
        Write-Log "GitHub sync error: $($_.Exception.Message)"
    }
}

function Update-AgentFromGithub {
    Write-Log "Kiem tra cap nhat Agent tu GitHub..."
    try {
        $rawUrl = "https://raw.githubusercontent.com/$Repo/$Branch/vps_agent.ps1"
        $wc = New-Object Net.WebClient
        $wc.Headers.Add("User-Agent", "TinhLinh-Agent-AutoUpdater")
        $newCode = $wc.DownloadString($rawUrl)
        if ($newCode -and $newCode.Contains("# TINHLINH VPS AGENT") -and ($newCode.Length -gt 2000)) {
            $curPath = Join-Path $Dir "vps_agent.ps1"
            $curCode = if (Test-Path $curPath) { [IO.File]::ReadAllText($curPath, [Text.Encoding]::UTF8) } else { "" }
            if ($newCode.Trim() -ne $curCode.Trim()) {
                Write-Log "Phat hien ban cap nhat moi tren GitHub! Dang tu dong cap nhat..."
                [IO.File]::WriteAllText($curPath, $newCode, [Text.Encoding]::UTF8)
                Write-Log "Khoi dong lai Agent voi ban moi..."
                Get-Process cloudflared -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
                try { if ($global:listener) { $global:listener.Stop(); $global:listener.Close() } } catch {}
                Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$curPath`"" -WorkingDirectory $Dir
                exit
            } else {
                Write-Log "Agent dang o phien ban moi nhat."
            }
        }
    } catch {
        Write-Log "Loi khi tu dong cap nhat Agent: $($_.Exception.Message)"
    }
}

function Start-TunnelProcess {
    if (-not (Test-Path $CloudflaredPath)) {
        Write-Log "WARNING: cloudflared.exe not found at $CloudflaredPath"
        return $null
    }
    # Dam bao khong co cloudflared cu chay trung lap gay xung dot route 502/530
    Get-Process cloudflared -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 300
    try {
        if ($script:CloudflaredEventPrefix) {
            foreach ($suffix in @("stdout", "stderr")) {
                $source = "$script:CloudflaredEventPrefix.$suffix"
                Unregister-Event -SourceIdentifier $source -ErrorAction SilentlyContinue
                Get-Job -Name $source -ErrorAction SilentlyContinue | Remove-Job -Force -ErrorAction SilentlyContinue
            }
        }

        $psi = New-Object Diagnostics.ProcessStartInfo
        $psi.FileName = $CloudflaredPath
        $psi.Arguments = "tunnel --no-autoupdate --url http://127.0.0.1:$Port --http-host-header localhost"
        $psi.WorkingDirectory = $Dir
        $psi.UseShellExecute = $false
        $psi.CreateNoWindow = $true
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true

        $proc = New-Object Diagnostics.Process
        $proc.StartInfo = $psi

        $script:CloudflaredEventPrefix = "TinhLinhCloudflared_$PID"
        $stdoutSource = "$script:CloudflaredEventPrefix.stdout"
        $stderrSource = "$script:CloudflaredEventPrefix.stderr"
        Register-ObjectEvent -InputObject $proc -EventName OutputDataReceived -SourceIdentifier $stdoutSource -Action {
            if ($EventArgs.Data -and $EventArgs.Data -match "(https://[a-zA-Z0-9-]+\.trycloudflare\.com)") {
                $global:LatestTunnelUrl = $Matches[1]
            }
        } | Out-Null

        Register-ObjectEvent -InputObject $proc -EventName ErrorDataReceived -SourceIdentifier $stderrSource -Action {
            if ($EventArgs.Data -and $EventArgs.Data -match "(https://[a-zA-Z0-9-]+\.trycloudflare\.com)") {
                $global:LatestTunnelUrl = $Matches[1]
            }
        } | Out-Null

        $global:LatestTunnelUrl = ""
        $null = $proc.Start()
        $proc.BeginOutputReadLine()
        $proc.BeginErrorReadLine()
        Write-Log "Cloudflare Tunnel launched in RAM (PID $($proc.Id))."

        # Cho toi da 15 giay de bat URL ban dau
        for ($i = 0; $i -lt 30; $i++) {
            if ($global:LatestTunnelUrl) { break }
            Start-Sleep -Milliseconds 500
        }
        if ($global:LatestTunnelUrl) {
            Write-Log "Tunnel URL detected on launch: $global:LatestTunnelUrl"
            Sync-TunnelUrl $global:LatestTunnelUrl
        }
        return $proc
    } catch {
        Write-Log "Failed to start cloudflared: $($_.Exception.Message)"
        return $null
    }
}

# 1. Khoi dong HttpListener voi DUAL-PREFIX (Tranh triet de loi HTTP 530)
$listener = New-Object Net.HttpListener
$listener.Prefixes.Add("http://127.0.0.1:$Port/")
$listener.Prefixes.Add("http://localhost:$Port/")
try { $listener.Prefixes.Add("http://+:$Port/") } catch {}
$listener.Start()
$global:listener = $listener
Write-Log "HttpListener online on 127.0.0.1:$Port and localhost:$Port."

# 2. Khoi dong Cloudflare Tunnel (100% RAM capture, zero intermediate files)
$cfProcess = Start-TunnelProcess
$task = $listener.GetContextAsync()
$lastClean = [DateTime]::MinValue
$lastUpdateCheck = Get-Date
$lastTunnelProbe = [DateTime]::MinValue
$lastTunnelUrl = ""

Write-Log "Entering main 24/7 loop (Zero disk logs, Auto-Updater enabled)..."

while ($listener.IsListening) {
    try {
        # A. Tu dong hoi sinh Cloudflare Tunnel neu bi ngat
        if (-not $cfProcess -or $cfProcess.HasExited) {
            Write-Log "Cloudflare exited or missing; auto-recovering..."
            $cfProcess = Start-TunnelProcess
        }

        # B. Xu ly HTTP Request bat dong bo
        if ($task.Wait(200)) {
            try {
                $context = $task.Result
                $task = $listener.GetContextAsync() # Don request tiep theo ngay

                $req = $context.Request
                $res = $context.Response
                $path = $req.Url.AbsolutePath

                # Auth check (tru /ping va /health)
                $tokenHeader = $req.Headers["X-Agent-Token"]
                $authHeader = $req.Headers["Authorization"]
                $isAuthed = ($tokenHeader -eq $Token) -or ($authHeader -eq "Bearer $Token") -or ($req.QueryString["token"] -eq $Token)

                if ($path -eq "/ping") {
                    Send-Response $res 200 @{ ok = $true; status = "online" }
                } elseif ($path -eq "/health") {
                    $free = [math]::Round(((Get-PSDrive C -ErrorAction SilentlyContinue).Free / 1GB), 2)
                    Send-Response $res 200 @{ ok = $true; status = "online"; disk_free_gb = $free }
                } elseif (-not $isAuthed) {
                    Send-Response $res 401 @{ ok = $false; error = "Unauthorized" }
                } elseif ($path -eq "/sys_info") {
                    $free = [math]::Round(((Get-PSDrive C -ErrorAction SilentlyContinue).Free / 1GB), 2)
                    Send-Response $res 200 @{ ok = $true; data = @{ hostname = $env:COMPUTERNAME; os = "Windows Server"; disk_free_gb = $free } }
                } elseif ($path -eq "/update") {
                    Send-Response $res 200 @{ ok = $true; message = "Dang tu dong cap nhat Agent tu GitHub va khoi dong lai..." }
                    Update-AgentFromGithub
                } elseif ($path -eq "/exec") {
                    $b = Get-Body $req
                    $timeout = if ($b.timeout) { [int]$b.timeout } else { 30 }
                    if ($b.shell -and ([string]$b.shell).ToLowerInvariant() -eq "cmd") {
                        $cmdResult = Exec-Cmd ("cmd.exe /d /s /c `"" + ([string]$b.cmd).Replace('"', '""') + "`"") $timeout
                    } else {
                        $cmdResult = Exec-Cmd ([string]$b.cmd) $timeout
                    }
                    Send-Response $res 200 $cmdResult
                } elseif ($path -eq "/read_file") {
                    $filePath = $req.QueryString["path"]
                    if ($filePath -and (Test-Path -LiteralPath $filePath)) {
                        $tail = 0
                        [int]::TryParse($req.QueryString["tail"], [ref]$tail) | Out-Null
                        $content = if ($tail -gt 0) { (Get-Content -LiteralPath $filePath -Tail $tail -Encoding UTF8) -join "`n" } else { Get-Content -LiteralPath $filePath -Raw -Encoding UTF8 }
                        Send-Response $res 200 @{ ok = $true; path = $filePath; content = $content }
                    } else {
                        Send-Response $res 404 @{ ok = $false; error = "File not found" }
                    }
                } elseif ($path -eq "/write_file") {
                    $b = Get-Body $req
                    $parent = Split-Path ([string]$b.path) -Parent
                    if ($parent -and -not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
                    if ($b.base64) {
                        [IO.File]::WriteAllBytes($b.path, [Convert]::FromBase64String($b.content))
                    } else {
                        [IO.File]::WriteAllText($b.path, [string]$b.content, [Text.Encoding]::UTF8)
                    }
                    Send-Response $res 200 @{ ok = $true; path = $b.path }
                } elseif ($path -eq "/list_files") {
                    $p = if ($req.QueryString["path"]) { $req.QueryString["path"] } else { $Dir }
                    if (Test-Path $p) {
                        $items = @(Get-ChildItem -LiteralPath $p -Force -ErrorAction SilentlyContinue | ForEach-Object {
                            @{ name = $_.Name; path = $_.FullName; is_dir = $_.PSIsContainer; size = if ($_.PSIsContainer) { 0 } else { $_.Length }; modified = $_.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss") }
                        })
                        Send-Response $res 200 @{ ok = $true; items = $items }
                    } else {
                        Send-Response $res 404 @{ ok = $false; error = "Path not found" }
                    }
                } elseif ($path -eq "/processes") {
                    $f = $req.QueryString["filter"]
                    $procs = @(Get-Process -ErrorAction SilentlyContinue | Where-Object { (-not $f) -or ($_.ProcessName -like "*$f*") } | ForEach-Object {
                        @{ pid = $_.Id; name = $_.ProcessName; mem_mb = [math]::Round($_.WorkingSet64 / 1MB, 1) }
                    })
                    Send-Response $res 200 @{ ok = $true; processes = $procs }
                } elseif ($path -eq "/kill_process") {
                    $b = Get-Body $req
                    if ($b.pid) { Stop-Process -Id ([int]$b.pid) -Force -ErrorAction SilentlyContinue; Send-Response $res 200 @{ ok = $true } }
                    elseif ($b.name) { Stop-Process -Name ([string]$b.name).Replace(".exe","") -Force -ErrorAction SilentlyContinue; Send-Response $res 200 @{ ok = $true } }
                    else { Send-Response $res 400 @{ ok = $false; error = "Missing pid/name" } }
                } elseif ($path -eq "/rdp_keepalive") {
                    1..3 | ForEach-Object { & "$env:windir\System32\tscon.exe" $_ /dest:console *>$null }
                    Send-Response $res 200 @{ ok = $true }
                } else {
                    Send-Response $res 404 @{ ok = $false; error = "Not found" }
                }
            } catch {
                Write-Log "Request handler exception: $($_.Exception.Message)"
                $task = $listener.GetContextAsync()
            }
        } else {
            Start-Sleep -Milliseconds 100
        }

        # C. Sync Cloudflare Tunnel URL neu co URL moi (hoan toan trong RAM, khong tao file)
        if ($global:LatestTunnelUrl -and $global:LatestTunnelUrl -ne $lastTunnelUrl) {
            $lastTunnelUrl = $global:LatestTunnelUrl
            Sync-TunnelUrl $lastTunnelUrl
        }

        $now = Get-Date

        # D. Kiem tra ket noi Cloudflare Tunnel ngoai mang dinh ky (Chong triet de loi 530 / 1033)
        if ($global:LatestTunnelUrl -and (($now - $lastTunnelProbe).TotalSeconds -ge 60)) {
            $lastTunnelProbe = $now
            try {
                $probeRes = (Invoke-WebRequest -Uri "$global:LatestTunnelUrl/ping" -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop).StatusCode
                if ($probeRes -ne 200) { throw "Unexpected tunnel status: $probeRes" }
                $script:TunnelProbeFailures = 0
            } catch {
                $script:TunnelProbeFailures++
                Write-Log "Cloudflare probe failed ($script:TunnelProbeFailures/3): $($_.Exception.Message)"
                if ($script:TunnelProbeFailures -ge 3) {
                    Write-Log "Cloudflare Tunnel failed three consecutive probes. Restarting tunnel..."
                    try { $cfProcess.Kill() } catch {}
                    Get-Process cloudflared -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
                    $global:LatestTunnelUrl = ""
                    $script:TunnelProbeFailures = 0
                    $cfProcess = Start-TunnelProcess
                }
            }
        }

        # E. Storage Guard 24/7 (Kiem tra va don dep dinh ky moi 60 giay)
        if (($now - $lastClean).TotalSeconds -ge 60) {
            $lastClean = $now

            # 1. Xoay vong bot log neu > 2MB
            Get-ChildItem "C:\TinhLinh\*\autofarm_log.txt", "C:\Users\Administrator\Desktop\*\autofarm_log.txt" -ErrorAction SilentlyContinue | ForEach-Object {
                if ($_.Length -gt 2MB) {
                    $tail = Get-Content $_.FullName -Tail 1000 -ErrorAction SilentlyContinue
                    Set-Content $_.FullName -Value $tail -Encoding UTF8 -Force
                }
            }

            # 2. Don Temp va WER Crash Dumps
            Get-ChildItem "$env:TEMP\*", "C:\Windows\Temp\*", "$env:LOCALAPPDATA\CrashDumps\*", "C:\ProgramData\Microsoft\Windows\WER\ReportQueue\*" -Recurse -Force -ErrorAction SilentlyContinue |
                Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

            # 3. Don sach bat ky file log/trung gian (*.log, *.tmp, *.cmd) tai C:\TinhLinh (khong xoa game jar, script bat hay account)
            Get-ChildItem -Path $Dir -File -ErrorAction SilentlyContinue |
                Where-Object { ($_.Extension -in @(".log", ".tmp") -or $_.Name -in @("vps_watchdog.cmd", "vps_watchdog.ps1", "agent.log", "tunnel.log")) -and ($_.Name -notlike "autofarm_log*.txt") } |
                Remove-Item -Force -ErrorAction SilentlyContinue

            # 4. Kiem tra dung luong o C:
            $freeMB = (Get-PSDrive C -ErrorAction SilentlyContinue).Free / 1MB
            if ($freeMB -lt 1536) {
                Clear-RecycleBin -Force -ErrorAction SilentlyContinue
                Get-ChildItem "C:\Windows\SoftwareDistribution\Download\*", "C:\Windows\Logs\CBS\*.log", "C:\Windows\Logs\DISM\*.log" -Recurse -Force -ErrorAction SilentlyContinue |
                    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
            }
            if ($freeMB -lt 800) {
                & vssadmin.exe delete shadows /all /quiet *>$null
                [GC]::Collect()
            }
            # 5. Dinh ky xoa RAM WorkingSet chong tran commit memory/OOM
            Optimize-MemoryAndPagefile
        }

        # E. Tu dong cap nhat Agent tu GitHub dinh ky moi 5 phut (300s)
        $now = Get-Date
        if (($now - $lastUpdateCheck).TotalSeconds -ge 300) {
            $lastUpdateCheck = $now
            Update-AgentFromGithub
        }
    } catch {
        Write-Log "Supervisor loop error: $($_.Exception.Message)"
        Start-Sleep -Seconds 1
    }
}
