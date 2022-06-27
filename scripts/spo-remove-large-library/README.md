---
plugin: add-to-gallery
---

# Delete a library exceeding the list threshold limit. Remove the files and folders before deleting the library.  

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

$SiteURL = "https://yourtenantname.sharepoint.com/sites/SiteCollection"
$LibraryName = "YourLibraryName"
$ErrorActionPreference="Stop"

write-host $("Start time " + (Get-Date))

Connect-PnPOnline -URL $SiteURL -Interactive
#Get the web & Root folder of the library
$Web = Get-PnPWeb
$Library = Get-PnPList -Identity $LibraryName -Includes RootFolder
$Folder = $Library.RootFolder

#Get the site relative path of the Folder
    If($Folder.Context.web.ServerRelativeURL -eq "/")
    {
        $FolderSiteRelativeURL = $Folder.ServerRelativeUrl
    }
    Else
    {      
        $FolderSiteRelativeURL = $Folder.ServerRelativeUrl.Replace($Folder.Context.web.ServerRelativeURL,[string]::Empty)
    }

    #Remove all files
    $Files = Get-PnPFolderItem -FolderSiteRelativeUrl $FolderSiteRelativeURL -ItemType File
    ForEach ($File in $Files)
    {
        #Delete File
        Remove-PnPFile -ServerRelativeUrl $File.ServerRelativeURL -Force 
        Write-Host -f Green ("Deleted File: '{0}' at '{1}'" -f $File.Name, $File.ServerRelativeURL)     
    }

    #Remove all subfolders
    $SubFolders = Get-PnPFolderItem -FolderSiteRelativeUrl $FolderSiteRelativeURL -ItemType Folder
    Foreach($SubFolder in $SubFolders)
    {
       #Exclude "Forms" and Hidden folders
        If(($SubFolder.Name -ne "Forms") -and (-Not($SubFolder.Name.StartsWith("_"))))
        {
            #Delete the folder
            Remove-PnPFolder -Name $SubFolder.Name -Folder $FolderSiteRelativeURL -Force 
            Write-Host -f Green ("Deleted Folder: '{0}' at '{1}'" -f $SubFolder.Name, $SubFolder.ServerRelativeURL)
        }
    }

 Remove-PnPList -Identity $LibraryName -Force
 Write-Host ("Library {0} deleted" -f $LibraryName)

write-host $("End time " + (Get-Date))
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

