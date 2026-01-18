# OpenShift Deployment Verification Checklist

Complete this checklist to verify that your DevOps Incident Board is fully deployed and operational on OpenShift.

## Pre-Deployment Checks

- [ ] OpenShift cluster access verified (`oc whoami`)
- [ ] Backend API Docker image is built and pushed to registry
- [ ] Container registry credentials configured (if using private registry)
- [ ] All YAML manifest files are present in the `openshift/` directory:
  - [ ] 00-namespace.yaml
  - [ ] 01-secrets.yaml
  - [ ] 02-postgresql.yaml
  - [ ] 03-api.yaml
  - [ ] 04-frontend.yaml
  - [ ] 05-frontend-config.yaml

## Deployment Execution

- [ ] Namespace and ConfigMap created
  ```bash
  oc get namespace incident-board
  oc get configmap incident-board-config -n incident-board
  ```

- [ ] Secrets created
  ```bash
  oc get secrets -n incident-board
  ```
  Expected: At least `postgres-secret` and `app-secret`

- [ ] PostgreSQL StatefulSet deployed
  ```bash
  oc get statefulset -n incident-board
  ```

- [ ] API Deployment deployed
  ```bash
  oc get deployment/api -n incident-board
  ```

- [ ] Frontend Deployment deployed
  ```bash
  oc get deployment/frontend -n incident-board
  ```

## Pod Status Verification

### Check All Pods Are Running
```bash
oc get pods -n incident-board
```

**Verification Checklist:**
- [ ] PostgreSQL pod is `1/1 READY` and `Running`
  - Pod name: `postgresql-0`
  - Expected status: `Running`
  - Restarts: `0`

- [ ] API pods are running
  - Expected pods: `2` replicas (or as configured)
  - Each pod: `1/1 READY` and `Running`
  - Restarts: `0` for each

- [ ] Frontend pods are running
  - Expected pods: `2` replicas (or as configured)
  - Each pod: `1/1 READY` and `Running`
  - Restarts: `0` for each

### Pod Details
```bash
# Check individual pod status
oc describe pod postgresql-0 -n incident-board
oc describe pod api-<pod-id> -n incident-board
oc describe pod frontend-<pod-id> -n incident-board
```

**Verify each pod:**
- [ ] Status is `Running`
- [ ] No error conditions in Events section
- [ ] All containers ready (e.g., `1/1`, `2/2`)
- [ ] Container restart count is `0`

## Service Verification

### Check Services Are Created
```bash
oc get services -n incident-board
```

**Verification Checklist:**
- [ ] `api` service exists
  - Type: `ClusterIP`
  - Port: `8080/TCP`
  - Endpoints: Shows multiple IPs (one for each pod)
  - DNS: `api.incident-board.svc.cluster.local:8080`

- [ ] `frontend` service exists
  - Type: `ClusterIP`
  - Port: `8080/TCP`
  - Endpoints: Shows multiple IPs (one for each pod)
  - DNS: `frontend.incident-board.svc.cluster.local:8080`

- [ ] `postgresql` service exists
  - Type: `ClusterIP` (or `None` for headless)
  - Port: `5432/TCP`
  - Endpoints: Shows PostgreSQL pod IP
  - DNS: `postgresql.incident-board.svc.cluster.local:5432`

### Service Endpoints
```bash
oc get endpoints -n incident-board
```

**Verify endpoints have IP addresses:**
- [ ] `api` service has endpoints
- [ ] `frontend` service has endpoints
- [ ] `postgresql` service has endpoints

## Route/Ingress Verification

### Check External Access Route
```bash
oc get routes -n incident-board
```

**Verification Checklist:**
- [ ] `frontend` route exists
- [ ] Host field has a value (e.g., `incident-board.apps.example.com`)
- [ ] TLS termination: `edge` or `reencrypt`
- [ ] Status shows available routes

### Get Frontend URL
```bash
oc get route frontend -n incident-board -o jsonpath='{.spec.host}'
```

**Verification:**
- [ ] Command returns a valid hostname
- [ ] Note this URL for later testing

## Container Image Verification

### Check Images Are Pulled
```bash
oc get pods -n incident-board -o wide
```

**Verification Checklist:**
- [ ] PostgreSQL container image: `postgres:15-alpine` (or your configured version)
- [ ] API container image: Your backend API image (check IMAGE column)
- [ ] Frontend container image: `nginxinc/nginx-unprivileged:1.24-alpine`
- [ ] Node column shows which node each pod is running on
- [ ] No `ImagePullBackOff` errors

## Storage Verification

### Persistent Volume Claims
```bash
oc get pvc -n incident-board
```

**Verification Checklist:**
- [ ] `postgresql-pvc` exists
- [ ] Status: `Bound`
- [ ] Capacity: `10Gi` (or as configured)
- [ ] Access mode: `RWO` (ReadWriteOnce)

