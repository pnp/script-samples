---
plugin: add-to-gallery
---

# Enable/Disable Search Crawling on Sites and Libraries

## Summary

This sample allows you to enable or disable Search crawling on site or a library. You can use this to control the search indexing of a site or library but if you disable, web parts and search experiences will not work against the locations you disable. However, this can be used to remove locations from Microsoft 365 Copilot. 

> [!Warning]
> Please be aware this script contains a command that will remove content from search, ensure you test and understand the implications of running the script. If this is an active site, you can negatively impact the user experience.


![Example Screenshot](assets/example.png)

# [PnP PowerShell](#tab/pnpps)

```powershell

Connect-PnPOnline https://contoso.sharepoint.com/sites/SearchEnableDisableTest -Interactive

# Note: No Search Crawl is false because it is crawling the site by default - love these MS negative logic
$status = Get-PnPWeb -Includes NoCrawl
Write-Host "Current WEB status - Crawling: $(!$status.NoCrawl)" 

# Disable Search No Site Scripting
# If you don't do this, you may get an access denied error
Set-PnPSite -NoScriptSite $false

# Disable Search Crawl
#----------------------------
Set-PnPWeb -NoCrawl

$status = Get-PnPWeb -Includes NoCrawl
Write-Host "Current WEB status - Crawling: $(!$status.NoCrawl)" 

# Enable Search Crawl
#----------------------------
Set-PnPWeb -NoCrawl:$false

$status = Get-PnPWeb -Includes NoCrawl
Write-Host "Current WEB status - Crawling: $(!$status.NoCrawl)" 

# Enable Search No Site Scripting
Set-PnPSite -NoScriptSite $true

#-----------------------------------------------------------
# Library Level
#-----------------------------------------------------------

# Remember - No Search Crawl is false because it is crawling the site by default
$listName = "Documents"

# Get the current status of the list
$list = Get-PnPList -Identity $listName -Includes NoCrawl
Write-Host "Current DOCUMENT LIBRARY ($($listName)) status - Crawling: $(!$list.NoCrawl)" 

# Disable Search Crawl on list
#-------------------------------
Set-PnPList -Identity $listName -NoCrawl

$list = Get-PnPList -Identity $listName -Includes NoCrawl
Write-Host "Current DOCUMENT LIBRARY ($($listName)) status - Crawling: $(!$list.NoCrawl)" 


# Enable Search Crawl on list
#-------------------------------
Set-PnPList -Identity $listName -NoCrawl:$false

$list = Get-PnPList -Identity $listName -Includes NoCrawl
Write-Host "Current DOCUMENT LIBRARY ($($listName)) status - Crawling: $(!$list.NoCrawl)"   

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***


## Contributors

| Author(s) |
|-----------|
| Paul Bullock |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-enable-disable-search-crawling" aria-hidden="true" />
