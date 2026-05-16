# Jenkins CI/CD Pipeline Setup Checklist

## Phase 1: Local Setup ✅
- [ ] Clone repository
- [ ] Copy `.env.example` to `.env`
- [ ] Copy `Backend/.env.example` to `Backend/.env`
- [ ] Copy `Frontend/.env.example` to `Frontend/.env`
- [ ] Run `./quick-start.sh` or `docker-compose up -d`
- [ ] Verify Backend: `curl http://localhost:8081`
- [ ] Verify Frontend: `curl http://localhost`
- [ ] Test MongoDB connection
- [ ] Run `docker-compose down` when complete

## Phase 2: Jenkins Server Setup
- [ ] SSH into Jenkins server: `ssh root@10.32.3.170`
- [ ] Run `jenkins-server-setup.sh` or manual setup
- [ ] Access Jenkins: http://10.32.3.170:8080
- [ ] Get initial password: `cat /var/lib/jenkins/secrets/initialAdminPassword`
- [ ] Complete Jenkins setup wizard
- [ ] Install suggested plugins
- [ ] Create admin account
- [ ] Verify Docker on Jenkins: `docker --version`
- [ ] Verify Docker Compose: `docker-compose --version`

## Phase 3: Jenkins Plugin Installation
- [ ] Go to Manage Jenkins → Manage Plugins
- [ ] Install: **GitLab Plugin**
- [ ] Install: **Docker Pipeline**
- [ ] Install: **SSH Agent**
- [ ] Install: **SonarQube Scanner**
- [ ] Install: **Blue Ocean** (optional but recommended)
- [ ] Restart Jenkins if prompted

## Phase 4: Credentials Setup
### 4.1 Docker Hub Credentials
- [ ] Go to Manage Jenkins → Manage Credentials → System → Global credentials
- [ ] Add Credentials
  - [ ] Kind: Username with password
  - [ ] ID: `docker-hub-credentials`
  - [ ] Username: Your DockerHub username
  - [ ] Password: Your DockerHub password
- [ ] Click Create

### 4.2 GitLab Access Token
- [ ] Create token in GitLab (User Settings → Access Tokens)
  - [ ] Name: `jenkins-token`
  - [ ] Scopes: `api`, `read_api`, `write_repository`, `read_user`, `read_repository`
- [ ] Copy token and save it

### 4.3 GitLab Credentials in Jenkins
- [ ] Add Credentials in Jenkins
  - [ ] Kind: GitLab API token
  - [ ] API token: Paste your GitLab token
  - [ ] Click Create

### 4.4 SonarQube Token
- [ ] Create token in SonarQube (User Settings → Security → Tokens)
- [ ] Copy token
- [ ] Add to Jenkins Credentials
  - [ ] Kind: Secret text
  - [ ] ID: `sonarqube-token`
  - [ ] Secret: Paste SonarQube token

### 4.5 SSH Key for Deployment
- [ ] On Jenkins server: `ssh-keygen -t rsa -f /home/jenkins/.ssh/id_rsa -N ""`
- [ ] Copy key to staging: `ssh-copy-id -i /home/jenkins/.ssh/id_rsa.pub root@10.32.3.172`
- [ ] Copy key to production: `ssh-copy-id -i /home/jenkins/.ssh/id_rsa.pub root@10.32.3.173`
- [ ] Add to Jenkins Credentials
  - [ ] Kind: SSH Username with private key
  - [ ] ID: `jenkins-ssh-key`
  - [ ] Username: `root`
  - [ ] Private Key: Paste contents of id_rsa

## Phase 5: Jenkins Configuration
### 5.1 Configure GitLab
- [ ] Manage Jenkins → Configure System → GitLab
- [ ] GitLab host URL: `http://10.32.4.111:8090`
- [ ] Credentials: Select GitLab token credentials
- [ ] Click Test Connection
- [ ] Should show: "Success"
- [ ] Click Apply and Save

### 5.2 Configure SonarQube
- [ ] Manage Jenkins → Configure System → SonarQube servers
- [ ] Name: `SonarQube`
- [ ] Server URL: `http://10.32.3.171:9000`
- [ ] Server authentication token: Select `sonarqube-token`
- [ ] Click Apply and Save

## Phase 6: Create Pipeline Job
- [ ] Manage Jenkins → New Item
- [ ] Job name: `student-management-pipeline`
- [ ] Type: **Pipeline**
- [ ] Click OK

### 6.1 General Settings
- [ ] Check: Discard old builds
  - [ ] Days to keep builds: 10
  - [ ] Max # of builds to keep: 10

### 6.2 Build Triggers
- [ ] Check: Build when a change is pushed to GitLab
- [ ] Check: Push Events
- [ ] Check: Merge Request Events
- [ ] Push Events: `staging, main`

### 6.3 Advanced Project Options
- [ ] Definition: Pipeline script from SCM
- [ ] SCM: Git
  - [ ] Repository URL: `http://10.32.4.111:8090/your-group/student-management.git`
  - [ ] Credentials: Select GitLab credentials
  - [ ] Branch Specifier: `*/staging` `*/main`
  - [ ] Script Path: `Jenkinsfile`
