# GitHub Repository Setup Guide

## Step 1: Initialize Git Repository Locally

Open VS Code terminal (PowerShell) and run:

```powershell
# Navigate to your project directory
cd "C:\Users\fhaal\OneDrive - Ministere de l'Enseignement Superieur et de la Recherche Scientifique\Desktop\Cloud_Project"

# Initialize git repository
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: DevOps Incident Board with Analytics Dashboard"
```

## Step 2: Create GitHub Repository

### Option A: Using GitHub Web Interface

1. Go to https://github.com/new
2. Repository name: `devops-incident-board` (or your preferred name)
3. Description: `DevOps Incident Management System with Analytics Dashboard, Employee of the Month, and Resolution Tracking`
4. Choose visibility: **Public** (recommended for portfolio) or **Private**
5. **DO NOT** initialize with README, .gitignore, or license (we already have these)
6. Click "Create repository"

### Option B: Using GitHub CLI (if installed)

```powershell
# Login to GitHub (if not already logged in)
gh auth login

# Create repository
gh repo create devops-incident-board --public --source=. --remote=origin --push
```

## Step 3: Connect Local Repository to GitHub

If you used Option A (web interface), run these commands:

```powershell
# Add remote origin (replace 'yosseer' with your GitHub username)
git remote add origin https://github.com/yosseer/devops-incident-board.git

# Verify remote
git remote -v

# Push to GitHub
git branch -M main
git push -u origin main
```

## Step 4: Verify Upload

1. Go to your repository URL: `https://github.com/yosseer/devops-incident-board`
2. Verify all files are present
3. Check that README.md displays correctly

## Step 5: Add Repository Topics (Optional but Recommended)

On your GitHub repository page:
1. Click on the gear icon  next to "About"
2. Add topics:
   - `devops`
   - `incident-management`
   - `analytics-dashboard`
   - `chart-js`
   - `express-js`
   - `html5`
   - `css3`
   - `javascript`
   - `dark-theme`
   - `full-stack`

## Step 6: Enable GitHub Pages (Optional)

If you want to host documentation:
1. Go to Settings  Pages
2. Source: Deploy from a branch
3. Branch: main  /docs (or root)
4. Click Save

## Future Updates

To push changes to GitHub:

```powershell
# Check status
git status

# Add changed files
git add .

# Commit changes
git commit -m "Your commit message here"

# Push to GitHub
git push
```

## Clone Repository on Another Machine

To use this repository on another machine:

```bash
# Clone the repository
git clone https://github.com/yosseer/devops-incident-board.git

# Navigate to the directory
cd devops-incident-board

# Install dependencies
npm install

# Start the API server
node mock-api-server.js

# Open the dashboard in browser
# beeper-ui/incident-board.html
```

## Useful Git Commands

```powershell
# View commit history
git log --oneline

# Create a new branch
git checkout -b feature-branch-name

# Switch branches
git checkout main

# View differences
git diff

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Discard local changes
git checkout -- filename
```

## Repository Structure After Push

Your GitHub repository will contain:

```
devops-incident-board/
 beeper-ui/
    incident-board.html    # Main dashboard
    incident-board.css     # Styling
 mock-api-server.js         # Express.js API
 package.json               # Node.js dependencies
 README.md                  # Main documentation
 QUICKSTART.md              # Quick start guide
 GITHUB_SETUP.md            # This file
 TESTING_GUIDE.md           # Testing instructions
 IMPLEMENTATION_GUIDE.md    # Implementation details
 LICENSE                    # MIT License
```

## Troubleshooting

### Authentication Issues

If you have authentication problems:

```powershell
# Use personal access token instead of password
# Generate token at: https://github.com/settings/tokens
# When prompted for password, enter the token

# Or configure credential helper
git config --global credential.helper wincred
```

### Large Files Warning

If you get warnings about large files:

```powershell
# Check file sizes
git ls-files | xargs ls -lh | sort -k5 -h

# Remove large files from git
git rm --cached path/to/large/file
echo "path/to/large/file" >> .gitignore
git commit -m "Remove large file"
```

### Push Rejected

If your push is rejected:

```powershell
# Pull changes first
git pull origin main --rebase

# Then push
git push origin main
```

## Next Steps

After pushing to GitHub:

1.  Star your own repository for easy access
2.  Share the repository link on your profile
3.  Add it to your resume/portfolio
4.  Consider adding GitHub Actions for automated testing
5.  Add screenshots to README for visual appeal

## Example Repository URL

Once created, your repository will be accessible at:
```
https://github.com/yosseer/devops-incident-board
```

And can be cloned with:
```bash
git clone https://github.com/yosseer/devops-incident-board.git
```

---

*DevOps Incident Management Board - GitHub Setup Guide*
