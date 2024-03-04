---
plugin: add-to-gallery
---

# Re-index SharePoint sites

## Summary

When using SharePoint columns in search solutions, you may need to map crawled properties to managed properties and update the search schema. For example, you can map the crawled property `ows_Foo` to `RefinableString100` and use it as a filter in [KQL](https://learn.microsoft.com/sharepoint/dev/general-development/keyword-query-language-kql-syntax-reference). For more information, refer to [How Do Site Columns Become Managed Properties](https://learn.microsoft.com/microsoft-365/community/how-do-site-columns-become-managed-properties-thus-available-for-search).

If your schema change applies to existing content, you must schedule a re-index operation for the affected content in order to have the data populated into the search index.

> [!IMPORTANT]
> Scheduling of re-indexing should **ALWAYS** happen at the smallest level possible. If affected data is in a specific library or list, then re-index ONLY the specific library. This can be achieved via the site settings in SharePoint or by using the command [Request-PnPReIndexList](https://pnp.github.io/powershell/cmdlets/Request-PnPReIndexList.html).

> [!CAUTION]
> The below script should **ONLY** be used for the scenario where a schema mapping affects ALL content in your tenant. Site re-indexing may add stress to the search system and take an extended amount of time to complete. Re-crawls of sites with more than one million items can potentially take weeks to process. Subsequent index updates could be delayed until the re-indexing is complete, leading to out-of-date search results. Make sure to only initiate a site re-index after making changes that require all items to be reindexed.

This PnP PowerShell script streamlines the process of re-indexing sites, libraries, or lists to ensure that search results remain accurate and relevant.

# [PnP PowerShell](#tab/pnpps)

```PowerShell
#Prompt for caution
Read-Host -Prompt "Are you sure you know what you are doing, and have read the text at https://pnp.github.io/script-samples/spo-reindex-sites/README.html?"

#Set Parameters
$AdminCenterURL = "https://contoso-admin.sharepoint.com"

# Connect to SharePoint admin center
Connect-PnPOnline -Url $AdminCenterURL -Interactive

#Get SharePoint sites
$m365Sites = Get-PnPTenantSite -Detailed | Where-Object {($_.Url -like '*/teams-*' -or $_.Template -eq 'TEAMCHANNEL#1') -and $_.Template -ne 'RedirectSite#0' } #filter to exclude redirect sites and to include team channel sites in the list
$m365Sites | ForEach-Object {
    # Connect to SharePoint site
    Connect-PnPOnline -Url $_.Url -Interactive
    
    #Request Reindex
    Request-PnPReIndexWeb
    Write-host "Reindexing: " $_.Url
}

# Disconnect SharePoint online connection
Disconnect-PnPOnline
```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365](#tab/cli-m365-ps)

```powershell
#Prompt for caution
Read-Host -Prompt "Are you sure you know what you are doing, and have read the text at https://pnp.github.io/script-samples/spo-reindex-sites/README.html?"

#Get Credentials to connect
$m365Status = m365 status
if ($m365Status -match "Logged Out") {
    m365 login
}

#Get SharePoint sites
$m365Sites = m365 spo site list | ConvertFrom-Json | Where-Object {$_.Url -like '*/sites/*' -and $_.Template -ne 'RedirectSite#0' } #filter to include sites with "/sites/" managed path and to exclude the redirect sites 

$m365Sites | ForEach-Object {
	Write-host "Requesting reindexing for: " $_.Url
	
    #Request Re-indexing of SharePoint site
	m365 spo web reindex --url $_.Url
}

#Disconnect SharePoint online connection
m365 logout
```

[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

***

## Contributors
| Author(s) |
|-----------|
| [Reshmee Auckloo (script)](https://github.com/reshmee011)|
| [Mikael Svenson (caution text)](https://github.com/wobba)|
| [Ganesh Sanap (script)](https://ganeshsanapblogs.wordpress.com/about) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-reindex-sites" aria-hidden="true" />