- [ ] Click Save

## Phase 7: GitLab Webhook Setup
- [ ] In GitLab, go to project → Settings → Webhooks
- [ ] URL: `http://your-jenkins-user:your-jenkins-token@10.32.3.170:8080/project/student-management-pipeline`
- [ ] Trigger events: Push events, Merge request events
- [ ] Check: Enable SSL verification (if using HTTPS)
- [ ] Click Add webhook
- [ ] Test the webhook (should show success)

## Phase 8: Deployment Server Setup (Staging & Production)
- [ ] SSH to staging server: `ssh root@10.32.3.172`
  - [ ] Install Docker: Follow docker-setup.sh
  - [ ] Create /app directory: `mkdir -p /app && cd /app`
  - [ ] Copy docker-compose.yml: `scp root@yourlocal:/path/docker-compose.yml /app/`
- [ ] Repeat for production server (10.32.3.173)

## Phase 9: Test Pipeline
### 9.1 Create Merge Request
- [ ] In GitLab, create a feature branch: `git checkout -b feature/test`
- [ ] Make a simple change and commit
- [ ] Push to GitLab: `git push origin feature/test`
- [ ] Create Merge Request: feature/test → staging

### 9.2 Watch Jenkins Build
- [ ] Go to Jenkins Dashboard
- [ ] Click `student-management-pipeline`
- [ ] Should see build running
- [ ] Watch each stage complete:
  - [ ] Checkout
  - [ ] Build Backend
  - [ ] Build Frontend
  - [ ] Test Backend
  - [ ] Code Quality Analysis
  - [ ] Push to Docker Hub
  - [ ] Deploy to Staging

### 9.3 Verify Deployment
- [ ] Check Docker Hub for new images
- [ ] Verify containers on staging server: `docker ps`
- [ ] Test Backend: `curl http://10.32.3.172:8081`
- [ ] Test Frontend: `curl http://10.32.3.172`

## Phase 10: Production Deployment Test
- [ ] Merge staging → main: `git checkout main && git merge staging && git push origin main`
- [ ] Go to Jenkins build
- [ ] Pipeline pauses for approval
- [ ] Click **Proceed** to approve production deployment
- [ ] Watch deployment complete
- [ ] Verify on production server: `curl http://10.32.3.173:8081`

## Phase 11: Verification & Validation
- [ ] Jenkins UI accessible: ✅ http://10.32.3.170:8080
- [ ] SonarQube accessible: ✅ http://10.32.3.171:9000
- [ ] Pipeline builds successfully: ✅ No errors
- [ ] Docker images pushed to Hub: ✅ Visible in Docker Hub
- [ ] Staging deployment works: ✅ Services running
- [ ] Production deployment works: ✅ Services running
- [ ] API endpoints responding: ✅ Backend working
- [ ] Frontend loading: ✅ Frontend working
- [ ] Database connected: ✅ MongoDB working

## Phase 12: Documentation & Handoff
- [ ] Team trained on git workflow
- [ ] Documentation reviewed with team
- [ ] Runbooks created for common issues
- [ ] On-call procedures documented
- [ ] Monitoring/alerting setup (if using)
- [ ] Backup procedures documented
- [ ] Disaster recovery plan created

## Ongoing Maintenance
- [ ] Monitor build times (Target: < 10 minutes)
- [ ] Keep Jenkins plugins updated
- [ ] Monitor disk space on Jenkins server
- [ ] Monitor Docker Hub storage
- [ ] Regular backup of Jenkins configuration
- [ ] Review and rotate access credentials quarterly
- [ ] Monitor pipeline success rate (Target: > 95%)

---

## 🔍 Quick Diagnostics

If something isn't working:

1. **Check Jenkins Logs**
   ```bash
   ssh root@10.32.3.170
   tail -f /var/log/jenkins/jenkins.log
   ```

2. **Check Docker on Jenkins**
   ```bash
   docker ps
   docker images
   docker system df
   ```

3. **Check Network Connectivity**
   ```bash
   ping 10.32.4.111  # GitLab
   curl http://10.32.4.111:8090
   curl http://10.32.3.171:9000  # SonarQube
   ```

4. **Test Git Clone**
   ```bash
   cd /tmp && git clone http://10.32.4.111:8090/your-group/student-management.git
   ```

5. **Check Deployment Server**
   ```bash
   ssh root@10.32.3.172
   docker-compose ps
   docker-compose logs
   ```

---

## 📞 Support Resources

- **Jenkins Setup**: See `JENKINS_SETUP.md`
- **Complete Guide**: See `CI-CD_COMPLETE_GUIDE.md`
- **Quick Start**: Run `./quick-start.sh`
- **Cleanup**: Run `./cleanup.sh`

---

## ✅ Sign-Off

- Setup started: _______________
- Setup completed: _______________
- Tested by: _______________
- Date: _______________
- Notes: _______________

**Remember**: Keep this checklist updated as you complete each step!
