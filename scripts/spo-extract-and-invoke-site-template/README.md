---
plugin: add-to-gallery
---

# Create a SharePoint site using the configuration of another site

## Background

This script uses PnP Powershell to extract the template of one SharePoint site and invoke it on another site. This lets you create sites with all the same lists and configuration as another SharePoint site. Perhaps you want to implement ALM practices around your SharePoint based development? This is a great way to get started!

Understand more about this script by reading this Microsoft 365 Platform Community Blog post - [Creating a SharePoint site using the configuration of another site with PnP Powershell](https://pnp.github.io/blog/post/creating-a-sharepoint-site-using-the-configuration-of-another-site-with-pnp-powershell/)

## Script - PnP PowerShell

```powershell

$ExistingSiteUrl = "https://yourtenant.sharepoint.com/sites/yourexistingsite"
$SiteTemplateFile = "\Template.xml"

Connect-PnPOnline -Url $ExistingSiteUrl -PnPManagementShell
Get-PnPSiteTemplate -Out $SiteTemplateFile

$TargetSiteUrl = "https://yourtenant.sharepoint.com/sites/yourtargetsite"

Connect-PnPOnline -Url $TargetSiteUrl -PnPManagementShell
Invoke-PnPSiteTemplate -Path $SiteTemplateFile

```


