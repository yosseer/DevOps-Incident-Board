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
git commit -m "Initial commit: Beeper application - DO188 comprehensive review lab"
```

## Step 2: Create GitHub Repository

### Option A: Using GitHub Web Interface

1. Go to https://github.com/new
2. Repository name: `beeper-do188-lab` (or your preferred name)
3. Description: `Full-stack containerized application for Red Hat DO188 comprehensive review - Spring Boot + React + PostgreSQL`
4. Choose visibility: **Public** (recommended for portfolio) or **Private**
5. **DO NOT** initialize with README, .gitignore, or license (we already have these)
6. Click "Create repository"

### Option B: Using GitHub CLI (if installed)

```powershell
# Login to GitHub (if not already logged in)
gh auth login

# Create repository
gh repo create beeper-do188-lab --public --source=. --remote=origin --push
```

## Step 3: Connect Local Repository to GitHub

If you used Option A (web interface), run these commands:

```powershell
# Add remote origin (replace 'yosseer' with your GitHub username)
git remote add origin https://github.com/yosseer/beeper-do188-lab.git

# Verify remote
git remote -v

# Push to GitHub
git branch -M main
git push -u origin main
```

## Step 4: Verify Upload

1. Go to your repository URL: `https://github.com/yosseer/beeper-do188-lab`
2. Verify all files are present
3. Check that README.md displays correctly

## Step 5: Add Repository Topics (Optional but Recommended)

On your GitHub repository page:
1. Click on the gear icon ⚙️ next to "About"
2. Add topics:
   - `red-hat`
   - `do188`
   - `spring-boot`
   - `react`
   - `podman`
   - `containers`
   - `postgresql`
   - `full-stack`
   - `containerization`
   - `multi-stage-build`

## Step 6: Enable GitHub Pages (Optional)

If you want to host documentation:
1. Go to Settings → Pages
2. Source: Deploy from a branch
3. Branch: main → /docs (or root)
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

## Clone Repository on Linux (DO188 Lab)

To use this repository in the DO188 lab environment:

```bash
# Clone the repository
git clone https://github.com/yosseer/beeper-do188-lab.git

# Navigate to the directory
cd beeper-do188-lab

# Make scripts executable
chmod +x deploy.sh cleanup.sh

# Run deployment
./deploy.sh
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
beeper-do188-lab/
├── beeper-backend/       # Spring Boot API
├── beeper-ui/           # React Frontend
├── README.md            # Main documentation
├── QUICKSTART.md        # Quick start guide
├── GITHUB_SETUP.md      # This file
├── LICENSE              # MIT License
├── .gitignore           # Git ignore rules
├── deploy.sh            # Deployment script
└── cleanup.sh           # Cleanup script
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

1. ✅ Add a detailed README badge for build status (if using CI/CD)
2. ✅ Star your own repository for easy access
3. ✅ Share the repository link on your profile
4. ✅ Add it to your resume/portfolio
5. ✅ Consider adding GitHub Actions for automated testing

## Example Repository URL

Once created, your repository will be accessible at:
```
https://github.com/yosseer/beeper-do188-lab
```

And can be cloned with:
```bash
git clone https://github.com/yosseer/beeper-do188-lab.git
```

---

**Need help?** Check [GitHub's documentation](https://docs.github.com/) or run `git help` for more information.
