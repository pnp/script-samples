---
plugin: add-to-gallery
---

# Update SharePoint Page Banner Image

## Summary

This sample script shows how to update the banner image at the top of the SharePoint online modern page using PnP PowerShell.

Scenario inspired from this blog post: [Update SharePoint Page Banner Image using PnP PowerShell](https://ganeshsanapblogs.wordpress.com/2023/03/22/update-sharepoint-page-banner-image-using-pnp-powershell/)

![Outupt Screenshot](assets/output.png)

# [PnP PowerShell](#tab/pnpps)

```powershell

# SharePoint online site url
$siteUrl = "https://contoso.sharepoint.com/sites/wlive"	

# Connect to SharePoint Online site  
Connect-PnPOnline -Url $siteUrl -Interactive

# Update site page banner image
Set-PnPPage -Identity "Open-Door-Policy" -HeaderType Custom -ServerRelativeImageUrl "/sites/wlive/SiteAssets/work-remotely.jpeg"

```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***

## Contributors

| Author(s) |
|-----------|
| [Ganesh Sanap](https://ganeshsanapblogs.wordpress.com/about) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-update-page-banner-image" aria-hidden="true" />
