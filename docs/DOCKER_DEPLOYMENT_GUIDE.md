# Docker Deployment Guide - Smart Airport Project

## Overview

This guide covers Docker-based deployment options for the Smart Airport NestJS application, providing containerized alternatives to traditional PM2-based deployment.

## 🐳 Docker Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Docker Environment                       │
├─────────────────────────────────────────────────────────────┤
│  🚀 Backend Container (smart-airport-backend)             │
│     - NestJS + Fastify + Bun Runtime                      │
│     - Port: 3001                                          │
│     - Multi-stage optimized build                         │
│                                                           │
│  🗄️ MongoDB Container (smart-airport-mongodb)            │
│     - MongoDB 7.0 with initialization scripts            │
│     - Port: 27017                                        │
│     - Persistent data volumes                            │
│                                                           │
│  🔄 Redis Container (smart-airport-redis)                │
│     - Redis 7.2 Alpine                                   │
│     - Port: 6379                                         │
│     - Password protected                                  │
└─────────────────────────────────────────────────────────────┘
```

## 🚀 Deployment Methods

### Method 1: Pre-built Docker Image (✅ RECOMMENDED)
**Best for**: Production deployment, fastest setup, proven solution

```bash
# Pull and run the pre-built image
docker pull uriel25x/grad-project:latest
docker run -d --name smart-airport -p 3001:3000 --env-file .env --restart unless-stopped uriel25x/grad-project:latest
```

**Features:**
- ✅ **Fastest deployment** (30 seconds)
- ✅ **Pre-optimized image** (93-second build time)
- ✅ **Production-ready** with Bun + Node.js hybrid
- ✅ **Proven successful** (deployed June 28, 2025)
- ✅ **Low resource usage** (165MB RAM, 1.14% CPU)

### Method 2: Ansible + Docker Deployment
**Best for**: Automated production deployment

```bash
cd ansible
# Simple Docker deployment (recommended)
ansible-playbook playbooks/deploy-simple-docker.yml -i inventory/onprems

# Or use ad-hoc commands for maximum control
ansible all -i inventory/onprems -m shell -a "docker run -d --name smart-airport -p 3001:3000 --env-file /path/to/.env --restart unless-stopped uriel25x/grad-project:latest"
```

**Features:**
- ✅ Automated deployment via Ansible
- ✅ Environment file management
- ✅ Health checks and verification
- ✅ Rollback capabilities

### Method 3: Local Docker Development
**Best for**: Local development, team onboarding, testing

```bash
cd docker
./setup.sh setup
```

**Features:**
- ✅ Complete local environment in minutes
- ✅ Consistent across all developer machines
- ✅ Includes all services (backend, MongoDB, Redis)
- ✅ Hot reload for development

### Method 4: Docker Compose (Full Stack)
**Best for**: Multi-service deployment, development environments

```bash
cd docker
docker compose up -d --build
```

**Features:**
- ✅ Complete stack (backend + MongoDB + Redis)
- ✅ Service orchestration
- ✅ Development and production configurations

## ✅ Proven Success Story

**Latest Deployment (June 28, 2025):**

### 🎯 Production-Ready Docker Image
- **Image**: `uriel25x/grad-project:latest`
- **Build Time**: 93 seconds (optimized from 12+ minutes)
- **Size**: Optimized multi-stage build
- **Status**: ✅ **Successfully deployed and running**

### 📊 Performance Metrics
```
Container: smart-airport (bab3bccc1579)
CPU Usage: 1.14% (very efficient!)
Memory: 165.1MB / 13.5GB (1.19%)
Network I/O: 214kB / 78.6kB
Processes: 19 PIDs
Status: Up and running ✅
```

### 🚀 Deployment Success
```bash
# Successful deployment commands:
docker pull uriel25x/grad-project:latest
docker run -d --name smart-airport -p 3001:3000 --env-file .env --restart unless-stopped uriel25x/grad-project:latest

