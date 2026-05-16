# Jenkins CI/CD Pipeline Setup Guide

## Overview
This document provides step-by-step instructions to set up a complete Jenkins CI/CD Pipeline for the Student Management project with build → test → deploy stages.

## Prerequisites
- Jenkins Server (10.32.3.170)
- Docker & Docker Compose installed on Jenkins server
- GitLab project (10.32.4.111:8090)
- SonarQube server (10.32.3.171)
- Staging server (10.32.3.172)
- Production server (10.32.3.173)

## Step 1: Prepare Local Environment

### 1.1 Copy Environment Variables
```bash
cp .env.example .env
# Edit .env with your actual credentials
```

### 1.2 Test Docker Build Locally
```bash
# Build and run locally
docker-compose up -d

# Verify containers
docker-compose ps

# Test Backend (Swagger)
curl http://localhost:8081

# Test Frontend
curl http://localhost

# Stop containers
docker-compose down
```

## Step 2: Setup Jenkins Server

### 2.1 SSH into Jenkins Server
```bash
ssh root@10.32.3.170
```

### 2.2 Create Setup Directory
```bash
mkdir -p /home/app-installed
cd /home/app-installed
```

### 2.3 Install Jenkins
```bash
touch jenkins-setup.sh
chmod +x jenkins-setup.sh
cat > jenkins-setup.sh << 'EOF'
#!/bin/bash
set -e

# Update system
apt-get update
apt-get upgrade -y

# Install Java
apt-get install -y openjdk-11-jdk

# Add Jenkins repository
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add -
sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'

# Install Jenkins
apt-get update
apt-get install -y jenkins

# Start Jenkins
systemctl start jenkins
systemctl enable jenkins

echo "Jenkins installation completed. Access it at http://10.32.3.170:8080"
EOF

./jenkins-setup.sh
```

### 2.4 Get Initial Admin Password
```bash
cat /var/lib/jenkins/secrets/initialAdminPassword
```

### 2.5 Install Docker on Jenkins Server
```bash
touch docker-setup.sh
chmod +x docker-setup.sh
cat > docker-setup.sh << 'EOF'
#!/bin/bash
set -e

# Install Docker dependencies
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Add Docker GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add Jenkins user to docker group
usermod -aG docker jenkins
newgrp docker

# Start Docker
systemctl start docker
systemctl enable docker

# Check versions
docker --version
docker compose version

echo "Docker installation completed"
EOF

./docker-setup.sh
```

### 2.6 Add Jenkins to sudoers (Optional)
```bash
visudo
# Add this line
jenkins ALL=(ALL) NOPASSWD: ALL
```

## Step 3: Configure Jenkins via Web UI

### 3.1 Access Jenkins
- Go to http://10.32.3.170:8080
- Enter the initial admin password
- Install suggested plugins
- Create admin account
- Install additional plugins:

### 3.2 Install Required Plugins
1. **Manage Jenkins → Manage Plugins → Available**
   - GitLab Plugin
   - Docker Pipeline
   - SSH Agent
   - SonarQube Scanner
   - Blue Ocean (optional but recommended)

### 3.3 Create Docker Hub Credentials
1. **Manage Jenkins → Manage Credentials → System → Global credentials**
2. **Add Credentials**
   - Kind: Username with password
   - ID: `docker-hub-credentials`
   - Username: `your-dockerhub-username`
   - Password: `your-dockerhub-password`

### 3.4 Create GitLab Access Token
1. Go to GitLab → User Settings → Access Tokens
2. Create token with:
   - Scopes: `api`, `read_api`, `write_repository`, `api`, `read_user`, `read_repository`
   - Name: `jenkins-token`
3. Copy the token

### 3.5 Configure GitLab in Jenkins
1. **Manage Jenkins → Configure System → GitLab**
2. Add GitLab Server:
   - GitLab host URL: `http://10.32.4.111:8090`
   - Credentials: Create new (use the token from step 3.4)
   - Kind: GitLab API token
   - API token: `paste-your-gitlab-token`
3. Test the connection
4. Click **Apply** and **Save**

