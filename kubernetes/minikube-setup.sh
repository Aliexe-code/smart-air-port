#!/bin/bash

# Smart Airport - Minimal Kubernetes Setup with Minikube
# This script sets up a local Kubernetes cluster for learning/testing

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

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install minikube if not present
install_minikube() {
    if ! command_exists minikube; then
        print_status "Installing Minikube..."
        curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
        sudo install minikube-linux-amd64 /usr/local/bin/minikube
        rm minikube-linux-amd64
        print_success "Minikube installed successfully"
    else
        print_success "Minikube already installed"
    fi
}

# Install kubectl if not present
install_kubectl() {
    if ! command_exists kubectl; then
        print_status "Installing kubectl..."
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
        rm kubectl
        print_success "kubectl installed successfully"
    else
        print_success "kubectl already installed"
    fi
}

# Start minikube cluster
start_cluster() {
    print_status "Starting Minikube cluster..."
    minikube start --driver=docker --memory=4096 --cpus=2
    print_success "Minikube cluster started"
    
    # Enable ingress addon
    print_status "Enabling ingress addon..."
    minikube addons enable ingress
    print_success "Ingress addon enabled"
}

# Deploy Smart Airport application
deploy_app() {
    print_status "Deploying Smart Airport to Kubernetes..."
    
    # Apply ConfigMap and Secrets first
    kubectl apply -f smart-airport-configmap.yaml
    print_success "ConfigMap and Secrets applied"
    
    # Apply deployment
    kubectl apply -f smart-airport-deployment-secure.yaml
    print_success "Deployment applied"
    
    # Wait for deployment to be ready
    print_status "Waiting for deployment to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/smart-airport
    print_success "Deployment is ready"
}

# Show status and access information
show_status() {
    print_status "Checking deployment status..."
    
    echo ""
    echo "=== Pods ==="
    kubectl get pods -l app=smart-airport
    
    echo ""
    echo "=== Services ==="
    kubectl get services
    
    echo ""
    echo "=== Ingress ==="
    kubectl get ingress
    
    # Get service URL
    SERVICE_URL=$(minikube service smart-airport-service --url)
    
    echo ""
    print_success "Smart Airport is deployed!"
    echo "Access your application at: $SERVICE_URL"
    echo "Health check: $SERVICE_URL/health"
    
    # Test health endpoint
    print_status "Testing health endpoint..."
    sleep 10
    if curl -s "$SERVICE_URL/health" > /dev/null; then
        print_success "Health check passed!"
    else
        print_warning "Health check failed - application might still be starting"
    fi
}

# Cleanup function
cleanup() {
    print_status "Cleaning up..."
    kubectl delete -f smart-airport-deployment-secure.yaml --ignore-not-found=true
    kubectl delete -f smart-airport-configmap.yaml --ignore-not-found=true
    print_success "Cleanup completed"
}

# Main execution
case "${1:-deploy}" in
    "install")
        print_status "Installing Kubernetes tools..."
        install_minikube
        install_kubectl
        print_success "Installation completed"
        ;;
    "start")
        print_status "Starting Kubernetes cluster..."
        start_cluster
        print_success "Cluster started"
        ;;
    "deploy")
        print_status "Deploying Smart Airport..."
        deploy_app
        show_status
        ;;
    "status")
        show_status
        ;;
    "cleanup")
        cleanup
        ;;
    "stop")
        print_status "Stopping Minikube cluster..."
        minikube stop
        print_success "Cluster stopped"
        ;;
    "full")
        print_status "Full setup: install -> start -> deploy"
        install_minikube
        install_kubectl
        start_cluster
        deploy_app
        show_status
        ;;
    *)
        echo "Usage: $0 {install|start|deploy|status|cleanup|stop|full}"
        echo ""
        echo "Commands:"
        echo "  install  - Install minikube and kubectl"
        echo "  start    - Start minikube cluster"
        echo "  deploy   - Deploy Smart Airport application"
        echo "  status   - Show deployment status"
        echo "  cleanup  - Remove Smart Airport deployment"
        echo "  stop     - Stop minikube cluster"
        echo "  full     - Complete setup from scratch"
        exit 1
        ;;
esac
