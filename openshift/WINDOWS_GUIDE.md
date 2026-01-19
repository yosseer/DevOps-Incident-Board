# OpenShift Deployment - Windows User Guide

This guide provides Windows-specific instructions for deploying the DevOps Incident Board to OpenShift.

## Prerequisites for Windows

### 1. Install OpenShift CLI (oc)

**Option A: Using Chocolatey (Recommended)**
```powershell
# If you don't have Chocolatey, install it first:
# From PowerShell as Administrator:
# Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Then install oc:
choco install openshift-cli
```

**Option B: Manual Download**
1. Go to https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/
2. Download `openshift-client-windows.zip`
3. Extract to a folder
4. Add the folder to your PATH environment variable

**Option C: Using scoop**
```powershell
scoop install openshift-client
```

### 2. Verify Installation
```powershell
oc version
# Should show: Client Version: ...
```

### 3. Configure OpenShift Access

```powershell
# Login to your OpenShift cluster
oc login --server=<your-openshift-server> -u <username> -p <password>

# Example:
# oc login --server=https://api.example.com:6443 -u developer -p password

# Verify login
oc whoami
```

## Deployment from Windows

### Method 1: Using Git Bash or Windows Subsystem for Linux (WSL)

If you have WSL2 or Git Bash installed, you can use the bash script directly:

**Using Git Bash:**
```bash
# Navigate to the project
cd "C:\Users\fhaal\OneDrive - Ministere de l'Enseignement Superieur et de la Recherche Scientifique\Desktop\Cloud_Project\openshift"

# Make script executable (in Git Bash)
chmod +x deploy.sh

# Run deployment
./deploy.sh
```

**Using WSL2:**
```bash
# Open WSL terminal
wsl

# Navigate to the project (Windows paths work in WSL)
cd "/mnt/c/Users/fhaal/OneDrive - Ministere de l'Enseignement Superieur et de la Recherche Scientifique/Desktop/Cloud_Project/openshift"

# Run deployment
bash deploy.sh
```

### Method 2: Using PowerShell (Windows Native)

Create a PowerShell script for deployment:

**Create file: `deploy.ps1`**
```powershell
# DevOps Incident Board - OpenShift Deployment Script (PowerShell)

param(
    [switch]$NoWait = $false
)

$ErrorActionPreference = "Stop"

function Write-Header {
    param([string]$Message)
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Blue
    Write-Host $Message -ForegroundColor Blue
    Write-Host "========================================" -ForegroundColor Blue
    Write-Host ""
}

function Write-Step {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Yellow
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

# Check if oc is installed
try {
    $ocVersion = oc version 2>&1
} catch {
    Write-Error "OpenShift CLI (oc) is not installed or not in PATH"
    Write-Host "Install from: https://docs.openshift.com/container-platform/latest/cli_tools/openshift_cli/getting-started-cli.html"
    exit 1
}

Write-Header "DevOps Incident Board - OpenShift Deploy (PowerShell)"

# Check oc login status
Write-Step "Checking OpenShift cluster connection..."
try {
    $user = oc whoami 2>&1
    Write-Success "Connected as: $user"
} catch {
    Write-Error "Not logged into OpenShift cluster"
    Write-Host "Login first with: oc login --server=<server-url> -u <username> -p <password>"
    exit 1
}

# Step 1: Create namespace and ConfigMap
Write-Step "Step 1: Creating namespace and ConfigMap..."
oc apply -f 00-namespace.yaml
Write-Success "Namespace created"
Write-Host ""

# Step 2: Create secrets
Write-Step "Step 2: Creating secrets..."
oc apply -f 01-secrets.yaml
Write-Success "Secrets created"
Write-Host ""

# Step 3: Deploy PostgreSQL
Write-Step "Step 3: Deploying PostgreSQL database..."
oc apply -f 02-postgresql.yaml
Write-Success "PostgreSQL deployment started"

if (-not $NoWait) {
    Write-Step "Waiting for PostgreSQL to be ready (this may take 30-60 seconds)..."
    oc rollout status statefulset/postgresql -n incident-board --timeout=300s | Out-Null
    Write-Success "PostgreSQL is ready"
} else {
    Write-Host "[--NoWait flag set, skipping wait]"
}
Write-Host ""

# Step 4: Deploy API
Write-Step "Step 4: Deploying backend API..."
oc apply -f 03-api.yaml
Write-Success "Backend API deployment started"

if (-not $NoWait) {
    Write-Step "Waiting for API to be ready (this may take 60-90 seconds)..."
    oc rollout status deployment/api -n incident-board --timeout=300s | Out-Null
    Write-Success "Backend API is ready"
} else {
    Write-Host "[--NoWait flag set, skipping wait]"
}
Write-Host ""

# Step 5: Deploy Frontend
Write-Step "Step 5: Deploying frontend..."
oc apply -f 04-frontend.yaml
oc apply -f 05-frontend-config.yaml
Write-Success "Frontend deployment started"

if (-not $NoWait) {
    Write-Step "Waiting for frontend to be ready..."
    oc rollout status deployment/frontend -n incident-board --timeout=300s | Out-Null
    Write-Success "Frontend is ready"
} else {
    Write-Host "[--NoWait flag set, skipping wait]"
}
Write-Host ""

# Get route information
Write-Header "Deployment Complete!"

try {
    $routeHost = oc get route frontend -n incident-board -o jsonpath='{.spec.host}' 2>$null
    if ($routeHost) {
        Write-Host "Access your application:" -ForegroundColor Yellow
        Write-Host "Frontend: https://$routeHost" -ForegroundColor Green
    }
} catch {
    Write-Host "Frontend route is being configured. Run 'oc get routes -n incident-board' to get the URL."
}

Write-Host ""
Write-Host "Useful PowerShell commands:" -ForegroundColor Yellow
Write-Host "  View pods:       oc get pods -n incident-board"
Write-Host "  View services:   oc get services -n incident-board"
Write-Host "  View routes:     oc get routes -n incident-board"
Write-Host "  View logs:       oc logs -f deployment/api -n incident-board"
Write-Host "  Describe pod:    oc describe pod <pod-name> -n incident-board"
Write-Host "  Port forward:    oc port-forward service/api 8080:8080 -n incident-board"
Write-Host ""
```

