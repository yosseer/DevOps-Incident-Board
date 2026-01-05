# 🐝 Beeper Application - DO188 Comprehensive Review

A containerized full-stack application built with Spring Boot (backend) and React (frontend), designed for the Red Hat DO188 course comprehensive review lab.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Detailed Setup Instructions](#detailed-setup-instructions)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)
- [Cleanup](#cleanup)
- [Project Structure](#project-structure)

## 🎯 Overview

**Beeper** is a simple social media application where users can post short messages ("beeps"). It demonstrates:

- Multi-stage containerized builds
- Container networking with DNS
- Persistent data storage with volumes
- Full-stack application deployment using Podman
- REST API with Spring Boot
- Modern React UI with Vite

## 🏗️ Architecture

```
┌─────────────────┐
│   beeper-ui     │  (React + Nginx)
│   Port: 8080    │
└────────┬────────┘
         │ beeper-frontend network
         │
┌────────┴────────┐
│  beeper-api     │  (Spring Boot)
│   Port: 8080    │
└────────┬────────┘
         │ beeper-backend network
         │
┌────────┴────────┐
│  beeper-db      │  (PostgreSQL)
│   Port: 5432    │
│ Volume: beeper-data
└─────────────────┘
```

## ✅ Prerequisites

**Required:**
- Podman installed and configured
- Access to Red Hat registries:
  - `registry.ocp4.example.com:8443/ubi8/openjdk-17:1.12`
  - `registry.ocp4.example.com:8443/ubi8/openjdk-17-runtime:1.12`
  - `registry.ocp4.example.com:8443/ubi9/nodejs-22:1`
  - `registry.ocp4.example.com:8443/ubi8/nginx-118:1`
  - `registry.ocp4.example.com:8443/rhel9/postgresql-13:1`

**For DO188 Lab:**
- RHEL workstation with DO188 course materials
- Lab environment started: `lab start comprehensive-review`

## 🚀 Quick Start

### Option 1: Automated Deployment (Linux/macOS)

```bash
# Make the script executable
chmod +x deploy.sh

# Run the deployment
./deploy.sh
```

### Option 2: Manual Deployment (Step-by-Step)

Follow the [Detailed Setup Instructions](#detailed-setup-instructions) below.

## 📖 Detailed Setup Instructions

### Step 1: Start Lab Environment (DO188 Only)

```bash
lab start comprehensive-review
cd /home/student/DO188/labs/comprehensive-review/
```

### Step 2: Create Podman Networks

```bash
podman network create beeper-backend
podman network create beeper-frontend
```

Verify networks:
```bash
podman network ls
```

### Step 3: Create Volume & Run PostgreSQL

```bash
# Create persistent volume
podman volume create beeper-data

# Run PostgreSQL container
podman run -d \
  --name beeper-db \
  --network beeper-backend \
  -v beeper-data:/var/lib/pgsql/data \
  -e POSTGRESQL_USER=beeper \
  -e POSTGRESQL_PASSWORD=beeper123 \
  -e POSTGRESQL_DATABASE=beeper \
  registry.ocp4.example.com:8443/rhel9/postgresql-13:1
```

Verify database is running:
```bash
podman ps | grep beeper-db
podman logs beeper-db
```

### Step 4: Build & Run Backend API

```bash
cd beeper-backend

# Build the image
podman build -t beeper-api:v1 .

# Run the container
podman run -d \
  --name beeper-api \
  --network beeper-backend \
  -e DB_HOST=beeper-db \
  beeper-api:v1

# Connect to frontend network
podman network connect beeper-frontend beeper-api
```

Verify API is running:
```bash
podman ps | grep beeper-api
podman logs beeper-api
```

### Step 5: Build & Run Frontend UI

```bash
cd ../beeper-ui

# Build the image
podman build -t beeper-ui:v1 .

# Run the container
podman run -d \
  --name beeper-ui \
  --network beeper-frontend \
  -p 8080:8080 \
  beeper-ui:v1
```

Verify UI is running:
```bash
podman ps | grep beeper-ui
podman logs beeper-ui
```

### Step 6: Access the Application

Open your browser and navigate to:
```
http://localhost:8080
```

## ✔️ Verification

### 1. Check All Containers are Running

```bash
podman ps
```

You should see 3 containers: `beeper-db`, `beeper-api`, and `beeper-ui`.

### 2. Test the UI

- Navigate to http://localhost:8080
- Create a new beep by filling out the form
- Verify the beep appears in the list

### 3. Test Data Persistence

```bash
# Create a beep via the UI first, then restart containers
podman restart beeper-db beeper-api beeper-ui

# Wait a few seconds for containers to start
sleep 10

# Refresh the browser - your beep should still be there
```

### 4. Test API Directly

```bash
# Get all beeps
curl http://localhost:8080/api/beeps

# Create a beep
curl -X POST http://localhost:8080/api/beeps \
  -H "Content-Type: application/json" \
  -d '{"message":"Test beep from curl","author":"CLI User"}'

# Health check
curl http://localhost:8080/api/beeps/health
```

### 5. Run Lab Checker (DO188 Only)

```bash
lab grade comprehensive-review
```

## 🔧 Troubleshooting

### Container Not Starting

**Check logs:**
```bash
podman logs beeper-db
podman logs beeper-api
podman logs beeper-ui
```

**Check container status:**
```bash
podman ps -a
```

### Network Issues

**Verify networks exist:**
```bash
podman network ls
```

**Inspect network connections:**
```bash
podman network inspect beeper-backend
podman network inspect beeper-frontend
```

**Test DNS resolution:**
```bash
podman exec beeper-api nslookup beeper-db
```

### Database Connection Errors

**Test database connectivity:**
```bash
podman exec beeper-db psql -U beeper -d beeper -c '\dt'
```

**Check environment variables:**
```bash
podman exec beeper-api env | grep DB_HOST
```

### Port Already in Use

**Check what's using port 8080:**
```bash
ss -tulpn | grep 8080
# or
lsof -i :8080
```

**Use a different port:**
```bash
podman run -d \
  --name beeper-ui \
  --network beeper-frontend \
  -p 8081:8080 \
  beeper-ui:v1
```

### Image Build Failures

**Authentication issues:**
```bash
podman login registry.ocp4.example.com:8443
```

**Check registry connectivity:**
```bash
curl -k https://registry.ocp4.example.com:8443/v2/
```

### UI Not Loading

**Check nginx logs:**
```bash
podman logs beeper-ui
```

**Verify API is accessible from UI:**
```bash
podman exec beeper-ui curl http://beeper-api:8080/api/beeps/health
```

## 🧹 Cleanup

### Stop All Containers

```bash
podman stop beeper-ui beeper-api beeper-db
```

### Remove Containers

```bash
podman rm beeper-ui beeper-api beeper-db
```

### Remove Networks

```bash
podman network rm beeper-frontend beeper-backend
```

### Remove Volume (⚠️ Deletes Data!)

```bash
podman volume rm beeper-data
```

### Remove Images

```bash
podman rmi beeper-ui:v1 beeper-api:v1
```

### Complete Cleanup Script

```bash
# Stop and remove everything
podman stop beeper-ui beeper-api beeper-db 2>/dev/null
podman rm beeper-ui beeper-api beeper-db 2>/dev/null
podman network rm beeper-frontend beeper-backend 2>/dev/null
podman volume rm beeper-data 2>/dev/null
podman rmi beeper-ui:v1 beeper-api:v1 2>/dev/null
```

## 📁 Project Structure

```
beeper-application/
├── beeper-backend/                 # Spring Boot API
│   ├── src/
│   │   └── main/
│   │       ├── java/com/redhat/training/beeper/
│   │       │   ├── BeeperApplication.java    # Main application
│   │       │   ├── Beep.java                 # Entity model
│   │       │   ├── BeepRepository.java       # Data access
│   │       │   └── BeepController.java       # REST endpoints
│   │       └── resources/
│   │           └── application.properties    # Configuration
│   ├── pom.xml                               # Maven dependencies
│   ├── settings.xml                          # Maven settings
│   └── Containerfile                         # Multi-stage build
│
├── beeper-ui/                      # React Frontend
│   ├── src/
│   │   ├── components/
│   │   │   ├── BeepForm.jsx                  # Create beep form
│   │   │   ├── BeepForm.css
│   │   │   ├── BeepList.jsx                  # List of beeps
│   │   │   ├── BeepList.css
│   │   │   ├── BeepItem.jsx                  # Individual beep
│   │   │   └── BeepItem.css
│   │   ├── App.jsx                           # Main component
│   │   ├── App.css
│   │   ├── index.jsx                         # Entry point
│   │   └── index.css
│   ├── public/
│   ├── index.html
│   ├── package.json                          # NPM dependencies
│   ├── vite.config.js                        # Vite configuration
│   ├── nginx.conf                            # Nginx config
│   └── Containerfile                         # Multi-stage build
│
├── deploy.sh                       # Automated deployment script
├── cleanup.sh                      # Cleanup script
└── README.md                       # This file
```

## 🎓 Learning Objectives

This lab demonstrates:

1. **Multi-stage Container Builds**
   - Separate build and runtime stages
   - Smaller production images
   - Build-time vs runtime dependencies

2. **Container Networking**
   - DNS-enabled networks
   - Multi-network container connections
   - Service discovery by name

3. **Data Persistence**
   - Named volumes
   - Database persistence across container restarts
   - Volume mounting

4. **Full-Stack Architecture**
   - Frontend/backend separation
   - REST API design
   - Reverse proxy configuration

5. **Container Orchestration**
   - Service dependencies
   - Environment configuration
   - Port mapping

## 📝 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/beeps` | Get all beeps (sorted by newest first) |
| GET | `/api/beeps/{id}` | Get a specific beep by ID |
| POST | `/api/beeps` | Create a new beep |
| DELETE | `/api/beeps/{id}` | Delete a beep |
| GET | `/api/beeps/health` | Health check endpoint |

## 🤝 Contributing

This is a training lab project. For improvements or issues:

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## 📄 License

This project is created for educational purposes as part of the Red Hat DO188 course.

## 🔗 Resources

- [Red Hat DO188 Course](https://www.redhat.com/en/services/training/do188-red-hat-openshift-development-i-introduction-containers-kubernetes)
- [Podman Documentation](https://docs.podman.io/)
- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [React Documentation](https://react.dev/)
- [Vite Documentation](https://vitejs.dev/)

---

**Built with ❤️ for Red Hat DO188 Comprehensive Review Lab**
"# Beeper-Application-" 
