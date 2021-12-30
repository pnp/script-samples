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

# [PnP PowerShell](#tab/pnpps)
```powershell

$SiteURL = "https://yourtenantname.sharepoint.com/sites/SiteCollection"
$LibraryName = "YourLibraryName"
$ErrorActionPreference="Stop"

Connect-PnPOnline –Url $siteUrl -interactive

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
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
***

## Contributors

| Author(s) |
|-----------|
| Reshmee Auckloo |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/spo-remove-large-library" aria-hidden="true" />
