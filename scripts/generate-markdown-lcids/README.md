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

# [CLI for Microsoft 365](#tab/cli-m365-ps)
```powershell

$m365Status = m365 status
if ($m365Status -match "Logged Out") {
    m365 login
}

$languages = m365 spo web installedlanguage list --webUrl 'https://contoso.sharepoint.com'
$languages = $languages | ConvertFrom-Json

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
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
***

## Contributors

| Author(s) |
|-----------|
| Paul Bullock |
| [Adam Wójcik](https://github.com/Adam-it)|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]

<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/generate-markdown-lcids" aria-hidden="true" />
