#!/bin/bash

# Azure SSH Setup Script for Smart Airport Project
# This script helps configure SSH access to your Azure VM

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
SSH_KEY_PATH="~/Downloads/GradServer_key.pem"
AZURE_HOST="51.105.241.63"
AZURE_USER="azureuser"

print_status "Setting up SSH access to Azure VM..."

# Expand tilde to full path
SSH_KEY_FULL_PATH="${SSH_KEY_PATH/#\~/$HOME}"

# Check if SSH key exists
if [ ! -f "$SSH_KEY_FULL_PATH" ]; then
    print_error "SSH key not found at: $SSH_KEY_FULL_PATH"
    print_status "Please ensure the key file exists in ~/Downloads/GradServer_key.pem"
    exit 1
fi

print_success "SSH key found at: $SSH_KEY_FULL_PATH"

# Set correct permissions for SSH key
print_status "Setting correct permissions for SSH key..."
chmod 600 "$SSH_KEY_FULL_PATH"
print_success "SSH key permissions set to 600"

# Test SSH connection
print_status "Testing SSH connection to Azure VM..."
if ssh -i "$SSH_KEY_FULL_PATH" -o ConnectTimeout=10 -o StrictHostKeyChecking=accept-new "$AZURE_USER@$AZURE_HOST" "echo 'SSH connection successful'" 2>/dev/null; then
    print_success "SSH connection to Azure VM successful!"
else
    print_error "SSH connection failed. Please check:"
    echo "  1. SSH key path: $SSH_KEY_FULL_PATH"
    echo "  2. Azure VM is running and accessible"
    echo "  3. Security group allows SSH (port 22)"
    echo "  4. Network connectivity"
    exit 1
fi

# Test Ansible connectivity
print_status "Testing Ansible connectivity..."
if ansible all -i inventory/onprems -m ping > /dev/null 2>&1; then
    print_success "Ansible can connect to Azure VM!"
else
    print_warning "Ansible connection test failed, but SSH works."
    print_status "This might be due to Python not being installed on the VM."
    print_status "Ansible will install Python during the first run."
fi

# Display connection information
print_success "Azure SSH setup complete!"
echo
print_status "Connection Details:"
echo "  Host: $AZURE_HOST"
echo "  User: $AZURE_USER"
echo "  SSH Key: $SSH_KEY_PATH"
echo
print_status "Manual SSH Command:"
echo "  ssh -i $SSH_KEY_PATH $AZURE_USER@$AZURE_HOST"
echo
print_status "Ansible Commands:"
echo "  # Test connection:"
echo "  ansible all -i inventory/onprems -m ping"
echo
echo "  # Deploy application:"
echo "  ansible-playbook playbooks/deploy-full.yml -i inventory/onprems"
echo
echo "  # Deploy with Docker:"
echo "  ansible-playbook playbooks/deploy-docker.yml -i inventory/onprems"

print_success "Ready to deploy to Azure! 🚀"
