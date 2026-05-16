#!/bin/bash

# Script to prepare Jenkins server with all dependencies

set -e

echo "=========================================="
echo "Jenkins Server Setup Script"
echo "=========================================="
echo ""

JENKINS_VERSION="2.414.1"
DOCKER_COMPOSE_VERSION="v2.20.2"

# Update system
echo "[1/6] Updating system packages..."
apt-get update
apt-get upgrade -y

# Install Java (required for Jenkins)
echo "[2/6] Installing Java..."
apt-get install -y openjdk-11-jdk

# Add Jenkins repository and install Jenkins
echo "[3/6] Installing Jenkins..."
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add -
sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
apt-get update
apt-get install -y jenkins

# Install Docker
echo "[4/6] Installing Docker..."
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

# Install Docker Compose
echo "[5/6] Installing Docker Compose..."
curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Configure permissions
echo "[6/6] Configuring permissions..."
usermod -aG docker jenkins
systemctl start jenkins
systemctl enable jenkins
systemctl start docker
systemctl enable docker

echo ""
echo "=========================================="
echo "✅ Jenkins server setup completed!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Wait 1-2 minutes for Jenkins to fully start"
echo "2. Access Jenkins at http://$(hostname -I | awk '{print $1}'):8080"
echo "3. Get initial password: cat /var/lib/jenkins/secrets/initialAdminPassword"
echo "4. Follow the Jenkins UI setup wizard"
echo "5. Install suggested plugins"
echo "6. Create admin account"
echo ""
echo "Verify installations:"
echo "  java -version"
echo "  docker --version"
echo "  docker-compose --version"
echo "  systemctl status jenkins"
echo ""
