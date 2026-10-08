[CmdletBinding()]
param(
    [string]$SourceJar = (Join-Path $PSScriptRoot 'TinhLinh.jar'),
    [string]$OutputJar = (Join-Path $PSScriptRoot 'TinhLinh-Clean-CPU-260x160.jar'),
    [int]$WindowWidth = 260,
    [int]$WindowHeight = 160
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $SourceJar -PathType Leaf)) {
    throw "Local baseline JAR not found: $SourceJar"
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

$javac = Join-Path $javaHome 'bin\javac.exe'
$java = Join-Path $javaHome 'bin\java.exe'
$scratch = Join-Path ([IO.Path]::GetTempPath()) ('tinhlinh-clean-window-' + [Guid]::NewGuid().ToString('N'))
$classes = Join-Path $scratch 'classes'
New-Item -ItemType Directory -Path $classes -Force | Out-Null

try {
    & $javac '--add-exports' 'java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED' `
        '-encoding' 'UTF-8' '-d' $classes `
        (Join-Path $PSScriptRoot 'tools\WindowPatch.java') `
        (Join-Path $PSScriptRoot 'tools\FreshExhaustion.java')
    if ($LASTEXITCODE -ne 0) {
        throw 'WindowPatch compilation failed.'
    }

    & $java '--add-exports' 'java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED' `
        '-cp' $classes 'WindowPatch' $SourceJar $OutputJar $WindowWidth $WindowHeight `
        (Join-Path $classes 'FreshExhaustion.class')
    if ($LASTEXITCODE -ne 0) {
        throw 'Local baseline window patch failed.'
    }

    $outputSize = (Get-Item -LiteralPath $OutputJar).Length
    if ($outputSize -lt 1000000) {
        throw "Output JAR is unexpectedly small: $outputSize bytes"
    }

    $zip = [IO.Compression.ZipFile]::OpenRead((Resolve-Path -LiteralPath $OutputJar))
    try {
        $names = @($zip.Entries | ForEach-Object FullName)
    }
    finally {
        $zip.Dispose()
    }
    $oldEntries = @($names | Where-Object { $_ -match '(^|/)AutoReconnect(Base)?(\$[^/]*)?\.class$' })
    if ($oldEntries.Count -gt 0) {
        throw ('Old AutoReconnect classes found in clean output: ' + ($oldEntries -join ', '))
    }

    if ($names -notcontains 'FreshExhaustion.class') {
        throw 'FreshExhaustion.class missing from clean output.'
    }

    Write-Output ("Built clean local baseline: {0} ({1:N0} bytes)" -f $OutputJar, $outputSize)
    Write-Output ("Window: {0}x{1}; old AutoReconnect classes: none" -f $WindowWidth, $WindowHeight)
}
finally {
    if (Test-Path -LiteralPath $scratch) {
        Remove-Item -LiteralPath $scratch -Recurse -Force -ErrorAction SilentlyContinue
    }
}
