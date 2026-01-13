# 🧪 Quick API Tests for Phase 1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  API Testing - Incident Board" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:8080/api/incidents"

# Test 1: Health Check
Write-Host "Test 1: Health Check" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/health" -UseBasicParsing
    Write-Host "✅ Health: $($response.Content)" -ForegroundColor Green
} catch {
    Write-Host "❌ Health check failed: $_" -ForegroundColor Red
}
Write-Host ""

# Test 2: Get All Incidents (should be empty initially)
Write-Host "Test 2: Get All Incidents" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri $baseUrl -Method Get
    Write-Host "✅ Retrieved $($response.Count) incidents" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to get incidents: $_" -ForegroundColor Red
}
Write-Host ""

# Test 3: Create CRITICAL Incident
Write-Host "Test 3: Create CRITICAL Incident" -ForegroundColor Yellow
$criticalIncident = @{
    title = "Production Database Down"
    description = "All users unable to access the application"
    severity = "CRITICAL"
    createdBy = "DevOps Team"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri $baseUrl -Method Post -Body $criticalIncident -ContentType "application/json"
    Write-Host "✅ Created incident ID: $($response.id)" -ForegroundColor Green
    Write-Host "   Title: $($response.title)" -ForegroundColor Gray
    Write-Host "   Severity: $($response.severity)" -ForegroundColor Red
    Write-Host "   Status: $($response.status)" -ForegroundColor Gray
    $criticalId = $response.id
} catch {
    Write-Host "❌ Failed to create incident: $_" -ForegroundColor Red
}
Write-Host ""

# Test 4: Create MEDIUM Incident
Write-Host "Test 4: Create MEDIUM Incident" -ForegroundColor Yellow
$mediumIncident = @{
    title = "API Response Times Increased"
    description = "Average response time up by 200ms"
    severity = "MEDIUM"
    createdBy = "Backend Team"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri $baseUrl -Method Post -Body $mediumIncident -ContentType "application/json"
    Write-Host "✅ Created incident ID: $($response.id)" -ForegroundColor Green
    Write-Host "   Title: $($response.title)" -ForegroundColor Gray
    Write-Host "   Severity: $($response.severity)" -ForegroundColor Yellow
    $mediumId = $response.id
} catch {
    Write-Host "❌ Failed to create incident: $_" -ForegroundColor Red
}
Write-Host ""

# Test 5: Create LOW Incident
Write-Host "Test 5: Create LOW Incident" -ForegroundColor Yellow
$lowIncident = @{
    title = "Minor UI Alignment Issue"
    description = "Button slightly misaligned on mobile"
    severity = "LOW"
    createdBy = "Frontend Team"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri $baseUrl -Method Post -Body $lowIncident -ContentType "application/json"
    Write-Host "✅ Created incident ID: $($response.id)" -ForegroundColor Green
    Write-Host "   Title: $($response.title)" -ForegroundColor Gray
    Write-Host "   Severity: $($response.severity)" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to create incident: $_" -ForegroundColor Red
}
Write-Host ""

# Test 6: Update Status to INVESTIGATING
if ($criticalId) {
    Write-Host "Test 6: Update Status to INVESTIGATING" -ForegroundColor Yellow
    $statusUpdate = @{
        status = "INVESTIGATING"
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/$criticalId/status" -Method Patch -Body $statusUpdate -ContentType "application/json"
        Write-Host "✅ Updated incident status to: $($response.status)" -ForegroundColor Green
    } catch {
        Write-Host "❌ Failed to update status: $_" -ForegroundColor Red
    }
    Write-Host ""
}

# Test 7: Get All Incidents Again
Write-Host "Test 7: Get All Incidents (After Creating)" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri $baseUrl -Method Get
    Write-Host "✅ Retrieved $($response.Count) incidents" -ForegroundColor Green
    foreach ($incident in $response) {
        $color = switch ($incident.severity) {
            "CRITICAL" { "Red" }
            "HIGH" { "DarkYellow" }
            "MEDIUM" { "Yellow" }
            "LOW" { "Green" }
            default { "Gray" }
        }
        Write-Host "   [$($incident.severity)] $($incident.title) - Status: $($incident.status)" -ForegroundColor $color
    }
} catch {
    Write-Host "❌ Failed to get incidents: $_" -ForegroundColor Red
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  ✅ API Testing Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Open http://localhost:5173 to see the UI" -ForegroundColor Gray
Write-Host "2. Check the color-coded incidents" -ForegroundColor Gray
Write-Host "3. Try changing status via dropdowns" -ForegroundColor Gray
Write-Host "4. Create new incidents with different severities" -ForegroundColor Gray
Write-Host ""
