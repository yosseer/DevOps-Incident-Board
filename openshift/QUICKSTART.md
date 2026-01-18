# Quick Start Card - OpenShift Deployment

## 🚀 60-Second Setup

### Step 1: Login
```powershell
oc login --server=https://your-openshift-server --username=your-user --password=your-password
```

### Step 2: Deploy
```powershell
cd openshift
.\deploy.ps1
```

### Step 3: Access
```powershell
oc get routes -n incident-board
# Copy URL and open in browser: https://...
```

---

## 📋 One-Pager Verification

```powershell
# 1. All pods running?
oc get pods -n incident-board
# Expected: 1 postgresql-0 + 2 api-* + 2 frontend-* = 5 pods (all Running)

# 2. Services exist?
oc get services -n incident-board
# Expected: api, frontend, postgresql

# 3. API responding?
oc port-forward service/api 8080:8080 -n incident-board &
Invoke-WebRequest http://localhost:8080/api/incidents/health
# Expected: 200 OK with status=UP

# 4. Frontend accessible?
oc get route frontend -n incident-board
# Open the URL in browser - should load dashboard
```

---

## 🔧 Essential Commands

| Task | Command |
|------|---------|
| **View pods** | `oc get pods -n incident-board` |
| **View logs** | `oc logs -f deployment/api -n incident-board` |
| **Pod status** | `oc describe pod <pod-name> -n incident-board` |
| **Scale API** | `oc scale deployment/api --replicas=3 -n incident-board` |
| **Restart API** | `oc rollout restart deployment/api -n incident-board` |
| **Port forward** | `oc port-forward service/api 8080:8080 -n incident-board` |
| **Get URL** | `oc get routes -n incident-board` |
| **Delete all** | `oc delete namespace incident-board` |

---

## ⚠️ Troubleshooting (First Steps)

| Issue | Try This |
|-------|----------|
| Pod not starting | `oc describe pod <pod-name> -n incident-board` |
| Check logs | `oc logs <pod-name> -n incident-board` |
| API not responding | `oc get pods -n incident-board -l app=api` |
| Cannot reach frontend | `oc get endpoints/frontend -n incident-board` |
| Database error | `oc logs statefulset/postgresql -n incident-board` |

---

## 📖 Documentation Map

| Need | Document |
|------|----------|
| Getting started | [README.md](./README.md) |
| Detailed setup | [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) |
| Windows setup | [WINDOWS_GUIDE.md](./WINDOWS_GUIDE.md) |
| After deploy | [VERIFICATION_CHECKLIST.md](./VERIFICATION_CHECKLIST.md) |
| Problem solving | [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) |
| Quick reference | [SUMMARY.md](./SUMMARY.md) |
| Full index | [INDEX.md](./INDEX.md) |

---

## 🎯 What Gets Deployed

```
Frontend (Public)     → https://incident-board.apps.example.com
   ↓ (proxies)
API (Internal)        → api.incident-board.svc.cluster.local:8080
   ↓
Database (Internal)   → postgresql.incident-board.svc.cluster.local:5432
```

**Replicas:** 2 API + 2 Frontend + 1 PostgreSQL = 5 pods total

---

## 📊 File Sizes & Readability

- **YAML Manifests**: 16 files (~500 lines total) - Auto-generated, don't edit
- **Scripts**: 2 files (~150 lines) - Auto-deploy, can customize
- **Documentation**: 7 files (~2000 lines) - Reference, start with README

---

## ✅ Pre-Deployment Checklist

- [ ] OpenShift cluster access (run `oc whoami`)
- [ ] OpenShift CLI installed (run `oc version`)
- [ ] Backend API image built and pushed to registry
- [ ] In `openshift/` directory
- [ ] All YAML files present (00-05)

---

## 🚨 Emergency Commands

```powershell
# Restart everything
oc delete pods --all -n incident-board

# Restart one service
oc rollout restart deployment/api -n incident-board

# See what broke
oc get events -n incident-board --sort-by='.lastTimestamp'

# Rollback update
oc rollout undo deployment/api -n incident-board

# Emergency delete all
oc delete namespace incident-board
```

---

## 📞 When Stuck

1. **Check status**: `oc status -n incident-board`
2. **View logs**: `oc logs <pod-name> -n incident-board`
3. **Read troubleshooting**: [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
4. **Contact**: fhalyosser@tbs.u-tunis.tn

---

## 💡 Pro Tips

```powershell
# Create alias for quick access
function cd-incident { cd openshift }

# Watch pods in real-time
oc get pods -n incident-board -w

# Follow logs live
oc logs -f deployment/api -n incident-board

# Test from outside cluster
oc port-forward service/api 8080:8080 -n incident-board &

# Copy command to clipboard (Windows)
$url = oc get route frontend -n incident-board -o jsonpath='{.spec.host}'
$url | Set-Clipboard
```

---

## 📈 Typical Deployment Timeline

- **00:00-00:30** → Login + start deploy
- **00:30-01:00** → PostgreSQL initializing
- **01:00-01:30** → API starting (waiting for DB)
- **01:30-02:00** → Frontend starting
- **02:00+** → Application ready for testing

Total: **~3-5 minutes** for first deployment

---

## 🎓 Key Concepts

| Term | Meaning |
|------|---------|
| **Pod** | Single container instance |
| **Deployment** | Manages multiple pod replicas |
| **StatefulSet** | Deployment with persistent storage (database) |
| **Service** | Internal DNS and load balancing |
| **Route** | External access point (OpenShift) |
| **PVC** | Persistent volume for data storage |
| **ConfigMap** | Configuration data (non-secret) |
| **Secret** | Sensitive data (passwords, tokens) |

---

## 🔐 Security Defaults

✅ Containers run as non-root  
✅ Resource limits enforced  
✅ No exposed secrets  
✅ TLS on external route  
✅ Health probes configured  

---

## 📝 File Manifest

```
openshift/
├── 00-namespace.yaml       ← Namespace + ConfigMap
├── 01-secrets.yaml          ← DB password, JWT token
├── 02-postgresql.yaml       ← Database with 10Gi storage
├── 03-api.yaml              ← Backend (2 replicas)
├── 04-frontend.yaml         ← Frontend + Route (2 replicas)
├── 05-frontend-config.yaml  ← Nginx config + HTML
├── deploy.sh                ← Bash script (Linux/Mac)
├── deploy.ps1               ← PowerShell script (Windows)
├── README.md                ← Overview
├── DEPLOYMENT_GUIDE.md      ← Full guide
├── VERIFICATION_CHECKLIST.md ← After-deploy checklist
├── TROUBLESHOOTING.md       ← Problem solver
├── WINDOWS_GUIDE.md         ← Windows instructions
├── SUMMARY.md               ← Quick reference
├── INDEX.md                 ← Documentation index
└── QUICKSTART.md            ← This file!
```

---

## 🎯 Success Criteria

✅ All 5 pods showing `Running` status  
✅ 3 services with endpoints  
✅ Frontend route has hostname  
✅ API health check returns 200 OK  
✅ Frontend loads without errors  
✅ Can create/view incidents  

---

**Ready? Run: `.\deploy.ps1`**

**Questions? See: [INDEX.md](./INDEX.md)**

**Problems? See: [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)**

---

*Last Updated: 2024*  
*Contact: fhalyosser@tbs.u-tunis.tn*
