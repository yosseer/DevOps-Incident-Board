# DevOps Incident Board

A professional DevOps Incident Management System built with **Spring Boot** (Java) backend and **vanilla HTML/CSS/JavaScript** frontend, featuring real-time analytics and employee performance tracking.

![Java](https://img.shields.io/badge/Java-21-orange)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-2.7.18-green)
![H2 Database](https://img.shields.io/badge/Database-H2-blue)
![OpenShift](https://img.shields.io/badge/OpenShift-Ready-red)
![Docker](https://img.shields.io/badge/Docker-Ready-2496ED)
![License](https://img.shields.io/badge/License-MIT-yellow)

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Quick Start](#quick-start)
- [Docker Deployment](#-docker-deployment)
- [Red Hat OpenShift Deployment](#️-red-hat-openshift-deployment)
- [API Endpoints](#api-endpoints)
- [Database](#database)
- [Author](#author)

---

## 🎯 Overview

**DevOps Incident Board** is a production-ready incident management system designed for DevOps teams. It enables:

- 🚨 Professional incident tracking with severity levels
- 📊 Real-time analytics dashboard with Chart.js
- 🏆 Employee of the Month gamification
- 🔄 Status workflow management (OPEN → INVESTIGATING → RESOLVED)
- ⏰ Auto-delete resolved incidents after 24 hours
- 🌙 Modern dark theme UI

---

## ✨ Features

### Core Incident Management
| Feature | Description |
|---------|-------------|
| Create Incidents | Report new incidents with title, description, and severity |
| Severity Levels | CRITICAL, HIGH, MEDIUM, LOW with color coding |
| Status Workflow | OPEN → INVESTIGATING → RESOLVED |
| Resolution Tracking | Mandatory resolver name and optional comments |
| Reopen Incidents | Reopen resolved incidents if needed |
| Auto-Delete | Resolved incidents auto-delete after 24 hours |

### Analytics Dashboard
- 📈 **Incidents Over Time** - Line chart showing trends (last 24 hours)
- 🏅 **Resolution Leaderboard** - Bar chart of top resolvers
- 🏆 **Employee of the Month** - Trophy card for top performer
- 🔴 **Live Updates** - Auto-refresh every 30 seconds

### UI/UX
- Dark gradient theme (#1e1e2e → #2a2d3a → #1a1d28)
- Color-coded severity badges
- Summary statistics cards
- Responsive design for all devices
- Smooth animations and transitions

---

## 🏗️ Architecture

### System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        USER BROWSER                              │
│                    http://localhost:3000                         │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          │ HTTP Requests
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                      FRONTEND LAYER                              │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                    index.html                              │  │
│  │              (Vanilla HTML/CSS/JavaScript)                 │  │
│  │                    + Chart.js (CDN)                        │  │
│  │                                                            │  │
│  │  Components:                                               │  │
│  │  • Summary Statistics Cards                                │  │
│  │  • Incident Form                                           │  │
│  │  • Active Incidents List                                   │  │
│  │  • Resolved Incidents List                                 │  │
│  │  • Analytics Dashboard (Charts)                            │  │
│  │  • Resolution Modal                                        │  │
│  └───────────────────────────────────────────────────────────┘  │
│                         Port: 3000                               │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          │ REST API (JSON)
                          │ GET, POST, PATCH, DELETE
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                      BACKEND LAYER                               │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │              Spring Boot Application                       │  │
│  │                   (Java 21)                                │  │
│  │                                                            │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │  │
│  │  │ Controller  │  │  Service    │  │ Repository  │        │  │
│  │  │   Layer     │──│   Layer     │──│   Layer     │        │  │
│  │  │             │  │  (JPA)      │  │ (Hibernate) │        │  │
│  │  └─────────────┘  └─────────────┘  └─────────────┘        │  │
│  │                                                            │  │
│  │  Endpoints:                                                │  │
│  │  • GET    /api/incidents                                   │  │
│  │  • POST   /api/incidents                                   │  │
│  │  • PATCH  /api/incidents/{id}/status                       │  │
│  │  • DELETE /api/incidents/{id}                              │  │
│  └───────────────────────────────────────────────────────────┘  │
│                         Port: 8080                               │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          │ JDBC Connection
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                      DATABASE LAYER                              │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                 H2 Database (File-based)                   │  │
│  │                                                            │  │
│  │  Tables:                                                   │  │
│  │  ┌─────────────────────────────────────────────────────┐  │  │
│  │  │ INCIDENTS                                            │  │  │
│  │  │ • id (BIGINT, PK)                                    │  │  │
│  │  │ • title (VARCHAR 200)                                │  │  │
│  │  │ • description (VARCHAR 1000)                         │  │  │
│  │  │ • severity (ENUM: CRITICAL, HIGH, MEDIUM, LOW)       │  │  │
│  │  │ • status (ENUM: OPEN, INVESTIGATING, RESOLVED)       │  │  │
│  │  │ • created_by (VARCHAR 255)                           │  │  │
│  │  │ • created_at (TIMESTAMP)                             │  │  │
│  │  │ • resolved_by (VARCHAR 255)                          │  │  │
│  │  │ • resolved_at (TIMESTAMP)                            │  │  │
│  │  │ • resolution_comment (VARCHAR 1000)                  │  │  │
│  │  └─────────────────────────────────────────────────────┘  │  │
│  │                                                            │  │
│  │  File: ./data/incidentboard.mv.db                          │  │
│  └───────────────────────────────────────────────────────────┘  │
│                    H2 Console: /h2-console                       │
└─────────────────────────────────────────────────────────────────┘
```

### Data Flow

```
┌──────────┐    ┌──────────┐    ┌──────────────┐    ┌──────────┐
│  User    │───▶│ Frontend │───▶│   Backend    │───▶│ Database │
│  Action  │    │  (HTML)  │    │ (Spring Boot)│    │   (H2)   │
└──────────┘    └──────────┘    └──────────────┘    └──────────┘
     │               │                  │                 │
     │  Click        │  fetch()         │  JPA Query      │
     │  Button       │  REST API        │  SQL            │
     ▼               ▼                  ▼                 ▼
┌──────────┐    ┌──────────┐    ┌──────────────┐    ┌──────────┐
│  Form    │◀───│  Update  │◀───│   JSON       │◀───│  Result  │
│  Submit  │    │   DOM    │    │   Response   │    │   Set    │
└──────────┘    └──────────┘    └──────────────┘    └──────────┘
```

---

## 🛠️ Tech Stack

### Backend
| Technology | Version | Purpose |
|------------|---------|---------|
| Java | 21 | Programming Language |
| Spring Boot | 2.7.18 | Web Framework |
| Spring Data JPA | 2.7.x | ORM / Data Access |
| Hibernate | 5.6.15 | JPA Implementation |
| H2 Database | 2.1.x | Embedded Database |
| HikariCP | 4.0.x | Connection Pool |
| Maven | 3.9.x | Build Tool |

### Frontend
| Technology | Purpose |
|------------|---------|
| HTML5 | Structure |
| CSS3 | Styling (Dark Theme) |
| JavaScript (ES6+) | Interactivity |
| Chart.js | Analytics Charts |
| Fetch API | HTTP Requests |

### Tools & Infrastructure
| Tool | Purpose |
|------|---------|
| npx serve | Static File Server |
| H2 Console | Database Management |
| Git | Version Control |

---

## 📁 Project Structure

```
DevOps-Incident-Board/
│
├── 📂 beeper-backend/                 # Spring Boot Backend
│   ├── 📂 src/
│   │   └── 📂 main/
│   │       ├── 📂 java/com/redhat/training/beeper/
│   │       │   ├── 📄 BeeperApplication.java    # Main Application
│   │       │   ├── 📄 Incident.java             # Entity Model
│   │       │   ├── 📄 IncidentController.java   # REST Controller
│   │       │   ├── 📄 IncidentRepository.java   # JPA Repository
│   │       │   ├── 📄 Severity.java             # Enum (CRITICAL, HIGH, MEDIUM, LOW)
│   │       │   └── 📄 Status.java               # Enum (OPEN, INVESTIGATING, RESOLVED)
│   │       └── 📂 resources/
│   │           ├── 📄 application.properties    # Configuration
│   │           └── 📄 data.sql                  # Sample Data
│   ├── 📂 data/                        # H2 Database Files
│   │   └── 📄 incidentboard.mv.db
│   └── 📄 pom.xml                      # Maven Dependencies
│
├── 📂 beeper-ui/                       # Frontend
│   ├── 📄 index.html                   # Main Dashboard
│   └── 📄 incident-board.css           # Styles
│
├── 📄 docker-compose.yml               # Docker Configuration
├── 📄 README.md                        # Documentation
├── 📄 LICENSE                          # MIT License
└── 📄 .gitignore                       # Git Ignore Rules
```

---

## 🚀 Quick Start

### Prerequisites
- **Java 21** (JDK)
- **Maven 3.9+**
- **Node.js** (for npx serve)

### Step 1: Start the Backend

```powershell
# Navigate to backend directory
cd beeper-backend

# Run Spring Boot application
mvn spring-boot:run
```

Backend will start on **http://localhost:8080**

### Step 2: Start the Frontend

```powershell
# Navigate to frontend directory
cd beeper-ui

# Start static file server
npx serve -l 3000
```

Frontend will start on **http://localhost:3000**

### Step 3: Open the Dashboard

Open your browser and navigate to: **http://localhost:3000**

---

## � Docker Deployment

### Build Docker Images

```bash
# Build Backend Image
cd beeper-backend
docker build -t incident-backend:latest -f Containerfile .

# Build Frontend Image
cd beeper-ui
docker build -t incident-frontend:latest -f Containerfile .
```

### Run with Docker

```bash
# Run Backend Container
docker run -d -p 8080:8080 --name backend incident-backend:latest

# Run Frontend Container
docker run -d -p 80:8080 --name frontend incident-frontend:latest
```

### Pre-built Images (Docker Hub)

```
docker.io/yosserfhal/incident-backend:latest
docker.io/yosserfhal/incident-frontend:v4
```

---

## ☁️ Red Hat OpenShift Deployment

### Live Demo URLs
| Service | URL |
|---------|-----|
| **Frontend** | https://incident-frontend-incident-board-containers.apps.na46r.prod.ole.redhat.com |
| **Backend API** | https://incident-backend-incident-board-containers.apps.na46r.prod.ole.redhat.com |

### OpenShift Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    OpenShift Cluster (RHOCP)                    │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    Route (HTTPS)                         │   │
│  │    incident-frontend-incident-board-containers.apps...   │   │
│  └─────────────────────────┬───────────────────────────────┘   │
│                            │                                    │
│                            ▼                                    │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              Frontend Deployment (2 replicas)            │   │
│  │                   Nginx + Static Files                   │   │
│  │                      Port: 8080                          │   │
│  │                                                          │   │
│  │    /api/* ──proxy──▶ incident-backend:8080/api/*        │   │
│  └─────────────────────────┬───────────────────────────────┘   │
│                            │                                    │
│                            ▼                                    │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              Backend Deployment (1 replica)              │   │
│  │                 Spring Boot + H2 Database                │   │
│  │                      Port: 8080                          │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Deploy to OpenShift

```bash
# 1. Login to OpenShift
oc login https://api.your-cluster.com:6443

# 2. Create namespace
oc new-project incident-board-containers

# 3. Deploy Backend
oc new-app docker.io/yosserfhal/incident-backend:latest \
  --name=incident-backend

# 4. Expose Backend Route
oc expose svc/incident-backend

# 5. Deploy Frontend
oc new-app docker.io/yosserfhal/incident-frontend:v4 \
  --name=incident-frontend \
  -e API_BASE_URL=/api

# 6. Expose Frontend Route
oc expose svc/incident-frontend

# 7. Verify Deployment
oc get pods
oc get routes
```

### OpenShift Features Used
- **Deployments** with multiple replicas
- **Services** for internal communication
- **Routes** for external HTTPS access
- **ConfigMaps** for environment configuration
- **HPA** (Horizontal Pod Autoscaler) for auto-scaling

---

## �📡 API Endpoints

### Base URL: `http://localhost:8080/api`

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/incidents` | Get all incidents (sorted by date) |
| `GET` | `/incidents/{id}` | Get incident by ID |
| `POST` | `/incidents` | Create new incident |
| `PATCH` | `/incidents/{id}/status` | Update incident status |
| `DELETE` | `/incidents/{id}` | Delete incident |

### Request/Response Examples

#### Create Incident
```json
POST /api/incidents
{
  "title": "Database Connection Timeout",
  "description": "Users unable to access application",
  "severity": "CRITICAL",
  "createdBy": "Mohamed Ben Ali"
}
```

#### Resolve Incident
```json
PATCH /api/incidents/1/status
{
  "status": "RESOLVED",
  "resolvedBy": "Ahmed Trabelsi",
  "resolutionComment": "Restarted database server"
}
```

---

## 🗄️ Database

### H2 Console Access
- **URL:** http://localhost:8080/h2-console
- **JDBC URL:** `jdbc:h2:file:./data/incidentboard`
- **Username:** `admin`
- **Password:** `admin123`

### Sample Data (Tunisian Names)
The database comes pre-populated with sample incidents:

| Reporter | Resolver |
|----------|----------|
| Mohamed Ben Ali | Ahmed Trabelsi |
| Fatma Bouazizi | Youssef Hammami |
| Amira Chaabane | Sami Belhaj |
| Nour Mansouri | Ines Mejri |
| Khalil Jebali | Mohamed Ben Ali |

---

## 🎨 Color Scheme

| Severity | Color | Hex Code |
|----------|-------|----------|
| 🔴 Critical | Red | `#ff6b6b` |
| 🟠 High | Orange | `#ff9800` |
| 🟡 Medium | Yellow | `#ffc107` |
| 🟢 Low | Green | `#4caf50` |
| ✅ Resolved | Green | `#10b981` |

**Background Gradient:** `#1e1e2e` → `#2a2d3a` → `#1a1d28`

---

## 👨‍💻 Author

**Yosser Fhal**

[![GitHub](https://img.shields.io/badge/GitHub-yosseer-181717?style=flat&logo=github)](https://github.com/yosseer)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Yosser%20Fhal-0077B5?style=flat&logo=linkedin)](https://www.linkedin.com/in/yosser-fhal-3a57411b4/)
[![Email](https://img.shields.io/badge/Email-fhalyosser%40tbs.u--tunis.tn-D14836?style=flat&logo=gmail)](mailto:fhalyosser@tbs.u-tunis.tn)

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  <b>Built with ❤️ for DevOps Teams</b><br>
  <i>Professional Incident Management System</i>
</p>
