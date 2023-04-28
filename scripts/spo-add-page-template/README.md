---
plugin: add-to-gallery
---

# Add Page template to Site

## Summary

This sample script shows how to add a page template to a SharePoint Online site collection using PnP PowerShell and CLI for Microsoft 365.

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

# [CLI for Microsoft 365](#tab/cli-m365-ps)

```powershell

# SharePoint online site URL
$siteUrl = "https://contoso.sharepoint.com/sites/SPConnect"

# Name of page template to add
$pageTemplateName = "pagetemplate.aspx"

# Get Credentials to connect
$m365Status = m365 status
if ($m365Status -match "Logged Out") {
   m365 login
}

# Add page template to SharePoint online site
m365 spo page add --name $pageTemplateName --webUrl $siteUrl --promoteAs Template

```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

## Contributors

| Author(s) |
|-----------|
| [@Expiscornovus](https://twitter.com/expiscornovus) |
| [Ganesh Sanap](https://ganeshsanapblogs.wordpress.com/about) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-add-page-template" aria-hidden="true" />