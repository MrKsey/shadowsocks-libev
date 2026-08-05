#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

echo "=== Building shadowsocks-libev statically for ARM64 (aarch64) ==="

# Check if Docker is available
if ! command -v docker &>/dev/null; then
    echo "ERROR: Docker is required. Please install Docker first."
    exit 1
fi

echo "Step 1: Building Docker image (this may take 10-20 minutes)..."
docker build --platform linux/amd64 \
    -t ss-libev-arm64 \
    -f "${REPO_DIR}/docker/arm64-static/Dockerfile" \
    "${REPO_DIR}"

echo ""
echo "Step 2: Extracting binaries..."
CONTAINER_ID=$(docker create ss-libev-arm64)
mkdir -p "${REPO_DIR}/arm64-output"
docker cp "${CONTAINER_ID}:/output/." "${REPO_DIR}/arm64-output/"
docker rm "${CONTAINER_ID}" >/dev/null

echo ""
echo "=== Build complete! ==="
echo "ARM64 binaries are in: ${REPO_DIR}/arm64-output/"
echo ""
ls -lh "${REPO_DIR}/arm64-output/"
file "${REPO_DIR}/arm64-output/"*