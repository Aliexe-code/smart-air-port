#!/bin/bash

# Smart Airport Docker Setup Script
# This script helps you set up and manage the Docker environment

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

# Function to check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! docker compose version &> /dev/null; then
        print_error "Docker Compose is not available. Please install Docker Compose first."
        exit 1
    fi
    
    print_success "Docker and Docker Compose are installed."
}

# Function to setup environment file
setup_env() {
    if [ ! -f .env ]; then
        print_status "Creating .env file from template..."
        cp .env.example .env
        print_warning "Please edit .env file with your configuration before starting services."
        print_status "You can edit it with: nano .env"
    else
        print_status ".env file already exists."
    fi
}

# Function to build and start services
start_services() {
    print_status "Building and starting Smart Airport services..."

    # Create logs directory
    mkdir -p logs

    # Build images
    print_status "Building backend image..."
    docker compose build backend

    # Start services
    print_status "Starting all services..."
    docker compose up -d
    
    # Wait for services to be healthy
    print_status "Waiting for services to be ready..."
    sleep 30
    
    # Check service status
    print_status "Checking service status..."
    docker compose ps

    print_success "Smart Airport services are running!"
    print_status "Backend API: http://localhost:3001"
    print_status "API Documentation: http://localhost:3001/api"
    print_status "Health Check: http://localhost:3001/health"
}

# Function to stop services
stop_services() {
    print_status "Stopping Smart Airport services..."
    docker compose down
    print_success "Services stopped."
}

# Function to view logs
view_logs() {
    print_status "Viewing application logs (Press Ctrl+C to exit)..."
    docker compose logs -f
}

# Function to check health
check_health() {
    print_status "Checking service health..."
    
    # Check if containers are running
    if ! docker compose ps | grep -q "Up"; then
        print_error "Services are not running. Start them first with: ./setup.sh start"
        exit 1
    fi

    # Check backend health
    if curl -f http://localhost:3001/health &> /dev/null; then
        print_success "Backend is healthy"
    else
        print_error "Backend health check failed"
    fi

    # Check MongoDB
    if docker compose exec -T mongodb mongosh --eval "db.adminCommand('ping')" &> /dev/null; then
        print_success "MongoDB is healthy"
    else
        print_error "MongoDB health check failed"
    fi

    # Check Redis
    if docker compose exec -T redis redis-cli ping &> /dev/null; then
        print_success "Redis is healthy"
    else
        print_error "Redis health check failed"
    fi
}

# Function to show usage
show_usage() {
    cat << EOF
Smart Airport Docker Setup Script

Usage: $0 [COMMAND]

Commands:
    setup       Setup environment and start services
    start       Start all services
    stop        Stop all services
    restart     Restart all services
    logs        View application logs
    health      Check service health
    status      Show service status
    build       Build and push Docker image to registry
    pull        Pull latest image from registry
    clean       Stop services and remove volumes (⚠️  deletes data)
    help        Show this help message

Examples:
    $0 setup       # First time setup
    $0 start       # Start services
    $0 logs        # View logs
    $0 health      # Check if everything is working

EOF
}

# Main script logic
case "${1:-}" in
    setup)
        print_status "Setting up Smart Airport Docker environment..."
        check_docker
        setup_env
        start_services
        check_health
        print_success "Setup complete! Your Smart Airport application is running."
        ;;
    start)
        check_docker
        start_services
        ;;
    stop)
        stop_services
        ;;
    restart)
        print_status "Restarting services..."
        docker compose restart
        print_success "Services restarted."
        ;;
    logs)
        view_logs
        ;;
    health)
        check_health
        ;;
    status)
        print_status "Service status:"
        docker compose ps
        ;;
    build)
        print_status "Building and pushing Docker image..."
        ./build-and-push.sh
        ;;
    pull)
        print_status "Pulling latest image from registry..."
        docker compose pull backend
        print_success "Latest image pulled successfully."
        ;;
    clean)
        print_warning "This will stop services and delete all data. Are you sure? (y/N)"
        read -r response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            print_status "Cleaning up..."
            docker compose down -v
            print_success "Cleanup complete."
        else
            print_status "Cleanup cancelled."
        fi
        ;;
    help|--help|-h)
        show_usage
        ;;
    "")
        print_error "No command specified."
        show_usage
        exit 1
        ;;
    *)
        print_error "Unknown command: $1"
        show_usage
        exit 1
        ;;
esac
