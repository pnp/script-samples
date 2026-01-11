# Cmdlet Help Automation

This directory contains automation for updating cmdlet help documentation from external repositories.

## Overview

The cmdlet help documentation is automatically synchronized from three upstream repositories using Git submodules:

- **PnP PowerShell**: [pnp/powershell](https://github.com/pnp/powershell)
- **CLI for Microsoft 365**: [pnp/cli-microsoft365](https://github.com/pnp/cli-microsoft365)
- **SharePoint Online Management Shell**: [MicrosoftDocs/OfficeDocs-SharePoint-PowerShell](https://github.com/MicrosoftDocs/OfficeDocs-SharePoint-PowerShell)

## Git Submodules

The submodules are located in `docfx/help-repos/` directory:

```
docfx/help-repos/
├── pnp-powershell/
├── cli-microsoft365/
└── OfficeDocs-SharePoint-PowerShell/
```

### Working with Submodules

To clone the repository with submodules:
```bash
git clone --recurse-submodules https://github.com/pnp/script-samples.git
```

To update submodules to the latest version:
```bash
git submodule update --remote --merge
```

## Automation

### Monthly Updates

A GitHub Action workflow (`.github/workflows/update-cmdlet-help.yml`) runs monthly on the 1st day of each month to:

1. Update all submodules to their latest versions
2. Run `Get-HelpJson.ps1` to regenerate help JSON files
3. Create a pull request if changes are detected

### Manual Updates

You can manually trigger the workflow from the GitHub Actions tab or run the script locally:

```powershell
cd docfx
./Get-HelpJson.ps1
```

## Get-HelpJson.ps1

This PowerShell script processes the documentation from the submodules and generates JSON files containing cmdlet names and their documentation URLs.

### Generated Files

The script generates the following files in `docfx/assets/help/`:

- `powershell.help.json` - PnP PowerShell cmdlets
- `cli.help.json` - CLI for Microsoft 365 commands
- `spoms.help.json` - SharePoint Online Management Shell cmdlets

These JSON files are used by the documentation website to provide quick links to cmdlet documentation.

## Benefits

- **Always up-to-date**: Monthly automatic updates ensure documentation links stay current
- **Human review**: All updates go through a PR review process
- **Traceability**: Git submodules track exact versions of upstream documentation
- **No manual maintenance**: Eliminates the need to manually sync documentation
