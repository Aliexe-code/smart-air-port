#!/bin/bash

# Fast Docker Build Script for Development
# Optimized for speed over size

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Configuration
REGISTRY="uriel25x"
PROJECT="grad-project"
TAG="${1:-dev-$(date +%Y%m%d-%H%M%S)}"
IMAGE_NAME="$REGISTRY/$PROJECT:$TAG"

print_status "⚡ Fast Docker build for development..."
print_status "Image: $IMAGE_NAME"

# Enable BuildKit for faster builds
export DOCKER_BUILDKIT=1

# Generate lockfile quickly if missing
cd ..
if [ ! -f "bun.lockb" ]; then
    print_status "Generating lockfile..."
    if command -v bun >/dev/null 2>&1; then
        timeout 60 bun install --lockfile-only || print_warning "Lockfile generation timed out"
    fi
fi

cd docker

# Fast build with minimal optimization
print_status "🔨 Building image (fast mode)..."
docker build \
    --file Dockerfile.backend \
    --tag "$IMAGE_NAME" \
    --target production \
    .. 2>&1 | grep -E "(Step|Successfully|Error|FAILED)" || true

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    print_success "Build completed!"
    
    # Quick test
    print_status "Testing image..."
    if docker run --rm "$IMAGE_NAME" bun --version > /dev/null 2>&1; then
        print_success "Image test passed!"
    fi
    
    # Update .env
    if [ -f .env ]; then
        sed -i "s|BACKEND_IMAGE=.*|BACKEND_IMAGE=$IMAGE_NAME|" .env
    else
        echo "BACKEND_IMAGE=$IMAGE_NAME" > .env
    fi
    
    print_success "Ready! Use: docker compose up -d"
else
    print_error "Build failed!"
    exit 1
fi
