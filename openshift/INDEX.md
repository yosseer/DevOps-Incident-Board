# OpenShift Deployment Documentation Index

## 📖 Start Here

**If you're new to this deployment, start with:**
1. [README.md](./README.md) - Overview and quick start
2. [SUMMARY.md](./SUMMARY.md) - Quick reference guide

## 🚀 Deployment Guide

### Choose Your Path:

**Windows Users:**
- [WINDOWS_GUIDE.md](./WINDOWS_GUIDE.md) - Complete Windows setup and deployment instructions

**Linux/Mac Users:**
- [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) - Step-by-step deployment (use `deploy.sh`)

**Anyone:**
- [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) - Full manual deployment guide

## ✅ After Deployment

- [VERIFICATION_CHECKLIST.md](./VERIFICATION_CHECKLIST.md) - Verify everything is working
- [SUMMARY.md](./SUMMARY.md) - Quick reference for common tasks

## 🐛 Troubleshooting

- [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) - Issue diagnosis and solutions
- [SUMMARY.md](./SUMMARY.md) - Quick troubleshooting table

## 📁 Files Reference

### YAML Manifests (Apply in Order)

| # | File | Lines | Purpose | Apply After |
|---|------|-------|---------|------------|
| 1 | `00-namespace.yaml` | ~30 | Create namespace & ConfigMap | (first) |
| 2 | `01-secrets.yaml` | ~20 | Create secrets for credentials | Namespace ready |
| 3 | `02-postgresql.yaml` | ~80 | Deploy PostgreSQL database | Secrets ready |
| 4 | `03-api.yaml` | ~100 | Deploy backend API | PostgreSQL running |
| 5 | `04-frontend.yaml` | ~60 | Deploy frontend web server | API running |
| 6 | `05-frontend-config.yaml` | ~150 | Deploy Nginx config & HTML | Frontend running |

### Deployment Scripts

| Script | OS | Purpose | Method |
|--------|----|---------| --------|
| `deploy.sh` | Linux/Mac/Git Bash/WSL | Automated deployment | `bash deploy.sh` |
| `deploy.ps1` | Windows PowerShell | Automated deployment | `.\deploy.ps1` |
| Manual | All | Step-by-step deployment | `oc apply -f <file>` |

### Documentation

| File | Purpose | Read Time |
|------|---------|-----------|
| README.md | Overview and quick start | 10 min |
| SUMMARY.md | Quick reference and common tasks | 5 min |
| DEPLOYMENT_GUIDE.md | Detailed deployment instructions | 20 min |
| VERIFICATION_CHECKLIST.md | Post-deployment verification | 15 min |
| TROUBLESHOOTING.md | Issue diagnosis and solutions | 20 min |
| WINDOWS_GUIDE.md | Windows-specific setup and tips | 15 min |

## 🎯 Quick Navigation

### I want to...

