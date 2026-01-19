# OpenShift Deployment Troubleshooting Guide

This guide helps diagnose and resolve common issues encountered during or after deploying the DevOps Incident Board to OpenShift.

## Quick Diagnostics

### Check Overall Cluster Health
```bash
# Check nodes are ready
oc get nodes

# Check cluster info
oc cluster-info

# Check project/namespace status
oc status -n incident-board
```

### Check All Resources
```bash
# Get all resources in namespace
oc get all -n incident-board

# Get all resources including services, routes, etc.
oc get all,pvc,secrets,configmaps -n incident-board
```

## Pod Issues

### 1. Pod Stuck in "Pending" State

**Symptoms**: Pod shows `Pending` status indefinitely

**Diagnosis**:
```bash
oc describe pod <pod-name> -n incident-board
```

Look for `Events` section. Common causes:

#### Insufficient Resources
```bash
# Check node capacity
oc top nodes
oc describe node <node-name>
```

**Solution**:
- Increase cluster capacity
- Reduce resource requests in manifest
- Use node selectors to target specific nodes

#### PVC Not Bound (PostgreSQL)
```bash
oc get pvc -n incident-board
```

**Solution**:
```bash
# Check storage classes
oc get storageclass

# Check for errors
oc describe pvc postgresql-pvc -n incident-board
```

If StorageClass is missing:
- Contact cluster admin
- Configure a StorageClass
- Update `02-postgresql.yaml` with correct StorageClass

### 2. Pod in "CrashLoopBackOff" State

**Symptoms**: Pod restarts repeatedly (RESTARTS column keeps increasing)

**Diagnosis**:
```bash
# Check logs
oc logs <pod-name> -n incident-board

# Check previous logs
oc logs <pod-name> -n incident-board --previous

# Get detailed description
oc describe pod <pod-name> -n incident-board
```

#### API Container Crashing
```bash
oc logs deployment/api -n incident-board --all-containers
```

**Common causes**:
- **Database not ready**: Wait for PostgreSQL pod to be ready
- **Invalid environment variables**: Check secrets and ConfigMaps
- **Image not found**: Verify image name and registry

**Solution for database not ready**:
```bash
# Check PostgreSQL status
oc get pods -n incident-board | grep postgresql
oc logs postgresql-0 -n incident-board

# Wait for PostgreSQL to be ready
oc rollout status statefulset/postgresql -n incident-board --timeout=300s

# Then restart API
oc rollout restart deployment/api -n incident-board
```

#### Frontend Container Crashing
```bash
oc logs deployment/frontend -n incident-board
```

**Common causes**:
- **Nginx configuration error**: Check nginx config in ConfigMap
- **Permission issues**: Check file permissions in container

**Solution for Nginx config error**:
```bash
# Test Nginx configuration
oc exec -it <frontend-pod> -n incident-board -- nginx -t

# Check Nginx error log
oc exec -it <frontend-pod> -n incident-board -- cat /var/log/nginx/error.log
```

### 3. Pod in "ImagePullBackOff" State

**Symptoms**: Pod can't start because image won't download

**Diagnosis**:
```bash
oc describe pod <pod-name> -n incident-board
# Look for "Failed to pull image" in Events
```

**Common causes**:
- Image name is wrong
- Registry credentials are missing
- Image doesn't exist in registry

**Solutions**:
```bash
# Verify image exists in registry
docker pull <image-name>

# Check image name in pod definition
oc get pod <pod-name> -n incident-board -o yaml | grep image:

# For private registry, create image pull secret
oc create secret docker-registry regcred \
  --docker-server=<registry-url> \
  --docker-username=<username> \
  --docker-password=<password> \
  -n incident-board

# Update service account to use the secret
oc patch serviceaccount default \
  -p '{"imagePullSecrets": [{"name": "regcred"}]}' \
  -n incident-board
```

### 4. Pod in "Error" State

**Symptoms**: Pod shows `Error` status

**Diagnosis**:
```bash
oc describe pod <pod-name> -n incident-board
oc logs <pod-name> -n incident-board
```

**Solution**:
- Fix the underlying issue shown in logs
- Delete and redeploy: `oc delete pod <pod-name> -n incident-board`
- Kubernetes will recreate it with new configuration

## Service and Networking Issues

### 1. Service Has No Endpoints

**Symptoms**: `oc get endpoints` shows service with no IP addresses

```bash
oc get endpoints -n incident-board
# Shows service with <none> in ENDPOINTS column
```

**Diagnosis**:
```bash
oc describe service <service-name> -n incident-board
oc get pods -n incident-board -l app=<app-name>
```

**Causes**:
- No pods running with matching labels
- Pod labels don't match service selector

