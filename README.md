# DevOps Incident Board - Professional Incident Management System

A professional DevOps Incident Management dashboard built with vanilla HTML/CSS/JavaScript and a mock Express.js API, featuring real-time analytics and employee performance tracking.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Quick Start](#quick-start)
- [API Endpoints](#api-endpoints)
- [Screenshots](#screenshots)
- [Project Structure](#project-structure)

## Overview

**DevOps Incident Board** is a professional incident management system that transforms the original Beeper social app into a production-ready DevOps tool. It demonstrates:

- Professional incident management with severity levels
- Status workflow (OPEN  INVESTIGATING  RESOLVED)
- Real-time analytics with Chart.js
- Employee of the Month gamification
- Separate Active and Resolved incidents sections
- Dark theme with gradient background
- 24-hour auto-delete for resolved incidents

## Features

### Core Incident Management
- Create, view, update, and delete incidents
- Severity levels: CRITICAL, HIGH, MEDIUM, LOW
- Status workflow: OPEN  INVESTIGATING  RESOLVED
- Separate Active and Resolved incidents sections
- Mandatory resolver name when resolving incidents
- Resolution comments for documentation
- Reopen resolved incidents if needed

### Analytics Dashboard
- **Incidents Over Time** - Line chart showing incident trends (last 24 hours)
- **Resolution Leaderboard** - Bar chart showing top resolvers
- **Employee of the Month** - Gamification feature highlighting top performer
- Live update animations with LIVE badge indicator

### UI/UX
- Professional dark theme with gradient background (#1e1e2e  #2a2d3a  #1a1d28)
- Color-coded severity indicators
- Summary statistics cards (Total, Critical, High, Medium, Low)
- 24-hour auto-delete timer for resolved incidents
- Responsive design for all screen sizes

## Architecture

### Standalone Testing Mode
```

        incident-board.html           
    (Vanilla HTML/CSS/JavaScript)     
         + Chart.js (CDN)             

                HTTP REST API
               

       mock-api-server.js             
    (Express.js Mock API)             
         Port: 8080                   

```

### Production Mode (Containerized)
```

   beeper-ui       (Nginx serving HTML/CSS/JS)
   Port: 8080    

          HTTP REST API

  beeper-api       (Spring Boot)
   Port: 8080    

          JDBC

  beeper-db        (PostgreSQL)
   Port: 5432    

```

## Quick Start

### Option 1: Quick Testing (Recommended)

```powershell
# 1. Start the mock API server
cd Cloud_Project
node mock-api-server.js

# 2. Open incident-board.html in browser
Start-Process "beeper-ui\incident-board.html"
```

### Option 2: Deploy to OpenShift (Production)

```powershell
# Navigate to OpenShift deployment directory
cd openshift

# Login to your OpenShift cluster
oc login --server=<your-openshift-server> -u <username> -p <password>

# Run the automated deployment
.\deploy.ps1

# Get your frontend URL
oc get routes -n incident-board
```

**For detailed OpenShift deployment instructions, see [openshift/README.md](./openshift/README.md)**

### Option 3: Local Containerized Deployment

```bash
# Make the script executable
chmod +x deploy.sh

# Run the deployment
./deploy.sh
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/incidents` | Get all incidents |
| POST | `/api/incidents` | Create new incident |
| PATCH | `/api/incidents/:id/status` | Update status/resolve incident |
| DELETE | `/api/incidents/:id` | Delete incident |

### Resolution Request Body
```json
{
  "status": "RESOLVED",
  "resolvedBy": "John Smith",
  "resolutionComment": "Fixed database connection pool",
  "resolvedAt": "2024-01-15T10:30:00Z"
}
```

## Troubleshooting

### API Connection Issues
If you see "Failed to load incidents", ensure the mock API is running:
```bash
node mock-api-server.js
```

### CORS Errors
The mock API server includes CORS headers. Make sure you're accessing via `localhost:8080`.

### Charts Not Loading
Chart.js is loaded from CDN. Ensure you have internet connectivity.
## Project Structure

```
Cloud_Project/
 beeper-ui/                        # Frontend
    incident-board.html           # Main dashboard (standalone)
    incident-board.css            # Dashboard styles
    index.html                    # Original entry point
    nginx.conf                    # Nginx configuration
    Containerfile                 # Multi-stage build
    src/                          # React source (original)

 beeper-backend/                   # Spring Boot API
    src/main/java/...             # Java source files
    pom.xml                       # Maven dependencies
    Containerfile                 # Multi-stage build

 openshift/                        # OpenShift deployment ✨ NEW
    *.yaml                        # Kubernetes manifests (6 files)
    deploy.sh                     # Automated bash deployment
    deploy.ps1                    # Automated PowerShell deployment
    README.md                     # Deployment guide
    QUICKSTART.md                 # 60-second quick start
    DEPLOYMENT_GUIDE.md           # Detailed instructions
    VERIFICATION_CHECKLIST.md     # Post-deployment verification
    TROUBLESHOOTING.md            # Issue resolution guide
    WINDOWS_GUIDE.md              # Windows-specific setup
    SUMMARY.md                    # Quick reference
    INDEX.md                      # Documentation index

 mock-api-server.js                # Express.js mock API for testing
 deploy.sh                         # Automated deployment script
 cleanup.sh                        # Cleanup script
 README.md                         # This file
```

## Deployment Options

### 🚀 Production Deployment: OpenShift/Kubernetes

**Complete microservices deployment with:**
- Isolated containers for each service (Frontend, Backend, Database)
- Kubernetes orchestration with automatic scaling
- Persistent storage for database
- Internal service discovery via DNS
- External HTTPS access via Route
- Health checks and auto-recovery
- Production-ready security settings

**Get started:**
1. Read [openshift/README.md](./openshift/README.md) - Overview
2. Follow [openshift/QUICKSTART.md](./openshift/QUICKSTART.md) - 60-second setup
3. Use [openshift/DEPLOYMENT_GUIDE.md](./openshift/DEPLOYMENT_GUIDE.md) - Full guide
4. Verify with [openshift/VERIFICATION_CHECKLIST.md](./openshift/VERIFICATION_CHECKLIST.md)

**Windows users:** See [openshift/WINDOWS_GUIDE.md](./openshift/WINDOWS_GUIDE.md)

**Troubleshooting:** [openshift/TROUBLESHOOTING.md](./openshift/TROUBLESHOOTING.md)

### 🏗️ Docker Containerization

```bash
# Build frontend image
cd beeper-ui
docker build -f Containerfile -t incident-board-frontend:latest .

# Build backend image
cd ../beeper-backend
docker build -f Containerfile -t incident-board-backend:latest .

# Run containers
docker run -d -p 8080:8080 --name frontend incident-board-frontend
docker run -d -p 8081:8080 --name backend incident-board-backend
```

### 🧪 Local Testing

```powershell
# Start mock API server
node mock-api-server.js

# Open UI
Start-Process "beeper-ui\incident-board.html"
```


## Key Files

| File | Purpose |
|------|---------|
| `beeper-ui/incident-board.html` | Main dashboard UI with all features |
| `beeper-ui/incident-board.css` | Complete styling with gradient theme |
| `mock-api-server.js` | Mock API server with sample incidents |

## Color Scheme

- **Background**: Dark gradient (#1e1e2e  #2a2d3a  #1a1d28)
- **Critical**: Red (#ff6b6b)
- **High**: Orange (#ff9800)
- **Medium**: Yellow (#ffc107)
- **Low**: Green (#4caf50)
- **Resolved**: Green with checkmark

## License

MIT License

---

**Built for DevOps teams - Professional Incident Management**
