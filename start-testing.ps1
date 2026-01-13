# 🚀 Quick Test - Incident Board
# Run this to test the new Incident Board using your existing container setup

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DevOps Incident Board - Quick Test" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$projectRoot = "C:\Users\fhaal\OneDrive - Ministere de l'Enseignement Superieur et de la Recherche Scientifique\Desktop\Cloud_Project"

# Check if on Linux/WSL or Windows
if ($IsLinux -or $IsMacOS) {
    Write-Host "⚠️  Detected Unix system. Please run deploy.sh instead:" -ForegroundColor Yellow
    Write-Host "   ./deploy.sh" -ForegroundColor Gray
    Write-Host ""
    exit 0
}

Write-Host "📋 Testing Options:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1️⃣  Container Testing (Recommended - Uses existing setup)" -ForegroundColor White
Write-Host "   - Uses Podman/Docker" -ForegroundColor Gray
Write-Host "   - No local Java/Maven needed" -ForegroundColor Gray
Write-Host "   - Complete environment" -ForegroundColor Gray
Write-Host ""
Write-Host "2️⃣  Local Development Testing" -ForegroundColor White
Write-Host "   - Requires Java 17+ and Node.js" -ForegroundColor Gray
Write-Host "   - Faster iteration" -ForegroundColor Gray
Write-Host "   - Good for development" -ForegroundColor Gray
Write-Host ""
Write-Host "3️⃣  Frontend Only (Use existing backend)" -ForegroundColor White
Write-Host "   - Test UI changes only" -ForegroundColor Gray
Write-Host "   - Requires Node.js" -ForegroundColor Gray
Write-Host ""

