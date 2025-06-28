#!/bin/bash

# Smart Airport - Jenkins Setup Script

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
    
    if ! docker compose version >/dev/null 2>&1 && ! command_exists docker-compose; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Get Jenkins initial admin password
get_jenkins_password() {
    print_status "Getting Jenkins initial admin password..."
    
    # Wait for Jenkins to start
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if docker exec smart-airport-jenkins test -f /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null; then
            local password=$(docker exec smart-airport-jenkins cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null)
            if [ ! -z "$password" ]; then
                echo ""
                echo "🔑 Jenkins Initial Admin Password:"
                echo "=================================="
                echo "$password"
                echo "=================================="
                echo ""
                return 0
            fi
        fi
        
        echo "⏳ Waiting for Jenkins to initialize... (attempt $attempt/$max_attempts)"
        sleep 10
        ((attempt++))
    done
    
    print_warning "Could not retrieve Jenkins password automatically."
    print_status "You can get it manually with: docker exec smart-airport-jenkins cat /var/jenkins_home/secrets/initialAdminPassword"
}

# Setup Jenkins
setup_jenkins() {
    print_status "Setting up Jenkins for Smart Airport..."
    
    # Create necessary directories
    mkdir -p jenkins/{docker,scripts,pipelines,config}
    
    # Start Jenkins
    cd jenkins/docker
    
    if command_exists docker-compose; then
        docker-compose up -d jenkins
    else
        docker compose up -d jenkins
    fi
    
    print_success "Jenkins container started"
    
    # Get initial password
    get_jenkins_password
}

# Install Jenkins plugins
install_plugins() {
    print_status "Installing recommended Jenkins plugins..."
    
    # Wait for Jenkins to be ready
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s http://localhost:8080/login >/dev/null 2>&1; then
            print_success "Jenkins is ready"
            break
        fi
        
        echo "⏳ Waiting for Jenkins to be ready... (attempt $attempt/$max_attempts)"
        sleep 10
        ((attempt++))
    done
    
    if [ $attempt -gt $max_attempts ]; then
        print_error "Jenkins did not start within expected time"
        return 1
    fi
    
    # List of essential plugins for Smart Airport
    local plugins=(
        "git"
        "workflow-aggregator"
        "docker-workflow"
        "pipeline-stage-view"
        "blueocean"
        "prometheus"
        "nodejs"
        "ansible"
        "kubernetes"
        "slack"
        "email-ext"
        "build-timeout"
        "timestamper"
        "ws-cleanup"
    )
    
    print_status "Recommended plugins to install manually:"
    for plugin in "${plugins[@]}"; do
        echo "  - $plugin"
    done
    
    echo ""
    print_status "Install these plugins via Jenkins UI at: http://localhost:8080"
}

# Create Jenkins job
create_jenkins_job() {
    print_status "Jenkins job creation instructions..."
    
    echo ""
    echo "📋 To create the Smart Airport pipeline job:"
    echo "1. Go to http://localhost:8080"
    echo "2. Click 'New Item'"
    echo "3. Enter name: 'smart-airport-pipeline'"
    echo "4. Select 'Pipeline' and click OK"
    echo "5. In Pipeline section:"
    echo "   - Definition: Pipeline script from SCM"
    echo "   - SCM: Git"
    echo "   - Repository URL: your-git-repo-url"
    echo "   - Script Path: jenkins/pipelines/smart-airport-pipeline.groovy"
    echo "6. Save and run the pipeline"
    echo ""
}

# Setup monitoring integration
setup_monitoring_integration() {
    print_status "Setting up monitoring integration..."
    
    # Check if monitoring network exists
    if docker network ls | grep -q "monitoring_monitoring"; then
        print_success "Monitoring network found - Jenkins will integrate with Prometheus/Grafana"
    else
        print_warning "Monitoring network not found. Start monitoring first:"
        echo "  cd monitoring && docker compose up -d"
    fi
}

