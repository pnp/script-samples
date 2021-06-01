---
plugin: add-to-gallery
---

# Delete all (non-group connected) modern SharePoint sites

## Summary

When you delete Microsoft 365 groups, the modern group-connected team sites get deleted with them. The script below handles the remaining modern sites: communication sites and groupless team sites.
 
[!INCLUDE [Delete Warning](../../docfx/includes/DELETE-WARN.md)]

![Example Screenshot](assets/example.png)
 
# [CLI for Microsoft 365 using PowerShell](#tab/cli-m365-ps)
```powershell
$sparksjoy = "Cat Lovers United", "Extranet", "Hub"
$sites = m365 spo site classic list -o json |ConvertFrom-Json
$sites = $sites | where {  $_.template -eq "SITEPAGEPUBLISHING#0" -or $_.template -eq "STS#3" -and -not ($sparksjoy -contains $_.Title)}
if ($sites.Count -eq 0) { break }
$sites | Format-Table Title, Url, Template
Read-Host -Prompt "Press Enter to start deleting (CTRL + C to exit)"
$progress = 0
$total = $sites.Count
foreach ($site in $sites)
{
    $progress++
    write-host $progress / $total":" $site.Title
    write-host $site.Url
    m365 spo site classic remove --url $site.Url
}
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
***

## Source Credit

Sample first appeared on [Delete all (non-group connected) modern SharePoint sites | CLI for Microsoft 365](https://pnp.github.io/cli-microsoft365/sample-scripts/spo/delete-non-group-connected-modern-sites/)

## Contributors

| Author(s) |
|-----------|
| Laura Kokkarinen |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/spo-delete-non-group-connected-modern-sites" aria-hidden="true" />