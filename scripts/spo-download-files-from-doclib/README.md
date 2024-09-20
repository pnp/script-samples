---
plugin: add-to-gallery-preparation
---

# Download all files from Document Libarary/Folder

> [!Note]
> This is a submission helper template please find the [contributor guidance](/docfx/contribute.md) to help you write this scenario.

## Summary

The script will download all files from an SharePoint Document Libraray or Folder
1. Download Doclib
2. Download a Folder from Doclib



![Example Screenshot](assets/example.png)

- Open Windows PowerShell ISE or VS Code
- Copy script below to your clipboard
- Paste script into your preferred editor
- Change config variables to reflect the site, library name & download location required


# [PnP PowerShell](#tab/pnpps)

```powershell
$clientId="......"
# Define variables
$siteUrl = "https://yoursharepointsite.sharepoint.com/sites/yoursite"
# Option 1:
# comment the line below and specify $libraryPath this parameter will be used
$libraryTitle = "Documents"
# Option 2:
$libraryPath = "/Shared Documents/YourFolder"
$localDownloadPath = "C:\Downloads\SharePointFiles"



# Connect to the SharePoint site
Connect-PnPOnline -Url $siteUrl -Interactive -clientID $clientID


if ($libraryTitle -ne $null) {
    $doclib = $doclib = Get-PnPList -Identity $libraryTitle -Includes RootFolder
    $libraryPath = "/"+$doclib.RootFolder.Name
}


function Download-FilesFromSharePoint {
    param (
        [string]$LibraryPath,
        [string]$LocalDownloadPath,
        [bool]$Recursive = $true
    )
    $folder =Get-PnPFolder -Url $LibraryPath
    $files = Get-PnPFolderItem -FolderSiteRelativeUrl $LibraryPath -ItemType File -Recursive:$Recursive
    # Download each file
    foreach ($file in $files) {
        $fileUrl = $file.ServerRelativeUrl
        $fileName = $file.Name
        $relpath = $fileUrl.SubString($folder.ServerRelativeUrl.length+1).Replace($fileName,"")
        $localFilePath =  $LocalDownloadPath
        if($relpath.length -gt 0){
            $localFilePath = Join-Path -Path $LocalDownloadPath -ChildPath $relpath
        }
         # Ensure the local download path exists
            if (-not (Test-Path -Path $localFilePath)) {
                $localFolder=New-Item -ItemType Directory -Path $localFilePath;
            }
        Write-Host "Downloading $fileName..."
        Get-PnPFile -Url $fileUrl  -Path $localFilePath -FileName $fileName -AsFile
    }
}

# Call the function to download files
Download-FilesFromSharePoint -LibraryPath $libraryPath -LocalDownloadPath $localDownloadPath 

Write-Host "Download completed."

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]




## Contributors

| Author(s) |
|-----------|
| [Peter Paul Kirschner](https://github.com/petkir) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/template-script-submission" aria-hidden="true" />