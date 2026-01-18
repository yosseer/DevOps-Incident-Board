# OpenShift Deployment Guide

This guide provides step-by-step instructions for deploying the DevOps Incident Board microservices to OpenShift.

## Prerequisites

1. **OpenShift Cluster Access**
   - You need an active OpenShift cluster
   - Verify access: `oc whoami`
   - If not connected: `oc login --server=<server-url> -u <username> -p <password>`

2. **OpenShift CLI (oc)**
   - Install the oc CLI tool: https://docs.openshift.com/container-platform/latest/cli_tools/openshift_cli/getting-started-cli.html
   - Verify: `oc version`

3. **Docker Images**
   - Backend API image must be pushed to an accessible container registry
   - Frontend image (nginx) is public: `nginxinc/nginx-unprivileged:1.24-alpine`
   - PostgreSQL image is public: `postgres:15-alpine`

## Deployment Steps

### Option 1: Automated Deployment (Recommended)

```bash
# Run the deployment script
chmod +x deploy.sh
./deploy.sh
```

The script will:
1. Create the namespace and configuration
2. Deploy secrets
3. Deploy PostgreSQL database
4. Deploy backend API
5. Deploy frontend with Nginx configuration
6. Wait for all services to become ready
7. Display the application URL

### Option 2: Manual Deployment

If you prefer manual steps or need more control:

#### Step 1: Create Namespace
```bash
oc apply -f 00-namespace.yaml
oc project incident-board
```

**Expected Output:**
```
namespace/incident-board created
configmap/incident-board-config created
Now using project "incident-board" on server "...".
```

#### Step 2: Create Secrets
```bash
oc apply -f 01-secrets.yaml
```

**Expected Output:**
```
secret/postgres-secret created
secret/app-secret created
```

**Verify:**
```bash
oc get secrets -n incident-board
```

#### Step 3: Deploy PostgreSQL Database
```bash
oc apply -f 02-postgresql.yaml
```

**Expected Output:**
```
persistentvolumeclaim/postgresql-pvc created
statefulset.apps/postgresql created
service/postgresql created
```

**Wait for ready:**
```bash
oc rollout status statefulset/postgresql -n incident-board
```

**Verify:**
```bash
oc get pods -n incident-board
# Should show: postgresql-0 with 1/1 READY
oc logs postgresql-0 -n incident-board  # Check for "database system is ready"
```

#### Step 4: Deploy Backend API
```bash
oc apply -f 03-api.yaml
```

**Expected Output:**
```
deployment.apps/api created
service/api created
```

**Wait for ready:**
```bash
oc rollout status deployment/api -n incident-board
```

**Verify:**
```bash
oc get pods -n incident-board
# Should show: api-xxxxx with 2/2 READY (2 replicas)
oc logs deployment/api -n incident-board --all-containers
# Check for Spring Boot startup messages
```

#### Step 5: Deploy Frontend
```bash
oc apply -f 04-frontend.yaml
oc apply -f 05-frontend-config.yaml
```

**Expected Output:**
```
deployment.apps/frontend created
service/frontend created
route.route.openshift.io/frontend created
configmap/nginx-config created
configmap/frontend-html created
```

**Wait for ready:**
```bash
oc rollout status deployment/frontend -n incident-board
```

**Verify:**
```bash
oc get pods -n incident-board
# Should show: frontend-xxxxx with 1/1 READY (2 replicas)
oc get routes -n incident-board
# Check the HOST/PORT column for your frontend URL
```

## Verification

### 1. Check All Pods are Running
```bash
oc get pods -n incident-board -o wide
```

**Expected Output:**
```
NAME                       READY   STATUS    RESTARTS
postgresql-0               1/1     Running   0
api-abc1234-5678d          1/1     Running   0
api-abc1234-9999e          1/1     Running   0
frontend-xyz9876-abc1d     1/1     Running   0
frontend-xyz9876-def2e     1/1     Running   0
```

### 2. Check All Services
```bash
oc get services -n incident-board
```

**Expected Output:**
```
NAME         TYPE        CLUSTER-IP      PORT(S)
api          ClusterIP   10.x.x.x        8080/TCP
frontend     ClusterIP   10.y.y.y        8080/TCP
postgresql   ClusterIP   None            5432/TCP
```

### 3. Check Route (External Access Point)
```bash
oc get routes -n incident-board
```

**Expected Output:**
```
NAME       HOST/PORT                         TLS TERMINATION
frontend   incident-board.app.example.com    edge
```

Copy the HOST/PORT value - this is your application URL.

### 4. Test Backend API Health
```bash
# From inside a pod
oc exec -it api-<pod-id> -n incident-board -- curl http://localhost:8080/api/incidents/health

# Or port-forward from your machine
oc port-forward service/api 8080:8080 -n incident-board &
curl http://localhost:8080/api/incidents/health
```

**Expected Response:**
```json
{
  "status": "UP",
  "database": "PostgreSQL 15 at postgresql.incident-board.svc.cluster.local:5432"
}
```

### 5. Test Frontend Access
```bash
# Get your frontend URL
FRONTEND_URL=$(oc get route frontend -n incident-board -o jsonpath='{.spec.host}')
echo "https://$FRONTEND_URL"

# Or open it in a browser directly from the console
oc get routes -n incident-board
```

### 6. Test API from Frontend
```bash
# Open the frontend URL in a browser
# Check the browser console for API calls
# Verify incidents load from the backend API
```

### 7. Check Pod Details
```bash
# View detailed pod information
oc describe pod postgresql-0 -n incident-board
oc describe pod api-<pod-id> -n incident-board
oc describe pod frontend-<pod-id> -n incident-board

# Check resource usage
oc top pods -n incident-board
oc top nodes
```

