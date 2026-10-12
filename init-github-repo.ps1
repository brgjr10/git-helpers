<# 
.SYNOPSIS
    Creates a new GitHub repository using the current folder name and pushes the local code.

.DESCRIPTION
    Run this script from any folder to initialize a git repo, create a GitHub repository
    with the same name as the folder, and push the code to GitHub.

.NOTES
    Requires: gh CLI (GitHub CLI) installed and authenticated (gh auth login)
#>

param(
    [switch]$Private,
    [string]$Description = ""
)

# Get the current folder name
$folderName = Split-Path -Leaf (Get-Location).Path
$repoName = $folderName

Write-Host "Initializing GitHub repo for: $repoName" -ForegroundColor Cyan

# Check if gh is installed
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Error "GitHub CLI (gh) is not installed. Install it from: https://cli.github.com/"
    exit 1
}

# Check if already a git repo
if (Test-Path ".git") {
    Write-Warning "Already a git repository. Skipping git init."
} else {
    git init
    Write-Host "Initialized git repository" -ForegroundColor Green
}

# Prompt for visibility if not specified
if (-not $PSBoundParameters.ContainsKey('Private')) {
    Write-Host ""
    Write-Host "Repository visibility:" -ForegroundColor Cyan
    Write-Host "  [1] Public"
    Write-Host "  [2] Private"
    $choice = Read-Host "Choose (1 or 2, default: 1)"
    $Private = ($choice -eq "2")
}

# Prompt for description if not provided
if (-not $Description) {
    Write-Host ""
    $Description = Read-Host "Description (optional, press Enter to skip)"
}

# Create .gitignore if it doesn't exist
if (-not (Test-Path ".gitignore")) {
    @"
# Dependencies
node_modules/
.pnp
.pnp.js

# Testing
coverage/

# Next.js
.next/
out/

# Production
build/
dist/

# Misc
.DS_Store
*.pem

# Debug
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Local env files
.env*.local
.env

# Vercel
.vercel

# TypeScript
*.tsbuildinfo
next-env.d.ts

# IDE
.idea/
.vscode/
*.swp
*.swo

# Helper scripts folder
git-helpers/
"@ | Set-Content .gitignore -Encoding UTF8
    Write-Host "Created .gitignore" -ForegroundColor Green
}

# Stage all files
git add .
Write-Host "Staged all files" -ForegroundColor Green

# Initial commit if no commits exist
if (-not (git rev-parse --verify HEAD 2>$null)) {
    git commit -m "Initial commit"
    Write-Host "Created initial commit" -ForegroundColor Green
}

# Create GitHub repo
$visibility = if ($Private) { "--private" } else { "--public" }
$descFlag = if ($Description) { "--description `"$Description`"" } else { "" }

$createCmd = "gh repo create $repoName $visibility $descFlag --source=. --push"
Write-Host "Creating GitHub repository..." -ForegroundColor Cyan
Invoke-Expression $createCmd

Write-Host "Done! Repository created and pushed to GitHub." -ForegroundColor Green
Write-Host "View at: https://github.com/$(gh api user --jq .login)/$repoName" -ForegroundColor Cyan