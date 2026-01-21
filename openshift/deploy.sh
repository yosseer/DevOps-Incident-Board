#!/bin/bash
# ============================================================================
# DevOps Incident Board - OpenShift Deployment Script
# Author: Yosser Fhal
# ============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="incident-board"
DOCKER_REGISTRY="docker.io"
DOCKER_USERNAME="yosserfhal"
BACKEND_IMAGE="${DOCKER_REGISTRY}/${DOCKER_USERNAME}/incident-backend"
FRONTEND_IMAGE="${DOCKER_REGISTRY}/${DOCKER_USERNAME}/incident-frontend"
IMAGE_TAG="latest"

# OpenShift cluster info (from user input)
OC_SERVER="https://api.na46r.prod.ole.redhat.com:6443"
OC_TOKEN="sha256~vFn-nGtaLtMqOIqNGrt6zkrWOWHLppEBmcLzYIrKybE"

# ============================================================================
# Helper Functions
# ============================================================================

print_header() {
    echo -e "\n${BLUE}============================================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}============================================================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# ============================================================================
# Step 1: Login to OpenShift
# ============================================================================
login_openshift() {
    print_header "Step 1: Logging into OpenShift"
    
    if ! command -v oc &> /dev/null; then
        print_error "OpenShift CLI (oc) is not installed!"
        print_info "Download from: https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/"
        exit 1
    fi
    
    echo "Logging into OpenShift cluster..."
    oc login --token="${OC_TOKEN}" --server="${OC_SERVER}" --insecure-skip-tls-verify=true
    
    if [ $? -eq 0 ]; then
        print_success "Successfully logged into OpenShift"
        oc whoami
    else
        print_error "Failed to login to OpenShift"
        exit 1
    fi
}

# ============================================================================
# Step 2: Build Docker Images
# ============================================================================
build_images() {
    print_header "Step 2: Building Docker Images"
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed!"
        exit 1
    fi
    
    # Get project root directory
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
    
    # Build backend image
    print_info "Building backend image..."
    cd "${PROJECT_ROOT}/beeper-backend"
    docker build -t "${BACKEND_IMAGE}:${IMAGE_TAG}" .
    print_success "Backend image built: ${BACKEND_IMAGE}:${IMAGE_TAG}"
    
    # Build frontend image
    print_info "Building frontend image..."
    cd "${PROJECT_ROOT}/beeper-ui"
    docker build -t "${FRONTEND_IMAGE}:${IMAGE_TAG}" .
    print_success "Frontend image built: ${FRONTEND_IMAGE}:${IMAGE_TAG}"
    
    cd "${PROJECT_ROOT}"
}

# ============================================================================
# Step 3: Push Images to Docker Hub
# ============================================================================
push_images() {
    print_header "Step 3: Pushing Images to Docker Hub"
    
    print_info "Logging into Docker Hub..."
    echo "Please enter your Docker Hub password/token:"
    docker login -u "${DOCKER_USERNAME}"
    
    print_info "Pushing backend image..."
    docker push "${BACKEND_IMAGE}:${IMAGE_TAG}"
    print_success "Backend image pushed"
    
    print_info "Pushing frontend image..."
    docker push "${FRONTEND_IMAGE}:${IMAGE_TAG}"
    print_success "Frontend image pushed"
}

# ============================================================================
# Step 4: Create OpenShift Project/Namespace
# ============================================================================
create_namespace() {
    print_header "Step 4: Creating OpenShift Project"
    
    # Check if namespace exists
    if oc get namespace "${NAMESPACE}" &> /dev/null; then
        print_warning "Namespace '${NAMESPACE}' already exists"
    else
        print_info "Creating namespace '${NAMESPACE}'..."
        oc new-project "${NAMESPACE}" --display-name="Incident Board" --description="DevOps Incident Management System"
        print_success "Namespace created"
    fi
    
    # Switch to the namespace
    oc project "${NAMESPACE}"
    print_success "Switched to project: ${NAMESPACE}"
}

# ============================================================================
# Step 5: Deploy OpenShift Resources
# ============================================================================
deploy_resources() {
    print_header "Step 5: Deploying OpenShift Resources"
    
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Apply resources in order
    print_info "Applying ConfigMaps..."
    oc apply -f "${SCRIPT_DIR}/01-configmaps.yaml"
    print_success "ConfigMaps created"
    
    print_info "Applying Secrets..."
    oc apply -f "${SCRIPT_DIR}/02-secrets.yaml"
    print_success "Secrets created"
    
    print_info "Applying PersistentVolumeClaim..."
    oc apply -f "${SCRIPT_DIR}/03-pvc.yaml"
    print_success "PVC created"
    
    print_info "Deploying Backend..."
    oc apply -f "${SCRIPT_DIR}/04-backend-deployment.yaml"
    print_success "Backend deployment created"
    
    print_info "Deploying Frontend..."
    oc apply -f "${SCRIPT_DIR}/05-frontend-deployment.yaml"
    print_success "Frontend deployment created"
    
    print_info "Applying HPA (Auto-scaling)..."
    oc apply -f "${SCRIPT_DIR}/06-hpa.yaml"
    print_success "HPA created"
    
    print_info "Applying Network Policies..."
    oc apply -f "${SCRIPT_DIR}/07-network-policies.yaml"
    print_success "Network policies created"
}

# ============================================================================
# Step 6: Wait for Deployments
# ============================================================================
wait_for_deployments() {
    print_header "Step 6: Waiting for Deployments to be Ready"
    
    print_info "Waiting for backend deployment..."
    oc rollout status deployment/incident-backend -n "${NAMESPACE}" --timeout=300s
    print_success "Backend is ready"
    
    print_info "Waiting for frontend deployment..."
    oc rollout status deployment/incident-frontend -n "${NAMESPACE}" --timeout=300s
    print_success "Frontend is ready"
}

# ============================================================================
# Step 7: Get Application URLs
# ============================================================================
get_urls() {
    print_header "Step 7: Application URLs"
    
    FRONTEND_URL=$(oc get route incident-frontend -n "${NAMESPACE}" -o jsonpath='{.spec.host}' 2>/dev/null || echo "Not found")
    BACKEND_URL=$(oc get route incident-backend -n "${NAMESPACE}" -o jsonpath='{.spec.host}' 2>/dev/null || echo "Not found")
    
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                    🚀 DEPLOYMENT SUCCESSFUL! 🚀                            ║${NC}"
    echo -e "${GREEN}╠════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${GREEN}║                                                                            ║${NC}"
    echo -e "${GREEN}║  Frontend Dashboard:                                                       ║${NC}"
    echo -e "${GREEN}║  ${BLUE}https://${FRONTEND_URL}${GREEN}${NC}"
    echo -e "${GREEN}║                                                                            ║${NC}"
    echo -e "${GREEN}║  Backend API:                                                              ║${NC}"
    echo -e "${GREEN}║  ${BLUE}https://${BACKEND_URL}/api/incidents${GREEN}${NC}"
    echo -e "${GREEN}║                                                                            ║${NC}"
    echo -e "${GREEN}║  H2 Database Console:                                                      ║${NC}"
    echo -e "${GREEN}║  ${BLUE}https://${BACKEND_URL}/h2-console${GREEN}${NC}"
    echo -e "${GREEN}║                                                                            ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ============================================================================
# Step 8: Show Deployment Status
# ============================================================================
show_status() {
    print_header "Deployment Status"
    
    echo -e "${YELLOW}Pods:${NC}"
    oc get pods -n "${NAMESPACE}"
    
    echo -e "\n${YELLOW}Services:${NC}"
    oc get services -n "${NAMESPACE}"
    
    echo -e "\n${YELLOW}Routes:${NC}"
    oc get routes -n "${NAMESPACE}"
    
    echo -e "\n${YELLOW}Deployments:${NC}"
    oc get deployments -n "${NAMESPACE}"
}

# ============================================================================
# Cleanup Function
# ============================================================================
cleanup() {
    print_header "Cleaning Up Deployment"
    
    read -p "Are you sure you want to delete all resources in '${NAMESPACE}'? (y/N): " confirm
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        print_info "Deleting all resources..."
        oc delete project "${NAMESPACE}" --wait=true
        print_success "Cleanup complete"
    else
        print_info "Cleanup cancelled"
    fi
}

# ============================================================================
# Main Menu
# ============================================================================
show_menu() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║         DevOps Incident Board - OpenShift Deployment           ║${NC}"
    echo -e "${BLUE}╠════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${BLUE}║  1. Full Deployment (Build + Push + Deploy)                    ║${NC}"
    echo -e "${BLUE}║  2. Deploy Only (Use existing images)                          ║${NC}"
    echo -e "${BLUE}║  3. Build Images Only                                          ║${NC}"
    echo -e "${BLUE}║  4. Push Images Only                                           ║${NC}"
    echo -e "${BLUE}║  5. Show Status                                                ║${NC}"
    echo -e "${BLUE}║  6. Get Application URLs                                       ║${NC}"
    echo -e "${BLUE}║  7. Cleanup (Delete all resources)                             ║${NC}"
    echo -e "${BLUE}║  8. Exit                                                       ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    read -p "Select an option [1-8]: " choice
    
    case $choice in
        1)
            login_openshift
            build_images
            push_images
            create_namespace
            deploy_resources
            wait_for_deployments
            get_urls
            show_status
            ;;
        2)
            login_openshift
            create_namespace
            deploy_resources
            wait_for_deployments
            get_urls
            show_status
            ;;
        3)
            build_images
            ;;
        4)
            push_images
            ;;
        5)
            login_openshift
            oc project "${NAMESPACE}" 2>/dev/null || true
            show_status
            ;;
        6)
            login_openshift
            oc project "${NAMESPACE}" 2>/dev/null || true
            get_urls
            ;;
        7)
            login_openshift
            cleanup
            ;;
        8)
            print_info "Goodbye!"
            exit 0
            ;;
        *)
            print_error "Invalid option"
            show_menu
            ;;
    esac
}

# ============================================================================
# Script Entry Point
# ============================================================================
print_header "DevOps Incident Board - OpenShift Deployment"
echo "Author: Yosser Fhal"
echo "Date: $(date)"

# Check if running with arguments
if [ "$1" = "--full" ]; then
    login_openshift
    build_images
    push_images
    create_namespace
    deploy_resources
    wait_for_deployments
    get_urls
    show_status
elif [ "$1" = "--deploy-only" ]; then
    login_openshift
    create_namespace
    deploy_resources
    wait_for_deployments
    get_urls
    show_status
elif [ "$1" = "--status" ]; then
    login_openshift
    oc project "${NAMESPACE}" 2>/dev/null || true
    show_status
elif [ "$1" = "--cleanup" ]; then
    login_openshift
    cleanup
else
    show_menu
fi
