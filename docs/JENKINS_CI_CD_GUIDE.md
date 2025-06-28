# Smart Airport - Jenkins CI/CD Guide

## 🎯 What is Jenkins?

**Jenkins** is an open-source automation server that enables Continuous Integration and Continuous Deployment (CI/CD) for your applications. It automates the entire software delivery pipeline from code commit to production deployment.

### 🔍 Why Add Jenkins to Smart Airport?

- **🚀 Automated Deployments** - Deploy with one click or automatically on code changes
- **🧪 Automated Testing** - Run tests automatically on every commit
- **🔄 Continuous Integration** - Catch issues early in the development cycle
- **📊 Build History** - Track all deployments and their status
- **🔒 Secure Deployments** - Controlled, auditable deployment process
- **📈 Scalable Workflows** - Handle complex deployment scenarios

## 🏗️ Jenkins Architecture for Smart Airport

```
┌─────────────────────────────────────────────────────────────┐
│                    Jenkins CI/CD Pipeline                  │
├─────────────────────────────────────────────────────────────┤
│  📥 Source Code (Git)                                      │
│  ├─ GitHub/GitLab Repository                               │
│  ├─ Webhook Triggers                                       │
│  └─ Branch-based Workflows                                 │
├─────────────────────────────────────────────────────────────┤
│  🔧 Jenkins Master (Port 8080)                            │
│  ├─ Pipeline Orchestration                                │
│  ├─ Build Scheduling                                      │
│  ├─ Plugin Management                                     │
│  └─ User Interface                                        │
├─────────────────────────────────────────────────────────────┤
│  🏗️ Build Process                                          │
│  ├─ Code Checkout                                         │
│  ├─ Dependency Installation (Bun/npm)                     │
│  ├─ Linting & Security Audit                             │
│  ├─ Testing (Unit, Integration, E2E)                     │
│  ├─ Application Build                                     │
│  └─ Docker Image Creation                                 │
├─────────────────────────────────────────────────────────────┤
│  🧪 Testing & Quality Gates                               │
│  ├─ Container Testing                                     │
│  ├─ Health Check Validation                              │
│  ├─ Performance Testing                                   │
│  └─ Security Scanning                                     │
├─────────────────────────────────────────────────────────────┤
│  🚀 Deployment Strategies                                  │
│  ├─ Staging Deployment (Auto)                            │
│  ├─ Production Deployment (Manual Approval)              │
│  ├─ Blue-Green Deployment                                │
│  └─ Rollback Capabilities                                │
├─────────────────────────────────────────────────────────────┤
│  📊 Integration with Monitoring                           │
│  ├─ Prometheus Metrics Collection                        │
│  ├─ AlertManager Notifications                           │
│  └─ Post-deployment Health Checks                        │
└─────────────────────────────────────────────────────────────┘
```

## 🚀 Quick Setup (5 minutes)

### Prerequisites
```bash
# Ensure Docker is running
docker --version

# Ensure monitoring stack is running (optional but recommended)
cd monitoring && docker compose ps
```

### 1. Start Jenkins
```bash
# Navigate to project root
cd /home/uriel/smart-air-port

# Start Jenkins with setup script
./jenkins/scripts/setup-jenkins.sh setup
```

### 2. Access Jenkins
- **🌐 Jenkins UI**: http://localhost:8080
- **🔑 Initial Password**: Displayed in setup script output
- **📋 Agent Port**: 50000 (for distributed builds)

### 3. Complete Initial Setup
1. **Unlock Jenkins** with the initial admin password
2. **Install suggested plugins** + Smart Airport specific plugins
3. **Create admin user** for your team
4. **Configure system** settings

## 📋 Jenkins Pipeline Features

### Automated Pipeline Stages

#### **1. 🔍 Checkout & Setup**
- Git repository checkout
- Environment verification
- Dependency installation (Bun/npm)
- Build version calculation

#### **2. 🧪 Quality Checks**
- **Linting**: Code style and quality checks
- **Security Audit**: Vulnerability scanning
- **Dependency Analysis**: Package security review

#### **3. 🧪 Testing**
- **Unit Tests**: Component-level testing
- **Integration Tests**: API and service testing
- **E2E Tests**: End-to-end user workflows

#### **4. 🏗️ Build**
- Application compilation
- Asset optimization
- Build artifact creation
- Artifact archiving

#### **5. 🐳 Docker Build**
- Docker image creation
- Multi-stage builds
- Image tagging and versioning
- Registry push (Docker Hub)

#### **6. 🧪 Container Testing**
- Container health checks
- API endpoint testing
- Performance validation
- Security scanning

#### **7. 🚀 Deployment**
- **Staging**: Automatic deployment for testing
- **Production**: Manual approval required
- **Blue-Green**: Zero-downtime deployments
- **Rollback**: Automatic failure recovery

#### **8. 📊 Post-Deploy Monitoring**
- Health check validation
- Metrics collection setup
- Monitoring integration
- Performance baseline

### Deployment Strategies

#### **Blue-Green Deployment**
```groovy
// Zero-downtime deployment
1. Deploy to blue environment (port 3004)
2. Test blue environment
3. Switch traffic to blue (update main container)
4. Cleanup old environment
```

#### **Direct Deployment**
```groovy
// Fast deployment for staging
1. Stop current container
2. Deploy new version
3. Verify deployment
```

#### **Rolling Deployment**
```groovy
// Gradual deployment (future enhancement)
1. Deploy to subset of instances
2. Gradually increase traffic
3. Monitor performance
```

## 🛠️ Jenkins Management Commands

### Start/Stop Jenkins
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

# Get admin password
./jenkins/scripts/setup-jenkins.sh password
```

### Docker Commands
```bash
# Start Jenkins with Docker Compose
cd jenkins/docker
docker compose up -d jenkins

