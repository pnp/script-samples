---
plugin: add-to-gallery
---

# Add dummy folders and files to a SharePoint library

## Summary

This sample shows how to add dummy files and folders into a library. The script was used to generate files within folders to perform some testing.


## Implementation
 
Open Windows Powershell ISE

Create a new file, e.g. TestDoc.docx and save it to a file server location , e.g. C:/Temp

A loop within another loop using while is used to create the number of specified files within each of the specified number of folders. 

# [PnP PowerShell](#tab/pnpps)

```powershell

#Parameters
$SiteURL = "https://contoso.sharepoint.com/sites/Company311"
#Library in which to create the dummy files and folders
$LibraryName = "LargeLibrary"
#Location of the dummy file
$LocalFile= "C:\Temp\TestDoc.docx"
#Number of files to create within each folder
$MaxFilesCount = 20
#Number of folders to create in the libraru
$MaxFolderCount = 500
#The name of the folder to be created
$FolderName  = "Folder"
Try {
    #Get the File from file server
    $File = Get-ChildItem $LocalFile
    Connect-PnPOnline -Url $SiteURL -Interactive

    $FolderCounter = 1
    
    While($FolderCounter -le $MaxFolderCount)
    {
      $newFolderName = $FolderName +"_"+ $FolderCounter
       try{
        
        Add-PnPFolder -Name $newFolderName -Folder "$($LibraryName)" | Out-Null
        Write-host -f Green "New Folder '$newFolderName' Created ($FolderCounter of $MaxFolderCount)!"   
       $FileCounter = 1
        While($FileCounter -le $MaxFilesCount)
        {
            $NewFileName= $File.BaseName+"_"+$FileCounter+".docx"
            Try{
               Add-PnPFile -Path $File -Folder "$($LibraryName)/$newFolderName" -NewFileName $NewFileName | Out-Null
            }
            Catch{
                Write-host "Error: $($_.Exception.Message)" -foregroundcolor Red
            }
            Write-host -f Green "New File '$NewFileName' Created ($FileCounter of $MaxFilesCount)!"
        $FileCounter++
        }
       }
        Catch{
                Write-host "Error: $($_.Exception.Message)" -foregroundcolor Red
            }
    $FolderCounter++;
   }

}
Catch {
    write-host -f Red "Error Uploading File:"$_.Exception.Message
}

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

## Contributors

| Author(s) |
|-----------|
| [Reshmee Auckloo](https://github.com/reshmee011)|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]

<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-add-dummy-folders-and-files" aria-hidden="true" />
