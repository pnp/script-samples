---
plugin: add-to-gallery
---

# Generate Markdown Report of LCIDs

## Summary

This is a simple report listing out the language IDs (LCIDs) of a SharePoint site and generated a markdown formatted table of the output. After this, the report is output to the shell and copied to the clipboard.

![Example Screenshot](assets/example.png)

# [PnP PowerShell](#tab/pnpps)

```powershell

Connect-PnPOnline -Url "https://contoso.sharepoint.com"

$languages = (Get-PnPWeb -Includes RegionalSettings.InstalledLanguages).RegionalSettings.InstalledLanguages | `
        Sort-Object -Property "DisplayName"

# Markdown format
$markdown = ""
$markdown += "| Name | Language Tag | LCID |`n"
$markdown += "|------|--------------|------|`n"

$languages | foreach-object{ $markdown += "| $($_.DisplayName) | $($_.LanguageTag) | $($_.LCID) |`n"} 

Write-Host $markdown

# Copy to clipboard
$markdown | clip

Write-Host "Script Complete! :)" -ForegroundColor Green

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Contributors

| Author(s) |
|-----------|
| Paul Bullock |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]

<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/generate-markdown-lcids" aria-hidden="true" />