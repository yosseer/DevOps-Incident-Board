# ============================================================================
# DevOps Incident Board - OpenShift Deployment Script (PowerShell)
# Author: Yosser Fhal
# For Windows Users
# ============================================================================

# Configuration
$NAMESPACE = "incident-board"
$DOCKER_REGISTRY = "docker.io"
$DOCKER_USERNAME = "yosserfhal"
$BACKEND_IMAGE = "${DOCKER_REGISTRY}/${DOCKER_USERNAME}/incident-backend"
$FRONTEND_IMAGE = "${DOCKER_REGISTRY}/${DOCKER_USERNAME}/incident-frontend"
$IMAGE_TAG = "latest"

# OpenShift cluster info
$OC_SERVER = "https://api.na46r.prod.ole.redhat.com:6443"
$OC_TOKEN = "sha256~vFn-nGtaLtMqOIqNGrt6zkrWOWHLppEBmcLzYIrKybE"

# Get script directory
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$PROJECT_ROOT = Split-Path -Parent $SCRIPT_DIR

# ============================================================================
# Helper Functions
# ============================================================================
function Write-Header($message) {
    Write-Host ""
    Write-Host "============================================================================" -ForegroundColor Blue
    Write-Host $message -ForegroundColor Blue
    Write-Host "============================================================================" -ForegroundColor Blue
    Write-Host ""
}

function Write-Success($message) {
    Write-Host "✓ $message" -ForegroundColor Green
}

function Write-Warning($message) {
    Write-Host "⚠ $message" -ForegroundColor Yellow
}

function Write-Error($message) {
    Write-Host "✗ $message" -ForegroundColor Red
}

function Write-Info($message) {
    Write-Host "ℹ $message" -ForegroundColor Cyan
}

# ============================================================================
# Step 1: Login to OpenShift
# ============================================================================
function Login-OpenShift {
    Write-Header "Step 1: Logging into OpenShift"
    
    # Check if oc is installed
    if (-not (Get-Command oc -ErrorAction SilentlyContinue)) {
        Write-Error "OpenShift CLI (oc) is not installed!"
        Write-Info "Download from: https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/"
        exit 1
    }
    
    Write-Info "Logging into OpenShift cluster..."
    oc login --token="$OC_TOKEN" --server="$OC_SERVER" --insecure-skip-tls-verify=true
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Successfully logged into OpenShift"
        oc whoami
    } else {
        Write-Error "Failed to login to OpenShift"
        exit 1
    }
}

# ============================================================================
# Step 2: Build Docker Images
# ============================================================================
function Build-Images {
    Write-Header "Step 2: Building Docker Images"
    
    # Check if docker is installed
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        Write-Error "Docker is not installed!"
        exit 1
    }
    
    # Build backend image
    Write-Info "Building backend image..."
    Set-Location "$PROJECT_ROOT\beeper-backend"
    docker build -t "${BACKEND_IMAGE}:${IMAGE_TAG}" .
    Write-Success "Backend image built: ${BACKEND_IMAGE}:${IMAGE_TAG}"
    
    # Build frontend image
    Write-Info "Building frontend image..."
    Set-Location "$PROJECT_ROOT\beeper-ui"
    docker build -t "${FRONTEND_IMAGE}:${IMAGE_TAG}" .
    Write-Success "Frontend image built: ${FRONTEND_IMAGE}:${IMAGE_TAG}"
    
    Set-Location $PROJECT_ROOT
}

# ============================================================================
# Step 3: Push Images to Docker Hub
# ============================================================================
function Push-Images {
    Write-Header "Step 3: Pushing Images to Docker Hub"
    
    Write-Info "Logging into Docker Hub..."
    docker login -u $DOCKER_USERNAME
    
    Write-Info "Pushing backend image..."
    docker push "${BACKEND_IMAGE}:${IMAGE_TAG}"
    Write-Success "Backend image pushed"
    
    Write-Info "Pushing frontend image..."
    docker push "${FRONTEND_IMAGE}:${IMAGE_TAG}"
    Write-Success "Frontend image pushed"
}

