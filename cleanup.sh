#!/bin/bash

# Cleanup script to stop and remove all containers

set -e

echo "Stopping and removing containers..."
docker-compose down --remove-orphans

echo "Removing unused Docker networks..."
docker network prune -f

echo "Removing unused Docker volumes..."
docker volume prune -f

echo "Cleanup completed!"
echo ""
echo "Optional: Remove all images"
echo "docker rmi -f student-management-backend student-management-frontend"
