# Cmdlet Help Automation

This directory contains automation for updating cmdlet help documentation from external repositories.

## Overview

The cmdlet help documentation is automatically synchronized from three upstream repositories using `git clone`:

- **PnP PowerShell**: [pnp/powershell](https://github.com/pnp/powershell)
- **CLI for Microsoft 365**: [pnp/cli-microsoft365](https://github.com/pnp/cli-microsoft365)
- **SharePoint Online Management Shell**: [MicrosoftDocs/OfficeDocs-SharePoint-PowerShell](https://github.com/MicrosoftDocs/OfficeDocs-SharePoint-PowerShell)

## Directory Structure

The repositories are cloned into `docfx/help-repos/` directory during the GitHub Action workflow:

```
docfx/help-repos/
├── pnp-powershell/
├── cli-microsoft365/
└── OfficeDocs-SharePoint-PowerShell/
```

**Note:** The `help-repos/` directory is ignored by Git (via `.gitignore`) and is only created during the automated workflow or manual updates.

## Automation

### Monthly Updates

A GitHub Action workflow (`.github/workflows/update-cmdlet-help.yml`) runs monthly on the 1st day of each month to:

1. Clone the latest versions of all three documentation repositories
2. Run `Get-HelpJson.ps1` to regenerate help JSON files
3. Create a pull request if changes are detected

### Manual Updates

You can manually run the update process locally:

```bash
# Create the help-repos directory
mkdir -p docfx/help-repos
cd docfx/help-repos

# Clone the repositories
git clone --depth 1 https://github.com/pnp/powershell.git pnp-powershell
git clone --depth 1 https://github.com/pnp/cli-microsoft365.git cli-microsoft365
git clone --depth 1 https://github.com/MicrosoftDocs/OfficeDocs-SharePoint-PowerShell.git OfficeDocs-SharePoint-PowerShell

# Go back to docfx directory and run the script
cd ..
pwsh ./Get-HelpJson.ps1
```

## Get-HelpJson.ps1

This PowerShell script processes the documentation from the cloned repositories and generates JSON files containing cmdlet names and their documentation URLs.

### Generated Files

The script generates the following files in `docfx/assets/help/`:

- `powershell.help.json` - PnP PowerShell cmdlets
- `cli.help.json` - CLI for Microsoft 365 commands
- `spoms.help.json` - SharePoint Online Management Shell cmdlets

These JSON files are used by the documentation website to provide quick links to cmdlet documentation.

## Benefits

- **Always up-to-date**: Monthly automatic updates ensure documentation links stay current
- **Human review**: All updates go through a PR review process
- **No local clutter**: Cloned repositories are not committed to the main repository
- **Simple approach**: Uses standard `git clone` instead of submodules
- **No manual maintenance**: Eliminates the need to manually sync documentation
