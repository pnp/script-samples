---
plugin: add-to-gallery
---

# Enable and Disable App Bar in SharePoint Online

## Summary

This script sample demonstrates how to enable and disable the App Bar on SharePoint online sites by utilizing PnP PowerShell and SPO Management Shell.

![Example Screenshot](assets/AppBar.png)


# [PnP PowerShell](#tab/pnpps)

```powershell


# SharePoint online Site url
$siteUrl = "https://contoso.sharepoint.com/sites/AmanSite"

# Connect to SharePoint online site
Connect-PnPOnline -Url $siteUrl -Interactive

# Set Temporarily Disable App Bar True in Order to Disable
Set-PnPTemporarilyDisableAppBar $true

# Set Temporarily Disable App Bar True in Order to Enable
Set-PnPTemporarilyDisableAppBar $false

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [SPO Management Shell](#tab/spoms-ps)

```powershell

# Connect to SPOService using Site URL
Connect-SPOService "https://contoso.sharepoint.com/sites/AmanSite"

# Set Temporarily Disable App Bar True in Order to Disable
Set-SPOTemporarilyDisableAppBar $true

# Set Temporarily Disable App Bar True in Order to Enable
Set-SPOTemporarilyDisableAppBar $false

```
[!INCLUDE [More about SPO Management Shell](../../docfx/includes/MORE-SPOMS.md)]

***

## Contributors

| Author |
|-----------|
| [Aman Panjwani](https://www.linkedin.com/in/aman-17-panjwani/) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-enable-disable-app-bar" aria-hidden="true" />
