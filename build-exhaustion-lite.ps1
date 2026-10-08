[CmdletBinding()]
param(
    [string]$OutputJar = (Join-Path $PSScriptRoot 'TinhLinh-Clean-CPU-260x160.jar'),
    [int]$WindowWidth = 260,
    [int]$WindowHeight = 160
)

$ErrorActionPreference = 'Stop'

# Compatibility entry point. Historical AutoReconnect injection is disabled.
& (Join-Path $PSScriptRoot 'build-clean-local-260x160.ps1') `
    -OutputJar $OutputJar `
    -WindowWidth $WindowWidth `
    -WindowHeight $WindowHeight
if ($LASTEXITCODE -ne 0) {
    throw 'Clean local baseline build failed.'
}
