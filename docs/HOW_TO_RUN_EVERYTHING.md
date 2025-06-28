# Smart Airport - How to Run Everything

## 🎯 Complete Command Guide

This guide contains **every command** you need to run your Smart Airport project using Docker, Ansible, and Kubernetes.

## 📋 Prerequisites Check

### Check if Tools are Installed
```bash
# Check Docker
docker --version
docker ps

# Check Ansible
ansible --version

# Check Node.js/Bun (for local development)
node --version
bun --version

# Check Git
git --version
```

### Install Missing Tools
```bash
# Install Docker (Ubuntu/Debian)
sudo apt update
sudo apt install docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Install Ansible
sudo apt install ansible

# Install Node.js and Bun
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
curl -fsSL https://bun.sh/install | bash
```

## 🚀 Method 1: Docker (RECOMMENDED - 30 seconds)

### Quick Start
```bash
# Navigate to project
cd /home/uriel/smart-air-port

# Pull and run the application
docker pull uriel25x/grad-project:latest
docker run -d \
  --name smart-airport \
  -p 3001:3000 \
  --env-file env.txt \
  --restart unless-stopped \
  uriel25x/grad-project:latest

# Test the application
curl http://localhost:3001/health
```

### Docker Management Commands
```bash
# Check container status
docker ps

# View logs
docker logs smart-airport
docker logs -f smart-airport  # Follow logs

# Stop/Start container
docker stop smart-airport
docker start smart-airport

# Restart container
docker restart smart-airport

# Update to latest version
docker pull uriel25x/grad-project:latest
docker stop smart-airport
docker rm smart-airport
docker run -d \
  --name smart-airport \
  -p 3001:3000 \
  --env-file env.txt \
  --restart unless-stopped \
  uriel25x/grad-project:latest

# Remove container
docker stop smart-airport
docker rm smart-airport

# View container stats
docker stats smart-airport

# Execute commands in container
docker exec -it smart-airport sh
```

### Build Your Own Image (Optional)
```bash
# Navigate to docker directory
cd docker

# Build the image
docker build -f Dockerfile.backend -t uriel25x/grad-project:latest ..

# Push to registry (if you have access)
docker login
docker push uriel25x/grad-project:latest
```

## 🤖 Method 2: Ansible (Automated Deployment)

### Prerequisites
```bash
# Ensure Docker and Ansible are running
sudo systemctl status docker
ansible --version

# Navigate to ansible directory
cd ansible
```

### Quick Ansible Deployment
```bash
# Test connectivity
ansible all -i inventory/onprems -m ping

# Deploy using ad-hoc commands (fastest)
ansible all -i inventory/onprems -m shell -a "docker stop smart-airport || true && docker rm smart-airport || true"
ansible all -i inventory/onprems -m shell -a "docker pull uriel25x/grad-project:latest"
ansible all -i inventory/onprems -m file -a "path=/home/uriel/smart-airport state=directory mode=0755"
ansible all -i inventory/onprems -m copy -a "src=../env.txt dest=/home/uriel/smart-airport/.env mode=0600"
ansible all -i inventory/onprems -m shell -a "docker run -d --name smart-airport -p 3001:3000 --env-file /home/uriel/smart-airport/.env --restart unless-stopped uriel25x/grad-project:latest"

# Verify deployment
ansible all -i inventory/onprems -m shell -a "docker ps --filter 'name=smart-airport'"
ansible all -i inventory/onprems -m uri -a "url=http://localhost:3001/health method=GET"
```

### Ansible Playbook Deployment
```bash
# Deploy using playbooks
ansible-playbook -i inventory/onprems playbooks/deploy-full.yml -v
ansible-playbook -i inventory/onprems playbooks/deploy-app-only.yml -v
ansible-playbook -i inventory/onprems playbooks/deploy-docker.yml -v

# Using deploy script
chmod +x deploy.sh
./deploy.sh full     # Full deployment
./deploy.sh app      # App only
./deploy.sh docker   # Docker deployment
```

### Ansible Management Commands
```bash
# Check application status
ansible all -i inventory/onprems -m shell -a "docker ps"
ansible all -i inventory/onprems -m shell -a "pm2 list"

# View logs
ansible all -i inventory/onprems -m shell -a "docker logs smart-airport --tail 20"
ansible all -i inventory/onprems -m shell -a "pm2 logs smart-airport --lines 50"

# Restart application
ansible all -i inventory/onprems -m shell -a "docker restart smart-airport"
ansible all -i inventory/onprems -m shell -a "pm2 restart smart-airport"

# Update application
ansible all -i inventory/onprems -m shell -a "docker pull uriel25x/grad-project:latest"
ansible all -i inventory/onprems -m shell -a "docker stop smart-airport && docker rm smart-airport"
ansible all -i inventory/onprems -m shell -a "docker run -d --name smart-airport -p 3001:3000 --env-file /home/uriel/smart-airport/.env --restart unless-stopped uriel25x/grad-project:latest"
```

