#!/bin/bash
# OpenShift Deployment Script for DevOps Incident Board

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}DevOps Incident Board - OpenShift Deploy${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if oc is installed
if ! command -v oc &> /dev/null; then
    echo -e "${RED}Error: 'oc' CLI tool is not installed or not in PATH${NC}"
    echo "Please install the OpenShift CLI: https://docs.openshift.com/container-platform/latest/cli_tools/openshift_cli/getting-started-cli.html"
    exit 1
fi

echo -e "${YELLOW}Step 1: Creating namespace and ConfigMap...${NC}"
oc apply -f 00-namespace.yaml
echo -e "${GREEN}✓ Namespace created${NC}"
echo ""

echo -e "${YELLOW}Step 2: Creating secrets...${NC}"
oc apply -f 01-secrets.yaml
echo -e "${GREEN}✓ Secrets created${NC}"
echo ""

echo -e "${YELLOW}Step 3: Deploying PostgreSQL database...${NC}"
oc apply -f 02-postgresql.yaml
echo -e "${GREEN}✓ PostgreSQL deployment started${NC}"
echo -e "${YELLOW}Waiting for PostgreSQL to be ready (this may take 30-60 seconds)...${NC}"
oc rollout status statefulset/postgresql -n incident-board --timeout=300s
echo -e "${GREEN}✓ PostgreSQL is ready${NC}"
echo ""

echo -e "${YELLOW}Step 4: Deploying backend API...${NC}"
oc apply -f 03-api.yaml
echo -e "${GREEN}✓ Backend API deployment started${NC}"
echo -e "${YELLOW}Waiting for API to be ready (this may take 60-90 seconds)...${NC}"
oc rollout status deployment/api -n incident-board --timeout=300s
echo -e "${GREEN}✓ Backend API is ready${NC}"
echo ""

echo -e "${YELLOW}Step 5: Deploying frontend...${NC}"
oc apply -f 04-frontend.yaml
oc apply -f 05-frontend-config.yaml
echo -e "${GREEN}✓ Frontend deployment started${NC}"
echo -e "${YELLOW}Waiting for frontend to be ready...${NC}"
oc rollout status deployment/frontend -n incident-board --timeout=300s
echo -e "${GREEN}✓ Frontend is ready${NC}"
echo ""

# Get the route hostname
ROUTE_HOST=$(oc get route frontend -n incident-board -o jsonpath='{.spec.host}' 2>/dev/null || echo "pending...")

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Deployment Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${YELLOW}Access your application:${NC}"
echo -e "${GREEN}Frontend: https://${ROUTE_HOST}${NC}"
echo ""
echo -e "${YELLOW}Useful oc commands:${NC}"
echo "  View pods:       oc get pods -n incident-board"
echo "  View services:   oc get services -n incident-board"
echo "  View routes:     oc get routes -n incident-board"
echo "  View logs:       oc logs -f deployment/api -n incident-board"
echo "  Describe pod:    oc describe pod <pod-name> -n incident-board"
echo ""
