---
plugin: add-to-gallery
---

# Disable SharePoint List Commenting at list level

## Summary

This sample script shows how to disable commenting feature in SharePoint online lists at list level.

Scenario inspired from this blog post: [Enable/Disable SharePoint Online List Comments using PnP PowerShell](https://ganeshsanapblogs.wordpress.com/2023/03/19/enable-disable-sharepoint-online-list-comments-using-pnp-powershell/)

If you want to enable/disable SharePoint list commenting at tenant level, check this PnP script sample: [Disable SharePoint List Commenting at tenant level](https://pnp.github.io/script-samples/spo-disable-list-comments-tenant/README.html?tabs=pnpps)

![Outupt Screenshot](assets/output.png)

# [PnP PowerShell](#tab/pnpps)

```powershell

# SharePoint online site URL
$siteUrl = "https://contoso.sharepoint.com/sites/SPConnect"

# Display name of SharePoint list
$listName = "Comments List"

# Connect to SharePoint online site
Connect-PnPOnline -Url $siteUrl -Interactive
 
# Disable SharePoint online list comments
Set-PnPList -Identity $listName -DisableCommenting $true

```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365](#tab/cli-m365-ps)

```powershell

# SharePoint online site URL
$siteUrl = "https://contoso.sharepoint.com/sites/SPConnect"

# Display name of SharePoint list
$listName = "Comments List"

# Get Credentials to connect
$m365Status = m365 status
if ($m365Status -match "Logged Out") {
   m365 login
}

# Disable SharePoint online list comments
m365 spo list set --webUrl $siteUrl --title $listName --disableCommenting true

```

[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

***

## Contributors

| Author(s) |
|-----------|
| [Ganesh Sanap](https://ganeshsanapblogs.wordpress.com/about) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-disable-list-comments" aria-hidden="true" />