### Azure Server Deployment (When Server is Accessible)
```bash
# Update inventory for Azure server
# Edit ansible/inventory/onprems:
# server_01 ansible_host=51.105.241.63 ansible_user=azureuser
# ansible_user=azureuser
# ansible_ssh_private_key_file=~/Downloads/GradServer_key.pem

# Test Azure connectivity
ssh -i ~/Downloads/GradServer_key.pem azureuser@51.105.241.63
ansible all -i inventory/onprems -m ping

# Deploy to Azure
ansible-playbook -i inventory/onprems playbooks/deploy-full.yml -v
```

## 🚢 Method 3: Kubernetes (Learning/Enterprise)

### Prerequisites
```bash
# Navigate to kubernetes directory
cd kubernetes

# Make scripts executable
chmod +x *.sh
```

### Local Kubernetes (Minikube)
```bash
# Install tools
./minikube-setup.sh install

# Start cluster
./minikube-setup.sh start

# Deploy application
./minikube-setup.sh deploy

# Full setup (install + start + deploy)
./minikube-setup.sh full

# Check status
./minikube-setup.sh status

# Get application URL
minikube service smart-airport-service --url

# Test application
curl $(minikube service smart-airport-service --url)/health
```

### Manual Kubernetes Deployment
```bash
# Apply configurations
kubectl apply -f smart-airport-configmap.yaml
kubectl apply -f smart-airport-secrets.yaml
kubectl apply -f smart-airport-deployment-secure.yaml
kubectl apply -f smart-airport-service.yaml

# Or apply all at once
kubectl apply -f .

# Check deployment
kubectl get all -l app=smart-airport
kubectl get pods -l app=smart-airport
kubectl get services
```

### Kubernetes Management Commands
```bash
# View resources
kubectl get all -l app=smart-airport
kubectl get pods -l app=smart-airport
kubectl get services
kubectl get deployments

# Scale application
kubectl scale deployment smart-airport --replicas=3
kubectl scale deployment smart-airport --replicas=5

# Update application
kubectl set image deployment/smart-airport smart-airport=uriel25x/grad-project:v2
kubectl rollout status deployment/smart-airport

# Rollback if needed
kubectl rollout undo deployment/smart-airport

# View logs
kubectl logs -l app=smart-airport
kubectl logs -l app=smart-airport -f  # Follow logs

# Debug pods
kubectl describe pods -l app=smart-airport
kubectl exec -it deployment/smart-airport -- sh

# Port forward for local access
kubectl port-forward service/smart-airport-service 3001:3001

# Cleanup
kubectl delete -f .
./minikube-setup.sh cleanup
./minikube-setup.sh stop
```

### Cloud Kubernetes Deployment
```bash
# Google Cloud (GKE)
./cloud-deploy.sh gke

# Azure (AKS)
./cloud-deploy.sh aks

# AWS (EKS)
./cloud-deploy.sh eks

# Deploy to existing cluster
./cloud-deploy.sh deploy

# Check status
./cloud-deploy.sh status

# Cleanup
./cloud-deploy.sh cleanup
```

## 🛠️ Local Development (Traditional)

### Using Node.js + Bun
```bash
# Navigate to project root
cd /home/uriel/smart-air-port

# Install dependencies
npm install
# or
bun install

# Set up environment
cp env.txt .env
# Edit .env file as needed

# Run in development mode
npm run start:dev
# or
bun run start:dev

# Run in production mode
npm run build
npm run start:prod
# or
bun run build
bun run start:prod

# Run tests
npm test
# or
bun test
```

### Using PM2 (Process Manager)
```bash
# Install PM2 globally
npm install -g pm2

# Start application
pm2 start bun --name smart-airport -- run start:prod

# PM2 management
pm2 list                    # List processes
pm2 logs smart-airport      # View logs
pm2 restart smart-airport   # Restart app
pm2 stop smart-airport      # Stop app
pm2 delete smart-airport    # Remove app
pm2 monit                   # Monitor resources
```

## 🧪 Testing Commands

### Health Checks
```bash
# Docker
curl http://localhost:3001/health

# Ansible (local)
curl http://localhost:3001/health

# Ansible (Azure server)
curl http://51.105.241.63:3001/health

# Kubernetes (minikube)
curl $(minikube service smart-airport-service --url)/health

# Local development
curl http://localhost:3000/health
```