**Deploy the application:**
- Windows → [WINDOWS_GUIDE.md#deployment-from-windows](./WINDOWS_GUIDE.md#deployment-from-windows)
- Linux/Mac → [DEPLOYMENT_GUIDE.md#option-2-manual-deployment](./DEPLOYMENT_GUIDE.md#option-2-manual-deployment)
- Automated → Run `deploy.sh` or `deploy.ps1`

**Verify deployment worked:**
- Go to [VERIFICATION_CHECKLIST.md](./VERIFICATION_CHECKLIST.md)

**Check pod status:**
- Command: `oc get pods -n incident-board`
- Details: [SUMMARY.md#monitoring-commands](./SUMMARY.md#monitoring-commands)

**View logs:**
- Command: `oc logs -f deployment/api -n incident-board`
- Details: [SUMMARY.md#view-logs](./SUMMARY.md#view-logs)

**Fix a problem:**
- Go to [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)

**Scale the application:**
- Command: `oc scale deployment/api --replicas=5 -n incident-board`
- Details: [SUMMARY.md#scale-services](./SUMMARY.md#scale-services)

**Access the application:**
- Command: `oc get routes -n incident-board`
- Details: [SUMMARY.md#quick-deployment](./SUMMARY.md#quick-deployment)

**Learn more about:**
- Architecture → [README.md#architecture](./README.md#-architecture)
- Security → [README.md#security-notes](./README.md#-security-notes)
- Commands → [SUMMARY.md#monitoring-commands](./SUMMARY.md#monitoring-commands)

## 📊 Deployment Checklist

- [ ] **Prerequisites**
  - [ ] OpenShift cluster access
  - [ ] `oc` CLI installed
  - [ ] Backend API image built and pushed
  - [ ] Docker images available

- [ ] **Deploy**
  - [ ] Run `deploy.sh` or `deploy.ps1`
  - [ ] Wait for all pods to reach `Running` state
  - [ ] Verify all services created
  - [ ] Verify frontend route created

- [ ] **Verify** (see [VERIFICATION_CHECKLIST.md](./VERIFICATION_CHECKLIST.md))
  - [ ] All pods running
  - [ ] All services created
  - [ ] Route working
  - [ ] Database responding
  - [ ] API responding
  - [ ] Frontend loading
  - [ ] E2E test passing

- [ ] **Customize** (if needed)
  - [ ] Update image names in manifests
  - [ ] Update resource limits
  - [ ] Update replica counts
  - [ ] Update security settings

- [ ] **Monitor**
  - [ ] Set up log monitoring
  - [ ] Set up resource monitoring
  - [ ] Configure alerts

## 🔗 Command Quick Reference

```bash
# Connection
oc login --server=<server> -u <user> -p <password>
oc project incident-board

# Deployment
oc apply -f 00-namespace.yaml
oc apply -f 01-secrets.yaml
# ... etc

# Status
oc get pods -n incident-board
oc get services -n incident-board
oc get routes -n incident-board
oc status -n incident-board

# Logs
oc logs -f deployment/api -n incident-board
oc logs -f statefulset/postgresql -n incident-board
oc logs -f deployment/frontend -n incident-board

# Debugging
oc describe pod <pod-name> -n incident-board
oc get events -n incident-board
oc port-forward service/api 8080:8080 -n incident-board

# Management
oc scale deployment/api --replicas=3 -n incident-board
oc rollout restart deployment/api -n incident-board
oc rollout undo deployment/api -n incident-board

# Cleanup
oc delete namespace incident-board  # WARNING: Deletes everything!
```

## 📚 Related Documentation

### External Resources
- [OpenShift Documentation](https://docs.openshift.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Red Hat Container Best Practices](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/security_guide/sec-working_with_containers)

### Project Files
- Parent README: [../README.md](../README.md)
- Backend Project: [../beeper-backend/](../beeper-backend/)
- Frontend Project: [../beeper-ui/](../beeper-ui/)
- Main Deployment Guide: [../DEPLOYMENT_GUIDE.md](../DEPLOYMENT_GUIDE.md)

## 📞 Support & Contact

**Issues?**
1. Check [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
2. Review cluster status: `oc status -n incident-board`
3. Check pod logs: `oc logs <pod> -n incident-board`

**Contact:**
- Email: fhalyosser@tbs.u-tunis.tn
- LinkedIn: https://www.linkedin.com/in/yosser-fhal-3a57411b4/

## 🗂️ Directory Structure

```
openshift/
├── YAML Manifests
│   ├── 00-namespace.yaml              # Namespace + ConfigMap
│   ├── 01-secrets.yaml                # Secrets
│   ├── 02-postgresql.yaml             # Database
│   ├── 03-api.yaml                    # Backend API
│   ├── 04-frontend.yaml               # Frontend + Route
│   └── 05-frontend-config.yaml        # Nginx Config + HTML
│
├── Scripts
│   ├── deploy.sh                      # Bash deployment script
│   ├── deploy.ps1                     # PowerShell deployment script
│   └── INDEX.md                       # This file
│
└── Documentation
    ├── README.md                      # Overview
    ├── SUMMARY.md                     # Quick reference
    ├── DEPLOYMENT_GUIDE.md            # Detailed instructions
    ├── VERIFICATION_CHECKLIST.md      # Verification steps
    ├── TROUBLESHOOTING.md             # Troubleshooting guide
    └── WINDOWS_GUIDE.md               # Windows-specific guide
```

## 📋 Version Information

- **Project**: DevOps Incident Board
- **Deployment Platform**: OpenShift / Kubernetes
- **Created**: 2024
- **Documentation Version**: 1.0
- **Last Updated**: 2024

## 🎓 Learning Path

1. **Beginner** - New to OpenShift?
   - Start with [README.md](./README.md)
   - Then read [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)
   - Follow the deployment steps

2. **Intermediate** - Deployed successfully?
   - Check [VERIFICATION_CHECKLIST.md](./VERIFICATION_CHECKLIST.md)
   - Learn [SUMMARY.md](./SUMMARY.md) common tasks
   - Practice scaling and monitoring

3. **Advanced** - Comfortable with deployment?
   - Read [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
   - Set up monitoring and alerts
   - Implement CI/CD pipeline
   - Configure auto-scaling

## ✨ Key Features

✅ Automated deployment scripts  
✅ Comprehensive documentation  
✅ Verification checklist  
✅ Troubleshooting guide  
✅ Windows-specific instructions  
✅ Production-ready manifests  
✅ High availability setup  
✅ Security best practices  
✅ Resource optimization  
✅ Health monitoring  

## 🚀 Getting Started

**For Windows Users:**
```powershell
cd openshift
oc login --server=<your-server> -u <user> -p <password>
.\deploy.ps1
```

**For Linux/Mac Users:**
```bash
cd openshift
oc login --server=<your-server> -u <user> -p <password>
bash deploy.sh
```

**Then verify:**
```bash
oc get routes -n incident-board
# Open the URL in your browser
```

---

**Ready?** Start with [README.md](./README.md) or jump to [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)!

**Windows?** See [WINDOWS_GUIDE.md](./WINDOWS_GUIDE.md)

**Issues?** Check [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