## Monitoring

### View Logs
```bash
# Backend API logs
oc logs -f deployment/api -n incident-board

# PostgreSQL logs
oc logs -f statefulset/postgresql -n incident-board

# Frontend logs
oc logs -f deployment/frontend -n incident-board

# Logs from specific pod
oc logs -f pod/api-abc1234-5678d -n incident-board

# Previous logs (if pod crashed)
oc logs pod/api-abc1234-5678d -n incident-board --previous
```

### Port Forwarding for Local Testing
```bash
# Forward PostgreSQL port
oc port-forward service/postgresql 5432:5432 -n incident-board &

# Forward API port
oc port-forward service/api 8080:8080 -n incident-board &

# Forward Frontend port
oc port-forward service/frontend 8080:8080 -n incident-board &
```

### Watch Deployments
```bash
# Monitor rollout status
oc rollout status deployment/api -n incident-board
oc rollout status deployment/frontend -n incident-board

# Watch pods in real-time
oc get pods -n incident-board -w

# Watch events
oc get events -n incident-board --sort-by='.lastTimestamp'
```

## Scaling

### Scale Backend API
```bash
# Scale to 3 replicas
oc scale deployment/api --replicas=3 -n incident-board

# View scaling status
oc get pods -n incident-board -l app=api
```

### Scale Frontend
```bash
# Scale to 3 replicas
oc scale deployment/frontend --replicas=3 -n incident-board

# View scaling status
oc get pods -n incident-board -l app=frontend
```

## Rolling Updates

### Update Backend API Image
```bash
# Trigger new rollout
oc rollout restart deployment/api -n incident-board

# Monitor the update
oc rollout status deployment/api -n incident-board

# View rollout history
oc rollout history deployment/api -n incident-board
```

## Troubleshooting

### Pods Not Starting

**Check pod status:**
```bash
oc describe pod <pod-name> -n incident-board
```

**Common issues:**
- Image not found → Check image names and registry access
- CrashLoopBackOff → Check pod logs: `oc logs <pod-name> -n incident-board`
- Pending → Check resources: `oc top nodes`

### Database Connection Issues

**Check database connectivity:**
```bash
oc exec -it api-<pod-id> -n incident-board -- \
  nc -zv postgresql.incident-board.svc.cluster.local 5432
```

**Check database logs:**
```bash
oc logs statefulset/postgresql -n incident-board
```

### Service Discovery Issues

**Test DNS resolution:**
```bash
oc run -it --rm debug --image=busybox --restart=Never -n incident-board -- \
  nslookup api.incident-board.svc.cluster.local
```

### Frontend Not Loading

**Check Nginx configuration:**
```bash
oc exec -it frontend-<pod-id> -n incident-board -- nginx -t
```

**Check Nginx logs:**
```bash
oc logs deployment/frontend -n incident-board
```

## Cleanup

### Delete Entire Application
```bash
# Delete all resources in the namespace
oc delete namespace incident-board

# This will delete:
# - All pods
# - All services and routes
# - All deployments and statefulsets
# - All persistent volumes (if configured to delete on namespace deletion)
# - All secrets and configmaps
```

### Delete Specific Resources
```bash
# Delete only frontend
oc delete deployment/frontend -n incident-board

# Delete only API
oc delete deployment/api -n incident-board

# Delete only database
oc delete statefulset/postgresql -n incident-board

# Delete secrets
oc delete secrets --all -n incident-board

# Delete ConfigMaps
oc delete configmaps --all -n incident-board
```

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    OpenShift Cluster                             │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │           incident-board Namespace                          │ │
│  │                                                               │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │ │
│  │  │   Frontend   │  │     API      │  │  PostgreSQL  │      │ │
│  │  │ Deployment   │  │  Deployment  │  │ StatefulSet  │      │ │
│  │  │  (2 pods)    │  │  (2 pods)    │  │  (1 pod)     │      │ │
│  │  └──────────────┘  └──────────────┘  └──────────────┘      │ │
│  │         ↓                 ↓                ↓                  │ │
│  │    ClusterIP:8080   ClusterIP:8080   ClusterIP:None         │ │
│  │                                                               │ │
│  │  ┌──────────────────────────────────────────────────────────┐│ │
│  │  │           OpenShift Route (TLS Edge)                     ││ │
│  │  │  incident-board.apps.example.com → frontend:8080        ││ │
│  │  └──────────────────────────────────────────────────────────┘│ │
│  └─────────────────────────────────────────────────────────────┘ │
│                                                                    │
│  Internal DNS Resolution:                                         │
│  - api.incident-board.svc.cluster.local:8080                     │
│  - postgresql.incident-board.svc.cluster.local:5432              │
│  - frontend.incident-board.svc.cluster.local:8080                │
│                                                                    │
└─────────────────────────────────────────────────────────────────┘
```

## Next Steps

1. **Monitor the Application**
   - Set up alerts for pod failures
   - Monitor resource usage
   - Track API response times

2. **Production Hardening**
   - Configure resource quotas
   - Set up network policies
   - Enable pod security policies
   - Configure persistent backup strategy

3. **CI/CD Integration**
   - Set up GitOps (ArgoCD, Flux)
   - Configure automated deployments on code push
   - Set up image scanning and vulnerability detection

4. **Observability**
   - Set up centralized logging (ELK, Loki)
   - Set up metrics collection (Prometheus)
   - Set up distributed tracing (Jaeger)

---

**Questions or Issues?** Check the troubleshooting section or consult the [OpenShift Documentation](https://docs.openshift.com/).
