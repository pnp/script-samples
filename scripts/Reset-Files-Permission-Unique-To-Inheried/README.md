---
plugin: add-to-gallery
---

# Reset files permissions unique to Inherited

## Summary
Reset bulk file permissions  from unique to parent folder inheritance.

![Example Screenshot](assets/example.png)

# [PnP PowerShell](#tab/pnpps)
```powershell

# Make sure necessary modules are installed
# PnP PowerShell to get access to M365 tenent

Install-Module PnP.PowerShell
$siteURL = "https://tenent.sharepoint.com/sites/Dataverse"
Connect-PnPOnline -Url $siteURL -Credentials (Get-Credential)
$listName = "Document Library"
#Get the Context
$Context = Get-PnPContext
## Get all folders from given list
$Folders = Get-PnPFolder -List $listName
Write-Output "Total Folder found $($Folders.Count)"
## Traverse all files from all folders.
foreach($folder in $folders){
    Write-Host "get all files from folder '$($folder.Name)'" -ForegroundColor DarkGreen
    $files = Get-PnPListItem -List $listName -FolderServerRelativeUrl $folder.ServerRelativeUrl
    Write-Host "Total Files found $($Files.Count) in folder $($folder.Name)" -ForegroundColor DarkGreen
    foreach ($file in $files){
        ## Check object type is file or folder.If file than do process else do nothing.
        if($file.FileSystemObjectType.ToString() -eq "File"){
            #Check File is unique permission or inherited permission.
            # If File has Unique Permission than below line return True else False
            $hasUniqueRole = Get-PnPProperty -ClientObject $file -Property HasUniqueRoleAssignments
            if($hasUniqueRole -eq $true){
                ## If File has Unique Permission than reset it to inherited permission from parent folder.
                Write-Output "Reset Permisison starting for file with id $($file.Id)" -ForegroundColor DarkGreen
                $file.ResetRoleInheritance()
                $file.update()
                $Context.ExecuteQuery()
            }
        }
    }
}
## Disconnect PnP Connection.
Disconnect-PnPOnline

```

## Contributors

| Author(s) |
|-----------|
| [Dipen Shah](https://github.com/dips365) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/Reset-Files-Permission-Unique-To-Inheried" aria-hidden="true" />