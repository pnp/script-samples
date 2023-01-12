---
plugin: add-to-gallery
---

# Create and add list template to SharePoint site with content types,site columns and list views 

## Summary

  [Creating site designs](https://learn.microsoft.com/en-us/sharepoint/dev/declarative-customization/site-design-overview) provides an option to easily provision sites consistently.
 
More about site design 
 [https://learn.microsoft.com/en-us/sharepoint/dev/declarative-customization/site-design-overview](https://learn.microsoft.com/en-us/sharepoint/dev/declarative-customization/site-design-overview)

  ![Example Screenshot](assets/example.png)

# [SPO Management Shell](#tab/spoms-ps)

```powershell

$adminSiteUrl = "https://tenant-admin.sharepoint.com/"
$siteUrl = "https://tenant.sharepoint.com/teams/D-team-Site"
$siteScriptFile = "C:\temp\TeamSite1.json";
$relativeListUrls = "/Lists/Issue tracker list", "/Lists/Progress tracker list";
$siteScriptTitle = "Test Team Site Common Script"
$siteDesignTitle = "Test Team Site Design"
$webTemplate = "64" #64 = Team Site, 68 = Communication Site, 1 = Groupless Team Site
$siteDesignDescription = "Test team site design with external sharing disabled and Open Access and Site Member Access library with views"
$previewImageUrl =  "https://tenant.sharepoint.com/sites/Assets/siteDesign-logo.png"

Connect-PnPOnline -url $siteUrl -interactive
#Team Site, only once and modify to include options to remove links and other actions
$extracted = Get-PnPSiteScriptFromWeb –Url $siteUrl -IncludeTheme -IncludeBranding -IncludeSiteExternalSharingCapability –IncludeRegionalSettings -IncludeLinksToExportedItems –IncludedLists $relativeListUrls
$extracted | Out-File $siteScriptFile

$siteScript =  Add-PnPSiteScript -Title $siteScriptTitle -Content (Get-Content $siteScriptFile -Raw)

$siteDesign = Add-PnPSiteDesign -SiteScriptIds $siteScript.Id -Title $siteDesignTitle -WebTemplate $webTemplate -Description $siteDesignDescription -PreviewImageUrl $previewImageUrl 

Grant-PnPSiteDesignRights -Identity  -Principals "test1@tenant.sharepoint.com"


```
![Results Screenshot](assets/results.png)

> [!Note]
> SharePoint tenant admin right are required to be able add list design

[!INCLUDE [More about SPO Management Shell](../../docfx/includes/MORE-SPOMS.md)]

***

## Contributors

| Author(s) |
|-----------|
| Reshmee Auckloo |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-add-sitedesign-permissions" aria-hidden="true" />

