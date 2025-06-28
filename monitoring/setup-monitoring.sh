#!/bin/bash

# Smart Airport - Prometheus Monitoring Setup Script

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

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command_exists docker; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! command_exists docker-compose && ! docker compose version >/dev/null 2>&1; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Setup monitoring stack
setup_monitoring() {
    print_status "Setting up Prometheus monitoring stack..."
    
    # Create necessary directories
    mkdir -p monitoring/{prometheus,grafana/{provisioning/{datasources,dashboards},dashboards},alertmanager}
    
    # Start monitoring stack
    cd monitoring
    if command_exists docker-compose; then
        docker-compose up -d
    else
        docker compose up -d
    fi
    
    print_success "Monitoring stack started"
}

# Check services status
check_services() {
    print_status "Checking services status..."
    
    # Wait for services to start
    sleep 30
    
    # Check Prometheus
    if curl -s http://localhost:9090/-/healthy > /dev/null; then
        print_success "Prometheus is healthy"
    else
        print_warning "Prometheus might not be ready yet"
    fi
    
    # Check Grafana
    if curl -s http://localhost:3000/api/health > /dev/null; then
        print_success "Grafana is healthy"
    else
        print_warning "Grafana might not be ready yet"
    fi
    
    # Check AlertManager
    if curl -s http://localhost:9093/-/healthy > /dev/null; then
        print_success "AlertManager is healthy"
    else
        print_warning "AlertManager might not be ready yet"
    fi
}

# Show access information
show_access_info() {
    echo ""
    echo "=== Monitoring Stack Access Information ==="
    echo ""
    echo "📊 Prometheus (Metrics & Alerts):"
    echo "   URL: http://localhost:9090"
    echo "   Status: http://localhost:9090/targets"
    echo ""
    echo "📈 Grafana (Dashboards):"
    echo "   URL: http://localhost:3000"
    echo "   Username: admin"
    echo "   Password: admin123"
    echo ""
    echo "🚨 AlertManager (Alert Management):"
    echo "   URL: http://localhost:9093"
    echo ""
    echo "🔍 Node Exporter (System Metrics):"
    echo "   URL: http://localhost:9100"
    echo ""
    echo "🏥 Smart Airport Health:"
    echo "   URL: http://localhost:3001/health"
    echo "   Metrics: http://localhost:3001/metrics"
    echo ""
}

# Install NestJS Prometheus dependencies
install_nestjs_deps() {
    print_status "Installing NestJS Prometheus dependencies..."

    # Navigate to project root (where package.json is)
    if [ -f "../package.json" ]; then
        cd ..
    elif [ -f "package.json" ]; then
        # Already in project root
        :
    else
        print_error "package.json not found. Please run from project root or monitoring directory."
        return 1
    fi

    # Install required packages
    if command_exists bun; then
        print_status "Using Bun to install packages..."
        bun add @willsoto/nestjs-prometheus prom-client
        bun add -D @types/prom-client
    elif command_exists npm; then
        print_status "Using npm to install packages..."
        npm install @willsoto/nestjs-prometheus prom-client
        npm install -D @types/prom-client
    else
        print_error "Neither bun nor npm found. Please install dependencies manually:"
        echo "  bun add @willsoto/nestjs-prometheus prom-client"
        echo "  bun add -D @types/prom-client"
        return 1
    fi

    print_success "NestJS dependencies installed"
}

# Main execution
main() {
    case "${1:-setup}" in
        "setup")
            print_status "Setting up complete monitoring stack..."
            check_prerequisites
            setup_monitoring
            check_services
            show_access_info
            print_success "Monitoring setup completed!"
            ;;
        "install-deps")
            install_nestjs_deps
            ;;
        "start")
            print_status "Starting monitoring stack..."
            cd monitoring
            if command_exists docker-compose; then
                docker-compose up -d
            else
                docker compose up -d
            fi
            check_services
            show_access_info
            ;;
        "stop")
            print_status "Stopping monitoring stack..."
            cd monitoring
            if command_exists docker-compose; then
                docker-compose down
            else
                docker compose down
            fi
            print_success "Monitoring stack stopped"
            ;;
        "restart")
            print_status "Restarting monitoring stack..."
            cd monitoring
            if command_exists docker-compose; then
                docker-compose restart
            else
                docker compose restart
            fi
            check_services
            print_success "Monitoring stack restarted"
            ;;
        "status")
            check_services
            show_access_info
            ;;
        "logs")
            cd monitoring
            if command_exists docker-compose; then
                docker-compose logs -f
            else
                docker compose logs -f
            fi
            ;;
        "cleanup")
            print_status "Cleaning up monitoring stack..."
            cd monitoring
            if command_exists docker-compose; then
                docker-compose down -v
            else
                docker compose down -v
            fi
            docker system prune -f
            print_success "Cleanup completed"
            ;;
        *)
            echo "Usage: $0 {setup|install-deps|start|stop|restart|status|logs|cleanup}"
            echo ""
            echo "Commands:"
            echo "  setup       - Complete setup (default)"
            echo "  install-deps - Install NestJS dependencies"
            echo "  start       - Start monitoring stack"
            echo "  stop        - Stop monitoring stack"
            echo "  restart     - Restart monitoring stack"
            echo "  status      - Check services status"
            echo "  logs        - View logs"
            echo "  cleanup     - Remove everything"
            exit 1
            ;;
    esac
}

main "$@"
