---
plugin: add-to-gallery
---

# Update content type with system update option to avoid updating modified and modified by properties.  

## Summary

Trying to delete a library exceeding the list view threshold results in the message "The attempted operation is prohibited because it exceeds the list view threshold" from the UI and using the cmdlet Remove-PnPList. The script was tested deleting a library containing more than 113 k files/nested folders. 

PnP PowerShell

## Implementation

- Open Windows PowerShell ISE
- Create a new file
- Copy a script  below

[!INCLUDE [Delete Warning](../../docfx/includes/DELETE-WARN.md)]

# [PnP PowerShell](#tab/pnpps)
```powershell

#Config Variables
$SiteURL = "https://yourtenantname.sharepoint.com/teams/TEAM-CommercialServices/"


Connect-PnPOnline -url $SiteURL  -Interactive
$list = "Finance" 
#FolderRelativeURL= "/Finance&CSCollaboration"
 
Try {

 #$CAMLQuery = "<View Scope='RecursiveAll'><Query><Where><Eq><FieldRef Name='FileDirRef'/><Value Type='Text'>$FolderRelativeURL</Value></Eq></Where></Query></View>"
 $CAMLQuery = "<View ><Query><Where><Eq><FieldRef Name='ContentType'/><Value Type='Text'>Finance Email</Value></Eq></Where></Query></View>"
#Read more: https://www.sharepointdiary.com/2017/02/sharepoint-online-get-list-items-from-folder-using-powershell.html#ixzz7c7bU0GFH
  $items = Get-PnPListItem -List $list -IncludeContentType -Query  $CAMLQuery
  
  forEach($listItem in $items){ 
   
     Set-PnPListItem -UpdateType SystemUpdate -List  $list -ContentType "Finance Email" -Identity $listItem
  
  }

}
catch {
    write-host "Error: $($_.Exception.Message)" -foregroundcolor Red
}

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]


# [CLI for Microsoft 365](#tab/cli-m365-ps)
```powershell

$siteUrl = "https://yourtenantname.sharepoint.com/sites/SiteCollection"
$libraryName = "YourLibraryName"

write-host $("Start time " + (Get-Date))

$m365Status = m365 status
if ($m365Status -match "Logged Out") {
    m365 login
}

#Remove all subfolders
$folders = m365 spo folder list --webUrl $siteUrl --parentFolderUrl $libraryName | ConvertFrom-Json
foreach($folder in $folders) {
    if(($folder.Name -ne "Forms") -and (-Not($folder.Name.StartsWith("_")))) {
        #Delete the folder
        m365 spo folder remove --webUrl $siteUrl --folderUrl $folder.ServerRelativeUrl --confirm
        Write-Host -f Green ("Deleted Folder: '{0}' at '{1}'" -f $folder.Name, $folder.ServerRelativeUrl)
    }
}

#Remove all files
$files = m365 spo file list --webUrl $siteUrl --folder $libraryName | ConvertFrom-Json
foreach($file in $files) {
    #Delete File
    m365 spo file remove --webUrl $siteUrl --url $file.ServerRelativeUrl --confirm
    Write-Host -f Green ("Deleted File: '{0}' at '{1}'" -f $file.Name, $file.ServerRelativeUrl)     
}

m365 spo list remove --webUrl $siteUrl --title $libraryName --confirm
Write-Host ("Library {0} deleted" -f $libraryName)

write-host $("End time " + (Get-Date))

```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

***

## Contributors

| Author(s) |
|-----------|
| Reshmee Auckloo |
| [Adam Wójcik](https://github.com/Adam-it)|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-remove-large-library" aria-hidden="true" />

