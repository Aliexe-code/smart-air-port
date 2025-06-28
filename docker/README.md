# Smart Airport Docker Setup

This directory contains Docker configuration for the Smart Airport application with separate containers for backend and database services.

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Docker Environment                       │
├─────────────────────────────────────────────────────────────┤
│  🚀 Backend Container (smart-airport-backend)             │
│     - NestJS + Fastify + Bun Runtime                      │
│     - Port: 3001                                          │
│     - Health checks enabled                               │
│                                                           │
│  🗄️ MongoDB Container (smart-airport-mongodb)            │
│     - MongoDB 7.0                                        │
│     - Port: 27017                                        │
│     - Persistent data storage                            │
│     - Initialization scripts                             │
│                                                           │
│  🔄 Redis Container (smart-airport-redis)                │
│     - Redis 7.2 Alpine                                   │
│     - Port: 6379                                         │
│     - Password protected                                  │
│     - Persistent data storage                            │
└─────────────────────────────────────────────────────────────┘
```

## 🚀 Quick Start

### Prerequisites
- Docker Engine 20.10+
- Docker Compose 2.0+

### 1. Setup Environment
```bash
cd docker
cp .env.example .env
# Edit .env with your configuration
```

### 2. Build and Start Services
```bash
# Build and start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Check status
docker-compose ps
```

### 3. Access Application
- **Backend API**: http://localhost:3001
- **API Documentation**: http://localhost:3001/api
- **Health Check**: http://localhost:3001/health
- **MongoDB**: localhost:27017
- **Redis**: localhost:6379

## 📋 Available Commands

### Development Commands
```bash
# Start services in development mode
docker compose up

# Start services in background
docker compose up -d

# View logs
docker compose logs -f backend
docker compose logs -f mongodb
docker compose logs -f redis

# Stop services
docker compose down

# Stop and remove volumes (⚠️ deletes data)
docker compose down -v
```

### Registry Commands
```bash
# Build and push to your registry
./build-and-push.sh

# Build with specific tag
./build-and-push.sh v1.0.0

# Pull latest image
docker compose pull backend

# Use setup script for registry operations
./setup.sh build    # Build and push
./setup.sh pull     # Pull latest
```

### Maintenance Commands
```bash
# Rebuild backend image
docker-compose build backend

# Restart specific service
docker-compose restart backend

# Execute commands in containers
docker-compose exec backend bun --version
docker-compose exec mongodb mongosh
docker-compose exec redis redis-cli

# View container stats
docker stats
```

## 🔧 Configuration

### Environment Variables
Key environment variables in `.env`:

| Variable | Description | Default |
|----------|-------------|---------|
| `JWT_SECRET` | JWT signing secret | Required |
| `MONGO_URI` | MongoDB connection | Auto-configured |
| `REDIS_HOST` | Redis host | Auto-configured |
| `STRIPE_SECRET_KEY` | Stripe API key | Optional |
| `AMADEUS_API_KEY` | Amadeus API key | Optional |
| `FRONTEND_URL` | Frontend URL | Required |

### Database Configuration
- **MongoDB**: Automatically initialized with collections and indexes
- **Redis**: Password-protected with persistent storage
- **Data Persistence**: Volumes ensure data survives container restarts

## 🔍 Health Checks

All services include health checks:
- **Backend**: HTTP health endpoint
- **MongoDB**: Database ping
- **Redis**: Redis ping

Check health status:
```bash
docker-compose ps
```

## 📊 Monitoring

### View Application Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend

# Last 100 lines
docker-compose logs --tail=100 backend
```

### Resource Usage
```bash
# Container stats
docker stats

# Disk usage
docker system df
```

## 🔒 Security Features

- **Non-root user**: Backend runs as non-root user
- **Password protection**: Database services are password-protected
- **Network isolation**: Services communicate via internal network
- **Health checks**: Automatic service health monitoring

## 🚀 Production Deployment

For production deployment:

1. **Update environment variables** in `.env`
2. **Configure reverse proxy** (Nginx/Traefik)
3. **Set up SSL certificates**
4. **Configure backup strategy** for data volumes
5. **Set up monitoring and logging**

## 🆘 Troubleshooting

### Common Issues

#### Backend won't start
```bash
# Check logs
docker-compose logs backend

# Rebuild image
docker-compose build backend --no-cache
```

#### Database connection issues
```bash
# Check MongoDB status
docker-compose exec mongodb mongosh --eval "db.adminCommand('ping')"

# Check network connectivity
docker-compose exec backend ping mongodb
```

#### Port conflicts
```bash
# Check what's using the port
sudo lsof -i :3001
sudo lsof -i :27017
sudo lsof -i :6379
```

### Reset Everything
```bash
# Stop and remove everything
docker-compose down -v

# Remove images
docker-compose down --rmi all

# Start fresh
docker-compose up -d
```

## 📞 Support

- **Application URL**: http://localhost:3001
- **Health Check**: http://localhost:3001/health
- **Logs**: `docker-compose logs -f`
- **Status**: `docker-compose ps`
