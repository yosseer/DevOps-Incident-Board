# DevOps Incident Board - OpenShift Deployment Guide

## 📋 Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Microservices Design](#microservices-design)
3. [Dockerfiles](#dockerfiles)
4. [OpenShift Manifests](#openshift-manifests)
5. [Deployment Instructions](#deployment-instructions)
6. [CI/CD Pipeline](#cicd-pipeline)
7. [Security Best Practices](#security-best-practices)
8. [Troubleshooting](#troubleshooting)

---

## 🏗️ Architecture Overview

### System Architecture on OpenShift

```
                                    ┌─────────────────────────────────────┐
                                    │         INTERNET / USERS            │
                                    └─────────────────┬───────────────────┘
                                                      │
                                                      │ HTTPS
                                                      ▼
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                              RED HAT OPENSHIFT CLUSTER                                   │
│  ┌───────────────────────────────────────────────────────────────────────────────────┐  │
│  │                            OPENSHIFT ROUTER (HAProxy)                              │  │
│  │                        Edge TLS Termination                                        │  │
│  └─────────────────────────────┬─────────────────────────┬───────────────────────────┘  │
│                                │                         │                               │
│                                │ Route                   │ Route                         │
│                                ▼                         ▼                               │
│  ┌──────────────────────────────────────┐  ┌──────────────────────────────────────┐     │
│  │         FRONTEND SERVICE             │  │         BACKEND SERVICE              │     │
│  │    incident-frontend:8080            │  │    incident-backend:8080             │     │
│  └─────────────────┬────────────────────┘  └─────────────────┬────────────────────┘     │
│                    │                                         │                           │
│                    │ ClusterIP                               │ ClusterIP                 │
│                    ▼                                         ▼                           │
│  ┌───────────────────────────────────────────────────────────────────────────────────┐  │
│  │                              POD NETWORK                                           │  │
│  │  ┌─────────────────────────────┐       ┌─────────────────────────────────────┐    │  │
│  │  │     FRONTEND POD (x2)       │       │         BACKEND POD (x1-3)          │    │  │
│  │  │  ┌───────────────────────┐  │       │  ┌─────────────────────────────┐    │    │  │
│  │  │  │   Nginx Container     │  │◀─────▶│  │  Spring Boot Container      │    │    │  │
│  │  │  │   (Non-root: 101)     │  │  API  │  │  (Non-root: 1001)           │    │    │  │
│  │  │  │   Port: 8080          │  │ Proxy │  │  Port: 8080                 │    │    │  │
│  │  │  │                       │  │       │  │                             │    │    │  │
│  │  │  │  Static Files:        │  │       │  │  REST API:                  │    │    │  │
│  │  │  │  • index.html         │  │       │  │  • GET /api/incidents       │    │    │  │
│  │  │  │  • incident-board.css │  │       │  │  • POST /api/incidents      │    │    │  │
│  │  │  │  • config.js          │  │       │  │  • PATCH /api/incidents/{id}│    │    │  │
│  │  │  └───────────────────────┘  │       │  │  • DELETE /api/incidents/{id}│   │    │  │
│  │  └─────────────────────────────┘       │  └─────────────────────────────┘    │    │  │
│  │                                        │                  │                   │    │  │
│  │                                        │                  │ JDBC              │    │  │
│  │                                        │                  ▼                   │    │  │
│  │                                        │  ┌─────────────────────────────┐    │    │  │
│  │                                        │  │    H2 Database (File)       │    │    │  │
│  │                                        │  │    /app/data/incidentboard  │    │    │  │
│  │                                        │  └──────────────┬──────────────┘    │    │  │
│  │                                        └─────────────────┼───────────────────┘    │  │
│  └──────────────────────────────────────────────────────────┼────────────────────────┘  │
│                                                             │                            │
│  ┌──────────────────────────────────────────────────────────┼────────────────────────┐  │
│  │                    PERSISTENT STORAGE                    │                         │  │
│  │  ┌───────────────────────────────────────────────────────▼───────────────────┐    │  │
│  │  │                    PersistentVolumeClaim: incident-db-pvc                  │    │  │
│  │  │                    Size: 1Gi | AccessMode: ReadWriteOnce                   │    │  │
│  │  └───────────────────────────────────────────────────────────────────────────┘    │  │
│  └───────────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                          │
│  ┌───────────────────────────────────────────────────────────────────────────────────┐  │
│  │                              CONFIGURATION                                         │  │
│  │  ConfigMaps:                    Secrets:                   HPA:                    │  │
│  │  • incident-backend-config      • incident-backend-secrets • backend-hpa (1-3)    │  │
│  │  • incident-frontend-config     • docker-registry-secret   • frontend-hpa (2-5)   │  │
│  └───────────────────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

### Data Flow

```
┌──────────┐    HTTPS    ┌──────────┐   Route    ┌──────────┐   Service   ┌──────────┐
│  User    │────────────▶│ OpenShift│───────────▶│  Nginx   │────────────▶│  Nginx   │
│ Browser  │             │  Router  │            │  Route   │             │   Pod    │
└──────────┘             └──────────┘            └──────────┘             └────┬─────┘
                                                                               │
                              ┌────────────────────────────────────────────────┘
                              │
                              │  /api/* proxy
                              ▼
┌──────────────────────────────────────────────────────────────────────────────────────┐
│                              Backend Service DNS                                      │
│              incident-backend.incident-board.svc.cluster.local:8080                  │
└──────────────────────────────────────────────────┬───────────────────────────────────┘
                                                   │
                                                   ▼
                                          ┌───────────────┐
                                          │ Spring Boot   │
                                          │    Pod        │
                                          │   (REST API)  │
                                          └───────┬───────┘
                                                  │
                                                  │ JPA/Hibernate
                                                  ▼
                                          ┌───────────────┐
                                          │  H2 Database  │
                                          │   (File PVC)  │
                                          └───────────────┘
```

---

## 🔧 Microservices Design

### Service Responsibilities

| Service | Responsibility | Technology | Port |
|---------|---------------|------------|------|
| **incident-frontend** | Dashboard UI, Charts, User interaction | Nginx + HTML/CSS/JS | 8080 |
| **incident-backend** | REST API, Business logic, Data persistence | Spring Boot + JPA | 8080 |

### incident-backend (Spring Boot REST API)

**Responsibilities:**
- RESTful API endpoints for incident CRUD operations
- Business logic for severity and status workflow
- Auto-deletion of resolved incidents (24 hours)
- Data persistence using JPA/Hibernate
- Health checks for Kubernetes probes
- H2 database management

**Key Components:**
```
com.redhat.training.beeper/
├── BeeperApplication.java     # Main Spring Boot application
├── Incident.java              # JPA Entity
├── IncidentController.java    # REST Controller
├── IncidentRepository.java    # JPA Repository
├── Severity.java              # Enum: CRITICAL, HIGH, MEDIUM, LOW
└── Status.java                # Enum: OPEN, INVESTIGATING, RESOLVED
```

### incident-frontend (Nginx Static Server)

**Responsibilities:**
- Serve static HTML/CSS/JavaScript files
- Proxy API requests to backend service
- Handle SSL termination from OpenShift router
- Runtime configuration injection via environment variables
- Health endpoint for Kubernetes probes

**Key Components:**
```
beeper-ui/
├── index.html              # Main dashboard (Chart.js, Fetch API)
├── incident-board.css      # Dark theme styles
├── nginx.conf              # Nginx configuration with API proxy
└── config.js               # Runtime API URL configuration
```

---

## 🐳 Dockerfiles

### Backend Dockerfile (Multi-stage Build)

```dockerfile
# Stage 1: Build with Maven
FROM maven:3.9.6-eclipse-temurin-21 AS builder
WORKDIR /app
COPY pom.xml settings.xml ./
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn clean package -DskipTests -B

# Stage 2: Runtime with JRE
FROM eclipse-temurin:21-jre-alpine
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup
WORKDIR /app
RUN mkdir -p /app/data && chown -R appuser:appgroup /app
COPY --from=builder --chown=appuser:appgroup /app/target/*.jar app.jar
USER 1001
EXPOSE 8080
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
```

**Key Features:**
- Multi-stage build reduces image size
- Non-root user (UID 1001) for OpenShift security
- JRE-only runtime (no JDK)
- Volume mount point at `/app/data`

### Frontend Dockerfile (Nginx)

```dockerfile
FROM nginx:1.25-alpine
RUN apk add --no-cache gettext
COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html incident-board.css /usr/share/nginx/html/
# OpenShift non-root configuration
RUN chown -R nginx:nginx /var/cache/nginx /var/log/nginx /usr/share/nginx/html && \
    chmod -R g+rwx /var/cache/nginx /var/run /var/log/nginx
USER 101
EXPOSE 8080
```

**Key Features:**
- Alpine-based for minimal size
- Non-privileged port 8080
- Runtime configuration via environment variables
- API proxy configuration

---

## 📦 OpenShift Manifests

### File Structure

```
openshift/
├── 00-namespace.yaml           # Namespace/Project definition
├── 01-configmaps.yaml          # Application configuration
├── 02-secrets.yaml             # Database & Docker credentials
├── 03-pvc.yaml                 # Persistent storage for H2
├── 04-backend-deployment.yaml  # Backend Deployment, Service, Route
├── 05-frontend-deployment.yaml # Frontend Deployment, Service, Route
├── 06-hpa.yaml                 # Horizontal Pod Autoscaler
├── 07-network-policies.yaml    # Network security policies
├── 08-pipeline.yaml            # Tekton CI/CD pipeline
├── deploy.sh                   # Bash deployment script
└── deploy.ps1                  # PowerShell deployment script
```

### Key Configurations

#### Probes Configuration

```yaml
# Liveness Probe - Is the container alive?
livenessProbe:
  httpGet:
    path: /actuator/health/liveness
    port: 8080
  initialDelaySeconds: 60
  periodSeconds: 10

# Readiness Probe - Is the container ready for traffic?
readinessProbe:
  httpGet:
    path: /actuator/health/readiness
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 5

# Startup Probe - Allow time for app to start
startupProbe:
  httpGet:
    path: /actuator/health
    port: 8080
  failureThreshold: 30
  periodSeconds: 10
```

#### Resource Limits

```yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "100m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

---

## 🚀 Deployment Instructions

### Prerequisites

1. **OpenShift CLI (oc)** installed
2. **Docker** installed and running
3. **Docker Hub** account (yosserfhal)

### Quick Deployment (Windows PowerShell)

```powershell
# Navigate to openshift directory
cd openshift

# Run deployment script
.\deploy.ps1

# Or use command line arguments
.\deploy.ps1 --full          # Build + Push + Deploy
.\deploy.ps1 --deploy-only   # Deploy existing images
.\deploy.ps1 --status        # Show deployment status
.\deploy.ps1 --cleanup       # Remove all resources
```

### Manual Deployment Steps

```powershell
# Step 1: Login to OpenShift
oc login --token=sha256~vFn-nGtaLtMqOIqNGrt6zkrWOWHLppEBmcLzYIrKybE --server=https://api.na46r.prod.ole.redhat.com:6443

# Step 2: Create project
oc new-project incident-board

# Step 3: Build and push images
cd beeper-backend
docker build -t yosserfhal/incident-backend:latest .
docker push yosserfhal/incident-backend:latest

cd ../beeper-ui
docker build -t yosserfhal/incident-frontend:latest .
docker push yosserfhal/incident-frontend:latest

# Step 4: Apply manifests
cd ../openshift
oc apply -f 01-configmaps.yaml
oc apply -f 02-secrets.yaml
oc apply -f 03-pvc.yaml
oc apply -f 04-backend-deployment.yaml
oc apply -f 05-frontend-deployment.yaml
oc apply -f 06-hpa.yaml
oc apply -f 07-network-policies.yaml

# Step 5: Wait for deployments
oc rollout status deployment/incident-backend
oc rollout status deployment/incident-frontend

# Step 6: Get URLs
oc get routes
```

### Verify Deployment

```powershell
# Check pods
oc get pods -n incident-board

# Check services
oc get svc -n incident-board

# Check routes
oc get routes -n incident-board

# View logs
oc logs -f deployment/incident-backend
oc logs -f deployment/incident-frontend

# Describe resources
oc describe deployment incident-backend
oc describe deployment incident-frontend
```

---

## 🔄 CI/CD Pipeline

### Tekton Pipeline Overview

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  Git Clone  │───▶│   Build     │───▶│   Push      │
│             │    │   Images    │    │   Images    │
└─────────────┘    └─────────────┘    └──────┬──────┘
                                             │
       ┌─────────────────────────────────────┘
       │
       ▼
┌─────────────┐    ┌─────────────┐
│   Deploy    │───▶│   Deploy    │
│   Backend   │    │   Frontend  │
└─────────────┘    └─────────────┘
```

### Trigger Pipeline

```powershell
# Create pipeline run
oc create -f 08-pipeline.yaml

# Watch pipeline progress
oc get pipelineruns -w

# View pipeline logs
tkn pipelinerun logs incident-board-pipeline-run-xxxxx
```

---

## 🔒 Security Best Practices

### Implemented Security Measures

| Security Measure | Implementation |
|-----------------|----------------|
| Non-root containers | UID 1001 (backend), UID 101 (frontend) |
| Privilege escalation | `allowPrivilegeEscalation: false` |
| Capabilities | All capabilities dropped |
| Seccomp profile | `RuntimeDefault` |
| Network policies | Frontend→Backend only |
| Secrets management | Kubernetes Secrets for credentials |
| TLS termination | Edge termination at OpenShift Router |
| Image scanning | Use trusted base images |

### Security Context

```yaml
securityContext:
  allowPrivilegeEscalation: false
  capabilities:
    drop:
      - ALL
  runAsNonRoot: true
  seccompProfile:
    type: RuntimeDefault
```

---

## 🔧 Troubleshooting

### Common Issues

#### 1. Pod CrashLoopBackOff

```powershell
# Check logs
oc logs <pod-name> --previous

# Common causes:
# - Database connection issues
# - Missing environment variables
# - Health check failures
```

#### 2. ImagePullBackOff

```powershell
# Check image pull secret
oc get secrets docker-registry-secret -o yaml

# Verify image exists
docker pull yosserfhal/incident-backend:latest
```

#### 3. Route Not Working

```powershell
# Check route configuration
oc describe route incident-frontend

# Verify service endpoints
oc get endpoints incident-frontend
```

#### 4. Database Persistence Issues

```powershell
# Check PVC status
oc get pvc incident-db-pvc

# Verify volume mount
oc exec -it <backend-pod> -- ls -la /app/data
```

### Useful Debug Commands

```powershell
# Get all resources
oc get all -n incident-board

# Describe pod issues
oc describe pod <pod-name>

# Execute shell in container
oc exec -it <pod-name> -- sh

# Port forward for local testing
oc port-forward svc/incident-backend 8080:8080

# View events
oc get events --sort-by='.lastTimestamp'
```

---

## 👨‍💻 Author

**Yosser Fhal**

- GitHub: [@yosseer](https://github.com/yosseer)
- LinkedIn: [Yosser Fhal](https://www.linkedin.com/in/yosser-fhal-3a57411b4/)
- Email: fhalyosser@tbs.u-tunis.tn

---

## 📄 License

This project is licensed under the MIT License.
