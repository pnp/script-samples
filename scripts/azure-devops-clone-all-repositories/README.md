# Azure DevOps Repo Cloner (PowerShell & AzureCli)

## Summary

A **secure, user-friendly PowerShell script** to clone **all accessible Git repositories** from an Azure DevOps organization — **no admin rights required**.

## Features

- **Interactive prompts** for:
  - Organization URL
  - Local clone folder
  - **Log file path** (auto-creates `.log`, validates write access)
- **Logs to both console and file** with timestamps and color-coding
- **Only clones repos the user has access to** — respects Azure DevOps permissions
- **Skips already cloned repos** — safe to re-run
- **No local admin rights needed** — works for developers, contributors, externals
- **Supports PAT or browser login** (`$env:AZURE_DEVOPS_EXT_PAT`)
- **Robust error handling** — never crashes on permission issues

## Requirements

- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) (`az`)
- `azure-devops` extension (`az extension add --name azure-devops`)
- Git (`git`)
- PowerShell 5.1+ (7+ recommended)

---

## How to Use

1. **Save** the script as `Clone-All-DevOpsRepos.ps1`
2. **Run in PowerShell**:


```powershell
.\Clone-All-DevOpsRepos.ps1
```

# [Azure CLI](#tab/azure-cli)

```powershell

<#
.SYNOPSIS
    Clone all Azure DevOps Git repositories from every project.

.DESCRIPTION
    Interactive or non-interactive (PAT). Organizes repos as:
    <LocalFolder>/<Project>/<Repo>
    Logs to both console and a user-specified log file (with .log auto-added).

.NOTES
    • Requires: Azure CLI + `azure-devops` extension
    • Use $env:AZURE_DEVOPS_EXT_PAT for CI/CD
    • PowerShell 7+ recommended

.EXAMPLE
    .\Clone-All-DevOpsRepos.ps1

    # Prompts for:
    #   Organization URL
    #   Local folder path
    #   Log file path (e.g. C:\Logs\clone.log)
#>

[CmdletBinding()]
param()

# Global log stream and path
$LogStream = $null
$LogFilePath = $null

# -------------------------------------------------
#  Helper: Colored, timestamped logging (console + file)
# -------------------------------------------------
function Write-Log {
    param(
        [string]$Message,
        [ValidateSet('INFO', 'WARN', 'ERROR', 'SUCCESS')][string]$Level = 'INFO'
    )
    $timestamp = Get-Date -Format "HH:mm:ss"
    $logLine = "[$timestamp] [$Level] $Message"

    # Console output with color
    $color = switch ($Level) {
        'INFO' { 'White' }
        'WARN' { 'Yellow' }
        'ERROR' { 'Red' }
        'SUCCESS' { 'Green' }
    }
    Write-Host $logLine -ForegroundColor $color

    # Write to file
    if ($LogStream) {
        try { $LogStream.WriteLine($logLine) } catch { }
    }
}

# -------------------------------------------------
#  1. Get Organization URL
# -------------------------------------------------
do {
    $org = Read-Host "Enter Azure DevOps organization URL (e.g. https://dev.azure.com/contoso)"
    $org = $org.Trim()
    if (-not $org) { Write-Host "Organization URL cannot be empty." -ForegroundColor Red }
} while (-not $org)

Write-Log "Using organization: $org" SUCCESS

# -------------------------------------------------
#  2. Get Local Clone Folder
# -------------------------------------------------
do {
    $folder = Read-Host "Enter local folder to clone repos into (e.g. C:\Repos or ./backup)"
    $folder = $folder.Trim()
    if (-not $folder) { Write-Host "Folder path cannot be empty." -ForegroundColor Red; continue }

    try {
        $resolved = Resolve-Path -Path $folder -ErrorAction Stop
        $LocalFolder = $resolved.Path
        break
    }
    catch {
        try {
            New-Item -ItemType Directory -Path $folder -Force | Out-Null
            $LocalFolder = (Resolve-Path -Path $folder).Path
            break
        }
        catch {
            Write-Host "Invalid or inaccessible path: $folder" -ForegroundColor Red
        }
    }
} while ($true)

Write-Log "Cloning into: $LocalFolder" SUCCESS

# -------------------------------------------------
#  3. Get Log FILE Path (with .log auto-add)
# -------------------------------------------------
do {
    Write-Host "`nEnter FULL PATH for LOG FILE (e.g. C:\Logs\clone.log or ./clone.log)" -ForegroundColor Cyan
    $logInput = Read-Host "Log file path"
    $logInput = $logInput.Trim()
    if (-not $logInput) {
        Write-Host "Log file path is required." -ForegroundColor Red
        continue
    }

    # Auto-add .log if missing
    if (-not $logInput.EndsWith('.log', [System.StringComparison]::OrdinalIgnoreCase)) {
        $logInput = "$logInput.log"
        Write-Host "Auto-added .log → $logInput" -ForegroundColor DarkGray
    }

    $logDir = Split-Path $logInput -Parent
    if (-not $logDir) { $logDir = "." }

    try {
        # Ensure directory exists
        if (-not (Test-Path $logDir)) {
            New-Item -ItemType Directory -Path $logDir -Force | Out-Null
            Write-Log "Created log directory: $logDir" INFO
        }

        # Test write access
        $testFile = Join-Path $logDir "log_$(Get-Random).tmp"
        "log" | Out-File $testFile -Force -Encoding utf8
        Remove-Item $testFile -Force

        # Resolve full path
        $LogFilePath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($logInput)

        # Open stream for appending
        $LogStream = [System.IO.StreamWriter]::new($LogFilePath, $true, [System.Text.Encoding]::UTF8)
        $LogStream.AutoFlush = $true

        Write-Log "Logging enabled to: $LogFilePath" SUCCESS
        break
    }
    catch {
        Write-Host "Cannot write to: $logInput" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.Message -like "*Access*denied*") {
            Write-Host "Tip: Run as Administrator, or use a user-writable folder (e.g. Documents)." -ForegroundColor Yellow
        }
    }
} while ($true)

