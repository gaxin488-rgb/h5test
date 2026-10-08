[CmdletBinding()]
param(
    [string]$OutputJar = (Join-Path $PSScriptRoot 'TinhLinh-Lite-CPU-1GB-260x160.jar'),
    [int]$WindowWidth = 260,
    [int]$WindowHeight = 160,
    [string]$HistoricalJar = ''
)

$ErrorActionPreference = 'Stop'

$jdkCandidates = @(
    'C:\Program Files\Java\jdk-17',
    'C:\Program Files\Java\jdk-17.0.12',
    'C:\Program Files\Java\jdk-17.0.13'
)
$javaHome = $jdkCandidates | Where-Object { Test-Path -LiteralPath (Join-Path $_ 'bin\javac.exe') } | Select-Object -First 1
if (-not $javaHome) {
    throw 'JDK 17 not found.'
}

$javac = Join-Path $javaHome 'bin\javac.exe'
$java = Join-Path $javaHome 'bin\java.exe'
$jarTool = Join-Path $javaHome 'bin\jar.exe'
$scratch = Join-Path ([IO.Path]::GetTempPath()) ('tinhlinh-exhaustion-build-' + [Guid]::NewGuid().ToString('N'))
$classes = Join-Path $scratch 'classes'
$sourceJar = Join-Path $scratch 'historical-lite.jar'
$renamedJar = Join-Path $scratch 'renamed-lite.jar'
$windowJar = Join-Path $scratch 'window-lite.jar'

New-Item -ItemType Directory -Path $classes -Force | Out-Null

function Export-GitBlob([string]$Repository, [string]$Blob, [string]$Destination) {
    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = 'git.exe'
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.ArgumentList.Add('-C')
    $startInfo.ArgumentList.Add($Repository)
    $startInfo.ArgumentList.Add('cat-file')
    $startInfo.ArgumentList.Add('blob')
    $startInfo.ArgumentList.Add($Blob)
    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $startInfo
    if (-not $process.Start()) {
        throw 'Cannot start Git to read historical JAR.'
    }
    $file = [IO.File]::Open($Destination, [IO.FileMode]::Create, [IO.FileAccess]::Write, [IO.FileShare]::None)
    try {
        $process.StandardOutput.BaseStream.CopyTo($file)
    }
    finally {
        $file.Dispose()
    }
    $process.WaitForExit()
    if ($process.ExitCode -ne 0) {
        throw ('Cannot read historical JAR from Git: ' + $process.StandardError.ReadToEnd())
    }
}

try {
    if ($HistoricalJar) {
        if (-not (Test-Path -LiteralPath $HistoricalJar -PathType Leaf)) {
            throw "Historical JAR not found: $HistoricalJar"
        }
        Copy-Item -LiteralPath $HistoricalJar -Destination $sourceJar -Force
    } else {
        $repoRoot = (Resolve-Path $PSScriptRoot).Path
        $blob = 'fb527724ce6210ad7b6002e7d8ec0305da670503'
        Export-GitBlob $repoRoot $blob $sourceJar
    }

    $asmExports = @(
        '--add-exports', 'java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED',
        '--add-exports', 'java.base/jdk.internal.org.objectweb.asm.commons=ALL-UNNAMED'
    )
    & $javac @asmExports -encoding UTF-8 -d $classes 'tools\RenameAutoReconnect.java'
    if ($LASTEXITCODE -ne 0) {
        throw 'RenameAutoReconnect compilation failed.'
    }
    & $java @asmExports -cp $classes RenameAutoReconnect $sourceJar $renamedJar
    if ($LASTEXITCODE -ne 0) {
        throw 'AutoReconnect bytecode rename failed.'
    }

    & $javac -encoding UTF-8 -cp $renamedJar -d $classes 'tools\AutoReconnect.java'
    if ($LASTEXITCODE -ne 0) {
        throw 'AutoReconnect bridge compilation failed.'
    }
    $bridgeClasses = @(Get-ChildItem -LiteralPath (Join-Path $classes 'com\a\d') -Filter 'AutoReconnect*.class' -File)
    if ($bridgeClasses.Count -eq 0) {
        throw 'AutoReconnect bridge classes were not compiled.'
    }
    foreach ($bridgeClass in $bridgeClasses) {
        & $jarTool uf $renamedJar -C $classes (Join-Path 'com\a\d' $bridgeClass.Name)
        if ($LASTEXITCODE -ne 0) {
            throw ('AutoReconnect bridge insertion failed: ' + $bridgeClass.Name)
        }
    }

    & $javac @asmExports -encoding UTF-8 -d $classes 'tools\WindowPatch.java'
    if ($LASTEXITCODE -ne 0) {
        throw 'WindowPatch compilation failed.'
    }
    & $java @asmExports -cp $classes WindowPatch $renamedJar $windowJar $WindowWidth $WindowHeight
    if ($LASTEXITCODE -ne 0) {
        throw 'Window patch failed.'
    }

    $entries = @(& $jarTool tf $windowJar)
    foreach ($required in @(
        'com/a/d/AutoReconnect.class',
        'com/a/d/AutoReconnectBase.class',
        'com/girlkun/DesktopLauncher.class',
        'com/girlkun/ReadinessMain.class'
    )) {
        if ($entries -notcontains $required) {
            throw "Required class missing from output: $required"
        }
    }
    $outputSize = (Get-Item -LiteralPath $windowJar).Length
    if ($outputSize -lt 40000000) {
        throw "Output JAR is unexpectedly small: $outputSize bytes"
    }
    Copy-Item -LiteralPath $windowJar -Destination $OutputJar -Force
    Write-Output ("Built {0} ({1:N0} bytes)" -f $OutputJar, $outputSize)
}
finally {
    if (Test-Path -LiteralPath $scratch) {
        Remove-Item -LiteralPath $scratch -Recurse -Force -ErrorAction SilentlyContinue
    }
}
