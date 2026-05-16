#!/bin/bash

# Jenkins CI/CD Quick Start
# This script helps you test the Docker setup locally before deploying to Jenkins

set -e

echo "=========================================="
echo "Jenkins CI/CD Quick Start Guide"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Step 1: Check Docker
echo -e "${YELLOW}[Step 1] Checking Docker installation...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed${NC}"
    echo "Please install Docker from https://docs.docker.com/engine/install/"
    exit 1
fi
echo -e "${GREEN}✅ Docker is installed: $(docker --version)${NC}"
echo ""

# Step 2: Check Docker Compose
echo -e "${YELLOW}[Step 2] Checking Docker Compose installation...${NC}"
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose is not installed${NC}"
    echo "Please install Docker Compose from https://docs.docker.com/compose/install/"
    exit 1
fi
echo -e "${GREEN}✅ Docker Compose is installed: $(docker-compose --version)${NC}"
echo ""

# Step 3: Build Docker images
echo -e "${YELLOW}[Step 3] Building Docker images...${NC}"
docker-compose build
echo -e "${GREEN}✅ Docker images built successfully${NC}"
echo ""

# Step 4: Start containers
echo -e "${YELLOW}[Step 4] Starting containers...${NC}"
docker-compose up -d
echo -e "${GREEN}✅ Containers started${NC}"
echo ""

# Step 5: Wait for services
echo -e "${YELLOW}[Step 5] Waiting for services to be ready...${NC}"
sleep 10

# Step 6: Check container status
echo -e "${YELLOW}[Step 6] Checking container status...${NC}"
docker-compose ps
echo ""

# Step 7: Test endpoints
echo -e "${YELLOW}[Step 7] Testing endpoints...${NC}"
echo ""

# Test Backend
echo "Testing Backend API..."
if curl -s http://localhost:8081 > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Backend is accessible at http://localhost:8081${NC}"
else
    echo -e "${RED}❌ Backend is not responding${NC}"
fi

# Test Frontend
echo "Testing Frontend..."
if curl -s http://localhost > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Frontend is accessible at http://localhost${NC}"
else
    echo -e "${RED}❌ Frontend is not responding${NC}"
fi

echo ""
echo -e "${YELLOW}[Step 8] Displaying useful URLs and commands${NC}"
echo ""
echo -e "${GREEN}Useful URLs:${NC}"
echo "  Backend API:      http://localhost:8081"
echo "  Frontend:         http://localhost"
echo "  MongoDB:          mongodb://admin:admin123@localhost:27017"
echo ""

echo -e "${GREEN}Useful Commands:${NC}"
echo "  View logs:        docker-compose logs -f"
echo "  View backend log: docker-compose logs -f backend"
echo "  View frontend log: docker-compose logs -f frontend"
echo "  Stop containers:  docker-compose down"
echo "  Restart services: docker-compose restart"
echo ""

echo -e "${GREEN}✅ Setup complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Test the application at http://localhost"
echo "2. Review the Backend/Dockerfile and Frontend/Dockerfile"
echo "3. Follow the JENKINS_SETUP.md guide to setup Jenkins"
echo "4. Push code to GitLab with staging/main branches"
echo "5. Watch the Jenkins pipeline run"
echo ""
