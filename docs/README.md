# Smart Airport Project Documentation

Welcome to the Smart Airport project documentation directory.

## 📚 Available Documentation

### 🤖 Deployment & Infrastructure
- **[HOW_TO_RUN_EVERYTHING.md](./HOW_TO_RUN_EVERYTHING.md)** - 🎯 **COMPLETE GUIDE** - Every command for every tool
- **[COMMAND_CHEAT_SHEET.md](./COMMAND_CHEAT_SHEET.md)** - ⚡ **QUICK REFERENCE** - Most common commands
- **[DEPLOYMENT_QUICK_START.md](./DEPLOYMENT_QUICK_START.md)** - 30-second deployment guide
- **[DOCKER_DEPLOYMENT_GUIDE.md](./DOCKER_DEPLOYMENT_GUIDE.md)** - Docker deployment and usage guide
- **[ANSIBLE_DEPLOYMENT_GUIDE.md](./ANSIBLE_DEPLOYMENT_GUIDE.md)** - Comprehensive guide to Ansible automation
- **[JENKINS_CI_CD_GUIDE.md](./JENKINS_CI_CD_GUIDE.md)** - 🚀 CI/CD automation with Jenkins
- **[PROMETHEUS_MONITORING_GUIDE.md](./PROMETHEUS_MONITORING_GUIDE.md)** - 📊 Enterprise monitoring with Prometheus
- **[KUBERNETES_GUIDE.md](./KUBERNETES_GUIDE.md)** - 🚢 What is Kubernetes and its role in your project
- **[KUBERNETES_HANDS_ON.md](./KUBERNETES_HANDS_ON.md)** - 🧪 Practical Kubernetes experiments
- **[KUBERNETES_QUICK_REFERENCE.md](./KUBERNETES_QUICK_REFERENCE.md)** - 📋 Essential Kubernetes commands
- **[ANSIBLE_QUICK_REFERENCE.md](./ANSIBLE_QUICK_REFERENCE.md)** - Quick commands and troubleshooting
- **[WHAT_IS_DOCKER_GUIDE.md](./WHAT_IS_DOCKER_GUIDE.md)** - What is Docker and its role in your project

### 💳 Payment Integration
- **[PAYMOB_PAYMENT_INTEGRATION.md](./PAYMOB_PAYMENT_INTEGRATION.md)** - PayMob payment gateway integration
- **[STRIPE_PAYMENT_INTEGRATION_DOCS.md](./STRIPE_PAYMENT_INTEGRATION_DOCS.md)** - Stripe payment integration
- **[test-paymob-sdk.md](./test-paymob-sdk.md)** - PayMob SDK testing guide

### 🎫 Booking System
- **[booking-module-api.md](./booking-module-api.md)** - Booking module API documentation
- **[round-trip-booking-feature.md](./round-trip-booking-feature.md)** - Round trip booking implementation
- **[postman-testing-guide-number-of-stops.md](./postman-testing-guide-number-of-stops.md)** - Testing guide for stops

### 👤 User Management
- **[user-module-api.md](./user-module-api.md)** - User module API documentation

### 🔔 Notifications
- **[notification.md](./notification.md)** - Notification system documentation

## 🚀 Quick Start

### ⚡ Fastest Deployment (30 seconds):
```bash
docker pull uriel25x/grad-project:latest
docker run -d --name smart-airport -p 3001:3000 --env-file env.txt --restart unless-stopped uriel25x/grad-project:latest
curl http://localhost:3001/health
```
**👆 See [HOW_TO_RUN_EVERYTHING.md](./HOW_TO_RUN_EVERYTHING.md) for ALL commands or [COMMAND_CHEAT_SHEET.md](./COMMAND_CHEAT_SHEET.md) for quick reference**

### For Complete Command Reference:
1. **All Commands**: [HOW_TO_RUN_EVERYTHING.md](./HOW_TO_RUN_EVERYTHING.md) - Every command for Docker, Ansible, Kubernetes
2. **Quick Reference**: [COMMAND_CHEAT_SHEET.md](./COMMAND_CHEAT_SHEET.md) - Most common commands and troubleshooting
3. **Quick Start**: [DEPLOYMENT_QUICK_START.md](./DEPLOYMENT_QUICK_START.md) - Proven 30-second deployment

### For Detailed Guides:
1. **Docker Deep Dive**: [DOCKER_DEPLOYMENT_GUIDE.md](./DOCKER_DEPLOYMENT_GUIDE.md) - Containerized deployment
2. **Ansible Automation**: [ANSIBLE_DEPLOYMENT_GUIDE.md](./ANSIBLE_DEPLOYMENT_GUIDE.md) - Automated deployment
3. **Understanding Docker**: [WHAT_IS_DOCKER_GUIDE.md](./WHAT_IS_DOCKER_GUIDE.md) - Containerization concepts

### For Learning Kubernetes:
1. **Understanding K8s**: Start with [KUBERNETES_GUIDE.md](./KUBERNETES_GUIDE.md) - what it is and when to use it
2. **Hands-On Practice**: Try [KUBERNETES_HANDS_ON.md](./KUBERNETES_HANDS_ON.md) - practical experiments
3. **Daily Commands**: Reference [KUBERNETES_QUICK_REFERENCE.md](./KUBERNETES_QUICK_REFERENCE.md) for operations
4. **Remember**: Your Docker setup is still perfect for production! K8s is for learning and enterprise scale.

### For Enterprise Monitoring:
1. **Prometheus Setup**: Follow [PROMETHEUS_MONITORING_GUIDE.md](./PROMETHEUS_MONITORING_GUIDE.md) - complete monitoring stack
2. **Quick Start**: `cd monitoring && docker compose up -d` - start monitoring in 2 minutes
3. **Access Monitoring**: Prometheus (http://localhost:9090), AlertManager (http://localhost:9093)
4. **Benefits**: Real-time metrics, alerting, performance insights, business intelligence

### For CI/CD Automation:
1. **Jenkins Setup**: Follow [JENKINS_CI_CD_GUIDE.md](./JENKINS_CI_CD_GUIDE.md) - complete CI/CD pipeline
2. **Quick Start**: `./jenkins/scripts/setup-jenkins.sh setup` - start Jenkins in 5 minutes
3. **Access Jenkins**: http://localhost:8080 - automated build and deployment
4. **Benefits**: Automated testing, deployment pipelines, build history, quality gates

### For Development:
1. Check the main [README.md](../README.md) in project root
2. Review API documentation for specific modules
3. Test payment integrations using provided guides

## 🏗️ Project Architecture

```
Smart Airport Application
├── 🚀 NestJS + Fastify Framework
├── 📦 Bun Runtime
├── 🗄️ MongoDB Database
├── 🔄 Redis Caching
├── ⚡ PM2 Process Manager
├── 💳 Payment Gateways (Stripe, PayMob)
├── ✈️ Amadeus Flight API
└── 🤖 Ansible Deployment Automation
```

## 📊 Latest Deployment Status

**✅ Successfully Deployed: June 28, 2025**
- **Method**: Docker + Ansible
- **Image**: `uriel25x/grad-project:latest`
- **Performance**: 1.14% CPU, 165MB RAM
- **Health**: http://localhost:3001/health ✅
- **Deployment Time**: 30 seconds

## 📞 Support & Contact

- **Local**: http://localhost:3001
- **Azure Server**: 51.105.241.63:3001 (when accessible)
- **Environment**: Production
- **Deployment**: Docker + Ansible automation
- **Monitoring**: Docker stats + health checks

---

*This documentation is maintained alongside the codebase and updated with each deployment.*