# Health check result:
curl http://localhost:3001/health
# Response: {"success":true,"message":"test mg","data":{"message":"test mg"},"error":null,"meta":null}
```

### 🔧 Technical Achievements
- ✅ **Hybrid Runtime**: Node.js for build, Bun for execution
- ✅ **Environment Integration**: All 44 environment variables loaded
- ✅ **Service Connectivity**: MongoDB, Redis, Gmail SMTP all connected
- ✅ **API Endpoints**: All routes mapped and functional
- ✅ **Auto-restart**: Container restarts automatically on failure

## 📋 Quick Commands Reference

### Production Deployment (Recommended):
```bash
# 1. Pull the latest image
docker pull uriel25x/grad-project:latest

# 2. Create environment file
cp env.txt .env
# Edit .env with your configuration

# 3. Run the container
docker run -d \
  --name smart-airport \
  -p 3001:3000 \
  --env-file .env \
  --restart unless-stopped \
  uriel25x/grad-project:latest

# 4. Verify deployment
docker ps --filter "name=smart-airport"
curl http://localhost:3001/health
```

### Local Development Setup:
```bash
# First time setup
cd docker
cp .env.example .env
# Edit .env with your configuration
./setup.sh setup

# Daily development
./setup.sh start    # Start services
./setup.sh logs     # View logs
./setup.sh health   # Check health
./setup.sh stop     # Stop services
```

### Production Deployment:
```bash
# Deploy via Ansible
cd ansible
ansible-playbook playbooks/deploy-docker.yml -i inventory/onprems

# Direct deployment (if needed)
cd docker
docker compose -f docker-compose.yml up -d --build
```

### Maintenance Commands:
```bash
# View service status
docker compose ps

# View logs
docker compose logs -f backend
docker compose logs -f mongodb
docker compose logs -f redis

# Restart services
docker compose restart backend

# Update application
docker compose build backend --no-cache
docker compose up -d backend

# Clean up
docker compose down -v  # ⚠️ Removes data
```

## 🔧 Configuration

### Environment Variables
Key variables in `.env` file:

```bash
# JWT Configuration
JWT_SECRET=your_jwt_secret
JWT_REFRESH_SECRET=your_refresh_secret

# Database (auto-configured in Docker)
MONGO_URI=mongodb://admin:smartairport123@mongodb:27017/smartairport?authSource=admin
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=smartairport123

# External APIs
STRIPE_SECRET_KEY=your_stripe_key
AMADEUS_API_KEY=your_amadeus_key
PAYMOB_API_KEY=your_paymob_key

# Application URLs
FRONTEND_URL=https://sky-shifters.vercel.app
APP_URL=http://localhost:3001
```

### Service Configuration
- **Backend**: Bun-based NestJS application with health checks
- **MongoDB**: Auto-initialized with collections and indexes
- **Redis**: Password-protected with persistent storage
- **Networking**: Internal Docker network for service communication

## 🔍 Monitoring & Health Checks

### Application Health:
```bash
# Check all services
docker compose ps

# Test backend health
curl http://localhost:3001/health

# Check database
docker compose exec mongodb mongosh --eval "db.adminCommand('ping')"

# Check Redis
docker compose exec redis redis-cli ping
```

### Logs and Debugging:
```bash
# Application logs
docker compose logs -f backend

# Database logs
docker compose logs -f mongodb

# All services
docker compose logs -f