# View Jenkins logs
docker compose logs -f jenkins

# Access Jenkins container
docker exec -it smart-airport-jenkins bash

# Stop Jenkins
docker compose down
```

### Pipeline Management
```bash
# Trigger build manually
curl -X POST http://localhost:8080/job/smart-airport-pipeline/build \
  --user admin:your-api-token

# Check build status
curl http://localhost:8080/job/smart-airport-pipeline/lastBuild/api/json \
  --user admin:your-api-token

# View build console output
curl http://localhost:8080/job/smart-airport-pipeline/lastBuild/consoleText \
  --user admin:your-api-token
```

## 📊 Integration with Existing Tools

### Docker Integration
- **Build**: Creates Docker images automatically
- **Test**: Runs containers for testing
- **Deploy**: Uses Docker for consistent deployments
- **Monitor**: Integrates with Docker stats and logs

### Prometheus Integration
- **Metrics**: Collects build and deployment metrics
- **Alerts**: Notifies on build failures
- **Health Checks**: Validates monitoring setup

### Ansible Integration (Optional)
- **Remote Deployment**: Deploy to multiple servers
- **Configuration Management**: Consistent server setup
- **Inventory Management**: Manage deployment targets

### Kubernetes Integration (Optional)
- **Container Orchestration**: Deploy to K8s clusters
- **Scaling**: Automatic scaling based on load
- **Service Discovery**: Automatic service registration

## 🔧 Pipeline Configuration

### Environment Variables
```groovy
environment {
    // Application Configuration
    APP_NAME = 'smart-airport'
    APP_VERSION = "${BUILD_NUMBER}-${GIT_COMMIT.take(7)}"
    
    // Docker Configuration
    DOCKER_IMAGE = 'uriel25x/grad-project'
    DOCKER_REGISTRY = 'docker.io'
    
    // Deployment Configuration
    STAGING_PORT = '3003'
    PRODUCTION_PORT = '3001'
    
    // Monitoring URLs
    PROMETHEUS_URL = 'http://localhost:9090'
}
```

### Build Triggers
```groovy
triggers {
    // Automatic build on Git push
    githubPush()
    
    // Poll for changes every 5 minutes
    pollSCM('H/5 * * * *')
    
    // Daily maintenance build at 2 AM
    cron('0 2 * * *')
}
```

### Quality Gates
```groovy
// Parallel quality checks
parallel {
    stage('Lint') { /* linting */ }
    stage('Security Audit') { /* security */ }
    stage('Tests') { /* testing */ }
}
```

## 📈 Benefits for Smart Airport

### For Development Team
- **🚀 Faster Releases**: Automated deployment pipeline
- **🐛 Early Bug Detection**: Automated testing on every commit
- **📊 Build Visibility**: Clear status of all builds and deployments
- **🔄 Consistent Process**: Same deployment process every time

### For Operations Team
- **📋 Deployment History**: Complete audit trail of all deployments
- **🔒 Controlled Releases**: Manual approval for production deployments
- **📊 Monitoring Integration**: Automatic health checks and monitoring
- **🚨 Failure Notifications**: Immediate alerts on build/deployment failures

### For Business
- **⚡ Faster Time to Market**: Automated pipeline reduces deployment time
- **🛡️ Reduced Risk**: Automated testing catches issues before production
- **📈 Higher Quality**: Consistent quality checks on every release
- **💰 Cost Efficiency**: Reduced manual effort and faster issue resolution

## 🔧 Troubleshooting

### Common Issues

#### Jenkins Won't Start
```bash
# Check Docker status
docker ps | grep jenkins

# Check logs
docker logs smart-airport-jenkins

# Restart Jenkins
./jenkins/scripts/setup-jenkins.sh restart
```

#### Pipeline Fails at Docker Build
```bash
# Check Docker daemon
docker info

# Check Dockerfile
docker build -f docker/Dockerfile.backend .

# Check Docker socket permissions
ls -la /var/run/docker.sock
```

#### Can't Access Jenkins UI
```bash
# Check port binding
netstat -tulpn | grep 8080

# Check firewall
sudo ufw status

# Check Jenkins logs
docker logs smart-airport-jenkins
```

#### Build Fails at Test Stage
```bash
# Run tests locally
bun test

# Check test configuration
cat package.json | grep test

# Check environment variables
docker exec smart-airport-jenkins env
```

### Useful Commands
```bash
# Get Jenkins initial password
docker exec smart-airport-jenkins cat /var/jenkins_home/secrets/initialAdminPassword

# Restart Jenkins service
docker exec smart-airport-jenkins systemctl restart jenkins

# Check Jenkins system info
curl http://localhost:8080/systemInfo --user admin:password

# Backup Jenkins configuration
docker exec smart-airport-jenkins tar -czf /tmp/jenkins-backup.tar.gz /var/jenkins_home
```

## 🎯 Next Steps

### Immediate Setup
1. **✅ Start Jenkins** using the setup script
2. **🔧 Complete initial configuration** via web UI
3. **📋 Create Smart Airport pipeline** job
4. **🚀 Run first build** and verify deployment

### Advanced Configuration
1. **🔗 Configure Git webhooks** for automatic builds
2. **📧 Set up email notifications** for build status
3. **💬 Configure Slack integration** for team notifications
4. **🔒 Set up proper security** and user management

### Optional Enhancements
1. **🧪 Add SonarQube** for code quality analysis
2. **📦 Set up Nexus** for artifact management
3. **🌐 Configure multi-environment** deployments
4. **📊 Create custom dashboards** for CI/CD metrics

**🚀 Your Smart Airport project now has enterprise-grade CI/CD automation with Jenkins!**
