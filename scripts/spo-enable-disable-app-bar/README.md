

# Enable and Disable App Bar in SharePoint Online

## Summary

This script sample demonstrates how to enable and disable the App Bar on SharePoint online sites by utilizing PnP PowerShell and SPO Management Shell. 

![Example Screenshot](assets/AppBar.png)

> [!Note]
> You cannot disable the SharePoint app bar permanently. However, you can temporarily disable the SharePoint app bar in your tenant using below PowerShell scripts until **March 31, 2023**.

# [PnP PowerShell](#tab/pnpps)

```powershell

# SharePoint online admin center URL
$siteUrl = "https://contoso-admin.sharepoint.com/"

# Connect to SharePoint online admin center
Connect-PnPOnline -Url $siteUrl -Interactive

# Set Temporarily Disable App Bar to True in order to disable
Set-PnPTemporarilyDisableAppBar $true

# Set Temporarily Disable App Bar to False in order to enable
Set-PnPTemporarilyDisableAppBar $false

# Disconnect SharePoint online connection
Disconnect-PnPOnline

```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [SPO Management Shell](#tab/spoms-ps)

```powershell

# SharePoint online admin center URL
$siteUrl = "https://contoso-admin.sharepoint.com/"

# Connect to SharePoint online admin center
Connect-SPOService -Url $siteUrl

# Set Temporarily Disable App Bar to True in order to disable
Set-SPOTemporarilyDisableAppBar $true

# Set Temporarily Disable App Bar to False in order to enable
Set-SPOTemporarilyDisableAppBar $false

# Disconnect SharePoint online connection
Disconnect-SPOService

```

[!INCLUDE [More about SPO Management Shell](../../docfx/includes/MORE-SPOMS.md)]

***

## Contributors

| Author |
|-----------|
| [Aman Panjwani](https://www.linkedin.com/in/aman-17-panjwani/) |
| [Ganesh Sanap](https://ganeshsanapblogs.wordpress.com/about) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-enable-disable-app-bar" aria-hidden="true" />