### 3.6 Create GitLab Webhook Token
1. In GitLab, go to Admin Area → Settings → Network
2. Check: "Allow requests to the local network from hooks and services"
3. Save

### 3.7 Create SonarQube Credentials
1. **Manage Jenkins → Manage Credentials → System → Global credentials**
2. **Add Credentials**
   - Kind: Secret text
   - ID: `sonarqube-token`
   - Secret: `your-sonarqube-token`

### 3.8 Configure SonarQube in Jenkins
1. **Manage Jenkins → Configure System → SonarQube servers**
2. Add SonarQube Server:
   - Name: `SonarQube`
   - Server URL: `http://10.32.3.171:9000`
   - Server authentication token: Select `sonarqube-token`
3. Click **Apply** and **Save**

## Step 4: Create SSH Key for Deployment

### 4.1 Generate SSH Key on Jenkins Server
```bash
ssh-keygen -t rsa -f /home/jenkins/.ssh/id_rsa -N ""
chown jenkins:jenkins /home/jenkins/.ssh/id_rsa
chmod 600 /home/jenkins/.ssh/id_rsa
```

### 4.2 Copy Key to Deployment Servers
```bash
# For Staging (10.32.3.172)
ssh-copy-id -i /home/jenkins/.ssh/id_rsa.pub root@10.32.3.172

# For Production (10.32.3.173)
ssh-copy-id -i /home/jenkins/.ssh/id_rsa.pub root@10.32.3.173
```

### 4.3 Create SSH Credentials in Jenkins
1. **Manage Jenkins → Manage Credentials → System → Global credentials**
2. **Add Credentials**
   - Kind: SSH Username with private key
   - ID: `jenkins-ssh-key`
   - Username: `root`
   - Private Key: (paste contents of `/home/jenkins/.ssh/id_rsa`)
3. Click **Create**

### 4.4 Get Private Key Content
```bash
cat /home/jenkins/.ssh/id_rsa
```

## Step 5: Create Jenkins Pipeline

### 5.1 Create New Pipeline Job
1. **Jenkins Dashboard → New Item**
2. Job name: `student-management-pipeline`
3. Select **Pipeline**
4. Click **OK**

### 5.2 Configure Pipeline - General Tab
- **Discard old builds**: Check
  - Strategy: Log Rotation
  - Days to keep builds: 10
  - Max # of builds to keep: 10

### 5.3 Configure Pipeline - Build Triggers
- Check **Build when a change is pushed to GitLab**
- Check **Push Events**
- Check **Merge Request Events**
- Push Events accepted for: `staging, main`

### 5.4 Configure Pipeline - Pipeline Tab
- Definition: **Pipeline script from SCM**
- SCM: **Git**
  - Repository URL: `http://10.32.4.111:8090/your-group/student-management.git`
  - Credentials: Create new → GitLab credentials (username + token)
  - Branch Specifier: `*/staging` `*/main`
  - Script Path: `Jenkinsfile`

### 5.5 Click **Save**

## Step 6: Setup SonarQube (Optional but Recommended)

### 6.1 SSH to SonarQube Server
```bash
ssh root@10.32.3.171
```

### 6.2 Install Docker
```bash
apt-get update && apt-get install -y docker.io docker-compose
systemctl start docker
systemctl enable docker
```

### 6.3 Run SonarQube
```bash
docker run -d --name sonarqube \
  -p 9000:9000 \
  -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLED=true \
  -e SONAR_JAVA_OPTS="-Xms512m -Xmx512m" \
  sonarqube:latest
```

### 6.4 Access SonarQube
- Go to http://10.32.3.171:9000
- Login: admin / admin (change password on first login)
- Create project for `student-management`

## Step 7: Setup Deployment Servers

### 7.1 SSH to Staging Server
```bash
ssh root@10.32.3.172
```

### 7.2 Install Docker & Docker Compose
```bash
# See docker-setup.sh content from Step 2.5

apt-get update
apt-get install -y docker.io docker-compose
systemctl start docker
systemctl enable docker

# Create app directory
mkdir -p /app
cd /app
```

