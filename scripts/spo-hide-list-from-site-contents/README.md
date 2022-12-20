---
plugin: add-to-gallery
---

# Hide SharePoint list from Site Contents

## Summary

If you need to hide the SharePoint list from the UI this simple PowerShell script will hide a specific list from the site contents. This will prevent users from easily accessing the list while, for example, you are still setting it up.
 
# [PnP PowerShell](#tab/pnpps)
```powershell
$listName = "listname"
$site = "https://contoso.sharepoint.com"

Connect-PnPOnline -url $site -Interactive
$list = Get-PnPList -Identity $listName
Set-PnPList -Identity $list -Hidden:$true

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***


## Contributors

| Author(s) |
|-----------|
| Leon Armston |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-hide-list-from-site-contents" aria-hidden="true" />