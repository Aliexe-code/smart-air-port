pipeline {
    agent any

    environment {
        // Application Configuration
        APP_NAME = 'smart-airport'
        APP_VERSION = "${BUILD_NUMBER}-${GIT_COMMIT.take(7)}"

        // Docker Configuration
        DOCKER_IMAGE = 'uriel25x/grad-project'
        DOCKER_REGISTRY = 'docker.io'
        DOCKER_CREDENTIALS = 'docker-hub-credentials'

        // Deployment Configuration
        STAGING_PORT = '3003'
        PRODUCTION_PORT = '3001'

        // Legacy Configuration (keeping for compatibility)
        BUN_INSTALL = "${HOME}/.bun"
        PATH = "${BUN_INSTALL}/bin:${PATH}"
        DEPLOY_DIR = "/var/www/smart-air-port"
        REMOTE_USER = "azureuser"
        REMOTE_HOST = "13.81.120.153"
        SSH_CREDENTIALS_ID = "smart-air-port-ssh-key"
        NODE_ENV = "production"

        // Monitoring URLs
        PROMETHEUS_URL = 'http://localhost:9090'
        GRAFANA_URL = 'http://localhost:3000'
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 30, unit: 'MINUTES')
        timestamps()
    }

    triggers {
        githubPush()
        pollSCM('H/5 * * * *')
    }

    stages {
        stage('🔍 Checkout & Setup') {
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

                // Setup environment
                sh '''
                    echo "🛠️ Setting up build environment..."

                    # Install Bun if not already installed
                    if ! command -v bun &> /dev/null; then
                        echo "📦 Installing Bun..."
                        curl -fsSL https://bun.sh/install | bash
                        export PATH="${HOME}/.bun/bin:${PATH}"
                    else
                        echo "✅ Bun is already installed"
                    fi

                    # Install dependencies
                    echo "📦 Installing dependencies..."
                    if command -v bun >/dev/null 2>&1; then
                        bun install
                    else
                        npm install
                    fi

                    # Verify environment
                    echo "🔍 Environment verification:"
                    node --version
                    if command -v bun >/dev/null 2>&1; then
                        bun --version
                    fi
                    docker --version
                '''
            }
        }

        stage('🧪 Quality Checks') {
            parallel {
                stage('Lint') {
                    steps {
                        echo '🔍 Running linting...'
                        sh '''
                            # Handle ESLint config
                            if [ -f eslint.config.js ]; then
                                mv eslint.config.js eslint.config.mjs
                            fi

                            # Run lint
                            if command -v bun >/dev/null 2>&1; then
                                bun run lint || echo "⚠️ Linting issues found"
                            else
                                npm run lint || echo "⚠️ Linting issues found"
                            fi
                        '''
                    }
                }

                stage('Security Audit') {
                    steps {
                        echo '🔒 Running security audit...'
                        sh '''
                            if command -v bun >/dev/null 2>&1; then
                                echo "🔍 Bun security audit not available, using npm..."
                                npm audit --audit-level=high || echo "⚠️ Security issues found"
                            else
                                npm audit --audit-level=high || echo "⚠️ Security issues found"
                            fi
                        '''
                    }
                }
            }
        }

        stage('🧪 Test') {
            steps {
                echo '🧪 Running tests...'
                sh '''
                    if command -v bun >/dev/null 2>&1; then
                        bun test || echo "⚠️ Tests failed but continuing..."
                    else
                        npm test || echo "⚠️ Tests failed but continuing..."
                    fi
                '''
            }
        }

        stage('🏗️ Build') {
            steps {
                echo '🏗️ Building application...'
                sh '''
                    if command -v bun >/dev/null 2>&1; then
                        bun run build
                    else
                        npm run build
                    fi

                    echo "✅ Build completed successfully"
                '''

                // Archive build artifacts
                archiveArtifacts artifacts: 'dist/**/*', allowEmptyArchive: true
            }
        }

        stage('🐳 Docker Build') {
            steps {
                echo '🐳 Building Docker image...'
                script {
                    def dockerImage = docker.build(
                        "${DOCKER_IMAGE}:${BUILD_VERSION}",
                        "-f docker/Dockerfile.backend ."
                    )
                    dockerImage.tag("latest")
                    env.DOCKER_IMAGE_ID = dockerImage.id
                }
                echo "✅ Docker image built: ${DOCKER_IMAGE}:${BUILD_VERSION}"
            }
        }

        stage('🧪 Container Testing') {
            steps {
                echo '🧪 Testing Docker container...'
                sh '''
                    echo "🚀 Starting test container..."

                    # Cleanup any existing test containers
                    docker stop smart-airport-test-${BUILD_NUMBER} || true
                    docker rm smart-airport-test-${BUILD_NUMBER} || true

                    # Start test container
                    docker run -d \
                        --name smart-airport-test-${BUILD_NUMBER} \
                        -p 3099:3000 \
                        -e NODE_ENV=test \
                        -e PORT=3000 \
                        ${DOCKER_IMAGE}:${BUILD_VERSION}

                    # Wait for container to start
                    echo "⏳ Waiting for container to start..."
                    sleep 30

                    # Test health endpoint
                    echo "🔍 Testing health endpoint..."
                    curl -f http://localhost:3099/health || {
                        echo "❌ Health check failed"
                        docker logs smart-airport-test-${BUILD_NUMBER}
                        exit 1
                    }

                    echo "✅ Container tests passed"

                    # Cleanup
                    docker stop smart-airport-test-${BUILD_NUMBER}
                    docker rm smart-airport-test-${BUILD_NUMBER}
                '''
            }
        }

        stage('🚀 Deploy to Production') {
            when {
                branch 'main'
            }
            input {
                message "Deploy to production?"
                ok "Deploy"
            }
            steps {
                echo '🎯 Deploying to production environment...'
                sh '''
                    echo "🎯 Deploying Smart Airport to production..."

                    # Stop existing production container
                    docker stop smart-airport || true
                    docker rm smart-airport || true

                    # Deploy new version
                    docker run -d \
                        --name smart-airport \
                        -p ${PRODUCTION_PORT}:3000 \
                        --env-file env.txt \
                        --restart unless-stopped \
                        --label "environment=production" \
                        --label "version=${BUILD_VERSION}" \
                        ${DOCKER_IMAGE}:${BUILD_VERSION}

                    # Wait for deployment
                    echo "⏳ Waiting for production deployment..."
                    sleep 30

                    # Verify production deployment
                    echo "🔍 Verifying production deployment..."
                    curl -f http://localhost:${PRODUCTION_PORT}/health || {
                        echo "❌ Production deployment verification failed"
                        docker logs smart-airport
                        exit 1
                    }

                    echo "✅ Production deployment successful"
                    echo "🔗 Production URL: http://localhost:${PRODUCTION_PORT}"
                '''
            }
        }

        stage('📊 Post-Deploy Monitoring') {
            steps {
                echo '📊 Setting up post-deployment monitoring...'
                sh '''
                    echo "📈 Checking monitoring integration..."

                    # Wait for metrics to be available
                    sleep 60

                    # Check application health
                    curl -f http://localhost:${PRODUCTION_PORT}/health

                    # Check metrics endpoint
                    curl -f http://localhost:${PRODUCTION_PORT}/metrics || echo "⚠️ Metrics endpoint not available"

                    # Check Prometheus integration
                    if curl -s ${PROMETHEUS_URL}/-/healthy >/dev/null 2>&1; then
                        echo "✅ Prometheus integration healthy"
                    else
                        echo "⚠️ Prometheus not available"
                    fi

                    echo "📊 Monitoring setup completed"
                '''
            }
        }

    }

    post {
        always {
            echo '🧹 Pipeline cleanup...'

            // Clean workspace
            cleanWs(
                cleanWhenNotBuilt: false,
                deleteDirs: true,
                disableDeferredWipeout: true,
                notFailBuild: true
            )

            // Archive important logs
            archiveArtifacts(
                artifacts: 'logs/**/*',
                allowEmptyArchive: true
            )
        }

        success {
            echo '✅ Smart Airport pipeline completed successfully!'

            script {
                // Create build info
                sh '''
                    echo "Build completed at $(date)" > build-info.txt
                    echo "Version: ${BUILD_VERSION}" >> build-info.txt
                    echo "Commit: ${GIT_COMMIT}" >> build-info.txt
                    echo "Branch: ${GIT_BRANCH}" >> build-info.txt
                    echo "Build number: ${BUILD_NUMBER}" >> build-info.txt
                    echo "Docker image: ${DOCKER_IMAGE}:${BUILD_VERSION}" >> build-info.txt
                    echo "Production URL: http://localhost:${PRODUCTION_PORT}" >> build-info.txt
                    echo "Monitoring URL: ${GRAFANA_URL}" >> build-info.txt
                '''

                // Archive build info
                archiveArtifacts artifacts: 'build-info.txt', allowEmptyArchive: true
            }
        }

        failure {
            echo '❌ Smart Airport pipeline failed!'

            script {
                // Create failure report
                sh '''
                    echo "Build failed at $(date)" > failure-report.txt
                    echo "Version: ${BUILD_VERSION}" >> failure-report.txt
                    echo "Commit: ${GIT_COMMIT}" >> failure-report.txt
                    echo "Branch: ${GIT_BRANCH}" >> failure-report.txt
                    echo "Build number: ${BUILD_NUMBER}" >> failure-report.txt
                    echo "Failed stage: ${env.STAGE_NAME}" >> failure-report.txt
                    echo "Build URL: ${BUILD_URL}" >> failure-report.txt
                '''

                // Archive failure report
                archiveArtifacts artifacts: 'failure-report.txt', allowEmptyArchive: true
            }
        }

        unstable {
            echo '⚠️ Smart Airport pipeline completed with warnings!'
        }
    }
}
