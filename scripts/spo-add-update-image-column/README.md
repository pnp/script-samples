---
plugin: add-to-gallery
---

# Add/Update Image in SharePoint Image column

## Summary

This sample script shows how to create a new list item with image column and update existing list item to update the image column using PnP PowerShell.

Scenario inspired from this blog post: [Add/Update image columns in SharePoint/Microsoft Lists using PnP PowerShell](https://ganeshsanapblogs.wordpress.com/2022/10/13/add-update-image-columns-in-sharepoint-microsoft-lists-using-pnp-powershell/)

![Outupt Screenshot](assets/output.png)

# [PnP PowerShell](#tab/pnpps)

```powershell

# SharePoint online site url
$siteUrl = "https://contoso.sharepoint.com/sites/SPConnect"	

# Connect to SharePoint Online site  
Connect-PnPOnline -Url $siteUrl -Interactive

# Create new list item with image column
Add-PnPListItem -List "Logo Universe" -Values @{"Title" = "PnP PowerShell"; "Image" = "{'type':'thumbnail','fileName':'PnP-PowerShell-Blue.png','fieldName':'Image','serverUrl':'https://contoso.sharepoint.com','serverRelativeUrl':'/sites/SPConnect/SiteAssets/Lists/dbc6f551-252b-462f-8002-c8f88d0d12d5/PnP-PowerShell-Blue.png'}"}

# Update list item with image column
Set-PnPListItem -List "Logo Universe" -Identity 12 -Values @{"Image" = "{'type':'thumbnail','fileName':'PnP-PowerShell-Blue.png','fieldName':'Image','serverUrl':'https://contoso.sharepoint.com','serverRelativeUrl':'/sites/SPConnect/SiteAssets/Lists/dbc6f551-252b-462f-8002-c8f88d0d12d5/PnP-PowerShell-Green.png'}"}

```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***

## Contributors

| Author(s) |
|-----------|
| [Ganesh Sanap](https://ganeshsanapblogs.wordpress.com/about) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-add-update-image-column" aria-hidden="true" />
