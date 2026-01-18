# OpenShift Deployment - DevOps Incident Board

This directory contains all necessary files for deploying the DevOps Incident Board microservices to OpenShift (Kubernetes-based container orchestration platform).

## 📋 Quick Start

```bash
# 1. Connect to your OpenShift cluster
oc login --server=<your-server> -u <username> -p <password>

# 2. Deploy using the automated script
cd openshift/
chmod +x deploy.sh
./deploy.sh

# 3. Get your frontend URL
oc get route frontend -n incident-board -o jsonpath='{.spec.host}'
```

Open the URL in your browser to access the application.

## 📁 Files Overview

### Manifest Files (YAML)

| File | Purpose | Components |
|------|---------|------------|
| `00-namespace.yaml` | Namespace and shared configuration | Namespace, ConfigMap |
| `01-secrets.yaml` | Sensitive data (credentials, tokens) | Secrets |
| `02-postgresql.yaml` | Database deployment | PVC, StatefulSet, Service |
| `03-api.yaml` | Backend API deployment | Deployment, Service |
| `04-frontend.yaml` | Frontend web server deployment | Deployment, Service, Route |
| `05-frontend-config.yaml` | Frontend configuration | Nginx ConfigMap, HTML ConfigMap |

### Documentation Files

| File | Purpose |
|------|---------|
| `README.md` | This file - overview and quick start |
| `DEPLOYMENT_GUIDE.md` | Detailed step-by-step deployment instructions |
| `VERIFICATION_CHECKLIST.md` | Comprehensive checklist to verify deployment |
| `TROUBLESHOOTING.md` | Common issues and solutions |
| `deploy.sh` | Automated deployment bash script |

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    OpenShift Cluster                             │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │        incident-board Namespace                             │ │
│  │                                                               │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │ │
│  │  │  Frontend    │  │   Backend    │  │ PostgreSQL   │      │ │
│  │  │ Deployment   │  │ Deployment   │  │ StatefulSet  │      │ │
│  │  │ (2 replicas) │  │ (2 replicas) │  │ (1 replica)  │      │ │
│  │  └──────────────┘  └──────────────┘  └──────────────┘      │ │
│  │         ↓                 ↓                ↓                  │ │
│  │    ClusterIP:8080   ClusterIP:8080   ClusterIP:5432         │ │
│  │    (2 endpoints)    (2 endpoints)     (1 endpoint)          │ │
│  │                                                               │ │
│  │  ┌──────────────────────────────────────────────────────────┐│ │
│  │  │            OpenShift Route (TLS Edge)                    ││ │
│  │  │  https://incident-board.apps.example.com                ││ │
│  │  │           ↓                                               ││ │
│  │  │  frontend ClusterIP:8080 (Load Balanced)                ││ │
│  │  └──────────────────────────────────────────────────────────┘│ │
│  └─────────────────────────────────────────────────────────────┘ │
│                                                                    │
│  Service Discovery (DNS):                                         │
│  • api.incident-board.svc.cluster.local:8080                     │
│  • postgresql.incident-board.svc.cluster.local:5432              │
│  • frontend.incident-board.svc.cluster.local:8080                │
│                                                                    │
└─────────────────────────────────────────────────────────────────┘

External User
    ↓
https://incident-board.apps.example.com
    ↓
OpenShift Route + TLS Edge Termination
    ↓
Frontend Deployment (2 pods, Load Balanced)
    ↓
