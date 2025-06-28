# Smart Airport - Command Cheat Sheet

## ⚡ Quick Commands Reference

### 🐳 Docker (RECOMMENDED - 30 seconds)
```bash
# Start application
docker run -d --name smart-airport -p 3001:3000 --env-file env.txt --restart unless-stopped uriel25x/grad-project:latest

# Check status
docker ps

# View logs
docker logs smart-airport -f

# Restart
docker restart smart-airport

# Stop & remove
docker stop smart-airport && docker rm smart-airport

# Test health
curl http://localhost:3001/health
```

### 🤖 Ansible (2 minutes)
```bash
# Navigate to ansible directory
cd ansible

# Quick deployment
ansible all -i inventory/onprems -m shell -a "docker run -d --name smart-airport -p 3001:3000 --env-file /home/uriel/smart-airport/.env --restart unless-stopped uriel25x/grad-project:latest"

# Check status
ansible all -i inventory/onprems -m shell -a "docker ps"

# Test connectivity
ansible all -i inventory/onprems -m ping

# View logs
ansible all -i inventory/onprems -m shell -a "docker logs smart-airport --tail 20"
```

### 🚢 Kubernetes (10 minutes)
```bash
# Navigate to kubernetes directory
cd kubernetes

# Full setup
./minikube-setup.sh full

# Get URL
minikube service smart-airport-service --url

# Scale
kubectl scale deployment smart-airport --replicas=3

# View status
kubectl get all -l app=smart-airport

# View logs
kubectl logs -l app=smart-airport -f

# Cleanup
./minikube-setup.sh cleanup
```

### 📊 Prometheus Monitoring (2 minutes)
```bash
# Navigate to monitoring directory
cd monitoring

# Start complete monitoring stack
docker compose up -d

# Access monitoring tools
# Prometheus: http://localhost:9090
# AlertManager: http://localhost:9093

# Check monitoring status
docker compose ps

# View monitoring logs
docker compose logs -f prometheus

# Stop monitoring
docker compose down
```

### 🚀 Jenkins CI/CD (5 minutes)
```bash
# Navigate to project root
cd /home/uriel/smart-air-port

# Start Jenkins
./jenkins/scripts/setup-jenkins.sh setup

# Access Jenkins UI
open http://localhost:8080

# Management commands
./jenkins/scripts/setup-jenkins.sh start    # Start
./jenkins/scripts/setup-jenkins.sh stop     # Stop
./jenkins/scripts/setup-jenkins.sh status   # Status
./jenkins/scripts/setup-jenkins.sh logs     # Logs
```

### 🛠️ Local Development
```bash
# Install dependencies
bun install

# Run development
bun run start:dev

# Run production
bun run build && bun run start:prod

# Using PM2
pm2 start bun --name smart-airport -- run start:prod
pm2 logs smart-airport
pm2 restart smart-airport
```

## 🔍 Monitoring Commands

### Check Application Health
```bash
# Docker
curl http://localhost:3001/health

# Kubernetes
curl $(minikube service smart-airport-service --url)/health

# Local dev
curl http://localhost:3000/health

# Monitoring health
curl http://localhost:9090/-/healthy    # Prometheus
```

### View Logs
```bash
# Docker
docker logs smart-airport --tail 50 -f

# Kubernetes
kubectl logs -l app=smart-airport -f

# PM2
pm2 logs smart-airport
```

### Check Resources
```bash
# Docker stats
docker stats smart-airport

# System resources
htop
df -h

# Kubernetes resources
kubectl top pods -l app=smart-airport
```

## 🚨 Troubleshooting

### Port Already in Use
```bash
sudo lsof -i :3001
sudo kill -9 $(sudo lsof -t -i:3001)
```

### Container Won't Start
```bash
docker logs smart-airport
docker stop smart-airport && docker rm smart-airport
# Then run docker run command again
```

### Permission Denied
```bash
sudo usermod -aG docker $USER
newgrp docker
```

### Reset Everything
```bash
docker stop smart-airport && docker rm smart-airport
docker system prune -a
# Then start fresh
```

## 📊 Quick Status Check

### One-Command Status
```bash
# Docker
docker ps --filter "name=smart-airport" && curl -s http://localhost:3001/health

# Kubernetes
kubectl get pods -l app=smart-airport && curl -s $(minikube service smart-airport-service --url)/health

# System
docker ps && free -h && df -h
```

## 🎯 Most Common Workflows

### Daily Development
```bash
# 1. Check if running
docker ps

# 2. View logs
docker logs smart-airport -f

# 3. Restart if needed
docker restart smart-airport

# 4. Test changes
curl http://localhost:3001/health
```

### Deploy New Version
```bash
# 1. Pull latest
docker pull uriel25x/grad-project:latest

# 2. Stop current
docker stop smart-airport && docker rm smart-airport

# 3. Start new
docker run -d --name smart-airport -p 3001:3000 --env-file env.txt --restart unless-stopped uriel25x/grad-project:latest

# 4. Test
curl http://localhost:3001/health
```

### Debug Issues
```bash
# 1. Check container status
docker ps -a

# 2. Check logs
docker logs smart-airport

# 3. Check system resources
docker stats smart-airport

# 4. Check port usage
sudo lsof -i :3001

# 5. Get shell access
docker exec -it smart-airport sh
```

## 📁 File Locations

### Important Files
```bash
/home/uriel/smart-air-port/env.txt              # Environment variables
/home/uriel/smart-air-port/docker/              # Docker files
/home/uriel/smart-air-port/ansible/             # Ansible playbooks
/home/uriel/smart-air-port/kubernetes/          # Kubernetes manifests
/home/uriel/smart-air-port/docs/                # Documentation
```

### Configuration Files
```bash
ansible/inventory/onprems                       # Ansible inventory
kubernetes/smart-airport-configmap.yaml         # K8s configuration
kubernetes/smart-airport-secrets.yaml           # K8s secrets
docker/Dockerfile.backend                       # Docker build file
```

## 🎯 Choose Your Method

| Method | Time | Complexity | Best For |
|--------|------|------------|----------|
| **Docker** | 30s | Simple | Production ✅ |
| **Ansible** | 2min | Medium | Automation |
| **Kubernetes** | 10min | Complex | Learning |
| **Monitoring** | 2min | Simple | Enterprise insights |
| **Jenkins** | 5min | Medium | CI/CD automation |
| **Local Dev** | 5min | Simple | Development |

## 📞 Emergency Commands

### Application Down
```bash
docker restart smart-airport
# or
docker stop smart-airport && docker rm smart-airport
docker run -d --name smart-airport -p 3001:3000 --env-file env.txt --restart unless-stopped uriel25x/grad-project:latest
```

### System Issues
```bash
sudo systemctl restart docker
docker system prune -a
```

### Complete Reset
```bash
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
docker system prune -a
# Then redeploy
```

**🚀 Keep this cheat sheet handy for daily operations!**