**Solution**:
```bash
# Check pod labels
oc get pods -n incident-board --show-labels

# Check service selector
oc describe service <service-name> -n incident-board | grep Selector

# Labels must match! Update if needed
oc label pods <pod-name> app=<app-name> -n incident-board --overwrite
```

### 2. Cannot Reach Service from Pod

**Symptoms**: DNS lookup or connection fails when testing from another pod

**Diagnosis**:
```bash
# Test DNS from another pod
oc exec -it <pod-name> -n incident-board -- \
  nslookup <service-name>.incident-board.svc.cluster.local

# Test connectivity
oc exec -it <pod-name> -n incident-board -- \
  nc -zv <service-name>.incident-board.svc.cluster.local <port>

# Check firewall/network policies
oc get networkpolicies -n incident-board
```

**Solutions**:
```bash
# Restart DNS cache (CoreDNS)
oc rollout restart deployment/coredns -n openshift-dns

# If network policies are blocking traffic
oc delete networkpolicies --all -n incident-board  # CAUTION: removes all policies

# Verify service port is correct
oc get service <service-name> -n incident-board
```

### 3. Frontend Cannot Reach API

**Symptoms**: Dashboard loads but shows "Failed to load incidents"

**Browser Console Check**:
- Open browser developer tools (F12)
- Check Console and Network tabs
- Look for failed requests to API

**Diagnosis**:
```bash
# Check Nginx proxy configuration
oc exec -it <frontend-pod> -n incident-board -- \
  cat /etc/nginx/conf.d/default.conf | grep -A5 "api"

# Test connectivity from frontend pod to API
oc exec -it <frontend-pod> -n incident-board -- \
  curl -v http://api.incident-board.svc.cluster.local:8080/api/incidents/health

# Check Nginx error log
oc exec -it <frontend-pod> -n incident-board -- \
  tail -20 /var/log/nginx/error.log
```

**Solutions**:
```bash
# Verify API service is running
oc get service/api -n incident-board

# Verify API pods are ready
oc get pods -n incident-board -l app=api

# Restart frontend pods to reload config
oc rollout restart deployment/frontend -n incident-board

# Check if ConfigMap with Nginx config is mounted correctly
oc describe pod <frontend-pod> -n incident-board | grep -A5 "Mounts"
```

## Database Issues

### 1. PostgreSQL Pod Not Starting

**Diagnosis**:
```bash
oc get pods -n incident-board | grep postgresql
oc logs postgresql-0 -n incident-board
oc describe pod postgresql-0 -n incident-board
```

**Common causes**:
- PVC not bound
- Insufficient storage
- Init failure

**Solutions**:
```bash
# Check PVC status
oc get pvc -n incident-board

# Check storage availability
oc get pv

# Describe PVC for errors
oc describe pvc postgresql-pvc -n incident-board

# If PVC is stuck, delete and recreate
oc delete pvc postgresql-pvc -n incident-board
oc apply -f 02-postgresql.yaml
```

### 2. Database Connection Timeout

**Symptoms**: API logs show connection timeout to PostgreSQL

**Diagnosis**:
```bash
# Test connection from API pod
oc exec -it <api-pod> -n incident-board -- \
  nc -zv postgresql.incident-board.svc.cluster.local 5432

# Check PostgreSQL service
oc get service/postgresql -n incident-board

# Check PostgreSQL pod readiness
oc describe pod postgresql-0 -n incident-board | grep Readiness
```

**Solutions**:
```bash
# Verify PostgreSQL is accepting connections
oc exec -it postgresql-0 -n incident-board -- \
  psql -U postgres -c "SELECT 1"

# Check PostgreSQL logs for connection issues
oc logs postgresql-0 -n incident-board | tail -50

# Restart PostgreSQL
oc delete pod postgresql-0 -n incident-board
# Kubernetes will recreate it (note: single pod, so this causes brief downtime)

# Verify API can connect after restart
oc rollout restart deployment/api -n incident-board
```

### 3. Database Authentication Failed

**Symptoms**: API logs show "password authentication failed"

**Diagnosis**:
```bash
# Check secrets
oc get secrets -n incident-board
oc describe secret postgres-secret -n incident-board

# Verify environment variables in API pod
oc exec -it <api-pod> -n incident-board -- \
  printenv | grep -i database
```

**Solution**:
```bash
# Compare credentials in secret with environment variables
oc get secret postgres-secret -n incident-board -o yaml

# If incorrect, recreate secret
oc delete secret postgres-secret -n incident-board
oc apply -f 01-secrets.yaml

# Restart API pods
oc rollout restart deployment/api -n incident-board
```

