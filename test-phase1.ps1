# 🧪 Test Phase 1 - DevOps Incident Board

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Testing Phase 1: Incident Features" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Change to backend directory
Write-Host "📦 Building Backend..." -ForegroundColor Yellow
Set-Location "beeper-backend"

# Clean and build
Write-Host "Running Maven clean package..." -ForegroundColor Gray
& ./mvnw clean package -DskipTests

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Backend built successfully!" -ForegroundColor Green
} else {
    Write-Host "❌ Backend build failed!" -ForegroundColor Red
    Set-Location ..
    exit 1
}

Write-Host ""
Write-Host "🚀 Starting Backend Server..." -ForegroundColor Yellow
Write-Host "   URL: http://localhost:8080" -ForegroundColor Gray
Write-Host "   API: http://localhost:8080/api/incidents" -ForegroundColor Gray
Write-Host ""

# Start backend in background
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD'; ./mvnw spring-boot:run"

# Wait for backend to start
Write-Host "⏳ Waiting for backend to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Test backend health
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/incidents/health" -UseBasicParsing
    Write-Host "✅ Backend is running!" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Backend may still be starting..." -ForegroundColor Yellow
}

# Change to frontend directory
Set-Location ../beeper-ui
Write-Host ""
Write-Host "📦 Installing Frontend Dependencies..." -ForegroundColor Yellow
npm install

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Frontend dependencies installed!" -ForegroundColor Green
} else {
    Write-Host "❌ Frontend installation failed!" -ForegroundColor Red
    Set-Location ..
    exit 1
}

Write-Host ""
Write-Host "🚀 Starting Frontend Server..." -ForegroundColor Yellow
Write-Host "   URL: http://localhost:5173" -ForegroundColor Gray
Write-Host ""

# Start frontend
npm run dev

Set-Location ..
