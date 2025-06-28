#!/bin/bash

# Smart Airport Application Deployment Script
# This script provides easy deployment options for the Smart Airport application

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
INVENTORY="inventory/onprems"
BUILD_NUMBER="latest"
ENVIRONMENT="production"
PLAYBOOK=""
EXTRA_VARS=""

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

# Function to show usage
show_usage() {
    cat << EOF
Smart Airport Application Deployment Script

Usage: $0 [OPTIONS] COMMAND

Commands:
    full        Full deployment (Docker + Application)
    app         Application update only
    docker      Docker Community deployment
    custom      Custom deployment with role selection

Options:
    -i, --inventory FILE    Inventory file (default: inventory/onprems)
    -b, --build NUMBER      Build number/tag (default: latest)
    -e, --environment ENV   Environment (default: production)
    -v, --vars "KEY=VALUE"  Extra variables
    -h, --help             Show this help message

Examples:
    $0 full                                    # Full deployment with defaults
    $0 app -b v1.2.3                         # Update app to version v1.2.3
    $0 full -i inventory/staging -e staging   # Deploy to staging environment
    $0 custom -v "selected_roles=['docker_install']"  # Install Docker only

EOF
}

# Function to validate prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if ansible is installed
    if ! command -v ansible-playbook &> /dev/null; then
        print_error "Ansible is not installed. Please install Ansible first."
        exit 1
    fi
    
    # Check if inventory file exists
    if [[ ! -f "$INVENTORY" ]]; then
        print_error "Inventory file '$INVENTORY' not found."
        exit 1
    fi
    
    # Check if we're in the ansible directory
    if [[ ! -f "ansible.cfg" ]]; then
        print_error "Please run this script from the ansible directory."
        exit 1
    fi
    
    print_success "Prerequisites check passed."
}

# Function to run ansible playbook
run_playbook() {
    local playbook_file="$1"
    local extra_vars_str=""
    
    # Build extra vars string
    if [[ -n "$BUILD_NUMBER" && "$BUILD_NUMBER" != "latest" ]]; then
        extra_vars_str="build_number=$BUILD_NUMBER"
    fi
    
    if [[ -n "$ENVIRONMENT" && "$ENVIRONMENT" != "production" ]]; then
        if [[ -n "$extra_vars_str" ]]; then
            extra_vars_str="$extra_vars_str environment=$ENVIRONMENT"
        else
            extra_vars_str="environment=$ENVIRONMENT"
        fi
    fi
    
    if [[ -n "$EXTRA_VARS" ]]; then
        if [[ -n "$extra_vars_str" ]]; then
            extra_vars_str="$extra_vars_str $EXTRA_VARS"
        else
            extra_vars_str="$EXTRA_VARS"
        fi
    fi
    
    # Build ansible command
    local ansible_cmd="ansible-playbook $playbook_file -i $INVENTORY"
    
    if [[ -n "$extra_vars_str" ]]; then
        ansible_cmd="$ansible_cmd -e \"$extra_vars_str\""
    fi
    
    print_status "Running: $ansible_cmd"
    print_status "Deploying to environment: $ENVIRONMENT"
    print_status "Build number: $BUILD_NUMBER"
    
    # Execute the command
    eval $ansible_cmd
    
    if [[ $? -eq 0 ]]; then
        print_success "Deployment completed successfully!"
    else
        print_error "Deployment failed!"
        exit 1
    fi
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--inventory)
            INVENTORY="$2"
            shift 2
            ;;
        -b|--build)
            BUILD_NUMBER="$2"
            shift 2
            ;;
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -v|--vars)
            EXTRA_VARS="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        full|app|docker|custom)
            COMMAND="$1"
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Check if command is provided
if [[ -z "$COMMAND" ]]; then
    print_error "No command specified."
    show_usage
    exit 1
fi

# Set playbook based on command
case $COMMAND in
    full)
        PLAYBOOK="playbooks/deploy-full.yml"
        ;;
    app)
        PLAYBOOK="playbooks/deploy-app-only.yml"
        ;;
    docker)
        PLAYBOOK="playbooks/docker-community.yml"
        ;;
    custom)
        PLAYBOOK="site.yml"
        ;;
    *)
        print_error "Unknown command: $COMMAND"
        show_usage
        exit 1
        ;;
esac

# Main execution
print_status "Starting Smart Airport Application deployment..."
check_prerequisites
run_playbook "$PLAYBOOK"
print_success "All done! 🚀"
