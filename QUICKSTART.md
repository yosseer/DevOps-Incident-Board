# Quick Start Guide

## For DO188 Lab Environment (Linux)

```bash
# 1. Start the lab
lab start comprehensive-review

# 2. Clone or copy this repository to:
#    /home/student/DO188/labs/comprehensive-review/

# 3. Navigate to the directory
cd /home/student/DO188/labs/comprehensive-review/

# 4. Run the automated deployment
chmod +x deploy.sh
./deploy.sh

# 5. Access the application
# Open browser to: http://localhost:8080

# 6. Run the lab checker
lab grade comprehensive-review
```

## For Local Development (Any OS)

### Prerequisites
- Podman installed
- Access to required container registries
- 8080 port available

### Manual Steps

```bash
# 1. Create networks
podman network create beeper-backend
podman network create beeper-frontend

# 2. Start database
podman volume create beeper-data
podman run -d \
  --name beeper-db \
  --network beeper-backend \
  -v beeper-data:/var/lib/pgsql/data \
  -e POSTGRESQL_USER=beeper \
  -e POSTGRESQL_PASSWORD=beeper123 \
  -e POSTGRESQL_DATABASE=beeper \
  registry.ocp4.example.com:8443/rhel9/postgresql-13:1

# 3. Build and run backend
cd beeper-backend
podman build -t beeper-api:v1 .
podman run -d --name beeper-api --network beeper-backend -e DB_HOST=beeper-db beeper-api:v1
podman network connect beeper-frontend beeper-api

# 4. Build and run frontend
cd ../beeper-ui
podman build -t beeper-ui:v1 .
podman run -d --name beeper-ui --network beeper-frontend -p 8080:8080 beeper-ui:v1

# 5. Verify
podman ps
curl http://localhost:8080/api/beeps/health
```

## Verification Steps

1. **All containers running**: `podman ps` shows 3 containers
2. **UI accessible**: Navigate to http://localhost:8080
3. **Create a beep**: Use the web form to post a message
4. **Test persistence**: `podman restart beeper-db beeper-api beeper-ui` - data should persist

## Common Issues

### Port 8080 in use
```bash
podman run -d --name beeper-ui --network beeper-frontend -p 8081:8080 beeper-ui:v1
# Then access at http://localhost:8081
```

### Registry authentication
```bash
podman login registry.ocp4.example.com:8443
```

### Check logs
```bash
podman logs beeper-db
podman logs beeper-api
podman logs beeper-ui
```

## Cleanup

```bash
./cleanup.sh
# or manually:
podman stop beeper-ui beeper-api beeper-db
podman rm beeper-ui beeper-api beeper-db
podman network rm beeper-frontend beeper-backend
podman volume rm beeper-data  # WARNING: Deletes all data!
```

For more details, see the [full README](README.md).
