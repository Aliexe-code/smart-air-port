#!/bin/bash

# Smart Airport - Kubernetes Setup Test
# Quick test to verify all files are ready

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}✅${NC} $1"
}

print_error() {
    echo -e "${RED}❌${NC} $1"
}

print_info() {
    echo -e "${YELLOW}ℹ️${NC} $1"
}

echo "🧪 Testing Kubernetes Setup..."
echo ""

# Test 1: Check files exist
echo "📁 Checking files..."
files=(
    "smart-airport-deployment.yaml"
    "smart-airport-configmap.yaml" 
    "smart-airport-deployment-secure.yaml"
    "minikube-setup.sh"
    "cloud-deploy.sh"
    "README.md"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        print_success "$file exists"
    else
        print_error "$file missing"
        exit 1
    fi
done

echo ""

# Test 2: Check scripts are executable
echo "🔧 Checking script permissions..."
scripts=("minikube-setup.sh" "cloud-deploy.sh")

for script in "${scripts[@]}"; do
    if [ -x "$script" ]; then
        print_success "$script is executable"
    else
        print_error "$script is not executable"
        exit 1
    fi
done

echo ""

# Test 3: Validate YAML syntax
echo "📝 Validating YAML files..."
yaml_files=(
    "smart-airport-deployment.yaml"
    "smart-airport-configmap.yaml"
    "smart-airport-deployment-secure.yaml"
)

for yaml_file in "${yaml_files[@]}"; do
    if command -v python3 >/dev/null 2>&1; then
        if python3 -c "import yaml; yaml.safe_load(open('$yaml_file'))" 2>/dev/null; then
            print_success "$yaml_file has valid YAML syntax"
        else
            print_error "$yaml_file has invalid YAML syntax"
        fi
    else
        print_info "$yaml_file (YAML validation skipped - python3 not available)"
    fi
done

echo ""

# Test 4: Check Docker image reference
echo "🐳 Checking Docker image reference..."
if grep -q "uriel25x/grad-project:latest" *.yaml; then
    print_success "Docker image reference found in YAML files"
else
    print_error "Docker image reference not found"
fi

echo ""

# Test 5: Show next steps
echo "🚀 Next Steps:"
echo ""
echo "For Local Learning (FREE):"
echo "  ./minikube-setup.sh full"
echo ""
echo "For Cloud Deployment (PAID):"
echo "  ./cloud-deploy.sh gke    # Google Cloud"
echo "  ./cloud-deploy.sh aks    # Azure"
echo "  ./cloud-deploy.sh eks    # AWS"
echo ""
echo "For Help:"
echo "  cat README.md"
echo ""

print_success "Kubernetes setup is ready! 🎉"
print_info "Remember: Your Docker setup is still the best choice for production!"