# ============================================================================
# Step 4: Create OpenShift Project
# ============================================================================
function Create-Namespace {
    Write-Header "Step 4: Creating OpenShift Project"
    
    # Check if namespace exists
    $namespaceExists = oc get namespace $NAMESPACE 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Warning "Namespace '$NAMESPACE' already exists"
    } else {
        Write-Info "Creating namespace '$NAMESPACE'..."
        oc new-project $NAMESPACE --display-name="Incident Board" --description="DevOps Incident Management System"
        Write-Success "Namespace created"
    }
    
    # Switch to the namespace
    oc project $NAMESPACE
    Write-Success "Switched to project: $NAMESPACE"
}

# ============================================================================
# Step 5: Deploy OpenShift Resources
# ============================================================================
function Deploy-Resources {
    Write-Header "Step 5: Deploying OpenShift Resources"
    
    Write-Info "Applying ConfigMaps..."
    oc apply -f "$SCRIPT_DIR\01-configmaps.yaml"
    Write-Success "ConfigMaps created"
    
    Write-Info "Applying Secrets..."
    oc apply -f "$SCRIPT_DIR\02-secrets.yaml"
    Write-Success "Secrets created"
    
    Write-Info "Applying PersistentVolumeClaim..."
    oc apply -f "$SCRIPT_DIR\03-pvc.yaml"
    Write-Success "PVC created"
    
    Write-Info "Deploying Backend..."
    oc apply -f "$SCRIPT_DIR\04-backend-deployment.yaml"
    Write-Success "Backend deployment created"
    
    Write-Info "Deploying Frontend..."
    oc apply -f "$SCRIPT_DIR\05-frontend-deployment.yaml"
    Write-Success "Frontend deployment created"
    
    Write-Info "Applying HPA (Auto-scaling)..."
    oc apply -f "$SCRIPT_DIR\06-hpa.yaml"
    Write-Success "HPA created"
    
    Write-Info "Applying Network Policies..."
    oc apply -f "$SCRIPT_DIR\07-network-policies.yaml"
    Write-Success "Network policies created"
}

# ============================================================================
# Step 6: Wait for Deployments
# ============================================================================
function Wait-ForDeployments {
    Write-Header "Step 6: Waiting for Deployments to be Ready"
    
    Write-Info "Waiting for backend deployment..."
    oc rollout status deployment/incident-backend -n $NAMESPACE --timeout=300s
    Write-Success "Backend is ready"
    
    Write-Info "Waiting for frontend deployment..."
    oc rollout status deployment/incident-frontend -n $NAMESPACE --timeout=300s
    Write-Success "Frontend is ready"
}

# ============================================================================
# Step 7: Get Application URLs
# ============================================================================
function Get-ApplicationURLs {
    Write-Header "Step 7: Application URLs"
    
    $FRONTEND_URL = oc get route incident-frontend -n $NAMESPACE -o jsonpath='{.spec.host}' 2>$null
    $BACKEND_URL = oc get route incident-backend -n $NAMESPACE -o jsonpath='{.spec.host}' 2>$null
    
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║                    🚀 DEPLOYMENT SUCCESSFUL! 🚀                            ║" -ForegroundColor Green
    Write-Host "╠════════════════════════════════════════════════════════════════════════════╣" -ForegroundColor Green
    Write-Host "║                                                                            ║" -ForegroundColor Green
    Write-Host "║  Frontend Dashboard:                                                       ║" -ForegroundColor Green
    Write-Host "║  https://$FRONTEND_URL" -ForegroundColor Cyan
    Write-Host "║                                                                            ║" -ForegroundColor Green
    Write-Host "║  Backend API:                                                              ║" -ForegroundColor Green
    Write-Host "║  https://$BACKEND_URL/api/incidents" -ForegroundColor Cyan
    Write-Host "║                                                                            ║" -ForegroundColor Green
    Write-Host "║  H2 Database Console:                                                      ║" -ForegroundColor Green
    Write-Host "║  https://$BACKEND_URL/h2-console" -ForegroundColor Cyan
    Write-Host "║                                                                            ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
}

