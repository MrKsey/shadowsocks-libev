#!/usr/bin/env pwsh
param()

$ErrorActionPreference = "Stop"
$RepoDir = Resolve-Path "$PSScriptRoot\..\.."
$OutputDir = Join-Path $RepoDir "arm64-output"

Write-Host "=== Building shadowsocks-libev statically for ARM64 (aarch64) ===" -ForegroundColor Cyan
Write-Host ""

# Check Docker
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Docker is required. Please install Docker Desktop from:" -ForegroundColor Red
    Write-Host "  https://www.docker.com/products/docker-desktop/" -ForegroundColor Red
    exit 1
}

Write-Host "Step 1: Building Docker image (this may take 10-20 minutes)..." -ForegroundColor Yellow
docker build --platform linux/amd64 `
    -t ss-libev-arm64 `
    -f (Join-Path $RepoDir "docker\arm64-static\Dockerfile") `
    $RepoDir

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Docker build failed!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Step 2: Extracting binaries..." -ForegroundColor Yellow

$ContainerId = docker create ss-libev-arm64
if (Test-Path $OutputDir) { Remove-Item -Recurse -Force $OutputDir }
New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
docker cp "${ContainerId}:/output/." $OutputDir
docker rm $ContainerId | Out-Null

Write-Host ""
Write-Host "=== Build complete! ===" -ForegroundColor Green
Write-Host "ARM64 binaries are in: $OutputDir" -ForegroundColor Green
Write-Host ""

Get-ChildItem $OutputDir | ForEach-Object {
    Write-Host ("  {0,-20} {1,10:N0} bytes" -f $_.Name, $_.Length)
}