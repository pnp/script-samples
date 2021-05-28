---
plugin: add-to-gallery
---

# Empty the tenant recycle bin

## Summary

Your deleted modern SharePoint sites are not going to disappear from the UI before they have been removed from the tenant recycle bin. You can either wait for three months, delete them manually via the SharePoint admin center, or run the script below.
 
[!INCLUDE [Delete Warning](../../docfx/includes/DELETE-WARN.md)]

![Example Screenshot](assets/example.png)
 
# [CLI for Microsoft 365](#tab/cli-m365-ps)
```powershell
$deletedSites = m365 spo tenant recyclebinitem list -o json | ConvertFrom-Json
$deletedSites | Format-Table Url

if ($deletedSites.Count -eq 0) { break }

Read-Host -Prompt "Press Enter to start deleting (CTRL + C to exit)"

$progress = 0
$total = $deletedSites.Count

foreach ($deletedSite in $deletedSites)
{
  $progress++
  Write-Host $progress / $total":" $deletedSite.Url
  m365 spo tenant recyclebinitem remove -u $deletedSite.Url --confirm
}
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
***

## Source Credit

Sample first appeared on [Empty the tenant recycle bin | CLI for Microsoft 365](https://pnp.github.io/cli-microsoft365/sample-scripts/spo/empty-tenant-recyclebin/)

## Contributors

| Author(s) |
|-----------|
| Laura Kokkarinen |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/spo-empty-tenant-recyclebin" aria-hidden="true" />