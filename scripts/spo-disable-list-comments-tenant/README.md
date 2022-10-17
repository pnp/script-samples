---
plugin: add-to-gallery
---

# Disable SharePoint List Commenting at tenant level

## Summary

This sample script shows how to disable commenting feature in SharePoint online lists at tenant level.

Scenario inspired from this blog post: [How to Enable/Disable the commenting in SharePoint Online/Microsoft Lists](https://ganeshsanapblogs.wordpress.com/2021/01/09/how-to-enable-disable-the-commenting-in-sharepoint-online-microsoft-lists/)

![Outupt Screenshot](assets/output.png)

# [PnP PowerShell](#tab/pnpps)

```powershell

# SharePoint online admin site url
$siteUrl = "https://<tenant>-admin.sharepoint.com/"	

# Connect to SharePoint Online site  
Connect-PnPOnline -Url $siteUrl -Interactive

# To disable comments on list items
Set-PnPTenant -CommentsOnListItemsDisabled $true

# To enable comments on list items
Set-PnPTenant -CommentsOnListItemsDisabled $false

```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***

## Contributors

| Author(s) |
|-----------|
| [Ganesh Sanap](https://ganeshsanapblogs.wordpress.com/about) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-disable-list-comments-tenant" aria-hidden="true" />
