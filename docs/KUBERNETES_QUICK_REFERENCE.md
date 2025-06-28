# Smart Airport - Kubernetes Quick Reference

## 🚀 Essential Commands

### Cluster Management
```bash
# Start local cluster
./minikube-setup.sh start

# Check cluster status
kubectl cluster-info

# Stop cluster
minikube stop

# Delete cluster
minikube delete
```

### Application Deployment
```bash
# Deploy Smart Airport
kubectl apply -f smart-airport-configmap.yaml
kubectl apply -f smart-airport-secrets.yaml
kubectl apply -f smart-airport-deployment-secure.yaml
kubectl apply -f smart-airport-service.yaml

# Deploy all at once
kubectl apply -f .

# Remove deployment
kubectl delete -f .
```

### Viewing Resources
```bash
# All Smart Airport resources
kubectl get all -l app=smart-airport

# Pods only
kubectl get pods -l app=smart-airport

# Services
kubectl get services

# Deployments
kubectl get deployments

# ConfigMaps and Secrets
kubectl get configmaps,secrets
```

### Scaling
```bash
# Scale up
kubectl scale deployment smart-airport --replicas=5

# Scale down
kubectl scale deployment smart-airport --replicas=2

# Check current replicas
kubectl get deployment smart-airport
```

### Updates and Rollbacks
```bash
# Update image
kubectl set image deployment/smart-airport smart-airport=uriel25x/grad-project:v2

# Check rollout status
kubectl rollout status deployment/smart-airport

# View rollout history
kubectl rollout history deployment/smart-airport

# Rollback to previous version
kubectl rollout undo deployment/smart-airport

# Rollback to specific revision
kubectl rollout undo deployment/smart-airport --to-revision=2
```

### Logs and Debugging
```bash
# View logs
kubectl logs -l app=smart-airport

# Follow logs
kubectl logs -l app=smart-airport -f

# Logs from specific pod
kubectl logs smart-airport-7fb46ffc77-abc123

# Get shell in pod
kubectl exec -it deployment/smart-airport -- sh

# Port forward for local access
kubectl port-forward service/smart-airport-service 3001:3001
```

### Configuration Management
```bash
# View ConfigMap
kubectl get configmap smart-airport-config -o yaml

# Edit ConfigMap
kubectl edit configmap smart-airport-config

# Update ConfigMap
kubectl patch configmap smart-airport-config -p '{"data":{"NODE_ENV":"development"}}'

# Restart deployment to pick up changes
kubectl rollout restart deployment/smart-airport
```

## 🔍 Troubleshooting Guide

### Pod Not Starting
```bash
# Check pod status
kubectl get pods -l app=smart-airport

# Describe pod for details
kubectl describe pod <pod-name>

# Check events
kubectl get events --sort-by=.metadata.creationTimestamp

# Common issues:
# - Image pull errors
# - Missing secrets/configmaps
# - Resource limits
# - Health check failures
```

### Service Not Accessible
```bash
# Check service
kubectl get service smart-airport-service

# Check endpoints
kubectl get endpoints smart-airport-service

# For minikube, get URL
minikube service smart-airport-service --url

# Test connectivity
kubectl run test-pod --image=busybox --rm -it -- wget -qO- smart-airport-service:3001/health
```

### Configuration Issues
```bash
# Check if ConfigMap exists
kubectl get configmap smart-airport-config

# Check if Secret exists
kubectl get secret smart-airport-secrets

# View environment variables in pod
kubectl exec deployment/smart-airport -- env | grep -E "(JWT|MONGO|REDIS)"
```

## 📊 Monitoring Commands

### Resource Usage
```bash
# Node resources
kubectl top nodes

# Pod resources
kubectl top pods -l app=smart-airport

# Describe node
kubectl describe node minikube
```

### Health Checks
```bash
# Check pod readiness
kubectl get pods -l app=smart-airport -o wide

# Test health endpoint
SERVICE_URL=$(minikube service smart-airport-service --url)
curl $SERVICE_URL/health

# Check deployment status
kubectl get deployment smart-airport -o wide
```

### Performance Testing
```bash
# Load test (simple)
for i in {1..100}; do curl -s $(minikube service smart-airport-service --url)/health > /dev/null; done

# Watch pod behavior during load
kubectl get pods -l app=smart-airport -w
```

## 🔧 Configuration Examples

