---
plugin: add-to-gallery
---

# Disable specified Tenant-wide Extension

## Summary

Tenant Wide Extensions list from the App Catalog helps to manage the activation / deactivation of the tenant wide extensions. The below sample script helps to disable the specified tenant wide extension based on the id parameter.

> [!Note]
> TenantWideExtensionDisabled column denotes the extension is enabled or disabled.
 
![Example Screenshot](assets/example.png)
 
# [CLI for Microsoft 365](#tab/cli-m365-ps)
```powershell
$extensionName = Read-Host "Enter the Extension Name"
$listName = "Tenant Wide Extensions"

$appCatalogUrl = m365 spo tenant appcatalogurl get
$filterQuery = "Title eq '" + $extensionName + "'"
$appItems = m365 spo listitem list --title $listName --webUrl $appCatalogUrl --fields "Id,Title" --filter $filterQuery --output json
$extItems = $appItems.Replace("Id", "ExtId") | ConvertFrom-JSON

if ($extItems.count -gt 0) {
  m365 spo listitem set --listTitle $listName --id $extItems.ExtId --webUrl $appCatalogUrl --TenantWideExtensionDisabled "true" >$null 2>&1
  Write-Host("Extension disabled.");
}
else {
  Write-Host("No extensions found with the name '" + $extensionName + "'.");
}
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
***


## Source Credit

Sample first appeared on [Disable specified Tenant-wide Extension | CLI for Microsoft 365](https://pnp.github.io/cli-microsoft365/sample-scripts/spo/disable-tenant-wide-extension/)

## Contributors

| Author(s) |
|-----------|
| Shantha Kumar T |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/spo-disable-tenant-wide-extension" aria-hidden="true" />