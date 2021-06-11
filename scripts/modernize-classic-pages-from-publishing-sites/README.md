---
plugin: add-to-gallery
---

# Modernizing classic pages from on-premises sites

## Summary

This is a **Modernizing classic pages from publishing sites** example to show the conversion of an on-premises 2013 publishing page over to SharePoint Online modern sites - this includes the extraction of the mapping files and conversion process.

> [!note]
> This script uses the older [SharePoint PnP PowerShell Online module](https://www.powershellgallery.com/packages/SharePointPnPPowerShellOnline/3.29.2101.0)

![Example Screenshot](assets/transform.jpg)

# [PnP PowerShell](#tab/pnpps)

```powershell

#-----------------------------
# Publishing Portal Commands
#-----------------------------

$sp13Conn = Connect-PnPOnline http://portal2013/en -Credentials OnPrem -ReturnConnection
$spOnlineConn = Connect-PnPOnline https://contoso.sharepoint.com/sites/PnPKatchup -Credentials Online -ReturnConnection

# Exporting Page Layout File
#------------------------------
# Example based on a page
Export-PnPClientSidePageMapping `
    -CustomPageLayoutMapping `
    -PublishingPage "Quality-Cherry-Cake.aspx" `
    -Folder "C:\temp\Demo" `
    -Connection $sp13Conn

# Example based to export all the layouts
Export-PnPClientSidePageMapping `
    -CustomPageLayoutMapping `
    -Folder "C:\temp\Demo" `
    -Connection $sp13Conn `
    -BuiltInWebPartMapping


# Transforming Page based on Exported Content
#-----------------------------------------------
ConvertTo-PnPClientSidePage -Identity "Quality-Cherry-Cake.aspx" -PublishingPage `
    -TargetConnection $spOnlineConn -Connection $sp13Conn `
    -Overwrite `
    -PageLayoutMapping C:\temp\Demo\custompagelayoutmapping-f3629db3-3e4d-48c4-b904-6fffab6dbb65-quality-cherry-cake.xml `
    -UserMappingFile C:\temp\Demo\usermapping.csv `
    -UrlMappingFile C:\temp\Demo\urlmapping.csv `
    -KeepPageCreationModificationInformation `
    -DisablePageComments `
    -LogType Console


```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Contributors

| Author(s) |
|-----------|
| Paul Bullock |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]

<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/modernize-classic-pages-from-publishing-sites" aria-hidden="true" />