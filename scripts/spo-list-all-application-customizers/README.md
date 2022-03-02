---
plugin: add-to-gallery
---

# List all application customizers in a tenant

## Summary

List all the application customizers in a tenant. Scope is default ``` all ```. Here we are using the
[custom action list](https://pnp.github.io/cli-microsoft365/cmd/spo/customaction/customaction-list/) command to list out all the Application Customizers in all the sites in the tenant.
 
 
# [CLI for Microsoft 365 with PowerShell](#tab/cli-m365-ps)
```powershell
$sites = m365 spo search --queryText "contentclass:STS_site -SPSiteURL:personal" --selectProperties "Path,Title" --allResults --output json | ConvertFrom-Json
foreach ($site in $sites) {                                                      
  write-host $site.Title                      
  write-host $site.Path                                             
  m365 spo customaction list --url $site.Path   
} 
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
 
# [Microsoft 365 CLI with Bash](#tab/m365cli-bash)
```bash
#!/bin/bash

# requires jq: https://stedolan.github.io/jq/

defaultIFS=$IFS
IFS=$'\n'

sites=$(m365 spo search --queryText "contentclass:STS_site -SPSiteURL:personal" --selectProperties "Path,Title" --allResults --output json)

for site in $(echo $sites | jq -c '.[]'); do
  siteUrl=$(echo ${site} | jq -r '.Path')
  siteName=$(echo ${site} | jq -r '.Title')
  echo $siteUrl
  echo $siteName
  m365 spo customaction list --url $siteUrl
done
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
***

## Source Credit

Sample first appeared on [List all application customizers in a tenant | CLI for Microsoft 365](https://pnp.github.io/cli-microsoft365/sample-scripts/spo/list-all-application-customizers/)

## Contributors

| Author(s) |
|-----------|
| Rabia Williams |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-list-all-application-customizers" aria-hidden="true" />
