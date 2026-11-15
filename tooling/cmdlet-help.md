# Refresh command documentation links

The Astro gallery uses the retained command-help index to link recognized commands in code and tags to their tool documentation. This tooling refreshes the index; it does not execute sample scripts.

The existing monthly workflow clones these public documentation repositories under the ignored `tooling/help-repos/` directory:

- [PnP PowerShell](https://github.com/pnp/powershell)
- [CLI for Microsoft 365](https://github.com/pnp/cli-microsoft365)
- [SharePoint Online Management Shell](https://github.com/MicrosoftDocs/OfficeDocs-SharePoint-PowerShell)

It runs `tooling/Get-HelpJson.ps1` and opens a reviewable update when the generated help JSON changes.

## Run a refresh manually

From the repository root in PowerShell:

```powershell
New-Item -ItemType Directory -Path .\tooling\help-repos -Force
Set-Location .\tooling\help-repos
git clone --depth 1 https://github.com/pnp/powershell.git pnp-powershell
git clone --depth 1 https://github.com/pnp/cli-microsoft365.git cli-microsoft365
git clone --depth 1 https://github.com/MicrosoftDocs/OfficeDocs-SharePoint-PowerShell.git OfficeDocs-SharePoint-PowerShell
Set-Location ..
.\Get-HelpJson.ps1
```

For an existing checkout, update the cloned repositories instead of cloning over them. Review changes under `docs/assets/help/`, then run the gallery tests and build before committing.
