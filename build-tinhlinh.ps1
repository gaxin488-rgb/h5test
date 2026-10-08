[CmdletBinding()]
param(
    [string]$SourceJar = '',
    [string]$OutputJar = '',
    [int]$WindowWidth = 260,
    [int]$WindowHeight = 160
)

$ErrorActionPreference = 'Stop'

$rootDir = $PSScriptRoot
if (-not $rootDir) { $rootDir = (Get-Location).Path }
if (-not $SourceJar) { $SourceJar = Join-Path $rootDir 'TinhLinh.jar' }
if (-not $OutputJar) { $OutputJar = Join-Path $rootDir 'TinhLinh.jar' }

if (-not (Test-Path -LiteralPath $SourceJar -PathType Leaf)) {
    throw "Source JAR not found: $SourceJar"
}

$jdkCandidates = @(
    'C:\Program Files\Java\jdk-17',
    'C:\Program Files\Java\jdk-17.0.12',
    'C:\Program Files\Java\jdk-17.0.13',
    'C:\TLKN\jre'
)
$javaHome = $jdkCandidates | Where-Object {
    Test-Path -LiteralPath (Join-Path $_ 'bin\javac.exe')
} | Select-Object -First 1

if (-not $javaHome) {
    # Check if javac is in PATH
    $javacCmd = Get-Command javac.exe -ErrorAction SilentlyContinue
    if ($javacCmd) {
        $javac = $javacCmd.Source
        $java = (Get-Command java.exe -ErrorAction SilentlyContinue).Source
    } else {
        throw 'JDK 17 with javac.exe not found.'
    }
} else {
    $javac = Join-Path $javaHome 'bin\javac.exe'
    $java = Join-Path $javaHome 'bin\java.exe'
}

$scratch = Join-Path ([IO.Path]::GetTempPath()) ('tinhlinh-build-' + [Guid]::NewGuid().ToString('N'))
$classes = Join-Path $scratch 'classes'
$tempOutputJar = Join-Path $scratch 'output.jar'
New-Item -ItemType Directory -Path $classes -Force | Out-Null

try {
    Write-Host "[1/3] Bien dich TinhLinhBot.java..." -ForegroundColor Cyan
    & $javac -encoding UTF-8 -cp $SourceJar -d $classes (Join-Path $rootDir 'tools\TinhLinhBot.java')
    if ($LASTEXITCODE -ne 0) {
        throw 'TinhLinhBot compilation failed.'
    }

    Write-Host "[2/3] Bien dich WindowPatch.java..." -ForegroundColor Cyan
    & $javac '--add-exports' 'java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED' `
        -encoding UTF-8 -d $classes (Join-Path $rootDir 'tools\WindowPatch.java')
    if ($LASTEXITCODE -ne 0) {
        throw 'WindowPatch compilation failed.'
    }

    Write-Host "[3/3] Ap dung bytecode injection va dong goi JAR..." -ForegroundColor Cyan
    $botClass = Join-Path $classes 'TinhLinhBot.class'
    & $java '--add-exports' 'java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED' `
        -cp $classes 'WindowPatch' $SourceJar $tempOutputJar $WindowWidth $WindowHeight $botClass
    if ($LASTEXITCODE -ne 0) {
        throw 'WindowPatch execution failed.'
    }

    # Kiem tra file dau ra
    $outputSize = (Get-Item -LiteralPath $tempOutputJar).Length
    if ($outputSize -lt 10000000) {
        throw "Output JAR is unexpectedly small: $outputSize bytes"
    }

    # Ghi de vao OutputJar
    Copy-Item -LiteralPath $tempOutputJar -Destination $OutputJar -Force
    Write-Host ("==> Thanh cong! Da tao {0} ({1:N0} bytes) [Cua so: {2}x{3}]" -f $OutputJar, $outputSize, $WindowWidth, $WindowHeight) -ForegroundColor Green
}
finally {
    if (Test-Path -LiteralPath $scratch) {
        Remove-Item -LiteralPath $scratch -Recurse -Force -ErrorAction SilentlyContinue
    }
}
