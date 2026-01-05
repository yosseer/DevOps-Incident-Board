#!/bin/bash

# Beeper Application Deployment Script
# This script automates the complete deployment of the Beeper application

set -e  # Exit on error

echo "=========================================="
echo "  Beeper Application Deployment"
echo "=========================================="
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}→ $1${NC}"
}

# Check if podman is installed
if ! command -v podman &> /dev/null; then
    print_error "Podman is not installed. Please install Podman first."
    exit 1
fi

print_success "Podman is installed"
echo ""

# Step 1: Create Networks
print_info "Step 1: Creating Podman networks..."
podman network create beeper-backend 2>/dev/null || print_info "Network beeper-backend already exists"
podman network create beeper-frontend 2>/dev/null || print_info "Network beeper-frontend already exists"
print_success "Networks created"
echo ""

# Step 2: Create Volume and Run Database
print_info "Step 2: Setting up PostgreSQL database..."
podman volume create beeper-data 2>/dev/null || print_info "Volume beeper-data already exists"

if podman ps -a --format "{{.Names}}" | grep -q "^beeper-db$"; then
    print_info "Removing existing beeper-db container..."
    podman stop beeper-db 2>/dev/null || true
    podman rm beeper-db 2>/dev/null || true
fi

podman run -d \
  --name beeper-db \
  --network beeper-backend \
  -v beeper-data:/var/lib/pgsql/data \
  -e POSTGRESQL_USER=beeper \
  -e POSTGRESQL_PASSWORD=beeper123 \
  -e POSTGRESQL_DATABASE=beeper \
  registry.ocp4.example.com:8443/rhel9/postgresql-13:1

print_success "Database container started"
echo "Waiting for database to initialize..."
sleep 5
echo ""

# Step 3: Build and Run Backend API
print_info "Step 3: Building and deploying backend API..."
cd beeper-backend

if podman images | grep -q "beeper-api.*v1"; then
    print_info "Removing existing beeper-api:v1 image..."
    podman rmi beeper-api:v1 2>/dev/null || true
fi

print_info "Building beeper-api image (this may take a few minutes)..."
podman build -t beeper-api:v1 .

if podman ps -a --format "{{.Names}}" | grep -q "^beeper-api$"; then
    print_info "Removing existing beeper-api container..."
    podman stop beeper-api 2>/dev/null || true
    podman rm beeper-api 2>/dev/null || true
fi

podman run -d \
  --name beeper-api \
  --network beeper-backend \
  -e DB_HOST=beeper-db \
  beeper-api:v1

podman network connect beeper-frontend beeper-api

print_success "Backend API container started"
echo "Waiting for API to start..."
sleep 5
echo ""

# Step 4: Build and Run Frontend UI
print_info "Step 4: Building and deploying frontend UI..."
cd ../beeper-ui

if podman images | grep -q "beeper-ui.*v1"; then
    print_info "Removing existing beeper-ui:v1 image..."
    podman rmi beeper-ui:v1 2>/dev/null || true
fi

print_info "Building beeper-ui image (this may take a few minutes)..."
podman build -t beeper-ui:v1 .

if podman ps -a --format "{{.Names}}" | grep -q "^beeper-ui$"; then
    print_info "Removing existing beeper-ui container..."
    podman stop beeper-ui 2>/dev/null || true
    podman rm beeper-ui 2>/dev/null || true
fi

podman run -d \
  --name beeper-ui \
  --network beeper-frontend \
  -p 8080:8080 \
  beeper-ui:v1

print_success "Frontend UI container started"
echo ""

# Step 5: Verify Deployment
print_info "Step 5: Verifying deployment..."
echo ""
echo "Container Status:"
podman ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""

# Wait for services to be ready
sleep 3

# Test API health
print_info "Testing API health..."
if curl -s http://localhost:8080/api/beeps/health &>/dev/null; then
    print_success "API is healthy"
else
    print_error "API health check failed - check logs with: podman logs beeper-api"
fi
echo ""

# Deployment Summary
echo "=========================================="
echo "  Deployment Complete!"
echo "=========================================="
echo ""
print_success "All containers are running"
echo ""
echo "Access the application at: http://localhost:8080"
echo ""
echo "Useful commands:"
echo "  View all containers:     podman ps"
echo "  View logs:"
echo "    - Database:            podman logs beeper-db"
echo "    - API:                 podman logs beeper-api"
echo "    - UI:                  podman logs beeper-ui"
echo ""
echo "  Restart containers:      podman restart beeper-db beeper-api beeper-ui"
echo "  Stop all:                podman stop beeper-ui beeper-api beeper-db"
echo ""
echo "To clean up everything, run: ./cleanup.sh"
echo ""
