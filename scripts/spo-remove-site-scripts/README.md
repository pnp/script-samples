---
plugin: add-to-gallery
---

# Delete custom SharePoint site scripts

## Summary

Site designs and especially site scripts can be something that ends up just hanging around in your tenant for a long time even though you no longer need them for anything. Use the scripts below to get rid of them. You might also find some site scripts that are not linked to any site design and hence never get executed!
 
[!INCLUDE [Delete Warning](../../docfx/includes/DELETE-WARN.md)]

# [SPO Management Shell](#tab/spoms-ps)

```powershell
Connect-SPOService "https://contoso-admin.sharepoint.com"

$keepThese = "Base Site Settings", "English Region", "Standard Site Columns", "Standard Libraries"
$siteScripts = Get-SPOSiteScript
$siteScripts = $siteScripts | Where-Object { -not ($keepThese -contains $_.Title)}

if ($siteScripts.Count -eq 0) { break }

$siteScripts | Format-Table Title, SiteScriptIds, Description
Read-Host -Prompt "Press Enter to start deleting (CTRL + C to exit)"
$progress = 0
$total = $siteScripts.Count

foreach ($siteScript in $siteScripts)
{
  $progress++
  Write-Host $progress / $total":" $siteScript.Title
  Remove-SPOSiteScript $siteScript.Id
}
```
[!INCLUDE [More about SPO Management Shell](../../docfx/includes/MORE-SPOMS.md)]

***

## Contributors

| Author(s) |
|-----------|
| Paul Bullock |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-remove-site-scripts" aria-hidden="true" />
