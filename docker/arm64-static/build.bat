@echo off
setlocal enabledelayedexpansion

echo === Building shadowsocks-libev statically for ARM64 (aarch64) ===
echo.

REM Check Docker
where docker >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERROR: Docker is required. Please install Docker Desktop from: https://www.docker.com/products/docker-desktop/
    exit /b 1
)

echo Step 1: Building Docker image (this may take 10-20 minutes)...
docker build --platform linux/amd64 -t ss-libev-arm64 -f docker\arm64-static\Dockerfile .

echo.
echo Step 2: Extracting binaries...
docker create --name ss-tmp ss-libev-arm64 >nul
if exist arm64-output rmdir /s /q arm64-output
mkdir arm64-output
docker cp ss-tmp:/output/. arm64-output\
docker rm ss-tmp >nul

echo.
echo === Build complete! ===
echo ARM64 binaries are in: arm64-output\
echo.
dir /b arm64-output\