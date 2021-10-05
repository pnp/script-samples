---
plugin: add-to-gallery
---

# Hide SharePoint list from Site Contents

## Summary

If you need to hide the SharePoint list from the UI this simple PowerShell script will hide a specific list from the site contents. This will prevent users from easily accessing the list while, for example, you are still setting it up.
 
# [CLI for Microsoft 365 with PowerShell](#tab/cli-m365-ps)
```powershell
$listName = "listName"
$site = "https://contoso.sharepoint.com/"

m365 login
$list = m365 spo list get --webUrl $site -t $listName -o json | ConvertFrom-Json
m365 spo list set --webUrl $site -i $list.Id -t $listName --hidden true
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
 
# [Microsoft 365 CLI with Bash](#tab/m365cli-bash)
```bash
#!/bin/bash

# requires jq: https://stedolan.github.io/jq/

listName="listName"
site=https://contoso.sharepoint.com/

m365 login
listId=$(m365 spo list get --webUrl $site -t "$listName" -o json | jq ".Id")
m365 spo list set --webUrl $site -i $listId -t $listName --hidden true
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
***

## Source Credit

Sample first appeared on [Hide SharePoint list from Site Contents | CLI for Microsoft 365](https://pnp.github.io/cli-microsoft365/sample-scripts/spo/hide-list-from-site-contents/)

## Contributors

| Author(s) |
|-----------|
| David Ramalho |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/spo-hide-list-from-site-contents" aria-hidden="true" />