<# 
.SYNOPSIS
    Stages all changes, prompts for a commit message, commits, and pushes to the remote repo.

.DESCRIPTION
    Run this script from any git repository to stage changes, enter a commit message,
    and push to the remote origin.

.NOTES
    Requires: git installed and a remote origin configured
#>

param(
    [string]$Message = "",
    [switch]$Amend = $false,
    [switch]$NoPush = $false
)

# Check if we're in a git repo
if (-not (Test-Path ".git")) {
    Write-Error "Not a git repository. Run init-github-repo.ps1 first or run 'git init'."
    exit 1
}

# Check for remote origin
$hasRemote = git remote get-url origin 2>$null
if (-not $hasRemote -and -not $NoPush) {
    Write-Error "No remote 'origin' configured. Add one with: git remote add origin <url>"
    exit 1
}

# Ensure our helper folder is in .gitignore
$helperFolder = "git-helpers"
$gitignorePath = ".gitignore"
$gitignoreContent = if (Test-Path $gitignorePath) { Get-Content $gitignorePath -Raw } else { "" }

$pattern = "^$([regex]::Escape($helperFolder))/$"
if ($gitignoreContent -notmatch $pattern) {
    if ($gitignoreContent -and $gitignoreContent[-1] -ne "`n") {
        $gitignoreContent += "`n"
    }
    $gitignoreContent += "$helperFolder/`n"
    $gitignoreContent | Set-Content $gitignorePath -Encoding UTF8
    Write-Host "Added $helperFolder/ to .gitignore" -ForegroundColor Green
}

# Show status
Write-Host "Current git status:" -ForegroundColor Cyan
git status --short

# Check if there are changes to commit
$status = git status --porcelain
if (-not $status -and -not $Amend) {
    Write-Host "No changes to commit." -ForegroundColor Yellow
    exit 0
}

# Stage all changes
git add .
Write-Host "Staged all changes" -ForegroundColor Green

# Get commit message
if (-not $Message) {
    Write-Host ""
    Write-Host "Enter commit message (press Enter when done):" -ForegroundColor Cyan
    $Message = Read-Host "Message"
    
    if (-not $Message) {
        Write-Error "Commit message cannot be empty."
        exit 1
    }
}

# Commit
if ($Amend) {
    git commit --amend --no-edit
    Write-Host "Amended previous commit" -ForegroundColor Green
} else {
    git commit -m $Message
    Write-Host "Committed: $Message" -ForegroundColor Green
}

# Push unless --no-push
if (-not $NoPush) {
    Write-Host "Pushing to origin..." -ForegroundColor Cyan
    $currentBranch = git branch --show-current
    git push origin $currentBranch
    Write-Host "Pushed to origin/$currentBranch" -ForegroundColor Green
} else {
    Write-Host "Skipped push (--no-push flag used)" -ForegroundColor Yellow
}

Write-Host "Done!" -ForegroundColor Green