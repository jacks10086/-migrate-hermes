# Hermes Verification Script

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "       Hermes Junction Verification" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$path = "$env:LOCALAPPDATA\hermes"

if (-not (Test-Path $path)) {
    Write-Host "  ERROR: Path not found: $path" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

$item = Get-Item $path -Force

if ($item.LinkType -eq "Junction") {
    $target = $item.Target
    Write-Host "  Status: OK" -ForegroundColor Green
    Write-Host "  Type: Junction" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Source: $path" -ForegroundColor Gray
    Write-Host "  Target: $target" -ForegroundColor Gray
    Write-Host ""

    # Check size
    $size = (Get-ChildItem -Path $target -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1GB
    $sizeGB = [math]::Round($size, 2)

    Write-Host "  Data size: $sizeGB GB" -ForegroundColor Gray

    # Check drive space
    $drive = $target[0]
    $driveInfo = Get-PSDrive -Name $drive -ErrorAction SilentlyContinue
    if ($driveInfo) {
        $freeGB = [math]::Round($driveInfo.Free / 1GB, 2)
        Write-Host "  Drive $drive free space: $freeGB GB" -ForegroundColor Gray
    }

    Write-Host ""
    Write-Host "  Result: Migration successful" -ForegroundColor Green
} else {
    Write-Host "  Status: NOT MIGRATED" -ForegroundColor Yellow
    Write-Host "  Type: Regular directory" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Path: $path" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Run migrate-hermes.ps1 to migrate" -ForegroundColor Cyan
}

Write-Host ""
Read-Host "Press Enter to exit"
