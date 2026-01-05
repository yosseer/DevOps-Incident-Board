# Beeper Application - Git Repository Setup Script for Windows
# Run this script in PowerShell to initialize and push to GitHub

Write-Host "=========================================="  -ForegroundColor Cyan
Write-Host "  Beeper Application - Git Setup"  -ForegroundColor Cyan
Write-Host "=========================================="  -ForegroundColor Cyan
Write-Host ""

$projectPath = "C:\Users\fhaal\OneDrive - Ministere de l'Enseignement Superieur et de la Recherche Scientifique\Desktop\Cloud_Project"

# Check if git is installed
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "✗ Git is not installed. Please install Git first." -ForegroundColor Red
    Write-Host "  Download from: https://git-scm.com/download/win" -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ Git is installed" -ForegroundColor Green
Write-Host ""

# Navigate to project directory
Set-Location $projectPath
Write-Host "→ Working directory: $projectPath" -ForegroundColor Yellow
Write-Host ""

# Check if already initialized
if (Test-Path ".git") {
    Write-Host "⚠ Git repository already initialized" -ForegroundColor Yellow
    $response = Read-Host "Do you want to reinitialize? This will remove git history (y/N)"
    if ($response -eq 'y' -or $response -eq 'Y') {
        Remove-Item -Recurse -Force .git
        Write-Host "✓ Removed existing git repository" -ForegroundColor Green
    } else {
        Write-Host "Using existing repository" -ForegroundColor Yellow
    }
}

# Initialize git repository
if (-not (Test-Path ".git")) {
    Write-Host "→ Initializing git repository..." -ForegroundColor Yellow
    git init
    Write-Host "✓ Git repository initialized" -ForegroundColor Green
    Write-Host ""
}

# Configure git user (if not already configured)
$userName = git config user.name
$userEmail = git config user.email

if (-not $userName) {
    Write-Host "→ Git user not configured" -ForegroundColor Yellow
    $name = Read-Host "Enter your name for git commits"
    git config user.name "$name"
    Write-Host "✓ Git user name set to: $name" -ForegroundColor Green
}

if (-not $userEmail) {
    $email = Read-Host "Enter your email for git commits"
    git config user.email "$email"
    Write-Host "✓ Git user email set to: $email" -ForegroundColor Green
}

Write-Host ""

# Check git status
Write-Host "→ Checking repository status..." -ForegroundColor Yellow
git status --short
Write-Host ""

# Add all files
Write-Host "→ Adding all files to git..." -ForegroundColor Yellow
git add .
Write-Host "✓ All files staged for commit" -ForegroundColor Green
Write-Host ""

# Create initial commit
Write-Host "→ Creating initial commit..." -ForegroundColor Yellow
git commit -m "Initial commit: Beeper application - DO188 comprehensive review lab

- Spring Boot backend with PostgreSQL
- React frontend with Vite
- Multi-stage Containerfiles for both services
- Automated deployment scripts
- Complete documentation"

Write-Host "✓ Initial commit created" -ForegroundColor Green
Write-Host ""

# Show commit log
Write-Host "Commit created:" -ForegroundColor Cyan
git log --oneline -1
Write-Host ""

# Prompt for GitHub repository
Write-Host "=========================================="  -ForegroundColor Cyan
Write-Host "  GitHub Repository Setup"  -ForegroundColor Cyan
Write-Host "=========================================="  -ForegroundColor Cyan
Write-Host ""
Write-Host "To push to GitHub, you need to:" -ForegroundColor Yellow
Write-Host "1. Create a new repository on GitHub (https://github.com/new)" -ForegroundColor White
Write-Host "2. Repository name: beeper-do188-lab (or your choice)" -ForegroundColor White
Write-Host "3. Do NOT initialize with README, .gitignore, or license" -ForegroundColor White
Write-Host ""

$pushNow = Read-Host "Have you created the GitHub repository? (y/N)"

if ($pushNow -eq 'y' -or $pushNow -eq 'Y') {
    $githubUsername = Read-Host "Enter your GitHub username"
    $repoName = Read-Host "Enter repository name (default: beeper-do188-lab)"
    
    if (-not $repoName) {
        $repoName = "beeper-do188-lab"
    }
    
    $repoUrl = "https://github.com/$githubUsername/$repoName.git"
    
    Write-Host ""
    Write-Host "→ Adding remote origin: $repoUrl" -ForegroundColor Yellow
    
    # Remove existing origin if it exists
    git remote remove origin 2>$null
    
    # Add new origin
    git remote add origin $repoUrl
    Write-Host "✓ Remote origin added" -ForegroundColor Green
    Write-Host ""
    
    # Rename branch to main if needed
    $currentBranch = git branch --show-current
    if ($currentBranch -ne "main") {
        Write-Host "→ Renaming branch to 'main'..." -ForegroundColor Yellow
        git branch -M main
        Write-Host "✓ Branch renamed to 'main'" -ForegroundColor Green
        Write-Host ""
    }
    
    # Push to GitHub
    Write-Host "→ Pushing to GitHub..." -ForegroundColor Yellow
    Write-Host "  (You may be prompted for GitHub credentials)" -ForegroundColor Yellow
    Write-Host ""
    
    try {
        git push -u origin main
        Write-Host ""
        Write-Host "✓ Successfully pushed to GitHub!" -ForegroundColor Green
        Write-Host ""
        Write-Host "=========================================="  -ForegroundColor Cyan
        Write-Host "  Setup Complete!"  -ForegroundColor Cyan
        Write-Host "=========================================="  -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Your repository is now available at:" -ForegroundColor Green
        Write-Host "  $repoUrl" -ForegroundColor White
        Write-Host ""
        Write-Host "View it in browser:" -ForegroundColor Yellow
        Write-Host "  https://github.com/$githubUsername/$repoName" -ForegroundColor White
        Write-Host ""
    } catch {
        Write-Host "✗ Failed to push to GitHub" -ForegroundColor Red
        Write-Host "  Error: $_" -ForegroundColor Red
        Write-Host ""
        Write-Host "Try pushing manually with:" -ForegroundColor Yellow
        Write-Host "  git push -u origin main" -ForegroundColor White
        Write-Host ""
    }
} else {
    Write-Host ""
    Write-Host "Repository initialized locally but not pushed to GitHub" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To push later, follow these steps:" -ForegroundColor Cyan
    Write-Host "1. Create repository on GitHub" -ForegroundColor White
    Write-Host "2. Run these commands:" -ForegroundColor White
    Write-Host ""
    Write-Host "   git remote add origin https://github.com/YOUR_USERNAME/REPO_NAME.git" -ForegroundColor Gray
    Write-Host "   git branch -M main" -ForegroundColor Gray
    Write-Host "   git push -u origin main" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "For detailed GitHub setup instructions, see:" -ForegroundColor Yellow
Write-Host "  .\GITHUB_SETUP.md" -ForegroundColor White
Write-Host ""

Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  → Add repository topics on GitHub" -ForegroundColor White
Write-Host "  → Update README with your specific details" -ForegroundColor White
Write-Host "  → Share your repository link!" -ForegroundColor White
Write-Host ""
