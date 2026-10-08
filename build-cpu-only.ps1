[CmdletBinding()]
param(
    [string]$SourceExe = (Join-Path $PSScriptRoot 'TLKN-setup (1).exe'),
    [string]$OutputJar = (Join-Path $PSScriptRoot 'TinhLinh-CPU-Only-260x160.jar'),
    [int]$WindowWidth = 260,
    [int]$WindowHeight = 160
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $SourceExe -PathType Leaf)) {
    throw "Installer not found: $SourceExe"
}

$archiveSource = $SourceExe
if ([IO.Path]::GetFileName($SourceExe) -like 'TLKN-setup*.exe') {
    $extractedGame = Join-Path ([IO.Path]::GetTempPath()) 'tinhlinh\_extract\game.exe'
    if (-not (Test-Path -LiteralPath $extractedGame -PathType Leaf)) {
        $extractedGame = 'D:\temp\_tlkn\_extract\game.exe'
    }
    if (-not (Test-Path -LiteralPath $extractedGame -PathType Leaf)) {
        throw 'Installer is not a readable archive; extract it first so game.exe is available.'
    }
    $archiveSource = $extractedGame
}

$jdkCandidates = @(
    'C:\Program Files\Java\jdk-17',
    'C:\Program Files\Java\jdk-17.0.12',
    'C:\Program Files\Java\jdk-17.0.13'
)
$javaHome = $jdkCandidates | Where-Object {
    Test-Path -LiteralPath (Join-Path $_ 'bin\javac.exe')
} | Select-Object -First 1
if (-not $javaHome) {
    throw 'JDK 17 not found.'
}

$sevenZip = (Get-Command '7z.exe' -ErrorAction SilentlyContinue).Source
if (-not $sevenZip) {
    throw '7z.exe is required to read the installer archive.'
}

$javac = Join-Path $javaHome 'bin\javac.exe'
$java = Join-Path $javaHome 'bin\java.exe'
$jar = Join-Path $javaHome 'bin\jar.exe'
$scratch = Join-Path ([IO.Path]::GetTempPath()) ('tinhlinh-cpu-only-' + [Guid]::NewGuid().ToString('N'))
$classes = Join-Path $scratch 'classes'
$sourceJar = Join-Path $scratch 'TinhLinh.jar'
New-Item -ItemType Directory -Path $classes -Force | Out-Null

try {
    $listing = (& $sevenZip l -slt $archiveSource | Out-String)
    $offsetMatch = [regex]::Match($listing, '(?m)^Offset = (\d+)')
    $sizeMatch = [regex]::Match($listing, '(?m)^Physical Size = (\d+)')
    if (-not $offsetMatch.Success -or -not $sizeMatch.Success) {
        throw 'The installer does not contain a readable embedded JAR.'
    }

    $offset = [Int64]$offsetMatch.Groups[1].Value
    $archiveSize = [Int64]$sizeMatch.Groups[1].Value
    $input = [IO.File]::OpenRead($archiveSource)
    try {
        if ($offset -lt 0 -or $archiveSize -le 0 -or $offset + $archiveSize -gt $input.Length) {
            throw 'Embedded JAR bounds are invalid.'
        }
        $input.Seek($offset, [IO.SeekOrigin]::Begin) | Out-Null
        $output = [IO.File]::Create($sourceJar)
        try {
            $remaining = $archiveSize
            $buffer = New-Object byte[] 1048576
            while ($remaining -gt 0) {
                $read = $input.Read($buffer, 0, [Math]::Min($buffer.Length, $remaining))
                if ($read -le 0) {
                    throw 'Unexpected end of embedded JAR.'
                }
                $output.Write($buffer, 0, $read)
                $remaining -= $read
            }
        }
        finally {
            $output.Dispose()
        }
    }
    finally {
        $input.Dispose()
    }

    & $jar tf $sourceJar | Select-Object -First 1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw 'Extracted source is not a valid JAR.'
    }

    & (Join-Path $PSScriptRoot 'build-clean-local-260x160.ps1') `
        -SourceJar $sourceJar `
        -OutputJar $OutputJar `
        -WindowWidth $WindowWidth `
        -WindowHeight $WindowHeight
    if ($LASTEXITCODE -ne 0) {
        throw 'CPU-only JAR build failed.'
    }

    $outputSize = (Get-Item -LiteralPath $OutputJar).Length
    if ($outputSize -lt 1000000) {
        throw "Output JAR is unexpectedly small: $outputSize bytes"
    }
    Write-Output ("Built CPU-only JAR: {0} ({1:N0} bytes)" -f $OutputJar, $outputSize)
    Write-Output ("Software-render profile: {0}x{1}, 15 FPS, audio disabled, VSync disabled, one network thread" -f $WindowWidth, $WindowHeight)
}
finally {
    if (Test-Path -LiteralPath $scratch) {
        Remove-Item -LiteralPath $scratch -Recurse -Force -ErrorAction SilentlyContinue
    }
}