### Persistent Volume
```bash
oc get pv | grep incident-board
```

**Verification:**
- [ ] At least one PV is bound to the PVC
- [ ] Capacity matches the PVC request

## Database Connectivity

### Test PostgreSQL Pod
```bash
oc exec -it postgresql-0 -n incident-board -- psql -U postgres -c "SELECT version();"
```

**Verification:**
- [ ] Command returns PostgreSQL version
- [ ] No authentication errors

### Test Database Initialization
```bash
oc logs statefulset/postgresql -n incident-board | grep -i "ready\|initialization\|error"
```

**Verification:**
- [ ] Logs show "database system is ready to accept connections"
- [ ] No initialization errors

### Test DNS Resolution from API Pod
```bash
oc exec -it api-<pod-id> -n incident-board -- \
  nc -zv postgresql.incident-board.svc.cluster.local 5432
```

**Expected Output:**
- [ ] Connection succeeded to postgresql:5432

## API Health Check

### Port Forward to API
```bash
oc port-forward service/api 8080:8080 -n incident-board &
```

### Test Health Endpoint
```bash
curl http://localhost:8080/api/incidents/health
```

**Expected Response:**
```json
{
  "status": "UP",
  "database": "PostgreSQL 15"
}
```

**Verification:**
- [ ] HTTP status: `200 OK`
- [ ] JSON response shows `"status": "UP"`
- [ ] Database connection is confirmed

### Test API Endpoints
```bash
# List all incidents
curl http://localhost:8080/api/incidents

# Get single incident (if exists)
curl http://localhost:8080/api/incidents/1
```

**Verification:**
- [ ] HTTP status: `200 OK`
- [ ] JSON response is valid and contains incidents

## Frontend Verification

### Access Frontend URL
```bash
# Get the route URL
FRONTEND_URL=$(oc get route frontend -n incident-board -o jsonpath='{.spec.host}')
echo "https://$FRONTEND_URL"

# Or open directly in browser
```

**Verification:**
- [ ] Frontend page loads successfully
- [ ] HTTPS connection works (if TLS is configured)
- [ ] Dashboard is visible

### Check Frontend Logs
```bash
oc logs deployment/frontend -n incident-board
```

**Verification:**
- [ ] No error messages
- [ ] Access logs show successful requests

### Test Frontend API Integration
```bash
# Open browser developer tools (F12)
# Check Network tab for API calls
# Verify /api/incidents requests are made to the backend
```

**Verification:**
- [ ] No 404 or 502 errors in Network tab
- [ ] API calls to `/api/incidents` succeed
- [ ] Incidents display on the dashboard

## Security Verification

### Check Security Context
```bash
oc get pods -n incident-board -o yaml | grep -A5 securityContext
```

**Verification:**
- [ ] `runAsNonRoot: true` is set
- [ ] `runAsUser` is set (not 0/root)
- [ ] `capabilities` are dropped

### Check Resource Limits
```bash
oc get pods -n incident-board -o wide
oc describe pod <pod-name> -n incident-board | grep -A10 "Limits\|Requests"
```

**Verification:**
- [ ] Each pod has memory requests and limits set
- [ ] Each pod has CPU requests and limits set
- [ ] No pod is using "unlimited" resources

## Health Probes Verification

### Liveness Probes
```bash
oc describe pod postgresql-0 -n incident-board | grep -A5 "Liveness"
oc describe pod api-<pod-id> -n incident-board | grep -A5 "Liveness"
oc describe pod frontend-<pod-id> -n incident-board | grep -A5 "Liveness"
```

**Verification:**
- [ ] PostgreSQL: `Liveness: exec [pg_isready ...] initial delay 30s timeout 5s`
- [ ] API: `Liveness: http-get http://:8080/api/incidents/health ... initial delay 60s timeout 5s`
- [ ] Frontend: `Liveness: http-get http://:8080/health ... initial delay 10s timeout 3s`

### Readiness Probes
```bash
oc describe pod <pod-name> -n incident-board | grep -A5 "Readiness"
```

**Verification:**
- [ ] PostgreSQL: `Readiness: exec [pg_isready ...] initial delay 10s timeout 5s`
- [ ] API: `Readiness: http-get http://:8080/api/incidents/health ... initial delay 30s timeout 5s`
- [ ] Frontend: `Readiness: http-get http://:8080/health ... initial delay 5s timeout 3s`

## Integration Testing

### End-to-End Test Scenario

#### 1. Get Frontend URL
```bash
FRONTEND_URL=$(oc get route frontend -n incident-board -o jsonpath='{.spec.host}')
echo "https://$FRONTEND_URL"
```

#### 2. Open Frontend
- [ ] Open browser and navigate to the URL above
- [ ] Dashboard loads without errors
- [ ] All UI elements are visible

