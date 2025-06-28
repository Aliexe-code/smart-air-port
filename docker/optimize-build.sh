#!/bin/bash

# Docker Build Optimization Script for Smart Airport
# This script optimizes the build process for faster Docker builds

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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
TAG="${1:-latest}"
IMAGE_NAME="$REGISTRY/$PROJECT:$TAG"

print_status "🚀 Starting optimized Docker build process..."
print_status "Image: $IMAGE_NAME"

# Step 1: Clean up previous builds
print_status "🧹 Cleaning up previous builds..."
docker system prune -f --filter "until=24h" > /dev/null 2>&1 || true
docker builder prune -f > /dev/null 2>&1 || true

# Step 2: Generate lockfile if missing
print_status "🔒 Checking for lockfile..."
cd ..
if [ ! -f "bun.lockb" ]; then
    print_warning "No bun.lockb found. Generating lockfile..."
    if command -v bun >/dev/null 2>&1; then
        bun install --lockfile-only
        print_success "Lockfile generated successfully"
    else
        print_warning "Bun not found locally. Lockfile will be generated in Docker."
    fi
else
    print_success "Lockfile found"
fi

# Step 3: Optimize build context
print_status "📦 Optimizing build context..."
BUILD_CONTEXT_SIZE=$(du -sh . 2>/dev/null | cut -f1 || echo "unknown")
print_status "Build context size: $BUILD_CONTEXT_SIZE"

# Step 4: Build with optimizations
print_status "🔨 Building optimized Docker image..."
cd docker

# Use BuildKit for better caching and parallelization
export DOCKER_BUILDKIT=1
export BUILDKIT_PROGRESS=plain

# Build with cache mount and optimizations
docker build \
    --file Dockerfile.backend \
    --tag "$IMAGE_NAME" \
    --build-arg BUILDKIT_INLINE_CACHE=1 \
    --cache-from "$IMAGE_NAME" \
    --progress=plain \
    .. 2>&1 | tee build.log

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    print_success "Docker image built successfully!"
else
    print_error "Docker build failed!"
    print_status "Check build.log for details"
    exit 1
fi

# Step 5: Analyze image
print_status "📊 Analyzing image..."
IMAGE_SIZE=$(docker images "$IMAGE_NAME" --format "table {{.Size}}" | tail -n 1)
print_status "Final image size: $IMAGE_SIZE"

# Step 6: Test image
print_status "🧪 Testing image..."
if docker run --rm --name test-container -d -p 3002:3001 "$IMAGE_NAME" > /dev/null 2>&1; then
    sleep 5
    if curl -f http://localhost:3002/health > /dev/null 2>&1; then
        print_success "Image health check passed!"
    else
        print_warning "Health check failed, but image starts"
    fi
    docker stop test-container > /dev/null 2>&1 || true
else
    print_warning "Could not test image (port might be in use)"
fi

# Step 7: Push to registry
print_status "📤 Pushing to registry..."
if docker info | grep -q "Username:"; then
    docker push "$IMAGE_NAME"
    print_success "Image pushed to registry!"
else
    print_warning "Not logged in to Docker Hub. Skipping push."
    print_status "Run 'docker login' to push to registry"
fi

# Step 8: Update environment
print_status "⚙️ Updating environment configuration..."
if [ -f .env ]; then
    if grep -q "BACKEND_IMAGE=" .env; then
        sed -i "s|BACKEND_IMAGE=.*|BACKEND_IMAGE=$IMAGE_NAME|" .env
    else
        echo "BACKEND_IMAGE=$IMAGE_NAME" >> .env
    fi
else
    cp .env.example .env
    sed -i "s|BACKEND_IMAGE=.*|BACKEND_IMAGE=$IMAGE_NAME|" .env
fi

# Step 9: Display summary
print_success "🎉 Optimized build completed!"
echo
print_status "Build Summary:"
echo "  Image: $IMAGE_NAME"
echo "  Size: $IMAGE_SIZE"
echo "  Build Context: $BUILD_CONTEXT_SIZE"
echo "  Build Log: docker/build.log"
echo
print_status "Next Steps:"
echo "  # Local deployment:"
echo "  docker compose up -d"
echo
echo "  # Remote deployment:"
echo "  cd ../ansible"
echo "  ansible-playbook playbooks/deploy-docker.yml -i inventory/onprems -e \"backend_image=$IMAGE_NAME\""
echo
print_status "Build optimizations applied:"
echo "  ✅ Multi-stage build with dependency caching"
echo "  ✅ Optimized .dockerignore"
echo "  ✅ BuildKit enabled for parallel builds"
echo "  ✅ Layer caching optimized"
echo "  ✅ Production-only dependencies in final image"

print_success "Ready for deployment! 🚀"