### Load Testing
```bash
# Simple load test
for i in {1..100}; do
  curl -s http://localhost:3001/health > /dev/null
  echo "Request $i completed"
done

# With timing
time for i in {1..50}; do curl -s http://localhost:3001/health > /dev/null; done
```

### API Testing
```bash
# Test different endpoints
curl http://localhost:3001/health
curl http://localhost:3001/api
curl http://localhost:3001/users
curl http://localhost:3001/flights

# Test with headers
curl -H "Content-Type: application/json" http://localhost:3001/health
```

## 🔍 Monitoring Commands

### Docker Monitoring
```bash
# Container stats
docker stats smart-airport

# System resources
docker system df
docker system info

# Container inspection
docker inspect smart-airport
```

### System Monitoring
```bash
# CPU and memory
htop
top

# Disk usage
df -h
du -sh /home/uriel/smart-air-port

# Network
netstat -tulpn | grep 3001
ss -tulpn | grep 3001

# Processes
ps aux | grep smart-airport
```

### Log Monitoring
```bash
# Docker logs
docker logs smart-airport --tail 50 -f

# System logs
journalctl -u docker -f
tail -f /var/log/syslog

# Application logs (if using PM2)
pm2 logs smart-airport --lines 50
```

## 🆘 Troubleshooting Commands

### Port Issues
```bash
# Check what's using port 3001
sudo lsof -i :3001
sudo netstat -tulpn | grep 3001

# Kill process using port
sudo kill -9 $(sudo lsof -t -i:3001)
```

### Docker Issues
```bash
# Restart Docker service
sudo systemctl restart docker

# Clean up Docker
docker system prune -a
docker volume prune
docker network prune

# Check Docker logs
journalctl -u docker.service
```

### Permission Issues
```bash
# Fix Docker permissions
sudo usermod -aG docker $USER
newgrp docker

# Fix file permissions
sudo chown -R $USER:$USER /home/uriel/smart-air-port
chmod +x kubernetes/*.sh
chmod +x ansible/deploy.sh
```

## 📊 Quick Reference Summary

### Fastest Deployment (30 seconds)
```bash
cd /home/uriel/smart-air-port
docker run -d --name smart-airport -p 3001:3000 --env-file env.txt --restart unless-stopped uriel25x/grad-project:latest
curl http://localhost:3001/health
```

### Most Automated (2 minutes)
```bash
cd ansible
ansible all -i inventory/onprems -m shell -a "docker run -d --name smart-airport -p 3001:3000 --env-file /path/to/.env --restart unless-stopped uriel25x/grad-project:latest"
```

### Most Educational (10 minutes)
```bash
cd kubernetes
./minikube-setup.sh full
curl $(minikube service smart-airport-service --url)/health
```

### Most Traditional (5 minutes)
```bash
cd /home/uriel/smart-air-port
bun install
bun run build
pm2 start bun --name smart-airport -- run start:prod
```

## 🚨 Common Issues & Solutions

### Issue: "Port 3001 already in use"
```bash
# Find what's using the port
sudo lsof -i :3001

# Kill the process
sudo kill -9 $(sudo lsof -t -i:3001)

# Or use different port
docker run -d --name smart-airport -p 3002:3000 --env-file env.txt uriel25x/grad-project:latest
```

### Issue: "Docker permission denied"
```bash
# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Restart Docker service
sudo systemctl restart docker
```

### Issue: "Container won't start"
```bash
# Check logs
docker logs smart-airport

# Common fixes:
# 1. Check environment file exists
ls -la env.txt

# 2. Recreate container
docker stop smart-airport
docker rm smart-airport
docker run -d --name smart-airport -p 3001:3000 --env-file env.txt --restart unless-stopped uriel25x/grad-project:latest
```

### Issue: "Ansible connection failed"
```bash
# Test SSH connection
ssh -i ~/Downloads/GradServer_key.pem azureuser@51.105.241.63

# Check inventory file
cat ansible/inventory/onprems

# Test Ansible connectivity
ansible all -i ansible/inventory/onprems -m ping
```

### Issue: "Kubernetes pods not starting"
```bash
# Check pod status
kubectl get pods -l app=smart-airport

# Describe pod for details
kubectl describe pod <pod-name>

# Check if secrets exist
kubectl get secrets
kubectl get configmaps

# Apply missing resources
kubectl apply -f kubernetes/smart-airport-secrets.yaml
kubectl apply -f kubernetes/smart-airport-configmap.yaml
```

### Issue: "Health check fails"
```bash
# Wait for application to start (can take 30-60 seconds)
sleep 30

# Check if container is running
docker ps

# Check logs for errors
docker logs smart-airport

# Test different endpoint
curl http://localhost:3001/
```

