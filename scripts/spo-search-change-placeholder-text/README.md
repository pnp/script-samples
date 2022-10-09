---
plugin: add-to-gallery
---

# Change the Placeholder text in SharePoint Search Box

## Summary

This sample script shows how to change the placeholder text in SharePoint online search box for a given (sub) site and/or for all the sites in a site collection.

Scenario inspired from this blog post: [SharePoint Online: How to change the placeholder text in the search box](https://ganeshsanapblogs.wordpress.com/2021/06/20/sharepoint-online-how-to-change-the-placeholder-text-in-the-search-box/)

![Outupt Screenshot](assets/output.png)

# [PnP PowerShell](#tab/pnpps)

```powershell

# SharePoint site collection url
$siteUrl = "https://<tenant>.sharepoint.com/contoso"

# Connect to SharePoint Online site  
Connect-PnPOnline -Url $siteUrl -Interactive

# Change the search box placeholder text for a given (sub) site
Set-PnPSearchSettings -Scope Web -SearchBoxPlaceholderText "Search Contoso Site"

# Change the search box placeholder text for all the sites in a site collection
Set-PnPSearchSettings -Scope Site -SearchBoxPlaceholderText "Search Contoso Site"

```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***

## Contributors

| Author(s) |
|-----------|
| [Ganesh Sanap](https://ganeshsanapblogs.wordpress.com/about) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-search-change-placeholder-text" aria-hidden="true" />
