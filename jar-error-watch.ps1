[CmdletBinding()]
param(
    [string]$JarPath = (Join-Path $PSScriptRoot 'TinhLinh-Lite-1GB-260x160.jar'),
    [string]$JavaPath = 'java',
    [string]$Label = 'lite',
    [int]$XmxMb = 64,
    [switch]$NoCommit
)

$ErrorActionPreference = 'Stop'

function ConvertTo-SafeLog {
    param([AllowNull()][string]$Text)

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return ''
    }

    $safe = $Text
    $safe = $safe -replace '(?im)(password|passwd|token|secret|authorization|bearer|access[_-]?key)\s*[:=]\s*\S+', '$1=[REDACTED]'
    $safe = $safe -replace '(?im)(account|username|user)\s*[:=]\s*\S+', '$1=[REDACTED]'
    $safe = $safe -replace '(?i)C:\\Users\\[^\\\r\n]+', 'C:\\Users\\[REDACTED]'

    if ($safe.Length -gt 200000) {
        return $safe.Substring(0, 100000) + "`n...[TRUNCATED]...`n" + $safe.Substring($safe.Length - 100000)
    }
    return $safe
}

function Commit-DiagnosticLog {
    param(
        [Parameter(Mandatory)][string]$LogPath,
        [Parameter(Mandatory)][string]$RunLabel
    )

    $repoRoot = $PSScriptRoot
    $relativePath = [IO.Path]::GetRelativePath($repoRoot, $LogPath)
    & git -C $repoRoot add -- $relativePath
    if ($LASTEXITCODE -ne 0) {
        throw 'Unable to stage diagnostic log.'
    }

    & git -C $repoRoot commit -m ("test: capture jar diagnostic log ({0})" -f $RunLabel)
    if ($LASTEXITCODE -ne 0) {
        throw 'Unable to commit diagnostic log.'
    }

    & git -C $repoRoot pull --rebase origin main
    if ($LASTEXITCODE -ne 0) {
        throw 'Diagnostic log committed locally but pull --rebase failed.'
    }

    & git -C $repoRoot push origin main
    if ($LASTEXITCODE -ne 0) {
        throw 'Diagnostic log committed locally but push failed.'
    }
}