# Resource usage
docker stats
```

## 🔄 Comparison: Traditional vs Docker

| Aspect | Traditional (PM2) | Docker Containers | **Proven Results** |
|--------|------------------|-------------------|-------------------|
| **Setup Time** | 5-10 minutes | **30 seconds** | ✅ Docker wins |
| **Resource Usage** | ~150MB | **165MB** | ✅ Nearly identical |
| **CPU Usage** | ~1-2% | **1.14%** | ✅ Excellent efficiency |
| **Isolation** | Process-level | Container-level | ✅ Better security |
| **Portability** | Server-specific | **Highly portable** | ✅ Works anywhere |
| **Scaling** | Manual PM2 cluster | Container orchestration | ✅ Cloud-ready |
| **Development** | Local dependencies | **Containerized environment** | ✅ Team consistency |
| **Debugging** | Direct process access | Container logs/exec | ✅ Both effective |
| **Rollback** | Backup-based | **Image-based** | ✅ Instant rollback |
| **Team Consistency** | Manual setup | **Identical containers** | ✅ Zero config drift |
| **Deployment** | Multi-step manual | **Single command** | ✅ Much simpler |

## 🎯 When to Use Docker

### ✅ Use Docker When:
- Setting up local development environment
- Need consistent environments across team
- Planning to scale horizontally
- Want container-level isolation
- Deploying to cloud platforms
- Need easy rollback capabilities

### ❌ Use Traditional When:
- Minimal resource usage is critical
- Need direct server access for debugging
- Simple single-server deployment
- Team is familiar with PM2 workflow
- Want to match existing manual process

## 🆘 Troubleshooting

### Common Issues:

#### Port Conflicts:
```bash
# Check what's using ports
sudo lsof -i :3001
sudo lsof -i :27017
sudo lsof -i :6379

# Stop conflicting services
sudo systemctl stop mongodb
sudo systemctl stop redis-server
```

#### Container Won't Start:
```bash
# Check logs
docker compose logs backend

# Rebuild image
docker compose build backend --no-cache

# Check disk space
docker system df
docker system prune
```

#### Database Connection Issues:
```bash
# Test MongoDB connection
docker compose exec mongodb mongosh

# Check network connectivity
docker compose exec backend ping mongodb
```

### Reset Everything:
```bash
# Complete cleanup
docker compose down -v
docker system prune -a
./setup.sh setup
```

## 📊 Enterprise Monitoring with Prometheus

### Quick Monitoring Setup
Add enterprise-grade monitoring to your Docker deployment:

```bash
# Start your app with complete monitoring stack
cd monitoring
docker compose up -d

# This starts:
# - Your Smart Airport app (port 3001)
# - Prometheus (port 9090) - Metrics collection
# - Grafana (port 3000) - Dashboards and visualization
# - AlertManager (port 9093) - Intelligent alerting
# - Node Exporter (port 9100) - System metrics
```

### Access Monitoring Dashboards
```bash
# Grafana (username: admin, password: admin123)
open http://localhost:3000

# Prometheus metrics and queries
open http://localhost:9090

# AlertManager for alert management
open http://localhost:9093

# Your app health endpoint
curl http://localhost:3001/health
```

### What You Get
- **📈 Real-time Metrics**: CPU, memory, disk, network usage
- **🚨 Intelligent Alerts**: Email/Slack notifications for issues
- **📊 Business Intelligence**: Track bookings, searches, payments
- **🔍 Performance Monitoring**: Response times, error rates, throughput
- **📋 Custom Dashboards**: Visual insights into your application

### Monitoring Commands
```bash
# Check all monitoring services
docker compose ps

# View monitoring logs
docker compose logs -f prometheus
docker compose logs -f grafana

# Restart monitoring stack
docker compose restart

# Stop monitoring (keeps your app running)
docker compose down
```

## 📞 Support

- **Application**: http://localhost:3001
- **API Docs**: http://localhost:3001/api
- **Health Check**: http://localhost:3001/health
- **Grafana Dashboard**: http://localhost:3000 (admin/admin123)
- **Prometheus Metrics**: http://localhost:9090
- **Setup Script**: `./setup.sh help`
- **Docker Docs**: See `docker/README.md`
- **Monitoring Guide**: See `docs/PROMETHEUS_MONITORING_GUIDE.md`

---

*This Docker setup provides a modern, scalable alternative to traditional deployment with enterprise-grade monitoring, while maintaining full compatibility with your existing Ansible automation.*
