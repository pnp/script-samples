---
plugin: add-to-gallery-preparation
---

# Add Page template to Site

## Summary

This sample script shows how to add a page template to a SharePoint Online site collection using PnP PowerShell.

![Example Screenshot](assets/example.gif)

## Implementation

- Open Visual Studio Code
- Create a new ps1 file
- Write a script as below
- Run the script like in the .Example of the Synopsis

# [PnP PowerShell](#tab/pnpps)

```powershell
<# .SYNOPSIS
    Provision a page templates.

.DESCRIPTION
    You need to have the latest version of PnP PowerShell

    Provision a single page template to a SharePoint Online site collection.

.PARAMETER SiteCollection
    Specifies the URL of the SharePoint Online Site Collection.

.PARAMETER PageName
    Specifies the name of the new page template.

.EXAMPLE
    PS> .\add_spopagetemplate.ps1 -SiteCollection "https://contoso.sharepoint.com" -PageName "Contoso Page Template"
  
#>

param ([Parameter(Mandatory)]$SiteCollection,[Parameter(Mandatory)]$PageName)

# Variables
$LogFileName = "add_spopagetemplates_" + $(get-date -f filedatetime) + ".txt"

#####################
Start-Transcript -Path .\logs\$LogFileName -NoClobber 

Connect-PnPOnline -Url $SiteCollection -Interactive

Add-PnPPage -Name $PageName -HeaderLayoutType FullWidthImage -PromoteAs Template -Publish

Disconnect-PnPOnline

#####################
Stop-Transcript
```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

## Contributors

| Author(s) |
|-----------|
| [@Expiscornovus](https://twitter.com/expiscornovus) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/template-script-submission" aria-hidden="true" />