### Issue: "Out of disk space"
```bash
# Clean Docker
docker system prune -a

# Clean logs
sudo journalctl --vacuum-time=7d

# Check disk usage
df -h
du -sh /home/uriel/smart-air-port
```

## 📞 Getting Help

### Check Status Commands
```bash
# Docker status
docker ps -a
docker images
docker system df

# System status
systemctl status docker
free -h
df -h

# Application status
curl http://localhost:3001/health
docker logs smart-airport --tail 10
```

### Useful Log Locations
```bash
# Docker logs
docker logs smart-airport

# System logs
journalctl -u docker.service
/var/log/syslog

# Application logs (if using PM2)
~/.pm2/logs/
```

### Reset Everything (Nuclear Option)
```bash
# Stop and remove all containers
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)

# Remove all images
docker rmi $(docker images -q)

# Clean system
docker system prune -a

# Restart Docker
sudo systemctl restart docker

# Start fresh
docker pull uriel25x/grad-project:latest
docker run -d --name smart-airport -p 3001:3000 --env-file env.txt --restart unless-stopped uriel25x/grad-project:latest
```

## 📊 Method 4: Prometheus Monitoring (Enterprise Monitoring)

### Quick Start Monitoring
```bash
# Navigate to monitoring directory
cd monitoring

# Start monitoring stack (Prometheus, Grafana, AlertManager, Node Exporter)
docker compose up -d prometheus grafana node-exporter alertmanager

# Check status
docker compose ps

# Access monitoring tools
# Grafana: http://localhost:3000 (admin/admin123)
# Prometheus: http://localhost:9090
# AlertManager: http://localhost:9093
# Node Exporter: http://localhost:9100
```

### Monitoring Management Commands
```bash
# Start all monitoring services
cd monitoring
docker compose up -d

# Start specific services
docker compose up -d prometheus grafana

# Check service status
docker compose ps

# View logs
docker compose logs -f prometheus
docker compose logs -f grafana

# Stop monitoring
docker compose down

# Restart services
docker compose restart prometheus
```

### Health Checks
```bash
# Check Smart Airport health
curl http://localhost:3001/health

# Check Prometheus health
curl http://localhost:9090/-/healthy

# Check Grafana health
curl http://localhost:3000/api/health

# Check Node Exporter metrics
curl http://localhost:9100/metrics
```

### Access Monitoring Dashboards
```bash
# Open Grafana (username: admin, password: admin123)
xdg-open http://localhost:3000

# Open Prometheus
xdg-open http://localhost:9090

# Open AlertManager
xdg-open http://localhost:9093
```

## 🚀 Method 5: Jenkins CI/CD (Automated Deployment)

### Quick Start Jenkins
```bash
# Navigate to project root
cd /home/uriel/smart-air-port

# Start Jenkins with setup script
./jenkins/scripts/setup-jenkins.sh setup

# Access Jenkins UI
open http://localhost:8080

# Get admin password (if needed)
./jenkins/scripts/setup-jenkins.sh password
```

### Jenkins Management Commands
```bash
# Start Jenkins
./jenkins/scripts/setup-jenkins.sh start

# Stop Jenkins
./jenkins/scripts/setup-jenkins.sh stop

# Restart Jenkins
./jenkins/scripts/setup-jenkins.sh restart

# Check status
./jenkins/scripts/setup-jenkins.sh status

# View logs
./jenkins/scripts/setup-jenkins.sh logs

# Complete cleanup
./jenkins/scripts/setup-jenkins.sh cleanup
```

### Pipeline Operations
```bash
# Trigger build manually (via UI)
# Go to http://localhost:8080/job/smart-airport-pipeline/build

# Check build status
curl http://localhost:8080/job/smart-airport-pipeline/lastBuild/api/json

# View build logs
curl http://localhost:8080/job/smart-airport-pipeline/lastBuild/consoleText

# Access Jenkins container
docker exec -it smart-airport-jenkins bash
```

### CI/CD Pipeline Features
- **🔍 Automated Checkout**: Git repository integration
- **🧪 Quality Checks**: Linting, security audit, testing
- **🏗️ Build Process**: Application compilation and Docker image creation
- **🧪 Container Testing**: Health checks and API validation
- **🚀 Deployment**: Staging (auto) and Production (manual approval)
- **📊 Monitoring Integration**: Post-deploy health checks and metrics

### Access Jenkins Services
```bash
# Jenkins Web UI
open http://localhost:8080

# Jenkins with monitoring integration
# - Prometheus: http://localhost:9090
# - Grafana: http://localhost:3000
# - Smart Airport: http://localhost:3001
```

**🎉 You now have every command needed to run Smart Airport with any method including enterprise monitoring and CI/CD automation!**
