---
plugin: add-to-gallery
---

# Lists active SharePoint site collection application catalogs

## Summary

A sample that shows how to find all installed site collection application catalogs within a tenant. IT Professionals or DevOps can benefit from it when they govern tenants or scan tenant for customizations. Pulling a list with site collection app catalogs can give them valuable information at what scale the tenant site collections are customized. The sample outputs the URL of the site collection, and this can help IT Pros or DevOps to dig deeper and find out what and how many solution packages a site collection app catalog has installed. Check for un-healthy solution packages or such that could be a security risk.

> [!Note} because the sample uses the SharePoint search API to identify the site collection application catalogs, a newly created one might not be indexed right away. The sample output would not list the newly created app catalog until the search crawler indexes it; this usually does not take longer than a few minutes.
 
# [CLI for Microsoft 365 with PowerShell](#tab/cli-m365-ps)
```powershell
$appCatalogs = m365 spo search --query "contentclass:STS_List_336" --selectProperties SPSiteURL --allResults --output json | ConvertFrom-Json

$appCatalogs | ForEach-Object { Write-Host $_.SPSiteURL }
Write-Host 'Total count:' $appCatalogs.Count
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
 
# [Microsoft 365 CLI with Bash](#tab/m365cli-bash)
```bash
#!/bin/bash

# requires jq: https://stedolan.github.io/jq/

appCatalogs=$(m365 spo search --query "contentclass:STS_List_336" --selectProperties SPSiteURL --allResults --output json)

echo $appCatalogs | jq -r '.[].SPSiteURL'
echo "Total count:" $(echo $appCatalogs | jq length)
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
***

## Source Credit

Sample first appeared on [Lists active SharePoint site collection application catalogs | CLI for Microsoft 365](https://pnp.github.io/cli-microsoft365/sample-scripts/spo/list-site-app-catalogs/)

## Contributors

| Author(s) |
|-----------|
| Inspired by David Ramalho |
| Waldek Mastykarz |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/spo-list-site-app-catalogs" aria-hidden="true" />