Internal: frontend:8080 → Nginx proxies /api/* to api:8080
    ↓
Backend API (2 pods, Load Balanced)
    ↓
PostgreSQL Connection Pool → postgresql:5432
    ↓
PostgreSQL Database (persistent storage)
```

## 🚀 Deployment Steps

### Prerequisites
1. Access to an OpenShift cluster
2. OpenShift CLI (`oc`) installed and configured
3. Backend API Docker image built and pushed to a container registry
4. Docker images available:
   - Backend API: `your-registry/incident-board-api:latest`
   - Frontend: `nginxinc/nginx-unprivileged:1.24-alpine` (public)
   - Database: `postgres:15-alpine` (public)

### Automated Deployment (Recommended)
```bash
./deploy.sh
```

### Manual Deployment
See [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) for detailed step-by-step instructions.

## ✅ Verification

After deployment, verify everything is working:

```bash
# Check all pods running
oc get pods -n incident-board

# Check services
oc get services -n incident-board

# Get frontend URL
oc get routes -n incident-board

# Test API health
oc port-forward service/api 8080:8080 -n incident-board &
curl http://localhost:8080/api/incidents/health
```

Complete checklist: See [VERIFICATION_CHECKLIST.md](./VERIFICATION_CHECKLIST.md)

## 🔧 Configuration

### Key Configuration Items

1. **Database Credentials** (`01-secrets.yaml`)
   - `DB_PASSWORD`: PostgreSQL password
   - Encoded in base64 within the secret

2. **Environment Variables** (`03-api.yaml`)
   - `SPRING_DATASOURCE_URL`: Points to PostgreSQL service DNS
   - `SPRING_PROFILES_ACTIVE`: Spring profiles to activate

3. **Nginx Configuration** (`05-frontend-config.yaml`)
   - Proxy rules for `/api/*` requests to backend
   - SPA routing (fallback to index.html)
   - Security headers
   - Caching policies

4. **Resource Limits**
   - PostgreSQL: 256Mi memory request, 512Mi limit
   - Backend API: 512Mi memory request, 1Gi limit
   - Frontend: 128Mi memory request, 256Mi limit

### Customization

To customize the deployment:

1. Edit the manifest files (YAML)
2. Update resource limits, replicas, image names, etc.
3. Reapply: `oc apply -f <file>`

For example, to scale API to 3 replicas:
```bash
oc scale deployment/api --replicas=3 -n incident-board
```

## 📊 Monitoring

### View Logs
```bash
# Real-time backend logs
oc logs -f deployment/api -n incident-board

# Database logs
oc logs statefulset/postgresql -n incident-board

# Frontend logs
oc logs deployment/frontend -n incident-board
```

### View Resource Usage
```bash
# CPU and memory usage
oc top pods -n incident-board

# Per-node usage
oc top nodes
```

### Watch Deployments
```bash
# Real-time pod status
oc get pods -n incident-board -w
```

## 🐛 Troubleshooting

For issues, see [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)

Quick diagnostics:
```bash
# Overall status
oc status -n incident-board

# All resources
oc get all,pvc,secrets,configmaps -n incident-board

# Detailed pod info
oc describe pod <pod-name> -n incident-board

# Pod logs
oc logs <pod-name> -n incident-board
```

## 🗑️ Cleanup

### Delete Specific Components
```bash
# Delete frontend only
oc delete deployment frontend -n incident-board

# Delete API only
oc delete deployment api -n incident-board

# Delete database
oc delete statefulset postgresql -n incident-board
oc delete pvc postgresql-pvc -n incident-board
```

### Delete Everything
```bash
# WARNING: This deletes the entire namespace and all data!
oc delete namespace incident-board
```

## 📈 Scaling

### Scale Deployments
```bash
# Scale API to 5 replicas
oc scale deployment/api --replicas=5 -n incident-board

# Scale frontend to 4 replicas
oc scale deployment/frontend --replicas=4 -n incident-board

# View scaled deployments
oc get pods -n incident-board
```

### Auto-scaling (Optional)
```bash
# Create horizontal pod autoscaler
oc autoscale deployment/api --min=2 --max=10 --cpu-percent=80 -n incident-board

# View HPA status
oc get hpa -n incident-board
```

## 🔐 Security Notes

### Security Features Implemented
- ✅ Non-root containers (runAsNonRoot: true)
- ✅ Resource limits to prevent DoS
- ✅ Health probes for pod lifecycle management
- ✅ Secrets for sensitive data (not in ConfigMaps)
- ✅ Internal ClusterIP services (not exposed)
- ✅ External access only via TLS-terminated Route

### Security Best Practices
1. **Secrets Management**
   - Never commit secrets to version control
   - Use sealed-secrets or external-secrets for production
   - Rotate credentials regularly

2. **Image Security**
   - Use specific image tags (not `latest`)
   - Scan images for vulnerabilities
   - Use minimal base images (Alpine, UBI)

3. **Network Security**
   - Implement network policies to restrict traffic
   - Use service mesh (Istio) for advanced policies
   - Enable TLS for inter-service communication

4. **Access Control**
   - Use OpenShift RBAC for namespace access
   - Implement pod security policies
   - Audit all access and changes

## 📝 Useful Commands Reference

```bash
# Connection
oc login --server=<server> -u <user> -p <password>
oc project incident-board

# Resources
oc get all -n incident-board
oc get pods,svc,routes,pvc -n incident-board
oc describe <resource> <name> -n incident-board

# Logs
oc logs <pod> -n incident-board
oc logs -f deployment/<name> -n incident-board
oc logs <pod> --previous -n incident-board

# Execution
oc exec <pod> -- <command> -n incident-board
oc port-forward <resource> <local>:<remote> -n incident-board
oc rsh <pod> -n incident-board  # Interactive shell

# Debugging
oc describe pod <pod> -n incident-board
oc get events -n incident-board
oc status -n incident-board

# Management
oc scale deployment/<name> --replicas=<n> -n incident-board
oc rollout restart deployment/<name> -n incident-board
oc rollout status deployment/<name> -n incident-board
oc rollout history deployment/<name> -n incident-board
oc rollout undo deployment/<name> -n incident-board

# Clean up
oc delete pod,deployment,service --all -n incident-board
oc delete namespace incident-board
```

## 📚 Additional Resources

- [OpenShift Documentation](https://docs.openshift.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Container Best Practices](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/security_guide/sec-working_with_containers)
- [Deployment Guide](./DEPLOYMENT_GUIDE.md)
- [Verification Checklist](./VERIFICATION_CHECKLIST.md)
- [Troubleshooting Guide](./TROUBLESHOOTING.md)

## 📞 Support

For issues or questions:
1. Check the [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) guide
2. Review the [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)
3. Check cluster events: `oc get events -n incident-board`
4. Review pod logs: `oc logs <pod> -n incident-board`
5. Contact your OpenShift cluster administrator

---

**Last Updated**: 2024
**Maintained by**: DevOps Team
**Contact**: fhalyosser@tbs.u-tunis.tn
**LinkedIn**: https://www.linkedin.com/in/yosser-fhal-3a57411b4/
