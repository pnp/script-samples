---
plugin: add-to-gallery
---

# Get, Update, Add, Remove SharePoint list items in large lists

## Summary

Working and processing lists items in large lists.

## Implementation

- Open Windows PowerShell ISE
- Create a new file
- Copy a script  below,

# [PnP PowerShell](#tab/pnpps)
```powershell

$url = "https://yourtenantname.sharepoint.com/sites/SiteCollection"
$list = "YourLargeList"
Connect-PnPOnline -Url $Url -Interactive


# create 5000+ list items
$batch = New-PnPBatch
1..5500 | ForEach-Object { 
            Add-PnPListItem -List $list -Values @{"Title"="Test Item Batched $_"} -Batch $batch 
           }

Invoke-PnPBatch -Batch $batch


#Update each list item separatelly
$batch = New-PnPBatch
$items = Get-PnPListItem -List $list -PageSize 1000
$items | ForEach-Object { 
            
            Set-PnPListItem -List $list -Identity $_.Id -Values @{"Title"="Test Item Batched and updated $_"} -Batch $batch
           }

Invoke-PnPBatch -Batch $batch


#remove each list item separatelly
$batch = New-PnPBatch
$items = Get-PnPListItem -List $list -PageSize 1000
$items | ForEach-Object { 
            Remove-PnPListItrm -List $list -Identity $_.Id
           }

Invoke-PnPBatch -Batch $batch


#read each list item separatelly
$batch = New-PnPBatch
Get-PnPListItem -List $list -PageSize 1000 | ForEach-Object { 
            get-PnPListItrm -List $list -Identity $_
           }

Invoke-PnPBatch -Batch $batch


```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***


## Contributors

| Author(s) |
|-----------|
| Valeras Narbutas |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/spo-list-items-large-lists" aria-hidden="true" />