**Run the PowerShell deployment script:**
```powershell
# Navigate to the openshift directory
cd "C:\Users\fhaal\OneDrive - Ministere de l'Enseignement Superieur et de la Recherche Scientifique\Desktop\Cloud_Project\openshift"

# Run the deployment script
.\deploy.ps1

# Or skip waiting for pods (useful for CI/CD):
.\deploy.ps1 -NoWait
```

### Method 3: Manual Deployment (Command by Command)

If you prefer to deploy step by step:

```powershell
# Set your working directory
cd "C:\Users\fhaal\OneDrive - Ministere de l'Enseignement Superieur et de la Recherche Scientifique\Desktop\Cloud_Project\openshift"

# Step 1: Create namespace
oc apply -f 00-namespace.yaml
oc project incident-board

# Step 2: Create secrets
oc apply -f 01-secrets.yaml

# Step 3: Deploy database
oc apply -f 02-postgresql.yaml
# Wait for PostgreSQL
oc rollout status statefulset/postgresql -n incident-board

# Step 4: Deploy API
oc apply -f 03-api.yaml
# Wait for API
oc rollout status deployment/api -n incident-board

# Step 5: Deploy frontend
oc apply -f 04-frontend.yaml
oc apply -f 05-frontend-config.yaml
# Wait for frontend
oc rollout status deployment/frontend -n incident-board

# Step 6: Get your frontend URL
oc get routes -n incident-board
```

## Verification from Windows

### Check Deployment Status

```powershell
# Check all pods
oc get pods -n incident-board

# Check all services
oc get services -n incident-board

# Check routes
oc get routes -n incident-board

# Get detailed pod information
oc describe pod <pod-name> -n incident-board
```

### View Logs from PowerShell

```powershell
# Real-time backend logs
oc logs -f deployment/api -n incident-board

# Database logs
oc logs statefulset/postgresql -n incident-board

# Frontend logs
oc logs deployment/frontend -n incident-board

# Logs from specific pod
oc logs <pod-name> -n incident-board

# Previous logs (if pod crashed)
oc logs <pod-name> -n incident-board --previous
```

### Port Forwarding from Windows

```powershell
# Forward API port
oc port-forward service/api 8080:8080 -n incident-board

# In another PowerShell window, test the API
Invoke-WebRequest http://localhost:8080/api/incidents/health

# Forward Frontend port
oc port-forward service/frontend 8080:8080 -n incident-board

# Test frontend
Invoke-WebRequest http://localhost:8080
```

## Accessing the Application

### Get Frontend URL

```powershell
# Get the route hostname
oc get route frontend -n incident-board -o jsonpath='{.spec.host}'

# Or get all information
oc get routes -n incident-board
```

### Open in Browser

```powershell
# Method 1: Copy the URL manually
$url = oc get route frontend -n incident-board -o jsonpath='{.spec.host}'
Start-Process "https://$url"

# Method 2: Use WSL/Git Bash
# The URLs work in all browsers

# Method 3: Manual
# Copy the URL from 'oc get routes -n incident-board' output
# Paste into your browser address bar
```

## Troubleshooting on Windows

### Issue: "oc command not found"

```powershell
# Check if oc is in PATH
oc version

# If not found, verify installation
Get-Command oc

# Try full path if installed with Chocolatey
C:\ProgramData\chocolatey\bin\oc.exe version

# Add to PATH if needed
$env:PATH += ";C:\path\to\oc\directory"
```

### Issue: Path Contains Spaces

```powershell
# Make sure to use quotes for paths with spaces
cd "C:\Users\fhaal\OneDrive - Ministere..."

# Or use short paths (8.3 format)
cd C:\Users\fhaal\ONEDRI~1\Desktop\Cloud_Project

# PowerShell usually handles this automatically
```

### Issue: Long-Running Commands

```powershell
# If deployment times out, you can increase the timeout
oc rollout status deployment/api -n incident-board --timeout=600s

# Or check status separately while waiting
oc get pods -n incident-board -w
```

