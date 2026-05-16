#!/bin/bash

# Deploy script for staging/production servers
# This script is executed by Jenkins via SSH

set -e

PROJECT_NAME="student-management"
DOCKER_HUB="${DOCKER_HUB}"
NAME_BACKEND="${NAME_BACKEND}"
NAME_FRONTEND="${NAME_FRONTEND}"
DOCKER_TAG="${DOCKER_TAG}"

echo "=========================================="
echo "Deployment Script"
echo "=========================================="
echo "Project: $PROJECT_NAME"
echo "Docker Hub: $DOCKER_HUB"
echo "Tag: $DOCKER_TAG"
echo "=========================================="
echo ""

# Create app directory if it doesn't exist
mkdir -p /app
cd /app

# Log in to Docker Hub
echo "[1/5] Logging in to Docker Hub..."
echo "${DOCKERHUB_CREDENTIALS_PSW}" | docker login -u "${DOCKERHUB_CREDENTIALS_USR}" --password-stdin

# Stop and remove old containers
echo "[2/5] Stopping and removing old containers..."
docker-compose down || true

# Pull the latest images
echo "[3/5] Pulling Docker images..."
docker pull "${DOCKER_HUB}/${NAME_BACKEND}:${DOCKER_TAG}"
docker pull "${DOCKER_HUB}/${NAME_FRONTEND}:${DOCKER_TAG}"

# Start new containers
echo "[4/5] Starting new containers..."
export DOCKER_HUB="${DOCKER_HUB}"
export NAME_BACKEND="${NAME_BACKEND}"
export NAME_FRONTEND="${NAME_FRONTEND}"
export DOCKER_TAG="${DOCKER_TAG}"
export BACKEND_CONTAINER_NAME="${PROJECT_NAME}-backend"
export FRONTEND_CONTAINER_NAME="${PROJECT_NAME}-frontend"
export MONGO_CONTAINER_NAME="${PROJECT_NAME}-mongo"
export BACKEND_PORT=8081
export FRONTEND_PORT=80
export MONGO_PORT=27017

docker-compose up -d

# Wait for services to be healthy
echo "[5/5] Waiting for services to be healthy..."
sleep 15

# Display container status
echo ""
echo "=========================================="
echo "Container Status:"
echo "=========================================="
docker-compose ps
echo ""

# Log in details
docker logout

echo ""
echo "✅ Deployment completed successfully!"
echo ""
echo "Access your application:"
echo "  Backend API:    http://$(hostname -I | awk '{print $1}'):8081"
echo "  Frontend:       http://$(hostname -I | awk '{print $1}')"
echo ""
echo "View logs:"
echo "  docker-compose logs -f backend"
echo "  docker-compose logs -f frontend"
echo ""