$choice = Read-Host "Choose option (1, 2, or 3)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "🐳 Container Testing Selected" -ForegroundColor Green
        Write-Host ""
        
        # Check for container runtime
        $containerCmd = $null
        if (Get-Command podman -ErrorAction SilentlyContinue) {
            $containerCmd = "podman"
            Write-Host "✅ Found Podman" -ForegroundColor Green
        } elseif (Get-Command docker -ErrorAction SilentlyContinue) {
            $containerCmd = "docker"
            Write-Host "✅ Found Docker" -ForegroundColor Green
        } else {
            Write-Host "❌ No container runtime found!" -ForegroundColor Red
            Write-Host "   Please install Podman or Docker" -ForegroundColor Yellow
            exit 1
        }
        
        Write-Host ""
        Write-Host "📦 Building images..." -ForegroundColor Yellow
        Write-Host "   This may take a few minutes on first run" -ForegroundColor Gray
        Write-Host ""
        
        # Build backend
        Write-Host "Building backend..." -ForegroundColor Cyan
        Set-Location "$projectRoot\beeper-backend"
        & $containerCmd build -t beeper-api:v2 -f Containerfile .
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Backend build failed!" -ForegroundColor Red
            exit 1
        }
        Write-Host "✅ Backend image built" -ForegroundColor Green
        Write-Host ""
        
        # Build frontend
        Write-Host "Building frontend..." -ForegroundColor Cyan
        Set-Location "$projectRoot\beeper-ui"
        & $containerCmd build -t beeper-ui:v2 -f Containerfile .
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Frontend build failed!" -ForegroundColor Red
            exit 1
        }
        Write-Host "✅ Frontend image built" -ForegroundColor Green
        Write-Host ""
        
        # Stop old containers
        Write-Host "🛑 Stopping old containers..." -ForegroundColor Yellow
        & $containerCmd stop beeper-ui beeper-api beeper-db 2>$null
        & $containerCmd rm beeper-ui beeper-api beeper-db 2>$null
        Write-Host ""
        
        # Create networks
        Write-Host "🌐 Creating networks..." -ForegroundColor Yellow
        & $containerCmd network create beeper-backend 2>$null
        & $containerCmd network create beeper-frontend 2>$null
        Write-Host ""
        
        # Start database
        Write-Host "🗄️  Starting database..." -ForegroundColor Yellow
        & $containerCmd run -d `
            --name beeper-db `
            --network beeper-backend `
            -e POSTGRESQL_USER=beeper `
            -e POSTGRESQL_PASSWORD=beeper123 `
            -e POSTGRESQL_DATABASE=beeper `
            -v beeper-data:/var/lib/pgsql/data `
            registry.access.redhat.com/rhel9/postgresql-13:1
        
        Write-Host "⏳ Waiting for database to be ready..." -ForegroundColor Gray
        Start-Sleep -Seconds 5
        Write-Host "✅ Database started" -ForegroundColor Green
        Write-Host ""
        
        # Start backend
        Write-Host "🚀 Starting backend API..." -ForegroundColor Yellow
        & $containerCmd run -d `
            --name beeper-api `
            --network beeper-backend `
            --network beeper-frontend `
            -e DB_HOST=beeper-db `
            -e DB_PORT=5432 `
            -e DB_NAME=beeper `
            -e DB_USER=beeper `
            -e DB_PASSWORD=beeper123 `
            beeper-api:v2
        
        Write-Host "⏳ Waiting for backend to start..." -ForegroundColor Gray
        Start-Sleep -Seconds 10
        Write-Host "✅ Backend started" -ForegroundColor Green
        Write-Host ""
        
        # Start frontend
        Write-Host "🎨 Starting frontend UI..." -ForegroundColor Yellow
        & $containerCmd run -d `
            --name beeper-ui `
            --network beeper-frontend `
            -p 8080:8080 `
            beeper-ui:v2
        
        Write-Host "⏳ Waiting for frontend to start..." -ForegroundColor Gray
        Start-Sleep -Seconds 5
        Write-Host "✅ Frontend started" -ForegroundColor Green
        Write-Host ""
        
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "  ✅ Deployment Complete!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "🌐 Open your browser to:" -ForegroundColor Yellow
        Write-Host "   http://localhost:8080" -ForegroundColor White
        Write-Host ""
        Write-Host "📊 Check container status:" -ForegroundColor Yellow
        Write-Host "   $containerCmd ps" -ForegroundColor Gray
        Write-Host ""
        Write-Host "📜 View logs:" -ForegroundColor Yellow
        Write-Host "   $containerCmd logs beeper-api" -ForegroundColor Gray
        Write-Host "   $containerCmd logs beeper-ui" -ForegroundColor Gray
        Write-Host ""
        
        # Try to open browser
        Start-Process "http://localhost:8080"
    }
    
    "2" {
        Write-Host ""
        Write-Host "💻 Local Development Testing Selected" -ForegroundColor Green
        Write-Host ""
        
        # Check Java
        if (Get-Command java -ErrorAction SilentlyContinue) {
            Write-Host "✅ Java found" -ForegroundColor Green
            java -version 2>&1 | Select-Object -First 1
        } else {
            Write-Host "❌ Java not found!" -ForegroundColor Red
            Write-Host "   Please install Java 17 or higher" -ForegroundColor Yellow
            exit 1
        }
        
        # Check Node
        if (Get-Command node -ErrorAction SilentlyContinue) {
            Write-Host "✅ Node.js found" -ForegroundColor Green
            node --version
        } else {
            Write-Host "❌ Node.js not found!" -ForegroundColor Red
            Write-Host "   Please install Node.js 16 or higher" -ForegroundColor Yellow
            exit 1
        }
        
        Write-Host ""
        Write-Host "🚀 Starting Backend..." -ForegroundColor Yellow
        Write-Host "   Open a NEW terminal and run:" -ForegroundColor Gray
        Write-Host ""
        Write-Host "   cd `"$projectRoot\beeper-backend`"" -ForegroundColor White
        Write-Host "   java -jar target\beeper-1.0.0.jar" -ForegroundColor White
        Write-Host ""
        Write-Host "Press Enter when backend is running..." -ForegroundColor Yellow
        Read-Host
        
        Write-Host ""
        Write-Host "🎨 Starting Frontend..." -ForegroundColor Yellow
        Set-Location "$projectRoot\beeper-ui"
        
        if (-not (Test-Path "node_modules")) {
            Write-Host "📦 Installing dependencies..." -ForegroundColor Cyan
            npm install
        }
        
        Write-Host ""
        Write-Host "✅ Starting dev server..." -ForegroundColor Green
        Write-Host "   Frontend will open at http://localhost:5173" -ForegroundColor Gray
        Write-Host ""
        
        npm run dev
    }
    
    "3" {
        Write-Host ""
        Write-Host "🎨 Frontend Only Testing Selected" -ForegroundColor Green
        Write-Host ""
        
        # Check Node
        if (Get-Command node -ErrorAction SilentlyContinue) {
            Write-Host "✅ Node.js found" -ForegroundColor Green
            node --version
        } else {
            Write-Host "❌ Node.js not found!" -ForegroundColor Red
            Write-Host "   Please install Node.js 16 or higher" -ForegroundColor Yellow
            exit 1
        }
        
        Write-Host ""
        Write-Host "⚠️  Make sure your backend is running on port 8080" -ForegroundColor Yellow
        Write-Host ""
        
        Set-Location "$projectRoot\beeper-ui"
        
        if (-not (Test-Path "node_modules")) {
            Write-Host "📦 Installing dependencies..." -ForegroundColor Cyan
            npm install
        }
        
        Write-Host ""
        Write-Host "✅ Starting dev server..." -ForegroundColor Green
        Write-Host "   Frontend will open at http://localhost:5173" -ForegroundColor Gray
        Write-Host ""
        
        npm run dev
    }
    
    default {
        Write-Host ""
        Write-Host "❌ Invalid option. Please run the script again." -ForegroundColor Red
        exit 1
    }
}

Set-Location $projectRoot
