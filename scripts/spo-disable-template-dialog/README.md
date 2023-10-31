---
plugin: add-to-gallery
---

# Disable Web Templates Gallery First Run Dialog

## Summary

When accessing a newly created site collection in SharePoint Online, you are presented with a dialog to select a web template. This script will disable this dialog.

![Example Screenshot](assets/example.png)


# [PnP PowerShell](#tab/pnpps)

```powershell

#connect to the site collection using one of the many options available in PnP PowerShell
$localConn = Connect-PnPOnline -Url $siteUrl -ClientId $ClientId -CertificateBase64Encoded $CertificateBase64Encoded -Tenant $TenantName -ReturnConnection -erroraction stop
                
$Web = Get-PnPWeb -Includes WebTemplatesGalleryFirstRunEnabled -connection $localConn
$Web.WebTemplatesGalleryFirstRunEnabled = $false
$Web.Update()
Invoke-PnPQuery -connection $localConn        

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***


## Contributors

| Author(s) |
|-----------|
| Kasper Larsen |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-disable-template-dialog" aria-hidden="true" />