### 4. PostgreSQL Data Persistence

**Symptoms**: Data is lost after pod restart

**Diagnosis**:
```bash
# Check PVC is mounted
oc exec -it postgresql-0 -n incident-board -- \
  df -h | grep /var/lib/postgresql

# Check data directory
oc exec -it postgresql-0 -n incident-board -- \
  ls -la /var/lib/postgresql/data/
```

**Solution**:
- Ensure PVC is properly configured in `02-postgresql.yaml`
- Verify storage class supports persistence
- Check pod definition has volumeMount

## Route/External Access Issues

### 1. Route Not Creating

**Symptoms**: `oc get routes` shows no route or route is pending

**Diagnosis**:
```bash
oc get routes -n incident-board
oc describe route frontend -n incident-board
```

**Common causes**:
- Service doesn't exist
- Service selector is wrong
- Ingress controller not running

**Solutions**:
```bash
# Verify frontend service exists
oc get service/frontend -n incident-board

# Verify service has endpoints
oc get endpoints/frontend -n incident-board

# Create route if it doesn't exist
oc expose service frontend -n incident-board

# Or apply the route from manifest
oc apply -f 04-frontend.yaml
```

### 2. Cannot Access Frontend via Route

**Symptoms**: Route URL doesn't load or times out

**Diagnosis**:
```bash
# Get route details
oc get route frontend -n incident-board -o yaml

# Test connectivity to route
curl -v https://<route-host>

# Check if frontend service has endpoints
oc get endpoints/frontend -n incident-board
```

**Common causes**:
- TLS certificate issues
- Frontend pods not ready
- Firewall blocking traffic

**Solutions**:
```bash
# Verify frontend pods are running
oc get pods -n incident-board -l app=frontend

# Check frontend pod readiness
oc describe pod <frontend-pod> -n incident-board | grep Readiness

# Test connectivity from cluster
oc exec -it <pod-name> -n incident-board -- \
  curl -v http://frontend.incident-board.svc.cluster.local:8080

# Restart frontend pods
oc rollout restart deployment/frontend -n incident-board

# For TLS issues, check cert
oc describe route frontend -n incident-board | grep TLS
```

### 3. "404 Not Found" or "502 Bad Gateway"

**Symptoms**: Frontend loads but shows 404 or 502 error

**Diagnosis**:
```bash
# Check Nginx error logs
oc logs deployment/frontend -n incident-board

# Check if API service is accessible
oc exec -it <frontend-pod> -n incident-board -- \
  curl http://api.incident-board.svc.cluster.local:8080/api/incidents/health

# Check Nginx config
oc exec -it <frontend-pod> -n incident-board -- \
  nginx -t
```

**Solutions**:
```bash
# Restart frontend pods
oc rollout restart deployment/frontend -n incident-board

# Verify API is running and healthy
oc get pods -n incident-board -l app=api
oc logs deployment/api -n incident-board

# Check Nginx proxy configuration in ConfigMap
oc get configmap nginx-config -n incident-board -o yaml
```

## API Health and Functionality Issues

### 1. API Health Endpoint Returns Error

**Symptoms**: `/api/incidents/health` returns error or wrong status

**Diagnosis**:
```bash
# Port forward to API
oc port-forward service/api 8080:8080 -n incident-board &

# Test endpoint
curl http://localhost:8080/api/incidents/health

# Check API logs
oc logs deployment/api -n incident-board
```

**Solution**:
- Check database connection (see Database Issues section)
- Verify environment variables
- Check Spring Boot application.properties

### 2. API Endpoints Return 500 Error

**Symptoms**: GET/POST requests to `/api/incidents` return 500 error

**Diagnosis**:
```bash
# Check API logs for stack traces
oc logs deployment/api -n incident-board --tail=50

# Get more detailed logs
oc logs deployment/api -n incident-board -c api --previous
```

**Common causes**:
- Database connection issue
- Invalid data format
- Missing required fields

**Solution**:
- Fix the issue indicated in error logs
- Restart API deployment: `oc rollout restart deployment/api -n incident-board`

### 3. API Response is Slow

**Symptoms**: Requests take too long to complete

**Diagnosis**:
```bash
# Measure response time
time curl http://localhost:8080/api/incidents

# Check resource usage
oc top pods -n incident-board

# Check database performance
oc exec -it postgresql-0 -n incident-board -- \
  psql -U postgres -c "SELECT * FROM pg_stat_statements ORDER BY mean_time DESC LIMIT 10;"
```

**Solutions**:
```bash
# Scale up replicas
oc scale deployment/api --replicas=3 -n incident-board

# Increase resource limits in 03-api.yaml
# Increase PostgreSQL resources in 02-postgresql.yaml

# Add database indexes (if applicable)
# Optimize queries (if applicable)
```

