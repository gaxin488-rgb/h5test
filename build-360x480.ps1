param(
    [string]$SourceJar = (Join-Path $PSScriptRoot 'TinhLinh.jar'),
    [string]$OutputJar = (Join-Path $PSScriptRoot 'TinhLinh-360x480.jar')
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $SourceJar -PathType Leaf)) {
    throw "Source JAR not found: $SourceJar"
}

$jdkCandidates = @(
    'C:\Program Files\Java\jdk-17',
    'C:\Program Files\Java\jdk-17.0.12',
    'C:\Program Files\Java\jdk-17.0.13'
)
$javaHome = $jdkCandidates | Where-Object { Test-Path (Join-Path $_ 'bin\javac.exe') } | Select-Object -First 1
if (-not $javaHome) {
    throw 'JDK 17 not found; the source JAR uses class version 61.'
}

$javac = Join-Path $javaHome 'bin\javac.exe'
$java = Join-Path $javaHome 'bin\java.exe'
$scratch = Join-Path ([IO.Path]::GetTempPath()) ('tinhlinh-window-build-' + [Guid]::NewGuid().ToString('N'))
$classes = Join-Path $scratch 'classes'
New-Item -ItemType Directory -Path $classes -Force | Out-Null

try {
    & $javac '--add-exports' 'java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED' '-encoding' 'UTF-8' '-d' $classes (Join-Path $PSScriptRoot 'tools\WindowPatch.java')
    if ($LASTEXITCODE -ne 0) { throw 'WindowPatch compilation failed.' }

    & $java '--add-exports' 'java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED' '-cp' $classes 'WindowPatch' $SourceJar $OutputJar
    if ($LASTEXITCODE -ne 0) { throw 'JAR patch failed.' }

    $outputSize = (Get-Item -LiteralPath $OutputJar).Length
    if ($outputSize -lt 1000000) { throw "Output JAR is unexpectedly small: $outputSize bytes" }
    Write-Output ("Built {0} ({1:N0} bytes)" -f $OutputJar, $outputSize)
}
finally {
    if (Test-Path -LiteralPath $scratch) {
        Remove-Item -LiteralPath $scratch -Recurse -Force -ErrorAction SilentlyContinue
    }
}
