# Ansible Quick Reference - Smart Airport Project

## 🚀 Quick Deployment Commands

### Full Deployment (New Server)
```bash
cd ~/smart-air-port/ansible
ansible-playbook playbooks/deploy-full.yml -i inventory/onprems
```

### Application Update Only
```bash
cd ~/smart-air-port/ansible
ansible-playbook playbooks/deploy-app-only.yml -i inventory/onprems
```

### Docker Deployment
```bash
cd ~/smart-air-port/ansible
ansible-playbook playbooks/deploy-docker.yml -i inventory/onprems
```

### Test Connection
```bash
cd ~/smart-air-port/ansible
ansible all -i inventory/onprems -m ping

# Or test SSH connection manually:
ssh -i ~/Downloads/GradServer_key.pem azureuser@51.105.241.63
```

## 📋 Manual vs Ansible Comparison

| Task | Manual Process | Ansible Traditional | Ansible Docker |
|------|----------------|---------------------|-----------------|
| **Time** | 30-60 minutes | 5-10 minutes | 8-12 minutes |
| **Errors** | Human mistakes possible | Automated, consistent | Automated, consistent |
| **Rollback** | Manual, complex | Automatic on failure | Container-based rollback |
| **Scaling** | Repeat for each server | One command, all servers | Container orchestration |
| **Isolation** | Process-level | Process-level | Container-level |
| **Portability** | Server-specific | Server-specific | Highly portable |

## 🔧 Your Deployment Process

### What Ansible Does (Matches Your Manual Steps):
```bash
# 1. System Setup
sudo apt update
sudo apt install unzip nodejs npm -y

# 2. Runtime Installation  
curl -fsSL https://bun.sh/install | bash

# 3. Global Tools
npm install -g @nestjs/cli
npm install -g pm2

# 4. Application Deployment
bun install
bun add --dev @swc/core @swc/cli
bun run build
pm2 start bun --name smart-airport -- run start
```

## 🐳 Docker Alternative

### Local Docker Development:
```bash
cd ~/smart-air-port/docker
./setup.sh setup
```

### Docker via Ansible:
```bash
cd ~/smart-air-port/ansible
ansible-playbook playbooks/deploy-docker.yml -i inventory/onprems
```

### Docker Benefits:
- ✅ **Container Isolation**: Better security and resource management
- ✅ **Consistent Environments**: Same setup everywhere
- ✅ **Easy Scaling**: Horizontal scaling with container orchestration
- ✅ **Quick Setup**: Faster local development environment

## 🎯 Target Configuration

- **Server**: `51.105.241.63`
- **User**: `azureuser`
- **Port**: `3001`
- **Application**: NestJS Smart Airport
- **Process Manager**: PM2
- **Runtime**: Bun

## 📁 File Locations on Server

```
/home/azureuser/smart-air-port/
├── dist/                 # Built application
├── src/                  # Source code
├── node_modules/         # Dependencies
├── logs/                 # PM2 logs
├── .env                  # Environment variables
├── ecosystem.config.js   # PM2 configuration
└── package.json          # Project configuration
```

## 🔍 Verification Commands

```bash
# Check application status
ansible all -i inventory/onprems -m shell -a "pm2 list"

# View logs
ansible all -i inventory/onprems -m shell -a "pm2 logs smart-airport --lines 20"

# Check services
ansible all -i inventory/onprems -m shell -a "systemctl status mongod redis-server"

# Test application
curl http://51.105.241.63:3001/health
```

## 🆘 Emergency Commands

```bash
# Restart application
ansible all -i inventory/onprems -m shell -a "pm2 restart smart-airport"

# Stop application
ansible all -i inventory/onprems -m shell -a "pm2 stop smart-airport"

# View system resources
ansible all -i inventory/onprems -m shell -a "free -h && df -h"
```

## 📞 Support

- **Application URL**: http://51.105.241.63:3001
- **API Docs**: http://51.105.241.63:3001/api
- **Logs Location**: `/home/azureuser/smart-air-port/logs/`
- **Configuration**: `/home/azureuser/smart-air-port/.env`
