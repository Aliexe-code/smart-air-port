#!/bin/bash

# Smart Airport - Cloud Kubernetes Deployment
# Supports Google Cloud (GKE), Azure (AKS), and AWS (EKS)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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
CLUSTER_NAME="smart-airport-cluster"
REGION="us-central1"  # Change based on your preference
NODE_COUNT=2

# Google Cloud (GKE) deployment
deploy_gke() {
    print_status "Deploying to Google Kubernetes Engine (GKE)..."
    
    # Create cluster
    print_status "Creating GKE cluster..."
    gcloud container clusters create $CLUSTER_NAME \
        --zone=$REGION-a \
        --num-nodes=$NODE_COUNT \
        --machine-type=e2-medium \
        --enable-autoscaling \
        --min-nodes=1 \
        --max-nodes=5
    
    # Get credentials
    gcloud container clusters get-credentials $CLUSTER_NAME --zone=$REGION-a
    
    deploy_application
}

# Azure (AKS) deployment
deploy_aks() {
    print_status "Deploying to Azure Kubernetes Service (AKS)..."
    
    # Create resource group
    az group create --name smart-airport-rg --location eastus
    
    # Create cluster
    print_status "Creating AKS cluster..."
    az aks create \
        --resource-group smart-airport-rg \
        --name $CLUSTER_NAME \
        --node-count $NODE_COUNT \
        --node-vm-size Standard_B2s \
        --enable-cluster-autoscaler \
        --min-count 1 \
        --max-count 5 \
        --generate-ssh-keys
    
    # Get credentials
    az aks get-credentials --resource-group smart-airport-rg --name $CLUSTER_NAME
    
    deploy_application
}

# AWS (EKS) deployment
deploy_eks() {
    print_status "Deploying to Amazon Elastic Kubernetes Service (EKS)..."
    
    # Create cluster (requires eksctl)
    print_status "Creating EKS cluster..."
    eksctl create cluster \
        --name $CLUSTER_NAME \
        --region us-west-2 \
        --nodegroup-name smart-airport-nodes \
        --node-type t3.medium \
        --nodes $NODE_COUNT \
        --nodes-min 1 \
        --nodes-max 5 \
        --managed
    
    deploy_application
}

# Deploy application to any cluster
deploy_application() {
    print_status "Deploying Smart Airport application..."
    
    # Apply configurations
    kubectl apply -f smart-airport-configmap.yaml
    kubectl apply -f smart-airport-deployment-secure.yaml
    
    # Wait for deployment
    kubectl wait --for=condition=available --timeout=300s deployment/smart-airport
    
    # Get external IP
    print_status "Waiting for external IP..."
    kubectl get service smart-airport-service --watch &
    WATCH_PID=$!
    
    # Wait for external IP (timeout after 5 minutes)
    for i in {1..30}; do
        EXTERNAL_IP=$(kubectl get service smart-airport-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
        if [ ! -z "$EXTERNAL_IP" ] && [ "$EXTERNAL_IP" != "null" ]; then
            break
        fi
        sleep 10
    done
    
    kill $WATCH_PID 2>/dev/null || true
    
    if [ ! -z "$EXTERNAL_IP" ] && [ "$EXTERNAL_IP" != "null" ]; then
        print_success "Deployment completed!"
        echo "External IP: $EXTERNAL_IP"
        echo "Application URL: http://$EXTERNAL_IP:3001"
        echo "Health check: http://$EXTERNAL_IP:3001/health"
    else
        print_warning "External IP not assigned yet. Check with: kubectl get services"
    fi
}

# Show cluster status
show_status() {
    echo "=== Cluster Info ==="
    kubectl cluster-info
    
    echo ""
    echo "=== Nodes ==="
    kubectl get nodes
    
    echo ""
    echo "=== Pods ==="
    kubectl get pods -l app=smart-airport
    
    echo ""
    echo "=== Services ==="
    kubectl get services
    
    echo ""
    echo "=== Ingress ==="
    kubectl get ingress
}

# Cleanup cloud resources
cleanup_cloud() {
    print_status "Cleaning up cloud resources..."
    
    # Delete application
    kubectl delete -f smart-airport-deployment-secure.yaml --ignore-not-found=true
    kubectl delete -f smart-airport-configmap.yaml --ignore-not-found=true
    
    # Delete cluster based on provider
    if command -v gcloud >/dev/null 2>&1; then
        print_warning "To delete GKE cluster, run:"
        echo "gcloud container clusters delete $CLUSTER_NAME --zone=$REGION-a"
    fi
    
    if command -v az >/dev/null 2>&1; then
        print_warning "To delete AKS cluster, run:"
        echo "az aks delete --resource-group smart-airport-rg --name $CLUSTER_NAME"
        echo "az group delete --name smart-airport-rg"
    fi
    
    if command -v eksctl >/dev/null 2>&1; then
        print_warning "To delete EKS cluster, run:"
        echo "eksctl delete cluster --name $CLUSTER_NAME"
    fi
}

# Main execution
case "${1:-help}" in
    "gke")
        deploy_gke
        ;;
    "aks")
        deploy_aks
        ;;
    "eks")
        deploy_eks
        ;;
    "deploy")
        deploy_application
        ;;
    "status")
        show_status
        ;;
    "cleanup")
        cleanup_cloud
        ;;
    *)
        echo "Usage: $0 {gke|aks|eks|deploy|status|cleanup}"
        echo ""
        echo "Cloud Providers:"
        echo "  gke      - Deploy to Google Kubernetes Engine"
        echo "  aks      - Deploy to Azure Kubernetes Service"
        echo "  eks      - Deploy to Amazon Elastic Kubernetes Service"
        echo ""
        echo "Commands:"
        echo "  deploy   - Deploy app to existing cluster"
        echo "  status   - Show cluster and app status"
        echo "  cleanup  - Remove app and show cluster cleanup commands"
        echo ""
        echo "Prerequisites:"
        echo "  GKE: gcloud CLI and authenticated"
        echo "  AKS: az CLI and authenticated"
        echo "  EKS: eksctl and AWS CLI authenticated"
        exit 1
        ;;
esac
