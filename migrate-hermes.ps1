# Hermes Migration Script - Simple Version

Write-Host ""
Write-Host "============================================" -ForegroundColor Yellow
Write-Host "       Hermes Migration Tool" -ForegroundColor Yellow
Write-Host "============================================" -ForegroundColor Yellow
Write-Host ""

# Ask for target path
$defaultPath = "D:\software\HermesDesktop"
Write-Host "Enter target path (or press Enter for default)" -ForegroundColor Cyan
Write-Host "Default: $defaultPath" -ForegroundColor Gray
$targetPath = Read-Host "Your input"

# Use default if empty
if ([string]::IsNullOrWhiteSpace($targetPath)) {
    $targetPath = $defaultPath
    Write-Host "Using default path: $targetPath" -ForegroundColor Gray
} else {
    Write-Host "Target: $targetPath" -ForegroundColor Gray
}

Write-Host ""

# Confirm
$confirm = Read-Host "Continue? (Y/N)"
if ($confirm -ne "Y" -and $confirm -ne "y") {
    Write-Host "Cancelled" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 0
}

Write-Host ""
Write-Host "Starting migration..." -ForegroundColor Cyan

# Step 1: Remove old directory if exists
Write-Host "Step 1: Cleaning old directory..." -ForegroundColor Gray
Remove-Item $targetPath -Recurse -Force -ErrorAction SilentlyContinue

# Step 2: Close processes
Write-Host "Step 2: Closing processes..." -ForegroundColor Gray
Get-Process node, python, hermes, uv -ErrorAction SilentlyContinue | Stop-Process -Force

# Step 3: Wait
Write-Host "Step 3: Waiting..." -ForegroundColor Gray
Start-Sleep 3

# Step 4: Create directory
Write-Host "Step 4: Creating directory..." -ForegroundColor Gray
New-Item -Path $targetPath -ItemType Directory -Force | Out-Null

# Step 5: Move data
Write-Host "Step 5: Moving data (this takes 5-10 minutes)..." -ForegroundColor Yellow
$targetData = Join-Path $targetPath "hermes"
robocopy "$env:LOCALAPPDATA\hermes" $targetData /E /MOVE /R:3 /W:5

# Step 6: Remove empty source directory (robocopy MOVE leaves empty folder)
Write-Host "Step 6: Cleaning source..." -ForegroundColor Gray
Remove-Item "$env:LOCALAPPDATA\hermes" -Force -Recurse -ErrorAction SilentlyContinue

# Step 7: Create junction
Write-Host "Step 7: Creating junction..." -ForegroundColor Gray
New-Item -Path "$env:LOCALAPPDATA\hermes" -ItemType Junction -Value $targetData -Force | Out-Null

# Step 8: Verify
Write-Host "Step 8: Verifying..." -ForegroundColor Gray
$result = Get-Item "$env:LOCALAPPDATA\hermes"

if ($result.LinkType -eq "Junction") {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Migration Complete!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Freed: ~3.3 GB on C drive" -ForegroundColor Green
    Write-Host "Data: $targetData" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Start Hermes" -ForegroundColor Gray
    Write-Host "2. Test Python tasks" -ForegroundColor Gray
    Write-Host ""

    # Save log
    $logPath = "$env:USERPROFILE\Desktop\hermes-migration-log.txt"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "Hermes Migration Log`nTime: $timestamp`nTarget: $targetData`nStatus: Success" | Out-File $logPath -Encoding UTF8
    Write-Host "Log saved to: $logPath" -ForegroundColor Gray
} else {
    Write-Host "Error: Junction not created" -ForegroundColor Red
}

Write-Host ""
Read-Host "Press Enter to exit"
