# Smart Airport - Minimal Kubernetes Setup

## 🎯 Purpose

This is a **minimal Kubernetes setup** for learning and experimentation. Your current Docker setup is perfect for production - use this only when you want to explore Kubernetes.

## 📊 Quick Comparison

| Aspect | Your Docker Setup | This K8s Setup |
|--------|------------------|----------------|
| **Complexity** | Simple ✅ | Complex |
| **Setup Time** | 30 seconds ✅ | 10-30 minutes |
| **Cost** | $10-50/month ✅ | $150-400/month |
| **Maintenance** | Minimal ✅ | Significant |
| **Learning Value** | Low | High 📚 |

## 🚀 Quick Start Options

### Option 1: Local Learning (Minikube) - FREE
```bash
cd kubernetes
chmod +x minikube-setup.sh

# Full setup from scratch
./minikube-setup.sh full

# Or step by step
./minikube-setup.sh install  # Install tools
./minikube-setup.sh start    # Start cluster
./minikube-setup.sh deploy   # Deploy app
```

### Option 2: Cloud Deployment - PAID
```bash
cd kubernetes
chmod +x cloud-deploy.sh

# Google Cloud (easiest)
./cloud-deploy.sh gke

# Azure (your current provider)
./cloud-deploy.sh aks

# AWS
./cloud-deploy.sh eks
```

## 📁 Files Overview

```
kubernetes/
├── README.md                           # This file
├── smart-airport-deployment.yaml       # Basic deployment
├── smart-airport-configmap.yaml        # Environment variables
├── smart-airport-deployment-secure.yaml # Production-ready deployment
├── minikube-setup.sh                   # Local development script
└── cloud-deploy.sh                     # Cloud deployment script
```

## 🔧 What Each File Does

### `smart-airport-deployment.yaml`
- **Purpose**: Basic Kubernetes deployment
- **Features**: 2 replicas, basic health checks, auto-scaling
- **Use**: Simple deployment for learning

### `smart-airport-configmap.yaml`
- **Purpose**: Separates configuration from code
- **Features**: ConfigMap for settings, Secrets for sensitive data
- **Use**: Better security practices

### `smart-airport-deployment-secure.yaml`
- **Purpose**: Production-ready deployment
- **Features**: Security contexts, resource limits, proper probes
- **Use**: Cloud deployment

## 🎓 Learning Path

### 1. Start Local (FREE)
```bash
# Install and run locally
./minikube-setup.sh full

# Check what's running
kubectl get all

# See your app
minikube service smart-airport-service
```

### 2. Understand the Concepts
```bash
# See pods (containers)
kubectl get pods

# See services (networking)
kubectl get services

# See deployments (app management)
kubectl get deployments

# Check logs
kubectl logs -l app=smart-airport

# Scale up/down
kubectl scale deployment smart-airport --replicas=3
```

### 3. Try Cloud (PAID - Optional)
```bash
# Only if you want to spend money learning
./cloud-deploy.sh gke  # Google Cloud
```

## 🛠️ Management Commands

### Check Status
```bash
# All resources
kubectl get all

# Just your app
kubectl get pods,services,deployments -l app=smart-airport

# Detailed info
kubectl describe deployment smart-airport
```

### Scaling
```bash
# Scale to 3 replicas
kubectl scale deployment smart-airport --replicas=3

# Auto-scaling (if HPA is enabled)
kubectl get hpa
```

### Updates
```bash
# Update to new image version
kubectl set image deployment/smart-airport smart-airport=uriel25x/grad-project:v2

# Check rollout status
kubectl rollout status deployment/smart-airport

# Rollback if needed
kubectl rollout undo deployment/smart-airport
```

### Debugging
```bash
# Check logs
kubectl logs -l app=smart-airport

# Get shell in pod
kubectl exec -it deployment/smart-airport -- sh

# Port forward for testing
kubectl port-forward service/smart-airport-service 3001:3001
```

## 💰 Cost Estimates

### Local (Minikube) - FREE
- **Cost**: $0
- **Resources**: Uses your laptop
- **Use**: Learning, development

### Google Cloud (GKE)
- **Cluster**: ~$70/month
- **Nodes**: ~$60/month (2 x e2-medium)
- **Load Balancer**: ~$20/month
- **Total**: ~$150/month

### Azure (AKS)
- **Cluster**: Free
- **Nodes**: ~$80/month (2 x Standard_B2s)
- **Load Balancer**: ~$25/month
- **Total**: ~$105/month

### AWS (EKS)
- **Cluster**: ~$75/month
- **Nodes**: ~$70/month (2 x t3.medium)
- **Load Balancer**: ~$25/month
- **Total**: ~$170/month

## 🆘 Troubleshooting

### Common Issues

#### Minikube Won't Start
```bash
# Check Docker is running
docker ps

# Reset minikube
minikube delete
minikube start
```

#### Pods Not Starting
```bash
# Check pod status
kubectl describe pod <pod-name>

# Check logs
kubectl logs <pod-name>

# Common issue: resource limits
kubectl top nodes
kubectl top pods
```

#### Can't Access Application
```bash
# For minikube
minikube service smart-airport-service

# For cloud
kubectl get services
# Look for EXTERNAL-IP
```

## 🎯 When to Use This

### ✅ Use Kubernetes When:
- Learning container orchestration
- Need auto-scaling (1000+ users)
- Multiple microservices
- Multi-region deployment
- Enterprise requirements

### ❌ Stick with Docker When:
- Single application ✅ **(Your current situation)**
- Small team ✅ **(Your current situation)**
- Budget conscious ✅ **(Your current situation)**
- Want simplicity ✅ **(Your current situation)**

## 🧹 Cleanup

### Local Cleanup
```bash
# Remove app
./minikube-setup.sh cleanup

# Stop cluster
./minikube-setup.sh stop

# Complete removal
minikube delete
```

### Cloud Cleanup
```bash
# Remove app
./cloud-deploy.sh cleanup

# Follow the instructions to delete cluster
# (This will stop billing)
```

## 📚 Next Steps

1. **Try Local First**: Start with minikube to learn concepts
2. **Understand Basics**: Learn pods, services, deployments
3. **Experiment**: Try scaling, updates, rollbacks
4. **Consider Cloud**: Only if you need enterprise features
5. **Return to Docker**: For your actual production needs 😊

---

**Remember**: This is for learning! Your current Docker setup is perfect for Smart Airport's needs.

**💡 Pro Tip**: Master Docker first, then learn Kubernetes when you actually need it (probably never for this project).