### Check Cluster Status

```powershell
# Overall status
oc status -n incident-board

# All resources
oc get all,pvc,secrets,configmaps -n incident-board

# Node status
oc get nodes
```

### Test API Connectivity

```powershell
# Using Invoke-WebRequest
$response = Invoke-WebRequest -Uri http://localhost:8080/api/incidents/health -UseBasicParsing
$response.Content | ConvertFrom-Json

# Or using curl (if installed)
curl http://localhost:8080/api/incidents/health
```

## Windows-Specific Tips

### 1. Managing Long Paths

The OneDrive path with special characters may be long. Use:
```powershell
# Create an alias or function
function cd-incident { cd "C:\Users\fhaal\OneDrive - Ministere de l'Enseignement Superieur et de la Recherche Scientifique\Desktop\Cloud_Project" }

# Then just use
cd-incident
```

### 2. Using Windows Terminal

Install Windows Terminal (recommended):
- https://microsoft.com/store/apps/9N0DX20HK701

Benefits:
- Multiple tabs for different services
- Better display of colors and Unicode
- Tab completion with PowerShell

### 3. Scheduled Deployment Script

Create a Windows scheduled task to run deployment:
```powershell
# Create a scheduled task for daily health checks
$action = New-ScheduledTaskAction -Execute 'oc' -Argument 'get pods -n incident-board'
$trigger = New-ScheduledTaskTrigger -Daily -At 9:00AM
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "CheckIncidentBoard" -Description "Check Incident Board pod status"
```

### 4. Context Menu Integration

Add "Open PowerShell Here" to right-click context menu:
```powershell
# Run as Administrator
New-Item -Path "HKCU:\Software\Classes\Folder\shell\pwsh" -Name "command" -Force | New-ItemProperty -Name "(Default)" -Value 'powershell -noe -c "cd ''%V''"' -Force
```

## Windows Batch Script Alternative

If PowerShell isn't available, create a batch file `deploy.bat`:

```batch
@echo off
REM DevOps Incident Board - OpenShift Deployment (Batch)

setlocal enabledelayedexpansion

echo.
echo ========================================
echo DevOps Incident Board - OpenShift Deploy
echo ========================================
echo.

REM Check if oc is installed
where oc >nul 2>nul
if %errorlevel% neq 0 (
    echo Error: 'oc' CLI tool is not installed or not in PATH
    echo Install from: https://docs.openshift.com/container-platform/latest/cli_tools/openshift_cli/getting-started-cli.html
    exit /b 1
)

REM Step 1
echo Creating namespace...
oc apply -f 00-namespace.yaml
echo.

REM Step 2
echo Creating secrets...
oc apply -f 01-secrets.yaml
echo.

REM Step 3
echo Deploying PostgreSQL...
oc apply -f 02-postgresql.yaml
echo Waiting for PostgreSQL...
oc rollout status statefulset/postgresql -n incident-board --timeout=300s
echo.

REM Step 4
echo Deploying API...
oc apply -f 03-api.yaml
echo Waiting for API...
oc rollout status deployment/api -n incident-board --timeout=300s
echo.

REM Step 5
echo Deploying Frontend...
oc apply -f 04-frontend.yaml
oc apply -f 05-frontend-config.yaml
echo Waiting for Frontend...
oc rollout status deployment/frontend -n incident-board --timeout=300s
echo.

REM Get route
for /f "tokens=*" %%i in ('oc get route frontend -n incident-board -o jsonpath="{.spec.host}" 2^>nul') do set "ROUTE_HOST=%%i"

echo ========================================
echo Deployment Complete!
echo ========================================
echo.
if not "%ROUTE_HOST%"=="" (
    echo Frontend URL: https://%ROUTE_HOST%
) else (
    echo Run: oc get routes -n incident-board
)
echo.
echo Useful commands:
echo   oc get pods -n incident-board
echo   oc get services -n incident-board
echo   oc logs -f deployment/api -n incident-board
echo.
```

Run with: `deploy.bat`

## Next Steps

1. **Verify Deployment**: Follow the [VERIFICATION_CHECKLIST.md](./VERIFICATION_CHECKLIST.md)
2. **Troubleshoot Issues**: Check [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
3. **Monitor Application**: Use `oc logs` and `oc get pods -w`
4. **Scale Services**: Use `oc scale deployment/api --replicas=3 -n incident-board`

## Support

For issues:
1. Check [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
2. Review cluster status: `oc status -n incident-board`
3. Check logs: `oc logs <pod> -n incident-board`
4. Contact: fhalyosser@tbs.u-tunis.tn

---

**Windows User Resources**:
- [OpenShift CLI on Windows](https://docs.openshift.com/container-platform/latest/cli_tools/openshift_cli/getting-started-cli.html)
- [Chocolatey Package Manager](https://chocolatey.org/)
- [Windows Terminal](https://microsoft.com/store/apps/9N0DX20HK701)
- [PowerShell Documentation](https://docs.microsoft.com/powershell/)
- [WSL2 Setup Guide](https://docs.microsoft.com/windows/wsl/install)
