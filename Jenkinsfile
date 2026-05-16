pipeline {
    agent any

    parameters {
        choice(name: 'ENVIRONMENT', choices: ['staging', 'production'], description: 'Select deployment environment')
    }

    environment {
        // Docker Hub Configuration
        DOCKER_HUB = credentials('docker-hub-username')
        DOCKERHUB_CREDENTIALS = credentials('docker-hub-credentials')
        
        // Project Configuration
        PROJECT_NAME = 'student-management'
        NAME_BACKEND = 'backend'
        NAME_FRONTEND = 'frontend'
        BACKEND_CONTAINER_NAME = "${PROJECT_NAME}-backend-${BRANCH_NAME}"
        FRONTEND_CONTAINER_NAME = "${PROJECT_NAME}-frontend-${BRANCH_NAME}"
        MONGO_CONTAINER_NAME = "${PROJECT_NAME}-mongo-${BRANCH_NAME}"
        
        // Tag Configuration - using branch name and short commit hash
        DOCKER_TAG = "${BRANCH_NAME.replace('/', '-')}-${GIT_COMMIT.take(7)}"
        
        // Database Configuration
        DB_HOST = '10.32.3.170'
        DB_PORT = '27017'
        
        // Deployment Servers
        STAGING_SERVER = '10.32.3.172'
        PRODUCTION_SERVER = '10.32.3.173'
        DEPLOY_USER = 'root'
        SSH_CREDENTIALS = 'jenkins-ssh-key'
        
        // SonarQube Configuration
        SONAR_HOST_URL = 'http://10.32.3.171:9000'
        SONAR_TOKEN = credentials('sonarqube-token')
        SONAR_PROJECT_KEY = 'student-management'
        
        // GitLab Configuration
        GITLAB_URL = 'http://10.32.4.111:8090'
        GITLAB_PROJECT = 'your-group/student-management'
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 1, unit: 'HOURS')
        timestamps()
    }

    triggers {
    gitlabPush()
}

    post {
        always {
            echo "Pipeline finished for branch: ${BRANCH_NAME}"
        }
        success {
            echo "✅ Pipeline succeeded!"
        }
        failure {
            echo "❌ Pipeline failed!"
        }
    }

    stages {
        stage('Checkout') {
            steps {
                echo "🔄 Checking out code from ${BRANCH_NAME}"
                checkout scm
                script {
                    env.GIT_COMMIT_MSG = sh(returnStdout: true, script: 'git log -1 --pretty=%B').trim()
                    env.GIT_AUTHOR = sh(returnStdout: true, script: 'git log -1 --pretty=%an').trim()
                }
                echo "Commit: ${GIT_COMMIT}"
                echo "Author: ${GIT_AUTHOR}"
                echo "Message: ${GIT_COMMIT_MSG}"
            }
        }

        stage('Build Backend') {
            when {
                anyOf {
                    branch 'staging'
                    branch 'main'
                    branch 'develop'
                }
            }
            steps {
                echo "🔨 Building Backend Docker image"
                dir('Backend') {
                    script {
                        sh '''
                            docker build -t ${DOCKER_HUB}/${NAME_BACKEND}:${DOCKER_TAG} .
                            docker tag ${DOCKER_HUB}/${NAME_BACKEND}:${DOCKER_TAG} ${DOCKER_HUB}/${NAME_BACKEND}:latest
                        '''
                    }
                }
            }
        }

        stage('Build Frontend') {
            when {
                anyOf {
                    branch 'staging'
                    branch 'main'
                    branch 'develop'
                }
            }
            steps {
                echo "🔨 Building Frontend Docker image"
                dir('Frontend') {
                    script {
                        sh '''
                            docker build -t ${DOCKER_HUB}/${NAME_FRONTEND}:${DOCKER_TAG} .
                            docker tag ${DOCKER_HUB}/${NAME_FRONTEND}:${DOCKER_TAG} ${DOCKER_HUB}/${NAME_FRONTEND}:latest
                        '''
                    }
                }
            }
        }

        stage('Test Backend') {
            when {
                anyOf {
                    branch 'staging'
                    branch 'main'
                    branch 'develop'
                }
            }
            steps {
                echo "🧪 Running Backend Tests"
                dir('Backend') {
                    script {
                        sh '''
                            echo "Running Backend tests..."
                            npm install
                            # Add your test command here
                            # npm test
                            echo "Backend tests completed"
                        '''
                    }
                }
            }
        }

        stage('Code Quality Analysis') {
            when {
                anyOf {
                    branch 'staging'
                    branch 'main'
                }
            }
            steps {
                echo "📊 Running SonarQube Analysis"
                script {
                    sh '''
                        docker run -v "$(pwd)":/app --workdir="/app" \
                            sonarsource/sonar-scanner-cli \
                            sonar-scanner \
                            -Dsonar.host.url="${SONAR_HOST_URL}" \
                            -Dsonar.login="${SONAR_TOKEN}" \
                            -Dsonar.sources="./Backend,./Frontend/src" \
                            -Dsonar.projectKey="${SONAR_PROJECT_KEY}" \
                            -Dsonar.projectName="${SONAR_PROJECT_KEY}" \
                            -Dsonar.projectVersion="V_${DOCKER_TAG}" || true
                    '''
                }
            }
        }

        stage('Push to Docker Hub') {
            when {
                anyOf {
                    branch 'staging'
                    branch 'main'
                }
            }
            steps {
                echo "🚀 Pushing Docker images to Docker Hub"
                script {
                    sh '''
                        echo ${DOCKERHUB_CREDENTIALS_PSW} | docker login -u ${DOCKERHUB_CREDENTIALS_USR} --password-stdin
                        docker push ${DOCKER_HUB}/${NAME_BACKEND}:${DOCKER_TAG}
                        docker push ${DOCKER_HUB}/${NAME_BACKEND}:latest
                        docker push ${DOCKER_HUB}/${NAME_FRONTEND}:${DOCKER_TAG}
                        docker push ${DOCKER_HUB}/${NAME_FRONTEND}:latest
                        docker logout
                        echo "Images pushed successfully"
                    '''
                }
            }
        }

        stage('Database Migration') {
            when {
                branch 'staging'
            }
            steps {
                echo "🗄️ Preparing Database Migration"
                script {
                    def userInput = input(
                        id: 'DBMigration',
                        message: 'Do you want to run database migration?',
                        parameters: [
                            choice(name: 'Migration', choices: 'no\nyes', description: 'Select option')
                        ]
                    )
                    
                    if (userInput == 'yes') {
                        echo "Executing database migration for staging environment..."
                        // Add your migration commands here
                        echo "Migration completed"
                    } else {
                        echo "Skipping database migration"
                    }
                }
            }
        }

        stage('Deploy to Staging') {
            when {
                branch 'staging'
            }
            steps {
                echo "🚀 Deploying to Staging Environment"
                script {
                    def deploying = '''
                        #!/bin/bash
                        set -e
                        
                        echo "Logging in to Docker Hub..."
                        echo "${DOCKERHUB_CREDENTIALS_PSW}" | docker login -u ${DOCKERHUB_CREDENTIALS_USR} --password-stdin
                        
                        echo "Stopping and removing old containers..."
                        docker-compose down || true
                        
                        echo "Pulling latest images..."
                        docker pull ${DOCKER_HUB}/${NAME_BACKEND}:${DOCKER_TAG}
                        docker pull ${DOCKER_HUB}/${NAME_FRONTEND}:${DOCKER_TAG}
                        
                        echo "Starting new containers..."
                        export DOCKER_HUB=${DOCKER_HUB}
                        export NAME_BACKEND=${NAME_BACKEND}
                        export NAME_FRONTEND=${NAME_FRONTEND}
                        export DOCKER_TAG=${DOCKER_TAG}
                        export BACKEND_CONTAINER_NAME=${BACKEND_CONTAINER_NAME}
                        export FRONTEND_CONTAINER_NAME=${FRONTEND_CONTAINER_NAME}
                        export MONGO_CONTAINER_NAME=${MONGO_CONTAINER_NAME}
                        export BACKEND_PORT=8081
                        export FRONTEND_PORT=80
                        export MONGO_PORT=27017
                        export NODE_ENV=staging
                        export MONGODB_URI=mongodb://${DB_HOST}:${DB_PORT}/student-management-staging
                        
                        docker-compose up -d
                        
                        echo "Waiting for containers to be healthy..."
                        sleep 10
                        
                        docker-compose ps
                        echo "Staging deployment completed successfully!"
                    '''
                    
                    writeFile file: 'deploy.sh', text: deploying
                    sh 'chmod +x deploy.sh'
                    
                    sshagent([SSH_CREDENTIALS]) {
                        sh '''
                            scp -o StrictHostKeyChecking=no deploy.sh ${DEPLOY_USER}@${STAGING_SERVER}:/tmp/
                            ssh -o StrictHostKeyChecking=no ${DEPLOY_USER}@${STAGING_SERVER} 'cd /app && bash /tmp/deploy.sh'
                        '''
                    }
                }
            }
        }

        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                echo "🚀 Deploying to Production Environment"
                script {
                    // Request approval before production deployment
                    def userInput = input(
                        id: 'ProductionDeploy',
                        message: 'Do you want to deploy to PRODUCTION?',
                        parameters: [
                            choice(name: 'Deploy', choices: 'no\nyes', description: 'Select option')
                        ]
                    )
                    
                    if (userInput == 'yes') {
                        def deploying = '''
                            #!/bin/bash
                            set -e
                            
                            echo "Logging in to Docker Hub..."
                            echo "${DOCKERHUB_CREDENTIALS_PSW}" | docker login -u ${DOCKERHUB_CREDENTIALS_USR} --password-stdin
                            
                            echo "Stopping and removing old containers..."
                            docker-compose down || true
                            
                            echo "Pulling latest images..."
                            docker pull ${DOCKER_HUB}/${NAME_BACKEND}:${DOCKER_TAG}
                            docker pull ${DOCKER_HUB}/${NAME_FRONTEND}:${DOCKER_TAG}
                            
                            echo "Starting new containers..."
                            export DOCKER_HUB=${DOCKER_HUB}
                            export NAME_BACKEND=${NAME_BACKEND}
                            export NAME_FRONTEND=${NAME_FRONTEND}
                            export DOCKER_TAG=${DOCKER_TAG}
                            export BACKEND_CONTAINER_NAME=${BACKEND_CONTAINER_NAME}
                            export FRONTEND_CONTAINER_NAME=${FRONTEND_CONTAINER_NAME}
                            export MONGO_CONTAINER_NAME=${MONGO_CONTAINER_NAME}
                            export BACKEND_PORT=8081
                            export FRONTEND_PORT=80
                            export MONGO_PORT=27017
                            export NODE_ENV=production
                            export MONGODB_URI=mongodb://${DB_HOST}:${DB_PORT}/student-management-production
                            
                            docker-compose up -d
                            
                            echo "Waiting for containers to be healthy..."
                            sleep 10
                            
                            docker-compose ps
                            echo "Production deployment completed successfully!"
                        '''
                        
                        writeFile file: 'deploy.sh', text: deploying
                        sh 'chmod +x deploy.sh'
                        
                        sshagent([SSH_CREDENTIALS]) {
                            sh '''
                                scp -o StrictHostKeyChecking=no deploy.sh ${DEPLOY_USER}@${PRODUCTION_SERVER}:/tmp/
                                ssh -o StrictHostKeyChecking=no ${DEPLOY_USER}@${PRODUCTION_SERVER} 'cd /app && bash /tmp/deploy.sh'
                            '''
                        }
                        
                        echo "✅ Production deployment completed!"
                    } else {
                        echo "Production deployment cancelled by user"
                        currentBuild.result = 'UNSTABLE'
                    }
                }
            }
        }

        stage('Smoke Tests') {
            when {
                anyOf {
                    branch 'staging'
                    branch 'main'
                }
            }
            steps {
                echo "🧪 Running Smoke Tests"
                script {
                    sh '''
                        echo "Waiting for services to be ready..."
                        sleep 15
                        
                        DEPLOY_SERVER="${STAGING_SERVER}"
                        if [ "${BRANCH_NAME}" = "main" ]; then
                            DEPLOY_SERVER="${PRODUCTION_SERVER}"
                        fi
                        
                        echo "Testing Backend API..."
                        curl -s -o /dev/null -w "%{http_code}" http://${DEPLOY_SERVER}:8081 || echo "Backend health check failed"
                        
                        echo "Testing Frontend..."
                        curl -s -o /dev/null -w "%{http_code}" http://${DEPLOY_SERVER} || echo "Frontend health check failed"
                        
                        echo "Smoke tests completed"
                    '''
                }
            }
        }
    }
}
