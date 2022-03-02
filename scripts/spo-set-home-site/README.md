---
plugin: add-to-gallery
---

# Set Home site for SharePoint tenant

## Summary

This sample script shows how to set a communication site as a home site for SharePoint online tenant.

Scenario inspired from this blog post: [Set up a home site in SharePoint Online](https://ganeshsanapblogs.wordpress.com/2021/03/17/set-up-a-home-site-in-sharepoint-online)

![Outupt Screenshot](assets/output.png)

# [PnP PowerShell](#tab/pnpps)

```powershell

# SharePoint tenant admin site collection url
$adminSiteUrl = "https://<tenant>-admin.sharepoint.com"

# Communication site collection url
$commSiteUrl = "https://<tenant>.sharepoint.com/communicationsite"

# Connect to SharePoint Online site  
Connect-PnPOnline -Url $adminSiteUrl -Interactive

# Set communication site as the home site
Set-PnPHomeSite -HomeSiteUrl $commSiteUrl

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365 with PowerShell](#tab/cli-m365-ps)
```powershell

# Ensure connected to tenant
$m365Status = m365 status
if ($m365Status -eq "Logged Out") {
    m365 login
}

# Communication site collection url
$commSiteUrl = "https://<tenant>.sharepoint.com/communicationsite"

# Set communication site as the home site
m365 spo homesite set --siteUrl $commSiteUrl

```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

***

## Contributors

| Author(s) |
|-----------|
| [Ganesh Sanap](https://twitter.com/GaneshSanap20) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-set-home-site" aria-hidden="true" />
