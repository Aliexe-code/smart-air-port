# Smart Airport - Kubernetes Hands-On Guide

## 🎯 Practical Kubernetes Experience

This guide provides hands-on experience with Kubernetes using your Smart Airport application. You'll learn by doing!

## 🚀 Quick Start (5 Minutes)

### Prerequisites
- Docker installed and running
- Your Smart Airport project

### Step 1: Start Local Kubernetes
```bash
cd kubernetes
./minikube-setup.sh full
```

**What happens:**
- Installs minikube and kubectl
- Starts local Kubernetes cluster
- Deploys your Smart Airport app
- Creates 2 replicas for high availability

### Step 2: Access Your App
```bash
# Get the URL
minikube service smart-airport-service --url

# Test health endpoint
curl $(minikube service smart-airport-service --url)/health
```

**Expected Result:**
```json
{"success":true,"message":"test mg","data":{"message":"test mg"},"error":null,"meta":null}
```

## 🧪 Hands-On Experiments

### Experiment 1: Scaling Your Application

#### See Current State
```bash
kubectl get pods -l app=smart-airport
```
**Output:**
```
NAME                             READY   STATUS    RESTARTS   AGE
smart-airport-7fb46ffc77-abc123  1/1     Running   0          2m
smart-airport-7fb46ffc77-def456  1/1     Running   0          2m
```

#### Scale Up (Simulate Traffic Growth)
```bash
# Scale to 5 replicas
kubectl scale deployment smart-airport --replicas=5

# Watch pods being created
kubectl get pods -l app=smart-airport -w
```

#### Scale Down (Optimize Resources)
```bash
# Scale back to 2 replicas
kubectl scale deployment smart-airport --replicas=2
```

**💡 Learning:** Kubernetes makes scaling instant and automatic!

### Experiment 2: Self-Healing (Fault Tolerance)

#### Kill a Pod (Simulate Crash)
```bash
# Get pod name
kubectl get pods -l app=smart-airport

# Delete one pod (replace with actual pod name)
kubectl delete pod smart-airport-7fb46ffc77-abc123

# Watch Kubernetes automatically create a new one
kubectl get pods -l app=smart-airport -w
```

**💡 Learning:** Kubernetes automatically replaces failed containers!

### Experiment 3: Rolling Updates (Zero Downtime)

#### Simulate App Update
```bash
# Update to a "new version" (same image for demo)
kubectl set image deployment/smart-airport smart-airport=uriel25x/grad-project:latest

# Watch the rolling update
kubectl rollout status deployment/smart-airport

# Check rollout history
kubectl rollout history deployment/smart-airport
```

#### Rollback if Needed
```bash
# Rollback to previous version
kubectl rollout undo deployment/smart-airport
```

**💡 Learning:** Kubernetes updates apps without downtime!

### Experiment 4: Load Balancing

#### Test Load Distribution
```bash
# Get service URL
SERVICE_URL=$(minikube service smart-airport-service --url)

# Make multiple requests and see different pods respond
for i in {1..10}; do
  echo "Request $i:"
  curl -s $SERVICE_URL/health | jq .
  sleep 1
done
```

**💡 Learning:** Kubernetes automatically distributes traffic across pods!

### Experiment 5: Configuration Management

#### View Current Configuration
```bash
# See ConfigMap
kubectl get configmap smart-airport-config -o yaml

# See Secrets (values are base64 encoded)
kubectl get secret smart-airport-secrets -o yaml
```

#### Update Configuration
```bash
# Update a config value
kubectl patch configmap smart-airport-config -p '{"data":{"NODE_ENV":"development"}}'

# Restart deployment to pick up changes
kubectl rollout restart deployment/smart-airport
```

**💡 Learning:** Kubernetes separates configuration from code!

## 📊 Monitoring and Debugging

### Check Application Health
```bash
# Overall cluster status
kubectl cluster-info

# All Smart Airport resources
kubectl get all -l app=smart-airport

# Detailed pod information
kubectl describe pods -l app=smart-airport

# Application logs
kubectl logs -l app=smart-airport --tail=20

# Follow logs in real-time
kubectl logs -l app=smart-airport -f
```

### Resource Usage
```bash
# Node resources
kubectl top nodes

# Pod resources (if metrics-server is enabled)
kubectl top pods -l app=smart-airport
```

### Troubleshooting
```bash
# Get events
kubectl get events --sort-by=.metadata.creationTimestamp

# Debug a specific pod
kubectl describe pod <pod-name>

# Get shell access to pod
kubectl exec -it deployment/smart-airport -- sh
```

