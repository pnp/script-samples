---
plugin: add-to-gallery
---

# Allow custom scripts in SharePoint online site

## Summary

This sample script shows how to allow use of custom scripts in SharePoint online at site level.

Scenario inspired from this blog post: [Allow use of custom scripts in SharePoint Online using PowerShell](https://ganeshsanapblogs.wordpress.com/2023/05/18/allow-use-of-custom-scripts-in-sharepoint-online-using-powershell/)

# [SPO Management Shell](#tab/spoms-ps)

```powershell

# SharePoint online admin center URL
$adminCenterUrl = "https://contoso-admin.sharepoint.com/"

# SharePoint online site URL
$siteUrl = Read-Host -Prompt "Enter your SharePoint site URL (e.g https://contoso.sharepoint.com/sites/SPConnect)"

# Connect to SharePoint online admin center
Connect-SPOService -Url $adminCenterUrl

# Allow custom scripts on SharePoint online site
Set-SPOSite $siteUrl -DenyAddAndCustomizePages 0

# Disconnect SharePoint online connection
Disconnect-SPOService

```

[!INCLUDE [More about SPO Management Shell](../../docfx/includes/MORE-SPOMS.md)]

# [PnP PowerShell](#tab/pnpps)

```powershell

# SharePoint online site URL
$siteUrl = Read-Host -Prompt "Enter your SharePoint site URL (e.g https://contoso.sharepoint.com/sites/SPConnect)"

# Connect to SharePoint online site
Connect-PnPOnline -Url $siteUrl -Interactive

# Allow custom scripts on SharePoint online site
Set-PnPSite -NoScriptSite $false

# Disconnect SharePoint online connection
Disconnect-PnPOnline

```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365](#tab/cli-m365-ps)

```powershell

# SharePoint online site URL
$siteUrl = Read-Host -Prompt "Enter your SharePoint site URL (e.g https://contoso.sharepoint.com/sites/SPConnect)"

# Get Credentials to connect
$m365Status = m365 status
if ($m365Status -match "Logged Out") {
   m365 login
}

# Allow custom scripts on SharePoint online site collection
m365 spo site set --url $siteUrl --noScriptSite $false

# Disconnect CLI for Microsoft connection
m365 logout

```

[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

***

## Contributors

| Author(s) |
|-----------|
| [Ganesh Sanap](https://ganeshsanapblogs.wordpress.com/about) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-allow-custom-scripts" aria-hidden="true" />
