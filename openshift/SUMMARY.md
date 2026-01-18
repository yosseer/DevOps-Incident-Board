# OpenShift Deployment - Summary & Quick Reference

## 📦 What's Deployed

Your DevOps Incident Board will be deployed to OpenShift with:

```
3-Tier Architecture:
├── Frontend Layer (Public)
│   ├── 2 Nginx pods with incident-board UI
│   ├── Load balanced via Kubernetes Service
│   └── Exposed via OpenShift Route (HTTPS)
│
├── Application Layer (Internal)
│   ├── 2 Spring Boot API pods
│   ├── Load balanced via Kubernetes Service
│   └── Internal DNS: api.incident-board.svc.cluster.local:8080
│
└── Data Layer (Internal)
    ├── 1 PostgreSQL StatefulSet pod
    ├── 10Gi persistent volume for data
    └── Internal DNS: postgresql.incident-board.svc.cluster.local:5432
```

## 🚀 Quick Deployment

### For Windows Users
```powershell
cd "C:\Users\fhaal\OneDrive - Ministere...\Cloud_Project\openshift"

# Option 1: Run PowerShell script
.\deploy.ps1

# Option 2: Run bash script (if Git Bash or WSL is installed)
bash deploy.sh

# Option 3: Manual commands
oc apply -f 00-namespace.yaml
oc apply -f 01-secrets.yaml
oc apply -f 02-postgresql.yaml
oc apply -f 03-api.yaml
oc apply -f 04-frontend.yaml
oc apply -f 05-frontend-config.yaml
```

### For Linux/Mac Users
```bash
cd ./openshift
chmod +x deploy.sh
./deploy.sh
```

## 📋 Files Overview

| File | Size | Purpose |
|------|------|---------|
| `00-namespace.yaml` | ~300 lines | Namespace + ConfigMap setup |
| `01-secrets.yaml` | ~20 lines | Database credentials & app secrets |
| `02-postgresql.yaml` | ~80 lines | Database deployment with persistent storage |
| `03-api.yaml` | ~100 lines | Backend API with 2 replicas |
| `04-frontend.yaml` | ~60 lines | Frontend with Route for external access |
| `05-frontend-config.yaml` | ~150 lines | Nginx config + HTML content ConfigMaps |
| **DEPLOYMENT_GUIDE.md** | ~400 lines | Detailed step-by-step instructions |
| **VERIFICATION_CHECKLIST.md** | ~350 lines | Post-deployment verification |
| **TROUBLESHOOTING.md** | ~450 lines | Issue diagnosis and solutions |
| **WINDOWS_GUIDE.md** | ~300 lines | Windows-specific instructions |
| **deploy.sh** | ~80 lines | Automated bash deployment script |
| **deploy.ps1** | ~120 lines | Automated PowerShell deployment script |

## ✅ Post-Deployment Verification

```bash
# 1. Check all pods running
oc get pods -n incident-board
# Expected: 1 postgresql-0, 2 api-xxxx, 2 frontend-xxxx (all Running)

# 2. Check services
oc get services -n incident-board
# Expected: api, frontend, postgresql (all with ClusterIP)

# 3. Check routes
oc get routes -n incident-board
# Expected: frontend route with hostname

# 4. Test API health
oc port-forward service/api 8080:8080 -n incident-board &
curl http://localhost:8080/api/incidents/health
# Expected: {"status":"UP",...}

# 5. Open frontend
# Get URL: oc get route frontend -n incident-board -o jsonpath='{.spec.host}'
# Open in browser: https://<url>
```

See [VERIFICATION_CHECKLIST.md](./VERIFICATION_CHECKLIST.md) for complete checklist.

## 🔧 Common Tasks

### View Logs
```bash
# Backend API
oc logs -f deployment/api -n incident-board

# Database
oc logs statefulset/postgresql -n incident-board

# Frontend
oc logs deployment/frontend -n incident-board

# Specific pod
oc logs <pod-name> -n incident-board
```

