---
plugin: add-to-gallery
---

# Export all List and Libraries with Item count and Permission in CSV

## Summary
Get all lists and Libraries along with total Item count and pemrission and export it in CV file using below power shell script.

![Example Screenshot](assets/example.png)

# [PnP PowerShell](#tab/pnpps)
```powershell

# Make sure necessary modules are installed
# PnP PowerShell to get access to M365 tenent

Install-Module PnP.PowerShell
$siteURL = "https://tenent.sharepoint.com/sites/Dataverse"

#  -UseWebLogin used for 2 factor Auth.  You can remove if you don't have MFA turned on
Connect-PnPOnline -Url  $siteUrl
 # get all lists from given SharePoint Site collection
 $lists = Get-PnPList
 If($lists.Count =gt 0){
   foreach($list in $lists){
     
   }
 }
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


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/bulk-undelete-from-recyclebin" aria-hidden="true" />