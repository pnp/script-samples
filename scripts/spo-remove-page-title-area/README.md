---
plugin: add-to-gallery
---

# Remove Title Area from SharePoint Page

## Summary

This sample script shows how to remove the title area at the top of the page from SharePoint online site page using PnP PowerShell.

Scenario inspired from this blog post: [SharePoint Online: Create a blank page without header & title](https://ganeshsanapblogs.wordpress.com/2021/03/26/sharepoint-online-create-a-blank-page-without-header-and-title/)

![Outupt Screenshot](assets/output.png)

# [PnP PowerShell](#tab/pnpps)

```powershell

# SharePoint online site url
$siteUrl = "https://contoso.sharepoint.com/sites/SPConnect"	

# Connect to SharePoint Online site  
Connect-PnPOnline -Url $siteUrl -Interactive

# Set site page layout to remove title area
Set-PnPPage -Identity "MyPage" -LayoutType Home

# Use below command to bring back the page title area
# Set-PnPPage -Identity "MyPage" -LayoutType Article

```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***

## Contributors

| Author(s) |
|-----------|
| [Ganesh Sanap](https://ganeshsanapblogs.wordpress.com/about) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-remove-page-title-area" aria-hidden="true" />
