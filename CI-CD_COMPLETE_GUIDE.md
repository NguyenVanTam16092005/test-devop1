# Complete Jenkins CI/CD Pipeline Setup - Student Management System

## 📋 Table of Contents
1. [Quick Overview](#overview)
2. [Project Structure](#project-structure)
3. [Prerequisites](#prerequisites)
4. [Local Development Setup](#local-development-setup)
5. [Jenkins Setup](#jenkins-setup)
6. [Pipeline Stages](#pipeline-stages)
7. [Deployment](#deployment)
8. [Troubleshooting](#troubleshooting)

---

## 📖 Overview

This repository contains a complete CI/CD pipeline setup for a MERN Student Management System using Jenkins. The pipeline automates:

- **Build**: Docker container creation for Backend (Node.js) and Frontend (React)
- **Test**: Unit tests and SonarQube code quality analysis
- **Deploy**: Automated deployment to Staging and Production environments

### Architecture

```
GitLab (10.32.4.111:8090)
    ↓
Jenkins Server (10.32.3.170:8080)
    ├→ Build Docker Images
    ├→ Run Tests
    ├→ Push to Docker Hub
    ├→ Deploy to Staging (10.32.3.172)
    └→ Deploy to Production (10.32.3.173)
```

---

## 📁 Project Structure

```
DevOps-main/
├── Backend/
│   ├── Dockerfile              # Backend containerization
│   ├── .dockerignore           # Files to ignore in Docker build
│   ├── .env.example            # Backend environment variables
│   ├── package.json
│   ├── server.js
│   └── routes/
│       └── students_route.js
├── Frontend/
│   ├── Dockerfile              # Frontend containerization
│   ├── .dockerignore           # Files to ignore in Docker build
│   ├── nginx.conf              # Nginx configuration for SPA
│   ├── .env.example            # Frontend environment variables
│   ├── package.json
│   ├── vite.config.js
│   └── src/
│       └── Components/
├── Jenkinsfile                 # CI/CD Pipeline definition
├── docker-compose.yml          # Multi-container orchestration
├── .env.example                # Root environment variables
├── .env.docker                 # Docker-specific env variables
├── JENKINS_SETUP.md            # Detailed Jenkins setup guide
├── quick-start.sh              # Quick start script
├── cleanup.sh                  # Cleanup script
├── deploy.sh                   # Deployment script
└── jenkins-server-setup.sh     # Jenkins server initialization
```

---

## ✅ Prerequisites

### Local Machine
- Docker Desktop (with Docker Compose v2+)
- Git
- Node.js 18+ (optional, for local development)

### Infrastructure
- Jenkins Server (Ubuntu 20.04+): 10.32.3.170
- Staging Server (Ubuntu 20.04+): 10.32.3.172
- Production Server (Ubuntu 20.04+): 10.32.3.173
- GitLab Server: 10.32.4.111:8090
- SonarQube Server: 10.32.3.171:9000
- MongoDB Server: 10.32.3.170:27017
- Docker Hub Account (for image registry)

---

## 🚀 Local Development Setup

### Step 1: Clone and Configure
```bash
# Clone the repository
git clone http://10.32.4.111:8090/your-group/student-management.git
cd student-management

# Copy environment files
cp .env.example .env
cp Backend/.env.example Backend/.env
cp Frontend/.env.example Frontend/.env

# Edit .env files with your configuration
vim .env
```

### Step 2: Quick Start with Docker
```bash
# Make script executable
chmod +x quick-start.sh

# Run quick start script (handles everything)
./quick-start.sh
```

Or manually:
```bash
# Build images
docker-compose build

# Start services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### Step 3: Verify Services
```bash
# Check containers
docker-compose ps

# Test Backend API
curl http://localhost:8081

# Test Frontend
curl http://localhost

# View specific logs
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f mongo
```

### Step 4: Access Applications
- **Frontend**: http://localhost
- **Backend API**: http://localhost:8081
- **MongoDB**: mongodb://admin:admin123@localhost:27017

---

## 🔧 Jenkins Setup

### Quick Setup (Automated)
```bash
# SSH into Jenkins server
ssh root@10.32.3.170

# Run automated setup
cd /home/app-installed
chmod +x jenkins-server-setup.sh
./jenkins-server-setup.sh

# Get initial admin password after setup
cat /var/lib/jenkins/secrets/initialAdminPassword
```

### Step-by-Step Manual Setup
For detailed step-by-step instructions, see [JENKINS_SETUP.md](./JENKINS_SETUP.md)

### Key Configuration Steps

1. **Access Jenkins**: http://10.32.3.170:8080
2. **Install Plugins**:
   - GitLab Plugin
   - Docker Pipeline
   - SSH Agent
   - SonarQube Scanner
   - Blue Ocean (recommended)

3. **Create Credentials**:
   - Docker Hub: `docker-hub-credentials`
   - GitLab Token: GitLab access token
   - SonarQube: `sonarqube-token`
   - SSH Key: `jenkins-ssh-key`

4. **Configure Integrations**:
   - GitLab: Add GitLab server and test connection
   - SonarQube: Add SonarQube server
   - Docker Hub: Setup authentication

5. **Create Pipeline Job**:
   - Name: `student-management-pipeline`
   - Type: Pipeline
   - Repository: `http://10.32.4.111:8090/your-group/student-management.git`
   - Script Path: `Jenkinsfile`
   - Trigger: GitLab push/merge request events

---

## 📊 Pipeline Stages

### Stage 1: Checkout
- Clones code from GitLab
- Captures commit metadata (author, message)

### Stage 2: Build Backend
- Builds Docker image: `${DOCKER_HUB}/backend:${TAG}`
- Uses Dockerfile with Node.js 18 Alpine

### Stage 3: Build Frontend
- Builds Docker image: `${DOCKER_HUB}/frontend:${TAG}`
- Uses multi-stage build with Nginx

### Stage 4: Test Backend
- Runs backend tests
- Can be extended with: `npm test`

### Stage 5: Code Quality Analysis
- Runs SonarQube analysis
- Scans both Backend and Frontend code
- Reports quality metrics

### Stage 6: Push to Docker Hub
- Authenticates with Docker Hub
- Pushes images with tags:
  - `branch-commithash` (e.g., `staging-abc1234`)
  - `latest`

### Stage 7: Database Migration (Optional)
- Prompts for manual approval
- Can run database migrations
- Skips if not needed

### Stage 8: Deploy to Staging
- Triggered on `staging` branch only
- Pulls latest images
- Stops old containers
- Starts new containers with docker-compose
- Waits for services to be healthy

### Stage 9: Deploy to Production
- Triggered on `main` branch only
- Requires manual approval
- Same deployment process as staging
- Uses production database configuration

### Stage 10: Smoke Tests
- Verifies Backend API health
- Verifies Frontend availability
- Runs after deployment

---

## 🌿 Git Branch Strategy

```
main (production)
  ↑
  └← staging (staging) ← develop (development)
```

### Branch Configuration

| Branch | Jenkins Trigger | Deploy To | Auto Deploy |
|--------|----------------|-----------|-------------|
| develop | ❌ No | - | ❌ No |
| staging | ✅ Yes | Staging | ✅ Yes |
| main | ✅ Yes | Production | ❌ Manual Approval |

### Git Workflow

```bash
# 1. Create feature branch from develop
git checkout -b feature/new-feature develop

# 2. Make changes and commit
git add .
git commit -m "feat: add new feature"

# 3. Push and create merge request
git push origin feature/new-feature
# → Create MR: feature/new-feature → develop

# 4. After review, merge to develop
# → Staging pipeline can pick it up if pushed to staging

# 5. To deploy to staging
git checkout staging
git merge develop
git push origin staging
# → Jenkins pipeline runs automatically

# 6. To deploy to production
git checkout main
git merge staging
git push origin main
# → Jenkins pipeline runs with manual approval required
```

---

## 🚀 Deployment

### Staging Deployment (Automatic)
```bash
# Push code to staging branch
git push origin staging

# Check Jenkins
# → Pipeline runs automatically
# → Deploys to 10.32.3.172

# Verify
curl http://10.32.3.172:8081
curl http://10.32.3.172
```

### Production Deployment (Manual Approval)
```bash
# Push code to main branch
git push origin main

# Go to Jenkins
# → Pipeline pauses for approval
# → Click "Proceed" to approve

# Verify
curl http://10.32.3.173:8081
curl http://10.32.3.173
```

### Manual Deployment (Without Jenkins)
```bash
# SSH to server
ssh root@10.32.3.172

# Navigate to app directory
cd /app

# Update docker-compose.yml with your image tags
export DOCKER_HUB=your-username
export NAME_BACKEND=backend
export NAME_FRONTEND=frontend
export DOCKER_TAG=staging-abc1234

# Deploy
docker-compose up -d

# Check status
docker-compose ps
docker-compose logs -f
```

---

## 📝 Environment Variables

### Root .env
```env
DOCKER_HUB=your-dockerhub-username
BACKEND_PORT=8081
FRONTEND_PORT=80
MONGO_PORT=27017
NODE_ENV=production
```

### Backend/.env
```env
MONGODB_URL=mongodb://admin:admin123@mongo:27017/student-management
PORT=80
NODE_ENV=production
```

### Frontend/.env
```env
VITE_API_URL=http://localhost:8081
```

---

## 🔍 Monitoring & Logging

### Jenkins
- Pipeline logs: Jenkins UI → Build → Console Output
- Real-time view: Jenkins UI → Open Blue Ocean

### Docker Containers
```bash
# View all logs
docker-compose logs -f

# View specific service
docker-compose logs -f backend
docker-compose logs -f frontend

# View last 100 lines
docker-compose logs --tail=100 backend

# Export logs
docker-compose logs > logs.txt
```

### Server Health
```bash
# SSH to server
ssh root@10.32.3.172

# Check containers
docker ps

# Check resource usage
docker stats

# Check health
docker-compose ps
curl http://localhost:8081/api/health
```

---

## 🆘 Troubleshooting

### Jenkins Cannot Connect to GitLab
```bash
# Check network connectivity
ssh root@10.32.3.170
curl -v http://10.32.4.111:8090

# Verify token is valid
# → GitLab: User Settings → Access Tokens

# Check Jenkins logs
tail -f /var/log/jenkins/jenkins.log
```

### Docker Build Fails
```bash
# Check Docker logs
docker-compose logs backend

# Test build manually
cd Backend
docker build -t test-backend:latest .

# Check for Dockerfile errors
cat Dockerfile
```

### SSH Deployment Fails
```bash
# Test SSH connection
ssh -i /home/jenkins/.ssh/id_rsa root@10.32.3.172

# Check permissions
ls -la /home/jenkins/.ssh/id_rsa
chmod 600 /home/jenkins/.ssh/id_rsa

# Verify docker-compose.yml exists
ssh root@10.32.3.172 ls -la /app/docker-compose.yml
```

### Container Health Check Fails
```bash
# Check logs
docker-compose logs backend

# Test manually
curl http://localhost:80

# Check port bindings
docker-compose ps
docker port backend
```

### MongoDB Connection Issues
```bash
# Check MongoDB container
docker-compose ps mongo

# Test connection
docker exec -it student-management-mongo mongosh -u admin -p admin123

# View logs
docker-compose logs mongo
```

---

## 📚 Additional Resources

- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [GitLab CI/CD](https://docs.gitlab.com/ee/ci/)
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [SonarQube Documentation](https://docs.sonarqube.org/)
- [Nginx Configuration](https://nginx.org/en/docs/)

---

## 🔐 Security Best Practices

1. **Credentials Management**
   - Never commit `.env` files
   - Use Jenkins credentials store
   - Rotate tokens regularly
   - Use SSH keys instead of passwords

2. **Docker Registry**
   - Keep sensitive images private
   - Sign images with Docker Content Trust
   - Regular security scanning

3. **Network Security**
   - Restrict SSH access
   - Use VPN for internal servers
   - Enable SSL/TLS for communication
   - Firewall rules

4. **Audit & Monitoring**
   - Enable Jenkins audit logs
   - Monitor deployment changes
   - Track who deployed what
   - Regular backup of configurations

---

## ✨ Next Steps

After successful setup:

1. ✅ Test full pipeline with staging deployment
2. Implement additional tests (unit, integration, e2e)
3. Add health checks and monitoring
4. Setup log aggregation (ELK, Splunk)
5. Implement rollback strategy
6. Setup alerts and notifications
7. Document runbooks for common issues
8. Regular backup and disaster recovery plan

---

## 📞 Support

For issues or questions:
1. Check [JENKINS_SETUP.md](./JENKINS_SETUP.md) for detailed setup
2. Review [Troubleshooting](#troubleshooting) section
3. Check Jenkins logs: `/var/log/jenkins/jenkins.log`
4. Review pipeline console output in Jenkins UI

---

## 📄 License

This project is licensed under the ISC License. See LICENSE file for details.

---

**Last Updated**: 2024
**Maintained By**: Your Team
**Pipeline Version**: 1.0.0
