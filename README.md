# git-helpers

Two PowerShell helper scripts for everyday git + GitHub workflows. Copy the whole
`git-helpers` folder into any project folder and run it from there.

<img width="1408" height="768" alt="image_d90a2bf7" src="https://github.com/user-attachments/assets/46de530c-9964-4e38-a281-031145aded95" />

## Requirements

- Windows + PowerShell 5.1+
- [git](https://git-scm.com/) installed and on PATH
- [GitHub CLI (gh)](https://cli.github.com/) installed and authenticated (`gh auth login`) — only needed for `init-github-repo`

## Usage

Either double-click a `.bat` file, or run the `.ps1` directly:

```powershell
powershell -ExecutionPolicy Bypass -File .\git-helpers\git-commit-push.ps1
```

**Both scripts operate on the folder that contains the `git-helpers` folder** (your
project), not the `git-helpers` folder itself. To target a different folder, pass
`-Path`:

```powershell
powershell -ExecutionPolicy Bypass -File .\git-commit-push.ps1 -Path "C:\Projects\my-app"
```

## git-commit-push

Stages all changes, prompts for a commit message, commits, and pushes to `origin`.

```powershell
.\git-commit-push.ps1 [-Message "msg"] [-Amend] [-NoPush] [-Path "dir"]
```

| Parameter | Description |
|-----------|-------------|
| `-Message` | Commit message (prompts if omitted) |
| `-Amend` | Amend the previous commit (`git commit --amend --no-edit`) |
| `-NoPush` | Commit only, skip the push |
| `-Path` | Target folder (default: parent of the `git-helpers` folder) |

Also ensures `git-helpers/` is listed in the project's `.gitignore` so the helper
scripts themselves are never committed.

## init-github-repo

Initializes a git repo, creates a GitHub repository named after the project folder,
and pushes the code.

```powershell
.\init-github-repo.ps1 [-Private] [-Description "desc"] [-Path "dir"]
```

| Parameter | Description |
|-----------|-------------|
| `-Private` | Create a private repo (default: public; prompts if omitted) |
| `-Description` | Repository description (prompts if omitted) |
| `-Path` | Target folder (default: parent of the `git-helpers` folder) |

Creates a sensible `.gitignore` (node_modules, build output, env files, IDE
folders, `git-helpers/`, etc.) if the project doesn't have one, then runs
`gh repo create <folder-name> --source=. --push`.

## Notes

- Run `init-github-repo` first in a new project; `git-commit-push` requires an
  existing repo with a remote `origin`.
- If a project has no changes, `git-commit-push` exits without committing.
- Errors are explicit: missing git repo, missing `origin` remote, missing `gh`,
  or an empty commit message all stop the script with a message.
