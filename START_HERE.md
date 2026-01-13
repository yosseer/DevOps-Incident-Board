# START HERE - DevOps Incident Board Guide

## What You Have

A **professional DevOps Incident Management System** with:
- Incident tracking with severity levels (CRITICAL, HIGH, MEDIUM, LOW)
- Status workflow (OPEN  INVESTIGATING  RESOLVED)
- Resolution comments with mandatory resolver name
- Separate Active and Resolved incidents sections
- 24-hour auto-delete for resolved incidents
- Analytics Dashboard with Chart.js
- Employee of the Month leaderboard
- Professional dark gradient theme

---

## Quick Start - 2 Simple Steps

### Step 1: Start the API Server

Open a terminal and run:

```powershell
cd "C:\Users\fhaal\OneDrive - Ministere de l'Enseignement Superieur et de la Recherche Scientifique\Desktop\Cloud_Project"
node mock-api-server.js
```

You should see: `Mock API server running on port 8080`

---

### Step 2: Open the Dashboard

Open another terminal and run:

```powershell
Start-Process "C:\Users\fhaal\OneDrive - Ministere de l'Enseignement Superieur et de la Recherche Scientifique\Desktop\Cloud_Project\beeper-ui\incident-board.html"
```

The dashboard will open in your browser.

---

## Files You Need to Know

| File | Purpose |
|------|---------|
| `beeper-ui/incident-board.html` | Main dashboard UI |
| `beeper-ui/incident-board.css` | Styling |
| `mock-api-server.js` | Mock API server |
| `README.md` | Project documentation |
| `QUICKSTART.md` | Quick reference |

---

## Testing Features

### Create an Incident
1. Fill in the "Report New Incident" form
2. Select severity level (CRITICAL recommended to see colors)
3. Click "Create Incident"

### Resolve an Incident
1. Click the status dropdown on any active incident
2. Select "RESOLVED"
3. **Enter your name** (required)
4. Optionally add a resolution comment
5. Click "Resolve Incident"

### View Analytics
- **Incidents Over Time**: Shows incident trends over 24 hours
- **Resolution Leaderboard**: Shows top resolvers
- **Employee of the Month**: Trophy card for the top performer

---

## Troubleshooting

### "Failed to load incidents" Error
The API server is not running. Start it with:
```powershell
node mock-api-server.js
```

### Charts Not Showing
- Requires internet connection (Chart.js loaded from CDN)
- Check browser console for errors

### Resolver Name Not Saving
- Restart the API server: `Ctrl+C` then `node mock-api-server.js`
