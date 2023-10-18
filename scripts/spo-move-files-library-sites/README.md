---
plugin: add-to-gallery
---

# Copying files between different SharePoint libraries with custom metadata

You might have a requirement to move sample files from a site to a different site, e.g. subset of production files to UAT site to allow testing of solutions. You may want better control over metadata settings, such as ProcessStatus, ensuring files are marked as "Pending" upon transfer . Unlike the default file copy feature, this script enables you to skip the copy process if the destination site lacks a matching folder structure as well setting custom metadata to specific values.

## Summary

# [PnP PowerShell](#tab/pnpps)

```PowerShell

﻿param (
    [Parameter(Mandatory=$false)]
    [string]$SourceSiteUrl = "https://contoso.sharepoint.com/teams/app",
    [Parameter(Mandatory=$false)]
    [string]$SourceFolderPath=  "https://contoso.sharepoint.com/teams/app/Temp Library/test",
    [Parameter(Mandatory=$false)]
    [string]$DestinationSiteUrl = "https://contoso.sharepoint.com/teams/t-app",
    [Parameter(Mandatory=$false)]
    [string]$DestinationFolderPath = "https://contoso.sharepoint.com/teams/t-app/TempLibrary/test"
)

# Generate a unique log file name using today's date
$todayDate = Get-Date -Format "yyyy-MM-dd"
$logFileName = "CopyFilesToSharePoint_$todayDate.log"
$logFilePath = Join-Path -Path $PSScriptRoot -ChildPath $logFileName

# Connect to the source and destination SharePoint sites
Connect-PnPOnline -Url $SourceSiteUrl -Interactive
$SourceConn  = Get-PnPConnection 
Connect-PnPOnline -Url $DestinationSiteUrl -Interactive
$DestConn  = Get-PnPConnection 
# Function to copy files recursively and log errors
function Copy-FilesToSharePoint {
    param (
        [string]$SourceFolderPath,
        [string]$DestinationFolderPath
    )
    $sourceRelativeFolderPath = $SourceFolderPath.Replace($SourceSiteUrl,'') 
    $sourceFiles = Get-PnPFolderItem  -FolderSiteRelativeUrl $sourceRelativeFolderPath -ItemType File -Connection $SourceConn
    foreach ($file in $sourceFiles) {
        $relativePath = $file.ServerRelativePath
       
        # Check if the destination folder exists
        $destinationFolder = Get-PnPFolder -Url $DestinationFolderPath -Connection $DestConn -ErrorAction SilentlyContinue
        if ($null -eq $destinationFolder) {
            $errorMessage = "Error: Destination folder '$DestinationFolderPath' does not exist."
            Write-Host $errorMessage -ForegroundColor Red
            Add-Content -Path $logFilePath -Value $errorMessage
            continue
        }

        try {
            #get file as stream
           $fileUrl =  $SourceFolderPath + "/" + $file.Name
           $p = $fileUrl.Replace($SourceSiteUrl,'') 
           $streamResult = Get-PnPFile -Url  $p  -Connection $SourceConn -AsMemoryStream
            # Upload the file to the destination folder
           $uploadedFile = Add-PnPFile -Folder $DestinationFolderPath -FileName $file.Name -Stream  $streamResult  -Values @{"ProcessStatus" = "Pending"} -Connection $DestConn #-ErrorAction St
       
            Write-Host "File '$($file.Name)' copied and status set to 'Pending' in '$DestinationFolderPath'" -ForegroundColor Green
        } catch {
            $errorMessage = "Error copying file '$($file.Name)' to '$DestinationFolderPath': $($_.Exception.Message)"
            Write-Host $errorMessage -ForegroundColor Red
            Add-Content -Path $logFilePath -Value $errorMessage
        }
    }
}


# Call the function to copy files to SharePoint
$sourceRelativeFolderPath = $SourceFolderPath.Replace($SourceSiteUrl,'') 
$sourceLevel1Folders = Get-PnPFolderItem  -FolderSiteRelativeUrl $sourceRelativeFolderPath -ItemType Folder  -Connection $SourceConn
Copy-FilesToSharePoint -SourceFolderPath $SourceFolderPath -DestinationFolderPath $DestinationFolderPath
$sourceLevel1Folders | ForEach-Object {
$sourceLevel1Folder = $_ 
if($_.Name -ne "Forms"){
    $sourcePath = $SourceFolderPath + "/" + $sourceLevel1Folder.Name
    $destPath = $DestinationFolderPath + "/" + $sourceLevel1Folder.Name
    Copy-FilesToSharePoint -SourceFolderPath $sourcePath  -DestinationFolderPath $destPath
    }
  $sourceLevel1Path =  $sourceRelativeFolderPath + "/" + $_.Name
  $sourceLevel2Folders = Get-PnPFolderItem  -FolderSiteRelativeUrl $sourceLevel1Path  -ItemType Folder  -Connection $SourceConn
  $sourceLevel2Folders | ForEach-Object {
    $sourceLevel2Folder = $_
    $sourcePath = $SourceFolderPath + "/" + $sourceLevel1Folder.Name + "/" + $sourceLevel2Folder.Name
    $destPath = $DestinationFolderPath + "/" + $sourceLevel1Folder.Name + "/" + $sourceLevel2Folder.Name
    Copy-FilesToSharePoint -SourceFolderPath $sourcePath  -DestinationFolderPath $destPath 
 }
}
# Disconnect from SharePoint
```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Contributors

| Author(s) |
|-----------|
| Reshmee Auckloo |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-move-files-library-sites" aria-hidden="true" />