function Start-JarWithErrorWatch {
    param(
        [Parameter(Mandatory)][string]$TargetJar,
        [Parameter(Mandatory)][string]$RuntimePath,
        [Parameter(Mandatory)][string]$RunLabel,
        [Parameter(Mandatory)][int]$HeapMb,
        [switch]$SkipCommit
    )

    if (-not (Test-Path -LiteralPath $TargetJar -PathType Leaf)) {
        throw "JAR not found: $TargetJar"
    }
    if ($HeapMb -lt 48 -or $HeapMb -gt 512) {
        throw 'HeapMb must be between 48 and 512.'
    }

    $runId = Get-Date -Format 'yyyyMMdd-HHmmss'
    $rawDir = Join-Path $env:TEMP 'tinhlinh-jar-watch'
    $diagnosticDir = Join-Path $PSScriptRoot 'diagnostics\jar'
    New-Item -ItemType Directory -Path $rawDir -Force | Out-Null
    New-Item -ItemType Directory -Path $diagnosticDir -Force | Out-Null

    $rawStdout = Join-Path $rawDir ("{0}-{1}.stdout" -f $RunLabel, $runId)
    $rawStderr = Join-Path $rawDir ("{0}-{1}.stderr" -f $RunLabel, $runId)
    $diagnosticPath = Join-Path $diagnosticDir ("jar-{0}-{1}.log" -f $RunLabel, $runId)
    $start = Get-Date
    $process = $null
    $exitCode = $null
    $maxWorkingSetMb = 0
    $failure = $null

    try {
        $javaArgs = @(
            '-Xms16m',
            ("-Xmx{0}m" -f $HeapMb),
            '-XX:+UseSerialGC',
            '-XX:MaxMetaspaceSize=64m',
            '-XX:ReservedCodeCacheSize=32m',
            '-Dfile.encoding=UTF-8',
            '-jar',
            $TargetJar
        )
        $process = Start-Process -FilePath $RuntimePath -ArgumentList $javaArgs `
            -WorkingDirectory $PSScriptRoot `
            -RedirectStandardOutput $rawStdout `
            -RedirectStandardError $rawStderr `
            -PassThru

        while (-not $process.HasExited) {
            $process.Refresh()
            $children = @(Get-CimInstance Win32_Process -Filter ("ParentProcessId={0}" -f $process.Id) -ErrorAction SilentlyContinue)
            $trackedIds = @($process.Id) + @($children.ProcessId)
            $workingSet = @(Get-Process -Id $trackedIds -ErrorAction SilentlyContinue | Measure-Object -Property WorkingSet64 -Sum).Sum
            if ($workingSet) {
                $currentMb = [math]::Round($workingSet / 1MB, 1)
                if ($currentMb -gt $maxWorkingSetMb) {
                    $maxWorkingSetMb = $currentMb
                }
            }
            Start-Sleep -Seconds 2
        }
        $process.Refresh()
        $exitCode = $process.ExitCode
    } catch {
        $failure = $_ | Out-String
    } finally {
        $end = Get-Date
        $stdout = if (Test-Path -LiteralPath $rawStdout) { Get-Content -LiteralPath $rawStdout -Raw -ErrorAction SilentlyContinue } else { '' }
        $stderr = if (Test-Path -LiteralPath $rawStderr) { Get-Content -LiteralPath $rawStderr -Raw -ErrorAction SilentlyContinue } else { '' }
        $events = @()
        try {
            $events = @(Get-WinEvent -FilterHashtable @{ LogName = 'Application'; StartTime = $start } -ErrorAction SilentlyContinue |
                Where-Object { $_.ProviderName -match 'Application Error|Windows Error Reporting|Java' } |
                Select-Object -First 10 TimeCreated, ProviderName, Id, Message)
        } catch {}

        $status = if ($failure) { 'watcher-error' } elseif ($exitCode -eq 0) { 'process-exit-0' } else { 'process-exit-error' }
        $report = [System.Collections.Generic.List[string]]::new()
        $report.Add('TinhLinh JAR diagnostic log')
        $report.Add(('status: {0}' -f $status))
        $report.Add(('label: {0}' -f $RunLabel))
        $report.Add(('jar: {0}' -f ([IO.Path]::GetFileName($TargetJar))))
        $report.Add(('started: {0:o}' -f $start))
        $report.Add(('ended: {0:o}' -f $end))
        $report.Add(('duration_seconds: {0:N1}' -f ($end - $start).TotalSeconds))
        $report.Add(('exit_code: {0}' -f $exitCode))
        $report.Add(('max_working_set_mb: {0}' -f $maxWorkingSetMb))
        $report.Add(('java_version: {0}' -f ((& $RuntimePath -version 2>&1) -join ' ')))
        if ($failure) {
            $report.Add("`n[WATCHER ERROR]")
            $report.Add((ConvertTo-SafeLog $failure))
        }
        $report.Add("`n[STDOUT]")
        $report.Add((ConvertTo-SafeLog $stdout))
        $report.Add("`n[STDERR]")
        $report.Add((ConvertTo-SafeLog $stderr))
        $report.Add("`n[WINDOWS APPLICATION EVENTS]")
        foreach ($event in $events) {
            $report.Add(('{0:o} {1} {2}: {3}' -f $event.TimeCreated, $event.ProviderName, $event.Id, (ConvertTo-SafeLog $event.Message)))
        }

        Set-Content -LiteralPath $diagnosticPath -Value ($report -join "`n") -Encoding UTF8
        if (-not $SkipCommit) {
            try {
                Commit-DiagnosticLog -LogPath $diagnosticPath -RunLabel $RunLabel
            } catch {
                Add-Content -LiteralPath $diagnosticPath -Value (("`n[COMMIT ERROR]`n{0}" -f (ConvertTo-SafeLog ($_ | Out-String)))) -Encoding UTF8
                Write-Error $_
            }
        }
        Remove-Item -LiteralPath $rawStdout, $rawStderr -Force -ErrorAction SilentlyContinue
        Write-Output ("Diagnostic log: {0}" -f $diagnosticPath)
    }
}

Start-JarWithErrorWatch -TargetJar $JarPath -RuntimePath $JavaPath -RunLabel $Label -HeapMb $XmxMb -SkipCommit:$NoCommit