# Show access information
show_access_info() {
    echo ""
    echo "=== Jenkins Access Information ==="
    echo ""
    echo "🚀 Jenkins Web UI:"
    echo "   URL: http://localhost:8080"
    echo "   Initial setup required on first access"
    echo ""
    echo "🔧 Jenkins Agent Port:"
    echo "   Port: 50000 (for distributed builds)"
    echo ""
    echo "📊 Integration URLs:"
    echo "   Smart Airport: http://localhost:3001"
    echo "   Prometheus: http://localhost:9090"
    echo "   Grafana: http://localhost:3000"
    echo ""
    echo "📁 Jenkins Home:"
    echo "   Volume: jenkins_home"
    echo "   Path: /var/jenkins_home (inside container)"
    echo ""
    echo "🐳 Docker Integration:"
    echo "   Docker socket mounted for building images"
    echo "   Can build and deploy Smart Airport containers"
    echo ""
}

# Check services status
check_services() {
    print_status "Checking Jenkins services..."
    
    cd jenkins/docker
    
    if command_exists docker-compose; then
        docker-compose ps
    else
        docker compose ps
    fi
    
    # Check Jenkins health
    if curl -s http://localhost:8080/login >/dev/null 2>&1; then
        print_success "Jenkins is accessible at http://localhost:8080"
    else
        print_warning "Jenkins might not be ready yet (this is normal for first startup)"
    fi
}

# Main execution
main() {
    case "${1:-setup}" in
        "setup")
            print_status "Setting up complete Jenkins CI/CD for Smart Airport..."
            check_prerequisites
            setup_jenkins
            setup_monitoring_integration
            install_plugins
            create_jenkins_job
            show_access_info
            print_success "Jenkins setup completed!"
            echo ""
            print_status "Next steps:"
            echo "1. Access Jenkins at http://localhost:8080"
            echo "2. Complete initial setup with the admin password shown above"
            echo "3. Install recommended plugins"
            echo "4. Create the Smart Airport pipeline job"
            ;;
        "start")
            print_status "Starting Jenkins..."
            cd jenkins/docker
            if command_exists docker-compose; then
                docker-compose up -d jenkins
            else
                docker compose up -d jenkins
            fi
            check_services
            show_access_info
            ;;
        "stop")
            print_status "Stopping Jenkins..."
            cd jenkins/docker
            if command_exists docker-compose; then
                docker-compose down
            else
                docker compose down
            fi
            print_success "Jenkins stopped"
            ;;
        "restart")
            print_status "Restarting Jenkins..."
            cd jenkins/docker
            if command_exists docker-compose; then
                docker-compose restart jenkins
            else
                docker compose restart jenkins
            fi
            check_services
            ;;
        "status")
            check_services
            show_access_info
            ;;
        "logs")
            cd jenkins/docker
            if command_exists docker-compose; then
                docker-compose logs -f jenkins
            else
                docker compose logs -f jenkins
            fi
            ;;
        "password")
            get_jenkins_password
            ;;
        "cleanup")
            print_status "Cleaning up Jenkins..."
            cd jenkins/docker
            if command_exists docker-compose; then
                docker-compose down -v
            else
                docker compose down -v
            fi
            docker system prune -f
            print_success "Jenkins cleanup completed"
            ;;
        *)
            echo "Usage: $0 {setup|start|stop|restart|status|logs|password|cleanup}"
            echo ""
            echo "Commands:"
            echo "  setup    - Complete Jenkins setup (default)"
            echo "  start    - Start Jenkins"
            echo "  stop     - Stop Jenkins"
            echo "  restart  - Restart Jenkins"
            echo "  status   - Check Jenkins status"
            echo "  logs     - View Jenkins logs"
            echo "  password - Get initial admin password"
            echo "  cleanup  - Remove Jenkins completely"
            exit 1
            ;;
    esac
}

main "$@"