## Configuration Issues

### 1. ConfigMap Not Mounted

**Symptoms**: Configuration files not present in container

**Diagnosis**:
```bash
# Check if ConfigMap exists
oc get configmap -n incident-board

# Check if pod has volume mounts
oc describe pod <pod-name> -n incident-board | grep -A20 "Mounts:"

# Check if files exist in container
oc exec -it <pod-name> -n incident-board -- ls -la /etc/nginx/conf.d/
```

**Solution**:
```bash
# Verify ConfigMap is applied
oc apply -f 05-frontend-config.yaml

# Restart pods to remount ConfigMap
oc rollout restart deployment/frontend -n incident-board
```

### 2. Environment Variables Not Set

**Symptoms**: Pod uses default values instead of configured values

**Diagnosis**:
```bash
# Check environment variables
oc exec -it <pod-name> -n incident-board -- printenv | grep -i "database\|spring\|api"

# Check secret values
oc get secret app-secret -n incident-board -o yaml
oc get secret postgres-secret -n incident-board -o yaml
```

**Solution**:
```bash
# Verify secret is created correctly
oc apply -f 01-secrets.yaml

# Verify pod definition references the secret
oc describe deployment api -n incident-board | grep -A10 "env\|valueFrom"

# Restart pods to pick up new environment variables
oc rollout restart deployment/api -n incident-board
```

## Resource and Performance Issues

### 1. Pods Running Out of Memory

**Symptoms**: Pod killed with OOMKilled status

**Diagnosis**:
```bash
oc describe pod <pod-name> -n incident-board | grep -A5 "Last State"

oc get events -n incident-board | grep OOMKilled
```

**Solution**:
```bash
# Increase memory limits in manifest
# Edit 02-postgresql.yaml, 03-api.yaml, or 04-frontend.yaml
# Increase limits.memory value

# Reapply configuration
oc apply -f <manifest-file>

# Check current usage
oc top pods -n incident-board
```

### 2. Pods Exceeding CPU Limits

**Symptoms**: CPU throttling in logs, slow performance

**Diagnosis**:
```bash
oc top pods -n incident-board --containers

oc describe pod <pod-name> -n incident-board | grep -A10 "Limits\|Requests"
```

**Solution**:
- Increase CPU limits in manifest
- Scale to more replicas
- Optimize application code

## Deployment Rollback

### If Deployment Has Issues After Update

```bash
# View rollout history
oc rollout history deployment/api -n incident-board

# Rollback to previous version
oc rollout undo deployment/api -n incident-board

# Rollback to specific version
oc rollout undo deployment/api --to-revision=1 -n incident-board

# Monitor rollback
oc rollout status deployment/api -n incident-board
```

## Emergency Procedures

### 1. Complete Restart

```bash
# Delete all pods (they will be recreated)
oc delete pods --all -n incident-board

# Watch pods restart
oc get pods -n incident-board -w
```

### 2. Restart Individual Service

```bash
# Restart API
oc rollout restart deployment/api -n incident-board

# Restart frontend
oc rollout restart deployment/frontend -n incident-board

# Restart PostgreSQL
oc delete pod postgresql-0 -n incident-board
```

### 3. Clear and Redeploy Everything

```bash
# Delete entire namespace (WARNING: data loss!)
oc delete namespace incident-board

# Redeploy from manifests
bash deploy.sh
```

## Getting Help

### Collect Debug Information

```bash
# Export all resources
oc get all,pvc,secrets,configmaps -n incident-board -o yaml > debug-resources.yaml

# Export pod descriptions
oc describe pods -n incident-board > debug-pods.txt

# Export events
oc get events -n incident-board -o yaml > debug-events.yaml

# Export logs
for pod in $(oc get pods -n incident-board -o name); do
  oc logs $pod -n incident-board > debug-logs-${pod##*/}.txt 2>&1
done

# Create a debug bundle
tar czf openshift-debug.tar.gz debug-*
```

### Common Commands Reference

```bash
# Check cluster status
oc status
oc cluster-info

# Get detailed information
oc describe <resource> <name> -n incident-board
oc get <resource> -o yaml -n incident-board

# Follow logs in real-time
oc logs -f deployment/<name> -n incident-board

# Execute commands in pod
oc exec <pod> -n incident-board -- <command>

# Port forward for local testing
oc port-forward service/<service> <local-port>:<remote-port> -n incident-board

# Watch resource status
oc get pods -n incident-board -w
```

---

**For more help**: Check the [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) or consult the [OpenShift Documentation](https://docs.openshift.com/).
