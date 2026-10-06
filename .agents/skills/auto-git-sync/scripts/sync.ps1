param(
    [string]$Message = ""
)

$ErrorActionPreference = "Stop"

# Ensure UTF-8 output
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$repoRoot = "d:\tinhlinh"
Set-Location $repoRoot

# Check if git is initialized
if (-not (Test-Path (Join-Path $repoRoot ".git"))) {
    Write-Host "[GitSync] Error: Not a git repository." -ForegroundColor Red
    exit 1
}

# Check git status
$status = git status --porcelain
if (-not $status) {
    Write-Host "[GitSync] No changes detected. Workspace is clean." -ForegroundColor Green
    exit 0
}

Write-Host "[GitSync] Changes detected:" -ForegroundColor Cyan
$status | ForEach-Object { Write-Host "  $_" }

# Default commit message if none provided
if ([string]::IsNullOrWhiteSpace($Message)) {
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $Message = "chore(sync): automated commit and sync [$timestamp]"
}

# 1. Stage changes
Write-Host "[GitSync] Staging changes..." -ForegroundColor Cyan
git add -A

# 2. Commit
Write-Host "[GitSync] Committing with message: '$Message'..." -ForegroundColor Cyan
git commit -m "$Message"

# 3. Pull rebase to avoid divergence (e.g., VPS auto-pushes)
Write-Host "[GitSync] Pulling latest changes from origin main (rebase)..." -ForegroundColor Cyan
try {
    git pull --rebase origin main
} catch {
    Write-Host "[GitSync] Rebase encountered issues, trying to abort or resolve..." -ForegroundColor Yellow
    git rebase --abort 2>$null
    git pull origin main --no-edit
}

# 4. Push to remote
Write-Host "[GitSync] Pushing to origin main..." -ForegroundColor Cyan
git push origin main

$latestCommit = git rev-parse --short HEAD
Write-Host "[GitSync] Successfully synced! Latest commit: $latestCommit" -ForegroundColor Green
