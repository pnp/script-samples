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

# Get the SharePoint online list 
$list = Get-PnPList -Identity $listName
 
# Disable SharePoint online list Comments
$list.DisableCommenting = $true
$list.Update()
Invoke-PnPQuery

```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***

## Contributors

| Author(s) |
|-----------|
| [Ganesh Sanap](https://ganeshsanapblogs.wordpress.com/about) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-disable-list-comments" aria-hidden="true" />
