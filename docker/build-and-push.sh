#!/bin/bash

# Smart Airport Docker Build and Push Script
# This script builds and pushes the Docker image to your registry

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
DEFAULT_TAG="latest"

# Get tag from command line or use default
TAG="${1:-$DEFAULT_TAG}"
IMAGE_NAME="$REGISTRY/$PROJECT:$TAG"

print_status "Building and pushing Smart Airport Docker image..."
print_status "Registry: $REGISTRY"
print_status "Project: $PROJECT"
print_status "Tag: $TAG"
print_status "Full image name: $IMAGE_NAME"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker first."
    exit 1
fi

# Build the image
print_status "Building Docker image..."
docker build -f Dockerfile.backend -t "$IMAGE_NAME" ..

if [ $? -eq 0 ]; then
    print_success "Docker image built successfully!"
else
    print_error "Docker build failed!"
    exit 1
fi

# Check if user is logged in to Docker Hub
print_status "Checking Docker Hub authentication..."
if ! docker info | grep -q "Username:"; then
    print_warning "Not logged in to Docker Hub. Please login first:"
    print_status "Run: docker login"
    echo
    read -p "Do you want to login now? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker login
    else
        print_error "Cannot push without Docker Hub authentication."
        exit 1
    fi
fi

# Push the image
print_status "Pushing image to Docker Hub..."
docker push "$IMAGE_NAME"

if [ $? -eq 0 ]; then
    print_success "Image pushed successfully!"
else
    print_error "Docker push failed!"
    exit 1
fi

# Update docker-compose.yml with new image
print_status "Updating docker-compose.yml..."
if [ -f .env ]; then
    # Update .env file
    if grep -q "BACKEND_IMAGE=" .env; then
        sed -i "s|BACKEND_IMAGE=.*|BACKEND_IMAGE=$IMAGE_NAME|" .env
    else
        echo "BACKEND_IMAGE=$IMAGE_NAME" >> .env
    fi
    print_success ".env file updated with new image"
else
    print_warning ".env file not found. Creating from template..."
    cp .env.example .env
    sed -i "s|BACKEND_IMAGE=.*|BACKEND_IMAGE=$IMAGE_NAME|" .env
    print_success ".env file created with new image"
fi

# Display usage information
print_success "Build and push completed successfully!"
echo
print_status "Image Details:"
echo "  Registry: $REGISTRY"
echo "  Project: $PROJECT"
echo "  Tag: $TAG"
echo "  Full Name: $IMAGE_NAME"
echo
print_status "To deploy this image:"
echo "  # Local deployment:"
echo "  docker compose up -d"
echo
echo "  # Remote deployment via Ansible:"
echo "  cd ../ansible"
echo "  ansible-playbook playbooks/deploy-docker.yml -i inventory/onprems -e \"backend_image=$IMAGE_NAME\""
echo
print_status "To build with a different tag:"
echo "  ./build-and-push.sh v1.0.0"
echo "  ./build-and-push.sh production"
echo "  ./build-and-push.sh $(date +%Y%m%d-%H%M%S)"

print_success "Ready for deployment! 🚀"
