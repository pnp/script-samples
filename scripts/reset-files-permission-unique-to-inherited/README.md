---
plugin: add-to-gallery
---

# Reset files permissions unique to Inherited

## Summary
Reset bulk file permissions  from unique to parent folder inheritance.

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
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]


# [CLI for Microsoft 365](#tab/cli-m365-ps)
```powershell
#Log in to Microsoft 365
Write-Host "Connecting to Tenant" -f Yellow

$m365Status = m365 status
if ($m365Status -match "Logged Out") {
    m365 login
}

$siteURL = Read-Host "Please enter Site URL"
$listName = Read-Host "Please enter list name"

# Get the list
$list = m365 spo list list --webUrl $siteURL --query "[?RootFolder.Name == '$listName']" --output json | ConvertFrom-Json

# Get all files in the list
$files = m365 spo file list --webUrl $siteURL --folder $listName --recursive --output json | ConvertFrom-Json
foreach ($file in $files) {
    # Avoid error: Cannot convert the JSON string because a dictionary that was converted from the string contains the duplicated keys 'Id' and 'ID'
    $fileProperties = m365 spo file get --webUrl $siteURL --id $file.UniqueId --asListItem --output json | ForEach-Object { $_.replace("Id", "_Id") } | ConvertFrom-Json
    
    if ($fileProperties.ID) {
        Write-Host "Processing file $($file.ServerRelativeUrl)"

        # Get the list item
        $listItem = m365 spo listitem get --webUrl $siteURL --listId $list.Id --id $fileProperties.ID --properties "HasUniqueRoleAssignments" | ConvertFrom-Json
        if ($listItem.HasUniqueRoleAssignments) {
            Write-Host "Restoring the role inheritance of list item: $($file.ServerRelativeUrl)"
            m365 spo listitem roleinheritance reset --webUrl $siteURL --listItemId $fileProperties.ID --listId $list.Id
        }
    }
}
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
***

## Contributors

| Author(s) |
|-----------|
| [Dipen Shah](https://github.com/dips365) |
| [Nanddeep Nachan](https://github.com/nanddeepn) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/reset-files-permission-unique-to-inherited" aria-hidden="true" />
