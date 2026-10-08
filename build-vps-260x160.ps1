param(
    [string]$SourceJar = (Join-Path $PSScriptRoot 'TinhLinh.jar'),
    [string]$OutputJar = (Join-Path $PSScriptRoot 'TinhLinh-260x160-vps.jar')
)

$ErrorActionPreference = 'Stop'
& (Join-Path $PSScriptRoot 'build-360x480.ps1') `
    -SourceJar $SourceJar `
    -OutputJar $OutputJar `
    -WindowWidth 260 `
    -WindowHeight 160
if ($LASTEXITCODE -ne 0) {
    throw 'VPS-compatible JAR build failed.'
}
