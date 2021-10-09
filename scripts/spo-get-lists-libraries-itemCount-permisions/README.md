---
plugin: add-to-gallery
---

# Export all List and Libraries with Item count and Permission in CSV

## Summary
Get all lists and Libraries along with total Item count and pemrissions and export it in CV file using below power shell script.

![Example Screenshot](assets/example.png)

# [PnP PowerShell](#tab/pnpps)
```powershell

# Make sure necessary modules are installed
# PnP PowerShell to get access to M365 tenent

Install-Module PnP.PowerShell
$siteURL = "https://tenent.sharepoint.com/sites/Dataverse"
$ReportOutput="C:\SiteInventory.csv"
$ResultData = @()
$UniquePermission = "";
#  -UseWebLogin used for 2 factor Auth.  You can remove if you don't have MFA turned on
Connect-PnPOnline -Url  $siteUrl
 # get all lists from given SharePoint Site collection
 $lists =  Get-PnPList -Includes HasUniqueRoleAssignments,RoleAssignments
 If($lists.Count -gt 0){
   foreach($list in $lists){
    $members = "";
    if($list.HasUniqueRoleAssignments -eq $false){
        $UniquePermission = "Inherited"
    }
    if($list.HasUniqueRoleAssignments -eq $true){
        $UniquePermission = "Unique"    
    }
    if($list.RoleAssignments.Count -gt 0){
        foreach($roleAssignment in $list.RoleAssignments){
            $property = Get-PnPProperty -ClientObject $roleAssignment -Property Member
            $members += $property.Title + ";"
        }
    }
     $ResultData+= New-Object PSObject -Property @{
            'List-Library Name' = $list.Title;
            'Id'=$list.Id;
            'Parent Web URL'=$list.ParentWebUrl;
            'Item Count' = $list.ItemCount;
            'Last Modified' = $list.LastItemModifiedDate.ToString();
            'Created'=$list.Created;
            'Default View URL'=$list.DefaultViewUrl;
            'Permision'=$UniquePermission;
            'Members'=$members;
            'isHidden'=$list.Hidden;
        }
   }
 }

 $ResultData | Export-Csv $ReportOutput -NoTypeInformation
```
## Contributors

| Author(s) |
|-----------|
| [Dipen Shah](https://github.com/dips365) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/bulk-undelete-from-recyclebin" aria-hidden="true" />