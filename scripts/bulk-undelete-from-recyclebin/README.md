---
plugin: add-to-gallery
---

# Undelete items from SharePoint Recycle bin

## Summary
sometimes users need to restore items from SharePoint recycle bin. This script allows them to undelete items from recycle bin and restore it in respective document library and list.

[!INCLUDE [Delete Warning](../../docfx/includes/DELETE-WARN.md)]

![Example Screenshot](assets/example.png)

# [PnP PowerShell](#tab/pnpps)
```powershell

# Make sure necessary modules are installed
# PnP PowerShell to get access to M365 tenent

Install-Module PnP.PowerShell
$siteURL = "https://tenent.sharepoint.com/sites/Dataverse"
$rows = 10000 
$userEmailAddress = "user@tenent.onmicrosoft.com" #admin user
#  -UseWebLogin used for 2 factor Auth.  You can remove if you don't have MFA turned on
Connect-PnPOnline -Url  $siteUrl
 $deletedItems = $null
 # Get files which is deleted by specific user.
 $deletedItems = Get-PnPRecycleBinItem -FirstStage -RowLimit $rows | Where-Object {$_.DeletedByEmail -Eq $userEmailAddress} | select Id,Title,LeafName,ItemType
 if($deletedItems.Count -gt 0)
 {
    Foreach ($deletedItem in $deletedItems){
        Write-Host "Restoring is in process for Item Id : " $deletedItem.Id
        Restore-PnPRecycleBinItem -Identity $deletedItem.Id.ToString() -Force
        Write-Host "Item with Id : " $deletedItem.Id " has been restored successfully."
    }
 }

```

## Contributors

| Author(s) |
|-----------|
| [Dipen Shah](https://github.com/dips365) |