#### 3. Check API Connection
- [ ] Incidents are displayed on the dashboard
- [ ] No "Failed to load incidents" errors

#### 4. Create New Incident (if form is available)
- [ ] Fill in the incident form
- [ ] Submit the form
- [ ] Verify new incident appears in the list

#### 5. Update Incident
- [ ] Click on an incident
- [ ] Change status or other fields
- [ ] Verify changes are saved

#### 6. Delete Incident
- [ ] Delete an incident
- [ ] Verify incident is removed from the list

## Monitoring and Logging

### Check Pod Logs
```bash
# PostgreSQL logs
oc logs statefulset/postgresql -n incident-board | tail -20

# API logs
oc logs deployment/api -n incident-board --all-containers | tail -20

# Frontend logs
oc logs deployment/frontend -n incident-board | tail -20
```

**Verification:**
- [ ] No error messages in any pod logs
- [ ] API logs show Spring Boot startup messages
- [ ] Frontend logs show Nginx startup messages

### Monitor Resource Usage
```bash
oc top pods -n incident-board
```

**Verification:**
- [ ] CPU usage is reasonable (not constantly at 100%)
- [ ] Memory usage is below the pod limits
- [ ] No pod is consuming excessive resources

### Watch Deployments
```bash
oc get pods -n incident-board -w
```

**Verification:**
- [ ] All pods remain in `Running` state
- [ ] No pods are restarting (RESTARTS column shows 0)

## Scaling Verification (Optional)

### Scale API Deployment
```bash
oc scale deployment/api --replicas=3 -n incident-board
oc get pods -n incident-board -l app=api
```

**Verification:**
- [ ] 3 API pods are running
- [ ] All pods show `1/1 READY`
- [ ] Frontend still loads correctly

### Scale Frontend Deployment
```bash
oc scale deployment/frontend --replicas=3 -n incident-board
oc get pods -n incident-board -l app=frontend
```

**Verification:**
- [ ] 3 frontend pods are running
- [ ] All pods show `1/1 READY`
- [ ] Dashboard still accessible

### Reset to Default Replicas
```bash
oc scale deployment/api --replicas=2 -n incident-board
oc scale deployment/frontend --replicas=2 -n incident-board
```

## Performance Testing (Optional)

### Load Test API
```bash
# Install Apache Bench if not already installed
# macOS: brew install httpd
# Ubuntu: sudo apt-get install apache2-utils

# Set API URL
API_URL="http://localhost:8080"  # if port-forwarded

# Run load test
ab -n 1000 -c 10 "$API_URL/api/incidents"
```

**Verification:**
- [ ] Requests complete without errors
- [ ] API handles concurrent connections

## Final Verification Checklist

- [ ] **All pods running**: 1 PostgreSQL + 2 API + 2 Frontend (or your configured replicas)
- [ ] **All services created**: api, frontend, postgresql
- [ ] **Route created**: frontend accessible from external URL
- [ ] **Database operational**: PostgreSQL can be accessed
- [ ] **API responding**: Health endpoint returns 200 OK
- [ ] **Frontend loads**: Dashboard UI loads successfully
- [ ] **Integration works**: Incidents display from backend database
- [ ] **No pod restarts**: All pods have RESTARTS = 0
- [ ] **Logs clean**: No errors in any pod logs
- [ ] **Security configured**: Non-root users, resource limits, security contexts
- [ ] **Health probes working**: Liveness and readiness probes configured
- [ ] **Storage working**: PostgreSQL PVC is bound and mounted

## Deployment Status Summary

**Deployment Date**: _________________

**Cluster**: _________________

**Namespace**: incident-board

**Frontend URL**: https://_________________ 

**Status**: 
- [ ] All systems operational
- [ ] Partial issues (see notes below)
- [ ] Major issues (see notes below)

**Notes**:
```



```

---

## Troubleshooting References

If any checks fail, refer to these commands:

### Pod Issues
```bash
# Detailed pod info
oc describe pod <pod-name> -n incident-board

# Pod logs
oc logs <pod-name> -n incident-board

# Previous logs (if crashed)
oc logs <pod-name> -n incident-board --previous

# Container-specific logs
oc logs <pod-name> -c <container-name> -n incident-board
```

### Service Issues
```bash
# Check endpoints
oc get endpoints -n incident-board

# Check service details
oc describe service <service-name> -n incident-board

# Test connectivity
oc exec -it <pod-name> -n incident-board -- \
  nc -zv <service-name>.incident-board.svc.cluster.local <port>
```

### Events
```bash
# View recent cluster events
oc get events -n incident-board --sort-by='.lastTimestamp'

# Watch events in real-time
oc get events -n incident-board -w
```

---

**Questions?** Check the [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) for detailed instructions.
