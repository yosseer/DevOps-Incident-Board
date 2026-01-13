# Quick Start Guide - DevOps Incident Board

## Quick Testing (Recommended)

```powershell
# 1. Start the mock API server
cd Cloud_Project
node mock-api-server.js

# 2. Open the dashboard in browser
Start-Process "beeper-ui\incident-board.html"
```

The dashboard will open automatically with sample incidents.

## Features Available

- Summary statistics (Total, Critical, High, Medium, Low)
- Active Incidents section with status dropdown
- Resolved Incidents section with 24h auto-delete timer
- Resolution modal with mandatory resolver name
- Analytics Dashboard with live charts
- Employee of the Month leaderboard

## Testing the API

```powershell
# Get all incidents
Invoke-RestMethod -Uri "http://localhost:8080/api/incidents"

# Create a new incident
$body = @{
    title = "Test Incident"
    description = "Test description"
    severity = "HIGH"
    createdBy = "Tester"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8080/api/incidents" -Method POST -Body $body -ContentType "application/json"

# Resolve an incident
$resolve = @{
    status = "RESOLVED"
    resolvedBy = "John Smith"
    resolutionComment = "Fixed the issue"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8080/api/incidents/1/status" -Method PATCH -Body $resolve -ContentType "application/json"
```

## Troubleshooting

### API Connection Error
If you see "Failed to load incidents":
```powershell
# Make sure the API server is running
node mock-api-server.js
```

### Port Already in Use
```powershell
# Find and kill process on port 8080
netstat -ano | findstr :8080
taskkill /PID <process_id> /F
```

## File Locations

| File | Location |
|------|----------|
| Dashboard | `beeper-ui/incident-board.html` |
| Styles | `beeper-ui/incident-board.css` |
| Mock API | `mock-api-server.js` |
podman network rm beeper-frontend beeper-backend
podman volume rm beeper-data  # WARNING: Deletes all data!
```

For more details, see the [full README](README.md).
