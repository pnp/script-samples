---
plugin: add-to-gallery
---

# Undelete items from SharePoint Recycle bin

## Summary
sometimes users need to restore items from SharePoint recycle bin. This script allows them to undelete items from recycle bin and restore it in respective document library and list.

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
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365](#tab/cli-m365-ps)
```powershell
# aim of this script is to restore items which were deleted by specific user

$siteURL = "https://tenant.sharepoint.com/sites/Dataverse"
$userEmailAddress = "user@tenant.onmicrosoft.com"

$m365Status = m365 status
if ($m365Status -match "Logged Out") {
    m365 login
}

$deletedItems = m365 spo site recyclebinitem list --siteUrl $siteURL --query "[?DeletedByEmail == '$userEmailAddress']" | ConvertFrom-Json
$deletedItemsIdList = [String]::Join(',', $deletedItems.Id)

Write-Host "Restoring is in progress for Items: $deletedItemsIdList"
m365 spo site recyclebinitem restore --siteUrl $siteURL --ids $deletedItemsIdList
Write-Host "Done"
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

***

## Contributors

| Author(s) |
|-----------|
| [Dipen Shah](https://github.com/dips365) |
| [Adam Wójcik](https://github.com/Adam-it)|


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/bulk-undelete-from-recyclebin" aria-hidden="true" />
