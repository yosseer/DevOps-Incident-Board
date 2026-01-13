#  Testing Guide - DevOps Incident Board

##  Quick Start Testing

### Prerequisites

- Node.js v14+ installed
- Modern web browser (Chrome, Firefox, Edge)

---

##  Starting the Application

### Step 1: Install Dependencies

```powershell
cd "c:\Users\fhaal\OneDrive - Ministere de l'Enseignement Superieur et de la Recherche Scientifique\Desktop\Cloud_Project"
npm install
```

### Step 2: Start the Mock API Server

```powershell
node mock-api-server.js
```

API will be available at: **http://localhost:8080**

### Step 3: Open the Dashboard

Option A: Double-click `beeper-ui/incident-board.html`

Option B: Use PowerShell:
```powershell
Start-Process "beeper-ui\incident-board.html"
```

---

##  Feature Testing Checklist

### 1. Summary Statistics

 **Test**: Open the dashboard
- **Expected**: Statistics section shows counts for Total, Critical, High, Medium, Low
- **Verify**: Numbers update when incidents are created/resolved/deleted

### 2. Active Incidents Section

 **Test**: View active incidents
- **Expected**: All non-resolved incidents display with:
  - Color-coded severity badge
  - Status dropdown (OPEN, INVESTIGATING)
  - Resolve button
  - Delete button

### 3. Create New Incident

 **Test**: Use the "Report New Incident" form
1. Fill in Reporter name: "Test User"
2. Select Severity: CRITICAL
3. Enter Title: "Test Production Outage"
4. Enter Description: "Testing the incident creation"
5. Click " Report Incident"

- **Expected**: New incident appears in Active section
- **Verify**: Statistics update (+1 Total, +1 Critical)

### 4. Resolution Workflow

 **Test**: Resolve an incident
1. Click "Resolve" button on any active incident
2. Modal should appear
3. Enter Resolver Name: "Admin User" (required)
4. Enter Resolution Comment: "Fixed the issue" (optional)
5. Click "Resolve Incident"

- **Expected**: Incident moves to Resolved section
- **Verify**: Shows resolver name and timestamp

### 5. Resolved Incidents Section

 **Test**: View resolved incidents
- **Expected**: Shows incidents resolved in last 24 hours
- **Verify**: Displays resolver name, resolution comment, and timestamp
- **Note**: Incidents older than 24 hours are auto-hidden

### 6. Status Dropdown

 **Test**: Change incident status
1. Click status dropdown on any active incident
2. Change from OPEN  INVESTIGATING

- **Expected**: Badge color changes to yellow
- **Verify**: Change persists after page refresh

### 7. Delete Incident

 **Test**: Delete an incident
1. Click delete () button on any incident
2. Confirm deletion

- **Expected**: Incident disappears
- **Verify**: Statistics update

### 8. Analytics Dashboard

 **Test**: View charts
- **Expected**: Two charts visible:
  1. "Incidents Over Time" - Line chart
  2. "Resolution Bar Chart" - Bar chart showing resolver counts

### 9. Employee of the Month

 **Test**: View leaderboard
- **Expected**: Trophy card showing top incident resolvers
- **Verify**: List updates when incidents are resolved

---

##  API Testing with PowerShell

### Health Check
```powershell
Invoke-RestMethod -Uri "http://localhost:8080/api/incidents" | ConvertTo-Json -Depth 5
```

### Create Incident
```powershell
$body = @{
    title = "API Test Incident"
    description = "Created via PowerShell"
    severity = "HIGH"
    createdBy = "PowerShell Tester"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8080/api/incidents" `
    -Method Post `
    -Body $body `
    -ContentType "application/json"
```

### Update Status
```powershell
$statusBody = @{ status = "INVESTIGATING" } | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8080/api/incidents/1/status" `
    -Method Patch `
    -Body $statusBody `
    -ContentType "application/json"
```

### Resolve Incident
```powershell
$resolveBody = @{
    status = "RESOLVED"
    resolvedBy = "Admin"
    resolutionComment = "Issue fixed"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8080/api/incidents/1/status" `
    -Method Patch `
    -Body $resolveBody `
    -ContentType "application/json"
```

### Delete Incident
```powershell
Invoke-RestMethod -Uri "http://localhost:8080/api/incidents/1" -Method Delete
```

---

##  Visual Testing

### Color Verification

| Severity | Expected Color |
|----------|----------------|
| CRITICAL | Red (#ff6b6b) |
| HIGH | Orange (#ff9800) |
| MEDIUM | Yellow (#ffc107) |
| LOW | Green (#4caf50) |

### Status Badge Colors

| Status | Expected Color |
|--------|----------------|
| OPEN | Red badge |
| INVESTIGATING | Yellow badge |
| RESOLVED | Green badge |

### Animations

- **LIVE badge**: Should pulse/animate on analytics dashboard
- **Cards**: Should have smooth hover effects
- **Charts**: Should animate when data updates

---

##  Troubleshooting

### "Cannot connect to API"

**Solution**:
```powershell
# Check if API is running
Test-NetConnection -ComputerName localhost -Port 8080

# Restart API server
node mock-api-server.js
```

### "Charts not loading"

**Solution**:
- Check browser console (F12) for errors
- Ensure internet connection (Chart.js loads from CDN)
- Clear browser cache and refresh

### "CORS errors"

**Solution**:
- Ensure mock-api-server.js has CORS enabled
- Check that API is running on port 8080

### "Page shows no incidents"

**Solution**:
- Verify API server is running
- Check browser console for fetch errors
- Try refreshing the page

---

##  Success Criteria

- [ ] Dashboard loads without errors
- [ ] All statistics display correctly
- [ ] Can create new incidents
- [ ] Can change incident status
- [ ] Can resolve incidents with mandatory name
- [ ] Resolved incidents appear in separate section
- [ ] Charts display and update
- [ ] Employee of the Month shows resolver leaderboard
- [ ] Delete functionality works
- [ ] Colors match severity levels
- [ ] LIVE badge animates

---

*DevOps Incident Management Board - Testing Guide*
