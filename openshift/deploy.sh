#!/bin/bash

# Beeper OpenShift Deployment Script
# This script deploys the Beeper application to OpenShift

set -e

NAMESPACE="devops-incident-board-app"
GITHUB_REPO="https://github.com/yosseer/DevOps-Incident-Board.git"

echo "=================================================="
echo "Deploying Beeper to OpenShift"
echo "=================================================="

# Check if oc CLI is available
if ! command -v oc &> /dev/null; then
    echo "ERROR: 'oc' CLI not found. Please install OpenShift CLI."
    exit 1
fi

# Check if logged in to OpenShift
if ! oc project &> /dev/null; then
    echo "ERROR: Not logged into OpenShift. Run 'oc login' first."
    exit 1
fi

echo ""
echo "Step 1: Creating namespace..."
oc apply -f config/namespace.yaml

echo ""
echo "Step 2: Switching to beeper namespace..."
oc project $NAMESPACE

echo ""
echo "Step 3: Setting up PostgreSQL database..."
oc apply -f database/secret.yaml
oc apply -f database/configmap.yaml
oc apply -f database/deployment.yaml

echo ""
echo "Step 4: Waiting for PostgreSQL to be ready..."
oc wait --for=condition=Ready pod -l app=postgresql -n $NAMESPACE --timeout=300s 2>/dev/null || echo "PostgreSQL startup may still be in progress..."

echo ""
echo "Step 5: Deploying backend (BuildConfig and Deployment)..."
oc apply -f backend/buildconfig.yaml
oc apply -f backend/deployment.yaml

echo ""
echo "Step 6: Deploying UI (BuildConfig and Deployment)..."
oc apply -f ui/buildconfig.yaml
oc apply -f ui/deployment.yaml

echo ""
echo "Step 9: Waiting for backend build..."
oc wait --for=condition=Complete build/beeper-backend-1 -n $NAMESPACE --timeout=600s 2>/dev/null || echo "Backend build may still be in progress..."

echo "Waiting for UI build..."
oc wait --for=condition=Complete build/beeper-ui-1 -n $NAMESPACE --timeout=600s 2>/dev/null || echo "UI build may still be in progress..."

echo ""
echo "Step 10: Deployment complete!"
echo ""
echo "=================================================="
echo "Application URLs:"
echo "=================================================="
echo ""

BACKEND_ROUTE=$(oc get route beeper-backend -n $NAMESPACE -o jsonpath='{.spec.host}' 2>/dev/null || echo "pending...")
UI_ROUTE=$(oc get route beeper-ui -n $NAMESPACE -o jsonpath='{.spec.host}' 2>/dev/null || echo "pending...")

echo "Backend API: http://$BACKEND_ROUTE"
echo "UI:          http://$UI_ROUTE"
echo ""
echo "Useful commands:"
echo "  oc logs -f deployment/postgresql -n $NAMESPACE               # View PostgreSQL logs"
echo "  oc logs -f deployment/beeper-backend -n $NAMESPACE           # View backend logs"
echo "  oc logs -f deployment/beeper-ui -n $NAMESPACE                # View UI logs"
echo "  oc describe pod -l app=postgresql -n $NAMESPACE              # Describe PostgreSQL pods"
echo "  oc describe pod -l app=beeper-backend -n $NAMESPACE          # Describe backend pods"
echo "  oc describe pod -l app=beeper-ui -n $NAMESPACE               # Describe UI pods"
echo "  oc get all -n $NAMESPACE                               # View all resources"
echo ""
echo "To scale deployments:"
echo "  oc scale deployment beeper-backend --replicas=3 -n $NAMESPACE"
echo "  oc scale deployment beeper-ui --replicas=2 -n $NAMESPACE"
echo ""
echo "=================================================="
