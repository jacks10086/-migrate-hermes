# Hermes Rollback Script - Simple Version

Write-Host ""
Write-Host "============================================" -ForegroundColor Yellow
Write-Host "       Hermes Rollback Tool" -ForegroundColor Yellow
Write-Host "============================================" -ForegroundColor Yellow
Write-Host ""

# Ask for source path
$defaultPath = "D:\software\HermesDesktop"
Write-Host "Enter source path (or press Enter for default)" -ForegroundColor Cyan
Write-Host "Default: $defaultPath" -ForegroundColor Gray
$sourcePath = Read-Host "Your input"

# Use default if empty
if ([string]::IsNullOrWhiteSpace($sourcePath)) {
    $sourcePath = $defaultPath
    Write-Host "Using default path: $sourcePath" -ForegroundColor Gray
} else {
    Write-Host "Source: $sourcePath" -ForegroundColor Gray
}

Write-Host ""

$sourceData = Join-Path $sourcePath "hermes"
$targetPath = "$env:LOCALAPPDATA\hermes"

# Check if migration exists
if (-not (Test-Path $sourceData)) {
    Write-Host "ERROR: Migrated data not found at: $sourceData" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Confirm
$confirm = Read-Host "Rollback? (Y/N)"
if ($confirm -ne "Y" -and $confirm -ne "y") {
    Write-Host "Cancelled" -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Starting rollback..." -ForegroundColor Cyan

# Remove junction
Write-Host "Removing junction..." -ForegroundColor Gray
Remove-Item $targetPath -Force -Recurse -ErrorAction SilentlyContinue

# Move back
Write-Host "Moving data back (this takes a few minutes)..." -ForegroundColor Yellow
robocopy $sourceData $targetPath /E /MOVE /R:3 /W:5

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Rollback Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "Data restored to: $targetPath" -ForegroundColor Green
Write-Host ""

Read-Host "Press Enter to exit"
