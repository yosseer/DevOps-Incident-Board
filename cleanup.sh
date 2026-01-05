#!/bin/bash

# Beeper Application Cleanup Script
# This script removes all containers, networks, volumes, and images created by the deployment

set -e

echo "=========================================="
echo "  Beeper Application Cleanup"
echo "=========================================="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}→ $1${NC}"
}

# Confirmation prompt
read -p "This will remove all Beeper containers, networks, and optionally the volume. Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cleanup cancelled."
    exit 0
fi

# Stop containers
print_info "Stopping containers..."
podman stop beeper-ui 2>/dev/null && print_success "Stopped beeper-ui" || print_warning "beeper-ui not running"
podman stop beeper-api 2>/dev/null && print_success "Stopped beeper-api" || print_warning "beeper-api not running"
podman stop beeper-db 2>/dev/null && print_success "Stopped beeper-db" || print_warning "beeper-db not running"
echo ""

# Remove containers
print_info "Removing containers..."
podman rm beeper-ui 2>/dev/null && print_success "Removed beeper-ui" || print_warning "beeper-ui not found"
podman rm beeper-api 2>/dev/null && print_success "Removed beeper-api" || print_warning "beeper-api not found"
podman rm beeper-db 2>/dev/null && print_success "Removed beeper-db" || print_warning "beeper-db not found"
echo ""

# Remove networks
print_info "Removing networks..."
podman network rm beeper-frontend 2>/dev/null && print_success "Removed beeper-frontend network" || print_warning "beeper-frontend network not found"
podman network rm beeper-backend 2>/dev/null && print_success "Removed beeper-backend network" || print_warning "beeper-backend network not found"
echo ""

# Ask about volume
read -p "Do you want to remove the database volume? This will DELETE ALL DATA! (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    podman volume rm beeper-data 2>/dev/null && print_success "Removed beeper-data volume" || print_warning "beeper-data volume not found"
else
    print_info "Keeping database volume (beeper-data)"
fi
echo ""

# Ask about images
read -p "Do you want to remove the built images? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Removing images..."
    podman rmi beeper-ui:v1 2>/dev/null && print_success "Removed beeper-ui:v1 image" || print_warning "beeper-ui:v1 image not found"
    podman rmi beeper-api:v1 2>/dev/null && print_success "Removed beeper-api:v1 image" || print_warning "beeper-api:v1 image not found"
else
    print_info "Keeping built images"
fi
echo ""

echo "=========================================="
echo "  Cleanup Complete!"
echo "=========================================="
echo ""
print_success "All specified resources have been removed"
echo ""
echo "To redeploy the application, run: ./deploy.sh"
echo ""
