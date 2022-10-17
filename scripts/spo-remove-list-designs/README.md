---
plugin: add-to-gallery
---

# Delete custom SharePoint list designs

## Summary

Custom list templates can be deleted by removing the list designs and associated site scripts when no longer needed. Use the scripts below to delete them. 
 
[!INCLUDE [Delete Warning](../../docfx/includes/DELETE-WARN.md)]


# [PnP PowerShell](#tab/pnpps)
```powershell
$adminSiteUrl = "https://contoso-admin.sharepoint.com/"
Connect-PnPOnline -url $adminSiteUrl -Interactive

$listDesignsTokeep = "Test Document Library", "List To Keep"

$listDesigns = Get-PnPListDesign  | Where-Object { -not ($listDesignsTokeep -contains $_.Title)}
if ($listDesigns.Count -eq 0) { break }

$listDesigns | Format-Table Title, SiteScriptIds, Description
Read-Host -Prompt "Press Enter to start deleting (CTRL + C to exit)"
$progress = 0
$total = $listDesigns.Count

foreach ($listDesign in $listDesigns)
{
  $progress++
  Write-Host $progress / $total":" $listDesign.Title
  $siteScriptId = $listDesign | select SiteScriptIds
  $siteScript = Get-PnPSiteScript -Identity $siteScriptId.SiteScriptIds.Guid
  Remove-PnPListDesign -Identity $listDesign -Force
  Remove-PnPSiteScript -Identity $siteScript -Force
}

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***

## Contributors

| Author(s) |
|-----------|
| [Reshmee Auckloo](https://github.com/reshmee011)|


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/spo-remove-list-designs" aria-hidden="true" />