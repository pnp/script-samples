---
plugin: add-to-gallery
---

# Retrieves site id from Microsoft Graph

## Summary

Sharing links can lead to oversharing, especially when default site sharing settings haven’t been updated to ‘People with existing access.’ To address this, consider using a utility script that deletes sharing links at the folder, file, and item levels. This approach can help mitigate oversharing issues during the Copilot for M365 rollout.

![Example Screenshot](assets/preview.png)

### Prerequisites

- The user account that runs the script must have access to the SharePoint Online site.

# [PnP PowerShell](#tab/pnpps)

```powershell
$siteUrl = Read-Host -Prompt "Enter site collection URL";
$dateTime = (Get-Date).toString("dd-MM-yyyy-hh-ss")
$invocation = (Get-Variable MyInvocation).Value
$directorypath = Split-Path $invocation.MyCommand.Path
$fileName = "SharingLinkDeletionReport-" + $dateTime + ".csv"
$ReportOutput = $directorypath + "\Logs\"+ $fileName

$global:Results = @();

#Exclude certain libraries
$ExcludedLists = @("Form Templates", "Preservation Hold Library", "Site Assets", "Images", "Pages", "Settings", "Videos","Timesheet"
    "Site Collection Documents", "Site Collection Images", "Style Library", "AppPages", "Apps for SharePoint", "Apps for Office")

Function QueryDeleteSharingLinksByObject($_web,$_object,$_type,$_relativeUrl,$_siteUrl,$_siteTitle,$_listTitle)
{
  $roleAssignments = Get-PnPProperty -ClientObject $_object -Property RoleAssignments
  
  foreach($roleAssign in $roleAssignments){
      Get-PnPProperty -ClientObject $roleAssign -Property RoleDefinitionBindings,Member;
      #Sharing link is in the format SharingLinks.03012675-2057-4d1d-91e0-8e3b176edd94.OrganizationView.20d346d3-d359-453b-900c-633c1551ccaa
    If ($roleAssign.Member.Title -like "SharingLinks*")
      {
        $global:Results += New-Object PSObject -property $([ordered]@{
            object= $_object.Title
            type = $_type          
            relativeURL = $_relativeURL
            siteUrl = $_siteUrl 
            siteTitle = $_siteTitle
            listTitle = $_listTitle 
            sharinglink = $roleAssign.Member.Title
        })
       Remove-PnPGroup -identity $roleAssign.Member.Title -force
    }
   }
}

  
Connect-PnPOnline -Url $siteUrl -Interactive

$web= Get-PnPWeb

Write-Host "Processing site $siteUrl"  -Foregroundcolor "Red"; 

$ll = Get-PnPList -Includes BaseType, Hidden, Title,HasUniqueRoleAssignments,RootFolder | Where-Object {$_.Hidden -eq $False -and $_.Title -notin $ExcludedLists } #$_.BaseType -eq "DocumentLibrary" 
  Write-Host "Number of lists $($ll.Count)";

  foreach($list in $ll)
  {
    $listUrl = $list.RootFolder.ServerRelativeUrl;       
    $listTitle = $list.Title; 
    #Get all list items in batches
    $ListItems = Get-PnPListItem -List $list -PageSize 2000 
        #Iterate through each list item
        ForEach($item in $ListItems)
        {
            $ItemCount = $ListItems.Count
            #Check if the Item has unique permissions
            $HasUniquePermissions = Get-PnPProperty -ClientObject $Item -Property "HasUniqueRoleAssignments"
            If($HasUniquePermissions)
            {       
                #Get Shared Links
                if($list.BaseType -eq "DocumentLibrary")
                {
                    $type= "File";
                    $fileUrl = $item.FieldValues.FileRef;
                }
                else
                {
                    $type= "Item";
                    $fileUrl = "$siteurl/lists/$listTitle/AllItems.aspx?FilterField1=ID&FilterValue1=$($item.id)"
                }
                QueryDeleteSharingLinksByObject $web $item $Type $fileUrl $siteUrl $web.Title $listTitle;
            }
        }
    }
 
  $global:Results | Export-CSV $ReportOutput -NoTypeInformation
Write-host -f Green "Sharing Links for user generated Successfully!"
```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***

## Source Credit

Sample first appeared on [Deletion of sharing links with PowerShell](https://reshmeeauckloo.com/posts/powershell-delete-sharinglinks/)

## Contributors

| Author(s) |
|-----------|
| [Reshmee Auckloo](https://github.com/reshmee011) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-delete-sharinglink-folder-file-item" aria-hidden="true" />