# -------------------------------------------------
#  4. Ensure Azure CLI + extension
# -------------------------------------------------
Write-Log "Installing azure-devops extension..." INFO
az extension add --name azure-devops --yes | Out-Null
if ($LASTEXITCODE) { Write-Log "Failed to install extension" ERROR; exit 1 }

# -------------------------------------------------
#  5. Authenticate
# -------------------------------------------------
Write-Log "Authenticating to Azure DevOps..." INFO
if (-not $env:AZURE_DEVOPS_EXT_PAT) {
    Write-Host "Opening browser for login (close when done)..." -ForegroundColor Cyan
    az login --allow-no-subscriptions | Out-Null
    if ($LASTEXITCODE) { Write-Log "Login failed" ERROR; exit 1 }
}
az devops configure --defaults organization=$org | Out-Null
if ($LASTEXITCODE) { Write-Log "Failed to set default org" ERROR; exit 1 }

# -------------------------------------------------
#  6. Get all projects
# -------------------------------------------------
Write-Log "Fetching projects..." INFO
$projectsJson = az devops project list --organization $org -o json
if ($LASTEXITCODE) { Write-Log "Failed to list projects" ERROR; exit 1 }

$projects = ($projectsJson | ConvertFrom-Json).value | Select-Object -ExpandProperty name
if (-not $projects) {
    Write-Log "No projects found. Check URL and permissions." ERROR
    if ($LogStream) { $LogStream.Close(); $LogStream.Dispose() }
    exit 1
}

Write-Log "Found $($projects.Count) project(s): $($projects -join ', ')" SUCCESS

# -------------------------------------------------
#  7. Function: Clone a single repo
# -------------------------------------------------
function Clone-Repo {
    param($Project, $RepoName, $RepoUrl, $Destination)

    if (Test-Path $Destination) {
        Write-Log "  [SKIP] $RepoName (already exists)" WARN
        return
    }

    Write-Log "  [CLONE] $RepoName ..." INFO
    $output = git clone $RepoUrl $Destination 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Log "  [DONE] $RepoName" SUCCESS
    }
    else {
        $errorMsg = ($output -join "`n").Trim()
        Write-Log "  [FAIL] $RepoName`n$errorMsg" ERROR
    }
}

# -------------------------------------------------
#  8. Main: Process each project (Sequential)
# -------------------------------------------------
foreach ($proj in $projects) {
    Write-Log "`n=== Project: $proj ===" INFO

    $reposJson = az repos list --org $org --project $proj `
        --query "[].{Name:name, Url:remoteUrl}" -o json

    if ($LASTEXITCODE) {
        Write-Log "  Failed to list repos in $proj" WARN
        continue
    }

    $repos = $reposJson | ConvertFrom-Json
    if (-not $repos) {
        Write-Log "  No repositories in $proj" WARN
        continue
    }

    foreach ($repo in $repos) {
        $destPath = Join-Path $LocalFolder "$proj/$($repo.Name)"
        $projFolder = Split-Path $destPath -Parent
        New-Item -ItemType Directory -Force -Path $projFolder | Out-Null

        Clone-Repo -Project $proj -RepoName $repo.Name -RepoUrl $repo.Url -Destination $destPath
    }
}

# -------------------------------------------------
#  9. Finalize
# -------------------------------------------------
Write-Log "`nCloning complete! All repositories are in:" SUCCESS
Write-Host "    $LocalFolder" -ForegroundColor Cyan
Write-Log "Log file: $LogFilePath" INFO

# Close log stream
if ($LogStream) {
    $LogStream.Close()
    $LogStream.Dispose()
}

```
[!INCLUDE [More about Azure CLI](../../docfx/includes/MORE-AZURECLI.md)]
***

## Contributors

| Author(s)       |
| --------------- |
| Harminder Singh |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/azure-devops-clone-all-repositories" aria-hidden="true" />
