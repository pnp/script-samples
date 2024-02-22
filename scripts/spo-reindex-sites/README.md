---
plugin: add-to-gallery
---

# Reindex SharePoint sites

## Summary

Keeping your SharePoint environment up-to-date is crucial, especially after making schema changes. This PnP PowerShell script streamlines the process of reindexing sites, libraries, or lists to ensure that search results remain accurate and relevant. 

# [PnP PowerShell](#tab/pnpps)

```PowerShell
#Set Parameters
$AdminCenterURL="https://contoso-admin.sharepoint.com"
Connect-PnPOnline -Url $AdminCenterURL -Interactive

$m365Sites = Get-PnPTenantSite -Detailed | Where-Object {($_.Url -like '*/teams-*' -or $_.Template -eq 'TEAMCHANNEL#1') -and $_.Template -ne 'RedirectSite#0' } #filter to exclude redirect sites and to include team channel sites in the list
$m365Sites | ForEach-Object {
    Connect-PnPOnline -Url $_.Url -Interactive
    #Request Reindex
    Request-PnPReIndexWeb
    Write-host "Reindexing: " $web $_.Url  
}
```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***

## Contributors
| Author(s) |
|-----------|
| [Reshmee Auckloo](https://github.com/reshmee011)|


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-reindex-sites" aria-hidden="true" />
