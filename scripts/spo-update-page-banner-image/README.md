

# Update SharePoint Page Banner Image

## Summary

This sample script shows how to update the banner image at the top of the SharePoint online modern page using PnP PowerShell and CLI for Microsoft 365.

Scenario inspired from this blog post: [Update SharePoint Page Banner Image using PnP PowerShell](https://ganeshsanapblogs.wordpress.com/2023/03/22/update-sharepoint-page-banner-image-using-pnp-powershell/)

![Outupt Screenshot](assets/output.png)

# [PnP PowerShell](#tab/pnpps)

```powershell

# SharePoint online site url
$siteUrl = "https://contoso.sharepoint.com/sites/wlive"	

# Name of the site page
$pageName = "Open-Door-Policy"

# Server relative URL of the image to use in site page header
$imageUrl = "/sites/wlive/SiteAssets/work-remotely.jpeg"

# Connect to SharePoint Online site  
Connect-PnPOnline -Url $siteUrl -Interactive

# Update site page banner image
Set-PnPPage -Identity $pageName -HeaderType Custom -ServerRelativeImageUrl $imageUrl

```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365](#tab/cli-m365-ps)

```powershell

# SharePoint online site URL
$siteUrl = "https://contoso.sharepoint.com/sites/wlive"

# Name of the site page
$pageName = "Open-Door-Policy.aspx"

# Server relative URL of the image to use in site page header
$imageUrl = "/sites/wlive/SiteAssets/work-remotely.jpeg"

# Get Credentials to connect
$m365Status = m365 status
if ($m365Status -match "Logged Out") {
   m365 login
}

# Update site page banner image
m365 spo page header set --webUrl $siteUrl --pageName $pageName --type Custom --imageUrl $imageUrl

```

[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

***

## Contributors

| Author(s) |
|-----------|
| [Ganesh Sanap](https://ganeshsanapblogs.wordpress.com/about) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-update-page-banner-image" aria-hidden="true" />
