---
plugin: add-to-gallery
---

# Get Folder Item properties

## Summary

This script demonstrates how to use **Get-PnPListItem** to retrieve files properties from large libraries, especially within specific folders, along with their associated properties.

# [PnP PowerShell](#tab/pnpps)

```PowerShell
$SiteUrl = Read-Host -Prompt "Enter site collection URL "; #e.g "https://contoso.sharepoint.com/sites/test"
Connect-PnPOnline -url $SiteUrl -Interactive
$listName = Read-Host -Prompt "Enter the library name, e.g. 'Shared Documents'" 
$FolderSiteRelativeURL = Read-Host -Prompt "Enter relative folder url starting with *, e.g. '*Shared Documents/folder' "; #e.g."*Shared Documents/folder/subfolder-folder/subfolder-subfolder-folder*"

$list = Get-PnPList $listName
$global:counter = 0
#Retrieving all items within the folder which is not a folder
$items = Get-PnPListItem -List $listName -PageSize 500 -Fields FileLeafRef,FileRef,PPF_Comments -ScriptBlock `
      { Param($items) $global:counter += $items.Count; Write-Progress -PercentComplete `
    ($global:Counter / ($List.ItemCount) * 100) -Activity "Getting folders from List:" -Status "Processing Items $global:Counter to $($List.ItemCount)";} `
    | Where {$_.FileSystemObjectType -ne "Folder" -and $_.FieldValues.FileRef -like $FolderSiteRelativeURL}
 
$type = [System.Collections.ArrayList]@();
 
$items | foreach-object {
    if($_.FieldValues.Issue_Comments){
        if($type -notcontains $_.FieldValues.Issue_Comments){
            $type.Add([PSCustomObject]@{
                Name = $_.FieldValues.Issue_Comments
            });
            write-host $_.FieldValues.Issue_Comments;
        }
   }
}
 
$type | Export-Csv -Path "C:\temp\categories.csv" -NoTypeInformation -Force -Delimiter "|"
```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***
## Source Credit

Sample first appeared on [Pnp Powershell Get Folder Item](https://reshmeeauckloo.com/posts/pnp-powershell-get-folder-item/)

## Contributors
| Author(s) |
|-----------|
| [Reshmee Auckloo (script)](https://github.com/reshmee011)|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-get-folder-item" aria-hidden="true" />
