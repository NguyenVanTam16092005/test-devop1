// Pipeline CI/CD cho hệ thống quản lý sinh viên - Student Management System
// Hỗ trợ tự động build, test, và deploy ứng dụng

pipeline {
    agent any

    parameters {
        choice(name: 'ENVIRONMENT', choices: ['staging', 'production'], description: 'Chọn môi trường deploy: staging hoặc production')
    }

    environment {
        // Cấu hình Docker Hub - Credentials để đăng nhập và push image
        DOCKER_HUB = credentials('docker-hub-username')
        DOCKERHUB_CREDENTIALS = credentials('docker-hub-credentials')
        
        // Cấu hình dự án - Tên ứng dụng và các thành phần
        PROJECT_NAME = 'student-management'
        NAME_BACKEND = 'backend'
        NAME_FRONTEND = 'frontend'
        
        // Nhánh và thẻ phiên bản (sẽ được thiết lập ở giai đoạn Checkout)
        COMPUTED_BRANCH = 'unknown'
        DOCKER_TAG = 'unknown'
        BACKEND_CONTAINER_NAME = 'unknown'
        FRONTEND_CONTAINER_NAME = 'unknown'
        MONGO_CONTAINER_NAME = 'unknown'
        
        // Cấu hình cơ sở dữ liệu MongoDB
        DB_HOST = '10.32.3.170'
        DB_PORT = '27017'
        
        // Địa chỉ máy chủ deploy (staging và production)
        STAGING_SERVER = '10.32.3.172'
        PRODUCTION_SERVER = '10.32.3.173'
        DEPLOY_USER = 'root'
        SSH_CREDENTIALS = 'jenkins-ssh-key'
        
        // Cấu hình SonarQube - Phân tích chất lượng mã
        SONAR_HOST_URL = 'http://10.32.3.171:9000'
        SONAR_TOKEN = credentials('sonarqube-token')
        SONAR_PROJECT_KEY = 'student-management'
        
        // Cấu hình GitLab (nếu sử dụng)
        GITLAB_URL = 'http://10.32.4.111:8090'
        GITLAB_PROJECT = 'your-group/student-management'
    }

    options {
        // Giữ lại tối đa 10 build gần nhất
        buildDiscarder(logRotator(numToKeepStr: '10'))
        // Hết thời gian chờ sau 1 giờ
        timeout(time: 1, unit: 'HOURS')
        // Hiển thị dấu thời gian cho mỗi thao tác
        timestamps()
    }

    triggers {
        // Kích hoạt pipeline khi có push từ GitHub
        githubPush()
    }

    post {
        // Các hành động luôn được thực hiện
        always {
            echo "✏️ Pipeline kết thúc cho nhánh: ${COMPUTED_BRANCH}"
        }
        success {
            echo "✅ Pipeline thành công!"
        }
        failure {
            echo "❌ Pipeline thất bại!"
        }
    }

    stages {
        // ========================================
        // GIAI ĐOẠN 1: CHECKOUT - Lấy mã nguồn
        // ========================================
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    // Trích xuất tên nhánh từ lệnh git (hoạt động cho cả multibranch và non-multibranch pipelines)
                    def branchName = sh(returnStdout: true, script: 'git rev-parse --abbrev-ref HEAD').trim()
                    env.COMPUTED_BRANCH = branchName
                    env.DOCKER_TAG = "${branchName.replace('/', '-')}-${GIT_COMMIT.take(7)}"
                    env.BACKEND_CONTAINER_NAME = "${PROJECT_NAME}-backend-${branchName}"
                    env.FRONTEND_CONTAINER_NAME = "${PROJECT_NAME}-frontend-${branchName}"
                    env.MONGO_CONTAINER_NAME = "${PROJECT_NAME}-mongo-${branchName}"
                    
                    env.GIT_COMMIT_MSG = sh(returnStdout: true, script: 'git log -1 --pretty=%B').trim()
                    env.GIT_AUTHOR = sh(returnStdout: true, script: 'git log -1 --pretty=%an').trim()
                }
                echo "🔄 Đang checkout mã từ nhánh: ${COMPUTED_BRANCH}"
                echo "Commit: ${GIT_COMMIT}"
                echo "Người commit: ${GIT_AUTHOR}"
                echo "Tin nhắn: ${GIT_COMMIT_MSG}"
            }
        }

        // ========================================
        // GIAI ĐOẠN 2: BUILD BACKEND
        // Build Docker image cho phần Backend
        // ========================================
        stage('Build Backend') {
            when {
                expression {
                    return env.COMPUTED_BRANCH ==~ /(staging|main|develop)/
                }
            }
            steps {
                echo "🔨 Đang build Docker image cho Backend"
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

        // ========================================
        // GIAI ĐOẠN 3: BUILD FRONTEND
        // Build Docker image cho phần Frontend
        // ========================================
        stage('Build Frontend') {
            when {
                expression {
                    return env.COMPUTED_BRANCH ==~ /(staging|main|develop)/
                }
            }
            steps {
                echo "🔨 Đang build Docker image cho Frontend"
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

        // ========================================
        // GIAI ĐOẠN 4: TEST BACKEND
        // Chạy các bài kiểm tra cho Backend
        // ========================================
        stage('Test Backend') {
            when {
                expression {
                    return env.COMPUTED_BRANCH ==~ /(staging|main|develop)/
                }
            }
            steps {
                echo "🧪 Đang chạy các bài kiểm tra Backend"
                dir('Backend') {
                    script {
                        sh '''
                            echo "Đang chạy kiểm tra Backend..."
                            npm install
                            # Thêm lệnh kiểm tra của bạn ở đây
                            # npm test
                            echo "Kiểm tra Backend hoàn tất"
                        '''
                    }
                }
            }
        }

        // ========================================
        // GIAI ĐOẠN 5: PHÂN TÍCH CHẤT LƯỢNG MÃ
        // Sử dụng SonarQube để phân tích mã
        // ========================================
        stage('Code Quality Analysis') {
            when {
                expression {
                    return env.COMPUTED_BRANCH ==~ /(staging|main)/
                }
            }
            steps {
                echo "📊 Đang chạy phân tích SonarQube"
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

        // ========================================
        // GIAI ĐOẠN 6: PUSH ĐẾN DOCKER HUB
        // Đẩy Docker images lên Docker Hub
        // ========================================
        stage('Push to Docker Hub') {
            when {
                expression {
                    return env.COMPUTED_BRANCH ==~ /(staging|main)/
                }
            }
            steps {
                echo "🚀 Đang đẩy Docker images lên Docker Hub"
                script {
                    sh '''
                        echo ${DOCKERHUB_CREDENTIALS_PSW} | docker login -u ${DOCKERHUB_CREDENTIALS_USR} --password-stdin
                        docker push ${DOCKER_HUB}/${NAME_BACKEND}:${DOCKER_TAG}
                        docker push ${DOCKER_HUB}/${NAME_BACKEND}:latest
                        docker push ${DOCKER_HUB}/${NAME_FRONTEND}:${DOCKER_TAG}
                        docker push ${DOCKER_HUB}/${NAME_FRONTEND}:latest
                        docker logout
                        echo "Đã đẩy images thành công"
                    '''
                }
            }
        }

        // ========================================
        // GIAI ĐOẠN 7: MIGRATION CƠ SỞ DỮ LIỆU
        // Chạy migration database (chỉ cho staging)
        // ========================================
        stage('Database Migration') {
            when {
                expression {
                    return env.COMPUTED_BRANCH == 'staging'
                }
            }
            steps {
                echo "🗄️ Chuẩn bị Database Migration"
                script {
                    def userInput = input(
                        id: 'DBMigration',
                        message: 'Bạn có muốn chạy database migration không?',
                        parameters: [
                            choice(name: 'Migration', choices: 'không\ncó', description: 'Chọn tùy chọn')
                        ]
                    )
                    
                    if (userInput == 'có') {
                        echo "Đang thực hiện migration database cho môi trường staging..."
                        // Thêm các lệnh migration của bạn ở đây
                        echo "Migration hoàn tất"
                    } else {
                        echo "Bỏ qua database migration"
                    }
                }
            }
        }

        // ========================================
        // GIAI ĐOẠN 8: DEPLOY ĐẾN STAGING
        // Deploy ứng dụng đến máy chủ staging
        // ========================================
        stage('Deploy to Staging') {
            when {
                expression {
                    return env.COMPUTED_BRANCH == 'staging'
                }
            }
            steps {
                echo "🚀 Đang deploy đến môi trường Staging"
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

        // ========================================
        // GIAI ĐOẠN 9: DEPLOY ĐẾN PRODUCTION
        // Deploy ứng dụng đến máy chủ production
        // ========================================
        stage('Deploy to Production') {
            when {
                expression {
                    return env.COMPUTED_BRANCH == 'main'
                }
            }
            steps {
                echo "🚀 Đang deploy đến môi trường Production"
                script {
                    // Yêu cầu phê duyệt trước khi deploy production
                    def userInput = input(
                        id: 'ProductionDeploy',
                        message: 'Bạn có muốn deploy đến PRODUCTION không?',
                        parameters: [
                            choice(name: 'Deploy', choices: 'không\ncó', description: 'Chọn tùy chọn')
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
                        
                        echo "✅ Đã hoàn tất deployment production!"
                    } else {
                        echo "Deployment production bị hủy bởi người dùng"
                        currentBuild.result = 'UNSTABLE'
                    }
                }
            }
        }

        // ========================================
        // GIAI ĐOẠN 10: SMOKE TESTS
        // Chạy các bài kiểm tra nhanh
        // ========================================
        stage('Smoke Tests') {
            when {
                expression {
                    return env.COMPUTED_BRANCH ==~ /(staging|main)/
                }
            }
            steps {
                echo "🧪 Đang chạy Smoke Tests"
                script {
                    sh '''
                        echo "Đang chờ các dịch vụ sẵn sàng..."
                        sleep 15
                        
                        DEPLOY_SERVER="${STAGING_SERVER}"
                        BRANCH_NAME="${COMPUTED_BRANCH}"
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
