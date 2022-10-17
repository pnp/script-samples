---
plugin: add-to-gallery
---

# Create a SharePoint site using the configuration of another site

## Summary

This script uses PnP Powershell to extract the template of one SharePoint site and invoke it on another site. This lets you create sites with all the same lists and configuration as another SharePoint site. Perhaps you want to implement ALM practices around your SharePoint based development? This is a great way to get started!


# [PnP PowerShell](#tab/pnpps)
```powershell

$ExistingSiteUrl = "https://yourtenant.sharepoint.com/sites/yourexistingsite"
$SiteTemplateFile = "\Template.xml"

Connect-PnPOnline -Url $ExistingSiteUrl -PnPManagementShell
Get-PnPSiteTemplate -Out $SiteTemplateFile

$TargetSiteUrl = "https://yourtenant.sharepoint.com/sites/yourtargetsite"

Connect-PnPOnline -Url $TargetSiteUrl -PnPManagementShell
Invoke-PnPSiteTemplate -Path $SiteTemplateFile

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

## Source Credit

Understand more about this script by reading this Microsoft 365 Platform Community Blog post - [Creating a SharePoint site using the configuration of another site with PnP Powershell](https://pnp.github.io/blog/post/creating-a-sharepoint-site-using-the-configuration-of-another-site-with-pnp-powershell/)


## Contributors

| Author(s) |
|-----------|
| Lewis Baybutt |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-extract-and-invoke-site-template" aria-hidden="true" />