### Environment Variables
```yaml
# In deployment.yaml
env:
- name: NODE_ENV
  valueFrom:
    configMapKeyRef:
      name: smart-airport-config
      key: NODE_ENV
- name: JWT_SECRET
  valueFrom:
    secretKeyRef:
      name: smart-airport-secrets
      key: JWT_SECRET
```

### Resource Limits
```yaml
# In deployment.yaml
resources:
  requests:
    memory: "200Mi"
    cpu: "100m"
  limits:
    memory: "500Mi"
    cpu: "500m"
```

### Health Checks
```yaml
# In deployment.yaml
livenessProbe:
  httpGet:
    path: /health
    port: 3000
  initialDelaySeconds: 30
  periodSeconds: 10
readinessProbe:
  httpGet:
    path: /health
    port: 3000
  initialDelaySeconds: 5
  periodSeconds: 5
```

## 🚀 Common Workflows

### Development Workflow
```bash
# 1. Start cluster
./minikube-setup.sh start

# 2. Deploy app
kubectl apply -f smart-airport-deployment-secure.yaml
kubectl apply -f smart-airport-service.yaml

# 3. Get access URL
minikube service smart-airport-service --url

# 4. Make changes to code, build new image
docker build -t uriel25x/grad-project:v2 .
docker push uriel25x/grad-project:v2

# 5. Update deployment
kubectl set image deployment/smart-airport smart-airport=uriel25x/grad-project:v2

# 6. Test changes
curl $(minikube service smart-airport-service --url)/health
```

### Production Deployment Workflow
```bash
# 1. Deploy to staging
kubectl apply -f . --namespace=staging

# 2. Run tests
kubectl run test --image=test-suite --namespace=staging

# 3. Deploy to production
kubectl apply -f . --namespace=production

# 4. Monitor deployment
kubectl rollout status deployment/smart-airport --namespace=production

# 5. Verify health
kubectl get pods -l app=smart-airport --namespace=production
```

### Scaling Workflow
```bash
# 1. Monitor current load
kubectl top pods -l app=smart-airport

# 2. Scale based on demand
kubectl scale deployment smart-airport --replicas=5

# 3. Monitor scaling
kubectl get pods -l app=smart-airport -w

# 4. Verify load distribution
for i in {1..10}; do curl -s $(minikube service smart-airport-service --url)/health; done
```

## 🎯 Best Practices

### Security
```bash
# Use secrets for sensitive data
kubectl create secret generic smart-airport-secrets --from-env-file=.env

# Run containers as non-root
securityContext:
  runAsNonRoot: true
  runAsUser: 1000

# Limit container capabilities
securityContext:
  capabilities:
    drop:
    - ALL
```

### Resource Management
```bash
# Always set resource requests and limits
resources:
  requests:
    memory: "200Mi"
    cpu: "100m"
  limits:
    memory: "500Mi"
    cpu: "500m"

# Use horizontal pod autoscaler
kubectl autoscale deployment smart-airport --cpu-percent=70 --min=2 --max=10
```

### Monitoring
```bash
# Use labels for organization
metadata:
  labels:
    app: smart-airport
    version: v1
    environment: production

# Implement health checks
livenessProbe:
  httpGet:
    path: /health
    port: 3000
readinessProbe:
  httpGet:
    path: /health
    port: 3000
```

## 📚 Learning Resources

### Official Documentation
- [Kubernetes Docs](https://kubernetes.io/docs/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

### Tutorials
- [Kubernetes Basics](https://kubernetes.io/docs/tutorials/kubernetes-basics/)
- [Learn Kubernetes](https://learnk8s.io/)

### Tools
- [k9s](https://k9scli.io/) - Terminal UI for Kubernetes
- [Lens](https://k8slens.dev/) - Desktop IDE for Kubernetes
- [Helm](https://helm.sh/) - Package manager for Kubernetes

## 🎯 Remember

### For Smart Airport:
- **Docker is perfect** for your current needs
- **Kubernetes is valuable** for learning
- **Use this reference** when experimenting
- **Consider migration** only at enterprise scale

### Key Commands to Remember:
```bash
kubectl get all -l app=smart-airport    # See everything
kubectl logs -l app=smart-airport -f     # Follow logs
kubectl scale deployment smart-airport --replicas=3  # Scale
minikube service smart-airport-service --url  # Get access URL
```

**🚀 Happy Kubernetes learning with Smart Airport!**
