---
plugin: add-to-gallery
---

# Empty the tenant recycle bin

## Summary

Your deleted modern SharePoint sites are not going to disappear from the UI before they have been removed from the tenant recycle bin. You can either wait for three months, delete them manually via the SharePoint admin center, or run the script below.
 
[!INCLUDE [Delete Warning](../../docfx/includes/DELETE-WARN.md)]

# [PnP PowerShell](#tab/pnpps)
```powershell
Connect-PnPOnline -Url 'https://contoso-admin.sharepoint.com' -Interactive #Change to your tenant admin site address

$deletedSites = Get-PnPTenantRecycleBinItem
$deletedSites | Format-Table Url

if ($deletedSites.Count -eq 0) 
{ 
    break 
}

Read-Host -Prompt "Press Enter to start deleting (CTRL + C to exit)"

$progress = 0
$total = $deletedSites.Count

foreach ($deletedSite in $deletedSites)
{
  $progress++
  Write-Host $progress / $total":" $deletedSite.Url
  Clear-PnPTenantRecycleBinItem -Url $deletedSite.Url -Wait -Force
}

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Source Credit

Sample first appeared on [Empty the tenant recycle bin | CLI for Microsoft 365](https://pnp.github.io/cli-microsoft365/sample-scripts/spo/empty-tenant-recyclebin/)

## Contributors

| Author(s) |
|-----------|
| [Leon Armston](https://github.com/LeonArmston)|


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-empty-tenant-recyclebin" aria-hidden="true" />