### 7.3 Copy docker-compose.yml to Server
```bash
# From your local machine
scp docker-compose.yml root@10.32.3.172:/app/
```

### 7.4 Repeat for Production Server (10.32.3.173)

## Step 8: Test the Pipeline

### 8.1 Push Code to GitLab
```bash
git add .
git commit -m "setup: initialize jenkins cicd pipeline"
git push origin staging
```

### 8.2 Create Merge Request
1. Go to GitLab
2. Create merge request from `develop` → `staging`
3. Merge it

### 8.3 Watch Jenkins Build
1. Go to Jenkins Dashboard
2. Click on `student-management-pipeline`
3. Watch the build progress in real-time (or use Blue Ocean view)

### 8.4 Check Build Results
- Build logs: See each stage execution
- Docker images: Check Docker Hub for uploaded images
- Staging deployment: Verify services running on 10.32.3.172

## Step 9: Verify Deployments

### 9.1 Staging Verification
```bash
# SSH to staging server
ssh root@10.32.3.172

# Check containers
docker ps

# Check logs
docker logs student-management-backend-staging
docker logs student-management-frontend-staging

# Test API
curl http://10.32.3.172:8081/api/health

# Test Frontend
curl http://10.32.3.172
```

### 9.2 Test Endpoints
- **Backend Swagger**: http://10.32.3.172:8081/swagger
- **Frontend**: http://10.32.3.172
- **API**: http://10.32.3.172:8081/api/students

## Pipeline Stages Overview

### Build Stage
- Builds Backend Docker image
- Builds Frontend Docker image

### Test Stage
- Runs backend unit tests
- Runs SonarQube code analysis

### Push Stage
- Authenticates with Docker Hub
- Pushes images with tags: `branch-commithash` and `latest`

### Deploy Staging
- Triggered on `staging` branch
- Pulls latest images
- Stops old containers
- Runs new containers with docker-compose

### Deploy Production
- Triggered on `main` branch
- Requires manual approval
- Same as staging but on production server

## Troubleshooting

### Jenkins Cannot Connect to GitLab
- Verify GitLab token is valid
- Check network connectivity: `ssh root@10.32.3.170` → `curl http://10.32.4.111:8090`

### Docker Build Fails
- Check Backend/Dockerfile and Frontend/Dockerfile are present
- Verify npm packages are compatible with Node.js 18

### SSH Deployment Fails
- Test SSH connection manually: `ssh -i /home/jenkins/.ssh/id_rsa root@10.32.3.172`
- Verify docker-compose.yml exists on deployment server

### SonarQube Analysis Fails
- Check SonarQube service is running
- Verify token is correct
- Check source code paths in Jenkinsfile

## Performance Tuning

### Optimize Docker Builds
- Use `.dockerignore` to exclude unnecessary files
- Use Docker layer caching
- Consider multi-stage builds (already done in Frontend)

### Optimize Jenkins
- Run pipeline in parallel where possible
- Use pipeline agent directives for specific tools
- Archive build artifacts for faster access

## Security Best Practices

1. **Credentials**
   - Use Jenkins credentials store, never hardcode secrets
   - Rotate tokens regularly
   - Use SSH keys instead of passwords when possible

2. **Docker Registry**
   - Keep one private repository for sensitive images
   - Sign images with Docker Content Trust

3. **Network**
   - Restrict SSH access to Jenkins server
   - Use VPN/Private networks for internal servers
   - Enable SSL/TLS for all communication

4. **Audit**
   - Enable Jenkins audit logs
   - Monitor deployment logs
   - Track who deployed what and when

## Next Steps

1. ✅ Complete this setup guide
2. Test the full pipeline with staging deployment
3. Implement additional tests (unit tests, integration tests)
4. Add health checks and monitoring
5. Implement rollback strategy
6. Setup production deployment approval workflow
7. Document runbooks for common issues

## Additional Resources

- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [GitLab CI/CD](https://docs.gitlab.com/ee/ci/)
- [Docker Documentation](https://docs.docker.com/)
- [SonarQube Documentation](https://docs.sonarqube.org/)