# ============================================================================
# Show Status
# ============================================================================
function Show-Status {
    Write-Header "Deployment Status"
    
    Write-Host "Pods:" -ForegroundColor Yellow
    oc get pods -n $NAMESPACE
    
    Write-Host "`nServices:" -ForegroundColor Yellow
    oc get services -n $NAMESPACE
    
    Write-Host "`nRoutes:" -ForegroundColor Yellow
    oc get routes -n $NAMESPACE
    
    Write-Host "`nDeployments:" -ForegroundColor Yellow
    oc get deployments -n $NAMESPACE
}

# ============================================================================
# Cleanup
# ============================================================================
function Cleanup-Deployment {
    Write-Header "Cleaning Up Deployment"
    
    $confirm = Read-Host "Are you sure you want to delete all resources in '$NAMESPACE'? (y/N)"
    if ($confirm -eq "y" -or $confirm -eq "Y") {
        Write-Info "Deleting all resources..."
        oc delete project $NAMESPACE --wait=true
        Write-Success "Cleanup complete"
    } else {
        Write-Info "Cleanup cancelled"
    }
}

# ============================================================================
# Main Menu
# ============================================================================
function Show-Menu {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Blue
    Write-Host "║         DevOps Incident Board - OpenShift Deployment           ║" -ForegroundColor Blue
    Write-Host "╠════════════════════════════════════════════════════════════════╣" -ForegroundColor Blue
    Write-Host "║  1. Full Deployment (Build + Push + Deploy)                    ║" -ForegroundColor Blue
    Write-Host "║  2. Deploy Only (Use existing images)                          ║" -ForegroundColor Blue
    Write-Host "║  3. Build Images Only                                          ║" -ForegroundColor Blue
    Write-Host "║  4. Push Images Only                                           ║" -ForegroundColor Blue
    Write-Host "║  5. Show Status                                                ║" -ForegroundColor Blue
    Write-Host "║  6. Get Application URLs                                       ║" -ForegroundColor Blue
    Write-Host "║  7. Cleanup (Delete all resources)                             ║" -ForegroundColor Blue
    Write-Host "║  8. Exit                                                       ║" -ForegroundColor Blue
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Blue
    Write-Host ""
    
    $choice = Read-Host "Select an option [1-8]"
    
    switch ($choice) {
        "1" {
            Login-OpenShift
            Build-Images
            Push-Images
            Create-Namespace
            Deploy-Resources
            Wait-ForDeployments
            Get-ApplicationURLs
            Show-Status
        }
        "2" {
            Login-OpenShift
            Create-Namespace
            Deploy-Resources
            Wait-ForDeployments
            Get-ApplicationURLs
            Show-Status
        }
        "3" { Build-Images }
        "4" { Push-Images }
        "5" {
            Login-OpenShift
            oc project $NAMESPACE 2>$null
            Show-Status
        }
        "6" {
            Login-OpenShift
            oc project $NAMESPACE 2>$null
            Get-ApplicationURLs
        }
        "7" {
            Login-OpenShift
            Cleanup-Deployment
        }
        "8" {
            Write-Info "Goodbye!"
            exit 0
        }
        default {
            Write-Error "Invalid option"
            Show-Menu
        }
    }
}

# ============================================================================
# Script Entry Point
# ============================================================================
Write-Header "DevOps Incident Board - OpenShift Deployment"
Write-Host "Author: Yosser Fhal"
Write-Host "Date: $(Get-Date)"

# Check command line arguments
if ($args[0] -eq "--full") {
    Login-OpenShift
    Build-Images
    Push-Images
    Create-Namespace
    Deploy-Resources
    Wait-ForDeployments
    Get-ApplicationURLs
    Show-Status
} elseif ($args[0] -eq "--deploy-only") {
    Login-OpenShift
    Create-Namespace
    Deploy-Resources
    Wait-ForDeployments
    Get-ApplicationURLs
    Show-Status
} elseif ($args[0] -eq "--status") {
    Login-OpenShift
    oc project $NAMESPACE 2>$null
    Show-Status
} elseif ($args[0] -eq "--cleanup") {
    Login-OpenShift
    Cleanup-Deployment
} else {
    Show-Menu
}
