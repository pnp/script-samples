---
plugin: add-to-gallery
---

# Empty SharePoint Online Site Recycle Bin

## Summary

This sample script shows how to empty SharePoint online site first stage and second stage recycle bin using PnP PowerShell.

Scenario inspired from this blog post: [SharePoint Online: Empty Recycle Bin using PnP PowerShell](https://ganeshsanapblogs.wordpress.com/2023/03/29/empty-sharepoint-online-recycle-bin-using-pnp-powershell/)

![Outupt Screenshot](assets/output.png)

# [PnP PowerShell](#tab/pnpps)

```powershell

# SharePoint online site URL
$siteUrl = "https://contoso.sharepoint.com/sites/SPConnect"

# Connect to SharePoint online site
Connect-PnPOnline -Url $siteUrl -Interactive

# Move all items from the first stage recycle bin to the second stage recycle bin
Move-PnPRecycleBinItem

# Empty second stage recycle bin in SharePoint site
Clear-PnPRecycleBinItem -SecondStageOnly

# Empty both first stage and second stage recycle bin in SharePoint site
Clear-PnPRecycleBinItem -All

```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***

## Contributors

| Author(s) |
|-----------|
| [Ganesh Sanap](https://ganeshsanapblogs.wordpress.com/) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-empty-recycle-bin" aria-hidden="true" />
