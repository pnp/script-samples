---
plugin: add-to-gallery
---

# Disable specified Tenant-wide Extension

## Summary

Tenant Wide Extensions list from the App Catalog helps to manage the activation / deactivation of the tenant wide extensions. The below sample script helps to disable the specified tenant wide extension based on the id parameter.

> [!Note]
> TenantWideExtensionDisabled column denotes the extension is enabled or disabled.
 
# [CLI for Microsoft 365 using PowerShell](#tab/cli-m365-ps)
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

# [CLI for Microsoft 365 using Bash](#tab/cli-m365-bash)

```bash
#!/bin/bash

# requires jq: https://stedolan.github.io/jq/

echo "Enter the extension name to disable: "; read extensionName;
listName="Tenant Wide Extensions";

appCatalogUrl=$(m365 spo tenant appcatalogurl get)
filterQuery="Title eq '$extensionName'"
appItemsJson=$(m365 spo listitem list --title "$listName" --webUrl "$appCatalogUrl" --fields "Id,Title" --filter "$filterQuery" --output json)
appItemId=( $(jq -r '.[].Id' <<< $appItemsJson))

if [[ $appItemId -gt 0 ]]
then
 m365 spo listitem set --listTitle "$listName" --id "$appItemId" --webUrl "$appCatalogUrl" --TenantWideExtensionDisabled "true" >/dev/null 2>&1
 echo "Extension disabled."
else
  echo "No extensions found with the name '$extensionName'."
fi
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