### Monitor Resources
```bash
# CPU and memory usage
oc top pods -n incident-board

# Real-time pod status
oc get pods -n incident-board -w
```

### Scale Services
```bash
# Scale API to 5 replicas
oc scale deployment/api --replicas=5 -n incident-board

# Scale frontend to 3 replicas
oc scale deployment/frontend --replicas=3 -n incident-board
```

### Update Configuration
```bash
# Edit manifest
oc edit deployment/api -n incident-board

# Or reapply with changes
# Edit the file, then:
oc apply -f 03-api.yaml

# Monitor the update
oc rollout status deployment/api -n incident-board
```

### Restart Services
```bash
# Restart API
oc rollout restart deployment/api -n incident-board

# Restart frontend
oc rollout restart deployment/frontend -n incident-board

# Restart database
oc delete pod postgresql-0 -n incident-board  # Will be recreated
```

### Port Forward for Local Testing
```bash
# API
oc port-forward service/api 8080:8080 -n incident-board &

# Frontend
oc port-forward service/frontend 8080:8080 -n incident-board &

# Database (from local machine)
oc port-forward service/postgresql 5432:5432 -n incident-board &
```

## 🐛 Quick Troubleshooting

| Issue | Command | Solution |
|-------|---------|----------|
| Pod not starting | `oc describe pod <pod>` | Check events for error |
| Pod restarting | `oc logs <pod> --previous` | Check logs for crash reason |
| Cannot reach API | `oc get endpoints/api` | Check service has endpoints |
| Frontend shows 502 | `oc logs deployment/frontend` | Check Nginx config and API connectivity |
| Database connection error | `oc logs deployment/api` | Verify PostgreSQL is running and initialized |

See [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) for detailed troubleshooting.

## 📊 Architecture Details

### Service Discovery
- **Frontend**: `frontend.incident-board.svc.cluster.local:8080` (internal)
- **API**: `api.incident-board.svc.cluster.local:8080` (internal)
- **Database**: `postgresql.incident-board.svc.cluster.local:5432` (internal)
- **External**: `https://incident-board.apps.example.com` (frontend only, via Route)

### Resource Limits
- **API**: 512Mi memory request, 1Gi max; 250m CPU request, 500m max
- **Frontend**: 128Mi memory request, 256Mi max; 100m CPU request, 200m max
- **PostgreSQL**: 256Mi memory request, 512Mi max; 250m CPU request, 500m max

### Health Checks
- **API**: HTTP GET `/api/incidents/health` - Liveness 60s, Readiness 30s
- **Frontend**: HTTP GET `/health` - Liveness 10s, Readiness 5s
- **PostgreSQL**: `pg_isready` - Liveness 30s, Readiness 10s

## 🔐 Security Features

✅ Non-root containers  
✅ Resource limits (CPU & memory)  
✅ Read-only root filesystem where possible  
✅ Secrets for sensitive data (not ConfigMaps)  
✅ Internal services not exposed  
✅ TLS termination on Route  
✅ Health probes for crash recovery  
✅ Dropped capabilities  

## 📈 Performance Expectations

- **Deployment time**: 3-5 minutes (first time)
- **Pod startup time**: ~30 seconds (PostgreSQL), ~20 seconds (API), ~10 seconds (Frontend)
- **API response time**: <100ms (healthy database)
- **Frontend load time**: <2 seconds

## 🗑️ Cleanup

```bash
# Delete entire deployment (WARNING: data loss!)
oc delete namespace incident-board

# Or delete specific components
oc delete deployment/api -n incident-board
oc delete deployment/frontend -n incident-board
oc delete statefulset/postgresql -n incident-board

# Verify deletion
oc get all,pvc,secrets,configmaps -n incident-board
```

## 📞 Documentation Files

