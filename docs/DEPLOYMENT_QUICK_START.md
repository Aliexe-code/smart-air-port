# Smart Airport - Deployment Quick Start Guide

## 🚀 Fastest Deployment (30 seconds)

**✅ PROVEN METHOD - Successfully deployed June 28, 2025**

### Prerequisites
- Docker installed and running
- Environment file ready (`env.txt`)

### One-Command Deployment
```bash
# Pull and run the production-ready image
docker pull uriel25x/grad-project:latest
docker run -d --name smart-airport -p 3001:3000 --env-file env.txt --restart unless-stopped uriel25x/grad-project:latest

# Verify deployment
curl http://localhost:3001/health
```

**Expected Response:**
```json
{"success":true,"message":"test mg","data":{"message":"test mg"},"error":null,"meta":null}
```

## 🎯 Deployment Options

| Method | Time | Best For | Command |
|--------|------|----------|---------|
| **Docker (Recommended)** | 30s | Production, Testing | `docker run uriel25x/grad-project:latest` |
| **Ansible + Docker** | 2min | Automated deployment | `ansible-playbook deploy-simple-docker.yml` |
| **Traditional PM2** | 5min | Direct server control | `ansible-playbook deploy-full.yml` |
| **Docker Compose** | 3min | Full development stack | `docker compose up -d` |

## 📋 Step-by-Step Instructions

### Method 1: Docker (Fastest) ⚡
```bash
# 1. Ensure Docker is running
docker --version

# 2. Create environment file
cp env.txt .env
# Edit .env if needed

# 3. Deploy
docker pull uriel25x/grad-project:latest
docker run -d \
  --name smart-airport \
  -p 3001:3000 \
  --env-file .env \
  --restart unless-stopped \
  uriel25x/grad-project:latest

# 4. Test
curl http://localhost:3001/health
```

### Method 2: Ansible + Docker (Automated) 🤖
```bash
# 1. Navigate to ansible directory
cd ansible

# 2. Verify connectivity
ansible all -i inventory/onprems -m ping

# 3. Deploy with ad-hoc commands (fastest)
ansible all -i inventory/onprems -m shell -a "docker pull uriel25x/grad-project:latest"
ansible all -i inventory/onprems -m shell -a "docker run -d --name smart-airport -p 3001:3000 --env-file /path/to/.env --restart unless-stopped uriel25x/grad-project:latest"

# 4. Verify
ansible all -i inventory/onprems -m uri -a "url=http://localhost:3001/health method=GET"
```

### Method 3: Traditional PM2 (Full Control) 🔧
```bash
cd ansible
ansible-playbook playbooks/deploy-full.yml -i inventory/onprems
```

## 🔍 Verification & Monitoring

### Health Checks
```bash
# Application health
curl http://localhost:3001/health

# Container status
docker ps --filter "name=smart-airport"

# Resource usage
docker stats smart-airport --no-stream

# Application logs
docker logs --tail 20 smart-airport
```

### Expected Results
- **Status**: Container running
- **CPU**: ~1-2%
- **Memory**: ~165MB
- **Response Time**: <100ms
- **Health**: 200 OK

## 🛠️ Management Commands

### Container Management
```bash
# Start/Stop
docker start smart-airport
docker stop smart-airport

# Restart
docker restart smart-airport

# Update to latest
docker pull uriel25x/grad-project:latest
docker stop smart-airport && docker rm smart-airport
docker run -d --name smart-airport -p 3001:3000 --env-file .env --restart unless-stopped uriel25x/grad-project:latest

# Remove
docker stop smart-airport && docker rm smart-airport
```

### Logs & Debugging
```bash
# View logs
docker logs smart-airport
docker logs -f smart-airport  # Follow logs

# Execute commands in container
docker exec -it smart-airport sh

# Container details
docker inspect smart-airport
```

## 🆘 Troubleshooting

### Common Issues

#### Port Already in Use
```bash
# Check what's using port 3001
sudo lsof -i :3001

# Stop conflicting service
sudo systemctl stop service-name
```

#### Container Won't Start
```bash
# Check logs
docker logs smart-airport

# Remove and recreate
docker stop smart-airport && docker rm smart-airport
# Then run the docker run command again
```

#### Health Check Fails
```bash
# Wait for startup (can take 30-60 seconds)
sleep 30 && curl http://localhost:3001/health

# Check container logs
docker logs smart-airport

# Verify environment file
docker exec smart-airport env | grep JWT_SECRET
```

## 📊 Performance Benchmarks

**Proven Performance (June 28, 2025):**
- **Deployment Time**: 30 seconds
- **CPU Usage**: 1.14%
- **Memory Usage**: 165MB
- **Build Time**: 93 seconds (optimized)
- **Container Size**: Optimized multi-stage
- **Startup Time**: ~15 seconds
- **Response Time**: <50ms

## 🌐 Access Points

Once deployed, your application is available at:
- **Main Application**: http://localhost:3001
- **Health Check**: http://localhost:3001/health
- **API Documentation**: http://localhost:3001/api (if available)

## 📞 Support

- **Docker Issues**: See `docs/DOCKER_DEPLOYMENT_GUIDE.md`
- **Ansible Issues**: See `docs/ANSIBLE_DEPLOYMENT_GUIDE.md`
- **Application Issues**: Check container logs with `docker logs smart-airport`

---

**🎉 Congratulations! Your Smart Airport application is now deployed and running!**
