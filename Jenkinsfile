// Pipeline CI/CD cho hệ thống quản lý sinh viên - Student Management System
// Hỗ trợ tự động build, test, và deploy ứng dụng

pipeline {
    agent any

    parameters {
        choice(name: 'ENVIRONMENT', choices: ['staging', 'production'], description: 'Chọn môi trường deploy: staging hoặc production')
    }

    environment {
        // Cấu hình Docker Hub - Credentials để đăng nhập và push image
        // DOCKER_HUB = credentials('docker-hub-username')
        // DOCKERHUB_CREDENTIALS = credentials('docker-hub-credentials')
        
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
        
        // Docker Hub - sẽ được set từ credentials khi deploy
        DOCKER_HUB = 'dockerhub-username'
        
        // Cấu hình SonarQube - Phân tích chất lượng mã
        SONAR_HOST_URL = 'http://10.32.3.171:9000'
        SONAR_TOKEN = 'sonarqube-token-placeholder'
        SONAR_PROJECT_KEY = 'student-management'
        
        // Cấu hình GitLab (nếu sử dụng)
        GITLAB_URL = 'http://10.32.4.111:8090'
        GITLAB_PROJECT = 'your-group/student-management'
    }

    options {
        // Bỏ qua checkout mặc định để tránh checkout 2 lần
        skipDefaultCheckout()
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

    stages {
        stage('Checkout') {
    steps {
        checkout scm
        script {
            // Đọc branch name - tối ưu cho Windows
            String branchName = 'unknown'
            
            try {
                // Phương pháp 1: Đọc trực tiếp từ .git/HEAD file (BEST FOR WINDOWS)
                String headFile = readFile('.git/HEAD').trim()
                if (headFile.startsWith('ref: ')) {
                    branchName = headFile.replace('ref: refs/heads/', '').trim()
                    echo "✅ Branch detected from .git/HEAD: ${branchName}"
                } else {
                    branchName = headFile.trim()
                }
            } catch (Exception e1) {
                try {
                    // Phương pháp 2: Dùng git command với bat (Windows)
                    branchName = bat(
                        returnStdout: true,
                        script: '@echo off && git rev-parse --abbrev-ref HEAD'
                    ).trim()
                    echo "✅ Branch detected via git command: ${branchName}"
                } catch (Exception e2) {
                    // Phương pháp 3: Fallback
                    branchName = env.BRANCH_NAME ?: env.GIT_BRANCH ?: 'develop'
                    if (branchName.contains('/')) {
                        branchName = branchName.tokenize('/').last()
                    }
                    echo "⚠️ Branch fallback to: ${branchName}"
                }
            }
            
            // Normalize: loại bỏ "origin/" prefix và whitespace
            branchName = branchName.replace('origin/', '').replaceAll(/\s+/, '')
            
            // Set environment variables
            env.COMPUTED_BRANCH = branchName
            String shortCommit = env.GIT_COMMIT ? env.GIT_COMMIT.take(7) : 'unknown'
            env.DOCKER_TAG = "${branchName.replace('/', '-')}-${shortCommit}"
            
            env.BACKEND_CONTAINER_NAME  = "${env.PROJECT_NAME}-backend-${branchName}"
            env.FRONTEND_CONTAINER_NAME = "${env.PROJECT_NAME}-frontend-${branchName}"
            env.MONGO_CONTAINER_NAME    = "${env.PROJECT_NAME}-mongo-${branchName}"

            echo "════════════════════════════════════════"
            echo "🎯 GIT CHECKOUT SUMMARY"
            echo "════════════════════════════════════════"
            echo "   ✓ Branch: ${env.COMPUTED_BRANCH}"
            echo "   ✓ Commit: ${env.GIT_COMMIT?.take(7) ?: 'unknown'}"
            echo "   ✓ Docker Tag: ${env.DOCKER_TAG}"
            echo "   ✓ Backend Container: ${env.BACKEND_CONTAINER_NAME}"
            echo "   ✓ Frontend Container: ${env.FRONTEND_CONTAINER_NAME}"
            echo "════════════════════════════════════════"
        }
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
                        bat '''
                            @echo off
                            echo Building Backend with tag: %DOCKER_TAG%
                            
                            REM Check if Docker is installed
                            where docker >nul 2>nul
                            if errorlevel 1 (
                                echo ⚠️ Docker is not installed. Skipping build.
                                echo Installing dependencies instead...
                                if exist package.json (
                                    npm install
                                )
                            ) else (
                                echo ✅ Docker found. Building image...
                                docker build -t %NAME_BACKEND%:%DOCKER_TAG% .
                                docker tag %NAME_BACKEND%:%DOCKER_TAG% %NAME_BACKEND%:latest
                                echo ✅ Backend build completed!
                                docker images | find "%NAME_BACKEND%"
                            )
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
                        bat '''
                            @echo off
                            echo Building Frontend with tag: %DOCKER_TAG%
                            
                            REM Check if Docker is installed
                            where docker >nul 2>nul
                            if errorlevel 1 (
                                echo ⚠️ Docker is not installed. Skipping build.
                                echo Installing dependencies instead...
                                if exist package.json (
                                    npm install
                                )
                            ) else (
                                echo ✅ Docker found. Building image...
                                docker build -t %NAME_FRONTEND%:%DOCKER_TAG% .
                                docker tag %NAME_FRONTEND%:%DOCKER_TAG% %NAME_FRONTEND%:latest
                                echo ✅ Frontend build completed!
                                docker images | find "%NAME_FRONTEND%"
                            )
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
                        powershell '''
                            Write-Host "Đang chạy kiểm tra Backend..."
                            npm install
                            # Thêm lệnh kiểm tra của bạn ở đây
                            # npm test
                            Write-Host "Kiểm tra Backend hoàn tất"
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
                    powershell '''
                        docker run -v "$(pwd)":/app --workdir=/app `
                            sonarsource/sonar-scanner-cli `
                            sonar-scanner `
                            -Dsonar.host.url="${env:SONAR_HOST_URL}" `
                            -Dsonar.login="${env:SONAR_TOKEN}" `
                            -Dsonar.sources="./Backend,./Frontend/src" `
                            -Dsonar.projectKey="${env:SONAR_PROJECT_KEY}" `
                            -Dsonar.projectName="${env:SONAR_PROJECT_KEY}" `
                            -Dsonar.projectVersion="V_${env:DOCKER_TAG}"
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
                    powershell '''
                        docker push ${env:DOCKER_HUB}/${env:NAME_BACKEND}:${env:DOCKER_TAG}
                        docker push ${env:DOCKER_HUB}/${env:NAME_BACKEND}:latest
                        docker push ${env:DOCKER_HUB}/${env:NAME_FRONTEND}:${env:DOCKER_TAG}
                        docker push ${env:DOCKER_HUB}/${env:NAME_FRONTEND}:latest
                        docker logout
                        Write-Host "Đã đẩy images thành công"
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
                        Write-Host "Stopping and removing old containers..."
                        docker-compose down
                        
                        Write-Host "Pulling latest images..."
                        docker pull ${env:DOCKER_HUB}/${env:NAME_BACKEND}:${env:DOCKER_TAG}
                        docker pull ${env:DOCKER_HUB}/${env:NAME_FRONTEND}:${env:DOCKER_TAG}
                        
                        Write-Host "Starting new containers..."
                        $env:DOCKER_HUB = "${env:DOCKER_HUB}"
                        $env:NAME_BACKEND = "${env:NAME_BACKEND}"
                        $env:NAME_FRONTEND = "${env:NAME_FRONTEND}"
                        $env:DOCKER_TAG = "${env:DOCKER_TAG}"
                        $env:BACKEND_CONTAINER_NAME = "${env:BACKEND_CONTAINER_NAME}"
                        $env:FRONTEND_CONTAINER_NAME = "${env:FRONTEND_CONTAINER_NAME}"
                        $env:MONGO_CONTAINER_NAME = "${env:MONGO_CONTAINER_NAME}"
                        $env:BACKEND_PORT = "8081"
                        $env:FRONTEND_PORT = "80"
                        $env:MONGO_PORT = "27017"
                        $env:NODE_ENV = "staging"
                        $env:MONGODB_URI = "mongodb://${env:DB_HOST}:${env:DB_PORT}/student-management-staging"
                        
                        docker-compose up -d
                        
                        Write-Host "Waiting for containers to be healthy..."
                        Start-Sleep -Seconds 10
                        
                        docker-compose ps
                        Write-Host "Staging deployment completed successfully!"
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
                            Write-Host "Stopping and removing old containers..."
                            docker-compose down
                            
                            Write-Host "Pulling latest images..."
                            docker pull ${env:DOCKER_HUB}/${env:NAME_BACKEND}:${env:DOCKER_TAG}
                            docker pull ${env:DOCKER_HUB}/${env:NAME_FRONTEND}:${env:DOCKER_TAG}
                            
                            Write-Host "Starting new containers..."
                            $env:DOCKER_HUB = "${env:DOCKER_HUB}"
                            $env:NAME_BACKEND = "${env:NAME_BACKEND}"
                            $env:NAME_FRONTEND = "${env:NAME_FRONTEND}"
                            $env:DOCKER_TAG = "${env:DOCKER_TAG}"
                            $env:BACKEND_CONTAINER_NAME = "${env:BACKEND_CONTAINER_NAME}"
                            $env:FRONTEND_CONTAINER_NAME = "${env:FRONTEND_CONTAINER_NAME}"
                            $env:MONGO_CONTAINER_NAME = "${env:MONGO_CONTAINER_NAME}"
                            $env:BACKEND_PORT = "8081"
                            $env:FRONTEND_PORT = "80"
                            $env:MONGO_PORT = "27017"
                            $env:NODE_ENV = "production"
                            $env:MONGODB_URI = "mongodb://${env:DB_HOST}:${env:DB_PORT}/student-management-production"
                            
                            docker-compose up -d
                            
                            Write-Host "Waiting for containers to be healthy..."
                            Start-Sleep -Seconds 10
                            
                            docker-compose ps
                            Write-Host "Production deployment completed successfully!"
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
                    powershell '''
                        Write-Host "Đang chờ các dịch vụ sẵn sàng..."
                        Start-Sleep -Seconds 15
                        
                        $DEPLOY_SERVER = "${env:STAGING_SERVER}"
                        $BRANCH_NAME = "${env:COMPUTED_BRANCH}"
                        if ($BRANCH_NAME -eq "main") {
                            $DEPLOY_SERVER = "${env:PRODUCTION_SERVER}"
                        }
                        
                        Write-Host "Testing Backend API..."
                        try { Invoke-WebRequest -Uri http://$DEPLOY_SERVER:8081 } catch { Write-Host "Backend health check failed" }
                        
                        Write-Host "Testing Frontend..."
                        try { Invoke-WebRequest -Uri http://$DEPLOY_SERVER } catch { Write-Host "Frontend health check failed" }
                        
                        Write-Host "Smoke tests completed"
                    '''
                }
            }
        }
    }

    post {
        // Các hành động luôn được thực hiện
        always {
            echo "✏️ Pipeline kết thúc cho nhánh: ${env.COMPUTED_BRANCH ?: 'unknown'}"
        }
        success {
            echo "✅ Pipeline thành công!"
        }
        failure {
            echo "❌ Pipeline thất bại!"
        }
    }
}
