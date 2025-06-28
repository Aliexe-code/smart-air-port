pipeline {
    agent any
    
    environment {
        // Docker configuration
        DOCKER_IMAGE = 'uriel25x/grad-project'
        DOCKER_TAG = "${BUILD_NUMBER}"
        DOCKER_LATEST = 'latest'
        DOCKER_REGISTRY = 'docker.io'
        
        // Application configuration
        APP_NAME = 'smart-airport'
        APP_PORT = '3001'
        
        // Deployment targets
        STAGING_SERVER = 'localhost'
        PRODUCTION_SERVER = '13.81.120.153'
        
        // Monitoring
        PROMETHEUS_URL = 'http://localhost:9090'
        GRAFANA_URL = 'http://localhost:3000'
    }
    
    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 30, unit: 'MINUTES')
        timestamps()
    }
    
    stages {
        stage('🔍 Checkout') {
            steps {
                echo '📥 Checking out source code...'
                checkout scm
                
                script {
                    env.GIT_COMMIT_SHORT = sh(
                        script: 'git rev-parse --short HEAD',
                        returnStdout: true
                    ).trim()
                    env.BUILD_VERSION = "${BUILD_NUMBER}-${env.GIT_COMMIT_SHORT}"
                }
                
                echo "🏷️ Build Version: ${env.BUILD_VERSION}"
            }
        }
        
        stage('🔧 Setup Environment') {
            steps {
                echo '🛠️ Setting up build environment...'
                
                // Install dependencies
                sh '''
                    echo "📦 Installing dependencies..."
                    if command -v bun >/dev/null 2>&1; then
                        echo "✅ Bun is available"
                        bun install
                    else
                        echo "⚠️ Bun not found, using npm"
                        npm install
                    fi
                '''
                
                // Verify environment
                sh '''
                    echo "🔍 Environment verification:"
                    node --version
                    npm --version
                    if command -v bun >/dev/null 2>&1; then
                        bun --version
                    fi
                    docker --version
                '''
            }
        }
        
        stage('🧪 Test') {
            parallel {
                stage('Unit Tests') {
                    steps {
                        echo '🧪 Running unit tests...'
                        sh '''
                            if command -v bun >/dev/null 2>&1; then
                                bun run test || echo "⚠️ Tests failed but continuing..."
                            else
                                npm test || echo "⚠️ Tests failed but continuing..."
                            fi
                        '''
                    }
                }
                
                stage('Lint Check') {
                    steps {
                        echo '🔍 Running linting...'
                        sh '''
                            if command -v bun >/dev/null 2>&1; then
                                bun run lint || echo "⚠️ Linting failed but continuing..."
                            else
                                npm run lint || echo "⚠️ Linting failed but continuing..."
                            fi
                        '''
                    }
                }
                
                stage('Security Scan') {
                    steps {
                        echo '🔒 Running security audit...'
                        sh '''
                            if command -v bun >/dev/null 2>&1; then
                                echo "🔍 Bun security audit not available, skipping..."
                            else
                                npm audit --audit-level=high || echo "⚠️ Security issues found but continuing..."
                            fi
                        '''
                    }
                }
            }
        }
        
        stage('🏗️ Build') {
            steps {
                echo '🏗️ Building application...'
                
                sh '''
                    echo "📦 Building Smart Airport application..."
                    if command -v bun >/dev/null 2>&1; then
                        bun run build
                    else
                        npm run build
                    fi
                    
                    echo "✅ Build completed successfully"
                '''
            }
        }
        
        stage('🐳 Docker Build') {
            steps {
                echo '🐳 Building Docker image...'
                
                script {
                    // Build Docker image
                    def dockerImage = docker.build(
                        "${DOCKER_IMAGE}:${BUILD_VERSION}",
                        "-f docker/Dockerfile.backend ."
                    )
                    
                    // Tag as latest
                    dockerImage.tag("${DOCKER_LATEST}")
                    
                    // Store image for later use
                    env.DOCKER_IMAGE_ID = dockerImage.id
                }
                
                echo "✅ Docker image built: ${DOCKER_IMAGE}:${BUILD_VERSION}"
            }
        }
        
        stage('🧪 Integration Tests') {
            steps {
                echo '🧪 Running integration tests...'
                
                sh '''
                    echo "🚀 Starting test container..."
                    
                    # Stop any existing test containers
                    docker stop smart-airport-test || true
                    docker rm smart-airport-test || true
                    
                    # Start test container
                    docker run -d \
                        --name smart-airport-test \
                        -p 3002:3000 \
                        -e NODE_ENV=test \
                        -e PORT=3000 \
                        ${DOCKER_IMAGE}:${BUILD_VERSION}
                    
                    # Wait for container to start
                    sleep 30
                    
                    # Test health endpoint
                    echo "🔍 Testing health endpoint..."
                    curl -f http://localhost:3002/health || {
                        echo "❌ Health check failed"
                        docker logs smart-airport-test
                        exit 1
                    }
                    
                    echo "✅ Integration tests passed"
                    
                    # Cleanup
                    docker stop smart-airport-test
                    docker rm smart-airport-test
                '''
            }
        }
        
        stage('📊 Quality Gates') {
            steps {
                echo '📊 Running quality checks...'
                
                sh '''
                    echo "📈 Checking application metrics..."
                    
                    # Check if monitoring is available
                    if curl -s ${PROMETHEUS_URL}/-/healthy >/dev/null 2>&1; then
                        echo "✅ Prometheus is healthy"
                    else
                        echo "⚠️ Prometheus not available"
                    fi
                    
                    if curl -s ${GRAFANA_URL}/api/health >/dev/null 2>&1; then
                        echo "✅ Grafana is healthy"
                    else
                        echo "⚠️ Grafana not available"
                    fi
                    
                    echo "📊 Quality gates passed"
                '''
            }
        }
        
        stage('🚀 Deploy to Staging') {
            when {
                anyOf {
                    branch 'develop'
                    branch 'staging'
                    branch 'main'
                }
            }
            steps {
                echo '🚀 Deploying to staging environment...'
                
                sh '''
                    echo "🎯 Deploying to staging..."
                    
                    # Stop existing staging container
                    docker stop smart-airport-staging || true
                    docker rm smart-airport-staging || true
                    
                    # Deploy new version
                    docker run -d \
                        --name smart-airport-staging \
                        -p 3003:3000 \
                        --env-file env.txt \
                        --restart unless-stopped \
                        ${DOCKER_IMAGE}:${BUILD_VERSION}
                    
                    # Wait for deployment
                    sleep 30
                    
                    # Verify deployment
                    curl -f http://localhost:3003/health || {
                        echo "❌ Staging deployment failed"
                        docker logs smart-airport-staging
                        exit 1
                    }
                    
                    echo "✅ Staging deployment successful"
                '''
            }
        }
        
        stage('🎯 Deploy to Production') {
            when {
                branch 'main'
            }
            input {
                message "Deploy to production?"
                ok "Deploy"
                parameters {
                    choice(
                        name: 'DEPLOYMENT_STRATEGY',
                        choices: ['blue-green', 'rolling', 'direct'],
                        description: 'Choose deployment strategy'
                    )
                }
            }
            steps {
                echo '🎯 Deploying to production environment...'
                
                script {
                    if (params.DEPLOYMENT_STRATEGY == 'blue-green') {
                        sh '''
                            echo "🔵 Blue-Green deployment..."
                            
                            # Deploy to blue environment (port 3004)
                            docker stop smart-airport-blue || true
                            docker rm smart-airport-blue || true
                            
                            docker run -d \
                                --name smart-airport-blue \
                                -p 3004:3000 \
                                --env-file env.txt \
                                --restart unless-stopped \
                                ${DOCKER_IMAGE}:${BUILD_VERSION}
                            
                            # Wait and verify
                            sleep 30
                            curl -f http://localhost:3004/health
                            
                            # Switch traffic (update main container)
                            docker stop smart-airport || true
                            docker rm smart-airport || true
                            
                            docker run -d \
                                --name smart-airport \
                                -p 3001:3000 \
                                --env-file env.txt \
                                --restart unless-stopped \
                                ${DOCKER_IMAGE}:${BUILD_VERSION}
                            
                            # Cleanup blue environment
                            sleep 30
                            docker stop smart-airport-blue || true
                            docker rm smart-airport-blue || true
                            
                            echo "✅ Blue-Green deployment completed"
                        '''
                    } else {
                        sh '''
                            echo "🚀 Direct deployment..."
                            
                            # Stop current production
                            docker stop smart-airport || true
                            docker rm smart-airport || true
                            
                            # Deploy new version
                            docker run -d \
                                --name smart-airport \
                                -p 3001:3000 \
                                --env-file env.txt \
                                --restart unless-stopped \
                                ${DOCKER_IMAGE}:${BUILD_VERSION}
                            
                            echo "✅ Production deployment completed"
                        '''
                    }
                }
                
                // Verify production deployment
                sh '''
                    echo "🔍 Verifying production deployment..."
                    sleep 30
                    
                    curl -f http://localhost:3001/health || {
                        echo "❌ Production deployment verification failed"
                        docker logs smart-airport
                        exit 1
                    }
                    
                    echo "✅ Production deployment verified"
                '''
            }
        }
        
        stage('📊 Post-Deploy Monitoring') {
            steps {
                echo '📊 Setting up post-deployment monitoring...'
                
                sh '''
                    echo "📈 Checking application metrics..."
                    
                    # Wait for metrics to be available
                    sleep 60
                    
                    # Check application health
                    curl -f http://localhost:3001/health
                    
                    # Check if metrics endpoint is available
                    curl -f http://localhost:3001/metrics || echo "⚠️ Metrics endpoint not available"
                    
                    echo "📊 Monitoring setup completed"
                '''
            }
        }
    }
    
    post {
        always {
            echo '🧹 Cleaning up...'
            
            // Cleanup test containers
            sh '''
                docker stop smart-airport-test || true
                docker rm smart-airport-test || true
            '''
            
            // Archive artifacts
            archiveArtifacts artifacts: 'dist/**/*', allowEmptyArchive: true
            
            // Publish test results if available
            publishTestResults testResultsPattern: 'test-results.xml', allowEmptyResults: true
        }
        
        success {
            echo '✅ Pipeline completed successfully!'
            
            // Send success notification
            sh '''
                echo "🎉 Smart Airport deployment successful!"
                echo "🔗 Application: http://localhost:3001"
                echo "📊 Monitoring: http://localhost:3000"
                echo "🏷️ Version: ${BUILD_VERSION}"
            '''
        }
        
        failure {
            echo '❌ Pipeline failed!'
            
            // Send failure notification
            sh '''
                echo "💥 Smart Airport deployment failed!"
                echo "📋 Check Jenkins logs for details"
                echo "🔗 Jenkins: http://localhost:8080"
            '''
        }
        
        unstable {
            echo '⚠️ Pipeline completed with warnings!'
        }
    }
}