1. **README.md** - Overview and getting started
2. **DEPLOYMENT_GUIDE.md** - Detailed deployment instructions
3. **VERIFICATION_CHECKLIST.md** - Post-deployment verification
4. **TROUBLESHOOTING.md** - Issue diagnosis and solutions
5. **WINDOWS_GUIDE.md** - Windows-specific instructions

## 🎯 Next Steps After Deployment

1. ✅ Run verification checklist
2. ✅ Monitor logs and resource usage
3. ✅ Test API endpoints
4. ✅ Configure auto-scaling (optional)
5. ✅ Set up monitoring and alerts (production)
6. ✅ Implement CI/CD pipeline (GitOps)

## 🔄 Update & Rollback

### Update Application
```bash
# Edit manifest file and save changes
oc apply -f 03-api.yaml

# Or trigger new rollout
oc rollout restart deployment/api -n incident-board
```

### Rollback to Previous Version
```bash
oc rollout undo deployment/api -n incident-board
oc rollout status deployment/api -n incident-board
```

## 📊 Monitoring Commands

```bash
# Overall status
oc status -n incident-board

# All resources
oc get all,pvc,secrets,configmaps -n incident-board

# Events
oc get events -n incident-board --sort-by='.lastTimestamp'

# Resource usage
oc top pods -n incident-board
oc top nodes

# Watch for changes
oc get pods -n incident-board -w
```

## 🚨 Support Resources

- **Documentation**: See DEPLOYMENT_GUIDE.md, VERIFICATION_CHECKLIST.md, TROUBLESHOOTING.md
- **Logs**: `oc logs <pod> -n incident-board`
- **Debugging**: `oc describe pod <pod>` -n incident-board`
- **Status**: `oc status -n incident-board`
- **Contact**: fhalyosser@tbs.u-tunis.tn
- **LinkedIn**: https://www.linkedin.com/in/yosser-fhal-3a57411b4/

## ℹ️ Important Notes

### Database Persistence
- PostgreSQL uses a 10Gi PersistentVolumeClaim
- Data survives pod restarts/crashes
- To reset: Delete PVC and recreate pod

### Networking
- All inter-service communication uses DNS names
- External access only via frontend Route
- API and Database are not exposed externally

### Resource Management
- Pods have memory and CPU limits to prevent runaway consumption
- Kubernetes may evict pods if cluster resources are low
- Monitor resource usage: `oc top pods`

### High Availability
- 2 replicas for API and Frontend for load balancing
- Single PostgreSQL instance (for HA, use PostgreSQL replication)
- Deployment disruption budgets can prevent too many simultaneous pod evictions

## 📝 File Structure

```
openshift/
├── 00-namespace.yaml          # Namespace + ConfigMap
├── 01-secrets.yaml            # Credentials
├── 02-postgresql.yaml         # Database (StatefulSet)
├── 03-api.yaml                # Backend (Deployment)
├── 04-frontend.yaml           # Frontend (Deployment + Route)
├── 05-frontend-config.yaml    # Nginx config + HTML
├── deploy.sh                  # Automated bash deployment
├── deploy.ps1                 # Automated PowerShell deployment
├── README.md                  # Overview
├── DEPLOYMENT_GUIDE.md        # Detailed instructions
├── VERIFICATION_CHECKLIST.md  # Post-deployment verification
├── TROUBLESHOOTING.md         # Issue resolution
└── WINDOWS_GUIDE.md           # Windows-specific guidance
```

## 🎓 Learning Resources

- [OpenShift Documentation](https://docs.openshift.com/)
- [Kubernetes Concepts](https://kubernetes.io/docs/concepts/)
- [Container Best Practices](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/security_guide/sec-working_with_containers)
- [Deploying to OpenShift](https://www.redhat.com/en/resources/openshift-deployment-guide)

---

**Status**: Ready for deployment  
**Last Updated**: 2024  
**Version**: 1.0  
**Platform**: OpenShift / Kubernetes  
**Contact**: fhalyosser@tbs.u-tunis.tn
