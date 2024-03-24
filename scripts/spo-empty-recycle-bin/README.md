---
plugin: add-to-gallery
---

# Empty SharePoint Online Site Recycle Bin

## Summary

This sample script shows how to empty SharePoint online site first stage and second stage recycle bin.

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

# [CLI for Microsoft 365](#tab/cli-m365-ps)

```powershell

# SharePoint online site URL
$siteUrl = "https://contoso.sharepoint.com/sites/SPConnect"

# Get Credentials to connect
$m365Status = m365 status
if ($m365Status -match "Logged Out") {
   m365 login
}

# Empty first stage recycle bin in SharePoint site permanently
m365 spo site recyclebinitem clear --siteUrl $siteUrl

# Empty second stage recycle bin in SharePoint site
m365 spo site recyclebinitem clear --siteUrl $siteUrl --secondary

```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

***

## Contributors

| Author(s) |
|-----------|
| [Ganesh Sanap](https://ganeshsanapblogs.wordpress.com/) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-empty-recycle-bin" aria-hidden="true" />