## 🔄 Comparison with Docker

### Docker Commands vs Kubernetes

| Task | Docker | Kubernetes |
|------|--------|------------|
| **Run App** | `docker run -d smart-airport` | `kubectl apply -f deployment.yaml` |
| **Scale** | `docker run -d smart-airport-2` | `kubectl scale deployment smart-airport --replicas=3` |
| **Update** | `docker stop && docker run new-image` | `kubectl set image deployment/smart-airport smart-airport=new-image` |
| **Logs** | `docker logs smart-airport` | `kubectl logs -l app=smart-airport` |
| **Stop** | `docker stop smart-airport` | `kubectl delete deployment smart-airport` |

### Performance Comparison

#### Docker (Your Production)
```bash
# Single container
docker stats smart-airport --no-stream
```
**Typical Output:**
```
CONTAINER     CPU %     MEM USAGE / LIMIT     MEM %     NET I/O
smart-airport 1.14%     165.1MiB / 13.5GiB    1.19%     214kB / 78.6kB
```

#### Kubernetes (This Test)
```bash
# Multiple containers
kubectl top pods -l app=smart-airport
```
**Typical Output:**
```
NAME                             CPU(cores)   MEMORY(bytes)
smart-airport-7fb46ffc77-abc123  2m           180Mi
smart-airport-7fb46ffc77-def456  2m           175Mi
smart-airport-7fb46ffc77-ghi789  2m           182Mi
```

**Analysis:**
- **Docker**: 1 container, 165MB RAM
- **Kubernetes**: 3 containers, ~540MB RAM total
- **Trade-off**: Higher resource usage for high availability

## 🎓 Learning Outcomes

After completing these experiments, you understand:

### 1. **Container Orchestration**
- How Kubernetes manages multiple containers
- Automatic scaling based on demand
- Self-healing when containers fail

### 2. **Service Discovery**
- How pods communicate with each other
- Load balancing across multiple instances
- Service abstraction over pod IPs

### 3. **Configuration Management**
- Separating config from code
- Managing secrets securely
- Environment-specific deployments

### 4. **Deployment Strategies**
- Rolling updates for zero downtime
- Rollback capabilities
- Health checks and readiness probes

### 5. **Operational Excellence**
- Monitoring and logging
- Debugging techniques
- Resource management

## 🧹 Cleanup

When you're done experimenting:

```bash
# Remove Smart Airport deployment
kubectl delete deployment smart-airport
kubectl delete service smart-airport-service
kubectl delete configmap smart-airport-config
kubectl delete secret smart-airport-secrets

# Stop minikube cluster
minikube stop

# Complete cleanup (optional)
minikube delete
```

## 🎯 Real-World Scenarios

### Scenario 1: Traffic Spike
**Problem:** Your Smart Airport app gets featured on news, traffic increases 10x
**Docker Solution:** Manually start more containers, configure load balancer
**Kubernetes Solution:** `kubectl scale deployment smart-airport --replicas=10`

### Scenario 2: Server Failure
**Problem:** Your Azure server crashes
**Docker Solution:** Manually restart server, redeploy container
**Kubernetes Solution:** Automatic failover to healthy nodes

### Scenario 3: App Update
**Problem:** Need to deploy new features without downtime
**Docker Solution:** Complex blue-green deployment setup
**Kubernetes Solution:** `kubectl set image deployment/smart-airport smart-airport=new-version`

### Scenario 4: Configuration Change
**Problem:** Need to update API keys across all instances
**Docker Solution:** Update env files, restart all containers
**Kubernetes Solution:** `kubectl patch configmap` + rolling restart

## 💡 Key Takeaways

### For Smart Airport Project:
1. **Current Docker setup is perfect** for your needs
2. **Kubernetes adds complexity** without immediate benefit
3. **Learning Kubernetes is valuable** for career growth
4. **Consider Kubernetes when** you have enterprise requirements

### When to Actually Use Kubernetes:
- **Traffic**: 1000+ concurrent users
- **Team**: 10+ developers
- **Services**: Multiple microservices
- **Regions**: Multi-region deployment
- **Budget**: $150-400/month for infrastructure

### Skills Gained:
- Container orchestration concepts
- Modern deployment practices
- Cloud-native application patterns
- Enterprise-grade operational skills

**🎉 Congratulations! You now have hands-on Kubernetes experience with your own application!**
