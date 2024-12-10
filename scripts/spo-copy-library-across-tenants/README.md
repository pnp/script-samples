---
plugin: add-to-gallery
---

# Copying a subset of a document library to another SharePoint tenants with resume functionality

## Summary

You might have the case to copy a subset of document library from one tenant to another one.
This examples
- containes resume functionality, especially when dealing with huge libraries
- select subset of files based on a meta data property value
- specify additional meta data columns to copy to target library
- creates necessary folder structure in target library
- creates a logfile with file copy status


### Prerequisites

- An EntraId app for each source and target tenant, either with app-only or delegated permissions to access the specific site
- Installed PowerShell modules PnP.PowerShell and ImportExcel


# [PnP PowerShell](#tab/pnpps)

```PowerShell

# Install the necessary module
#Install-Module -Name ImportExcel -Scope CurrentUser
#Install-Module PnP.PowerShell -Scope CurrentUser


###################
### User Config ###
###################

$sourceSite = "https://contoso.sharepoint.com/sites/source-site"
$sourceLibrary = "SourceDocLib"
$sourceDataQueryProperty = "<filter property>"
$sourceDataQueryPropertyValue = "<filter property value>"

$sourceAppId = "<source app id>"
$sourceTenantId = "<source tenant id>"
$sourceCertThumb ="<source cert thumb>"


$targetSite = "https://fabrikam.sharepoint.com/sites/target-site"
$targetLibrary = "TargetDocLib"

$targetAppId = "<target app id>"
$targetTenantId = "<target tenant id>"
$targetCertThumb = "<target cert thumb>"

$propertiesToMigrate = @('<ColumnName1>', '<ColumnName2>') # List of internal properties to migrate

$sourceCtx = Connect-PnPOnline -Url $sourceSite -ClientId $sourceAppId -Tenant $sourceTenantId -Thumbprint $sourceCertThumb -ReturnConnection
$targetCtx = Connect-PnPOnline -Url $targetSite -ClientId $targetAppId -Tenant $targetTenantId -Thumbprint $targetCertThumb -ReturnConnection

# Alternative for interactive login
#$sourceCtx = Connect-PnPOnline -Url $sourceSite -ClientId $sourceAppId -Tenant $sourceTenantId -Interactive -ReturnConnection
#$targetCtx = Connect-PnPOnline -Url $targetSite -ClientId $targetAppId -Tenant $targetTenantId -Interactive -ReturnConnection

###############
### Helpers ###
###############

# # Create fields in target library
# foreach ($property in $propertiesToMigrate) {
#     Add-PnPField -Type Text -InternalName $property -DisplayName $property -Group "EHS" -Connection $targetCtx
# }

###############################################
###############################################
#### DO NOT CHANGE ANYTHING BELOW THIS LINE ###
###############################################
###############################################

function GetFileCopyLog
{
    param(
        [Parameter(Mandatory=$true)]
        [string]$PathToFileCopyLog
    )

    if (-not (Test-Path $PathToFileCopyLog -PathType Leaf)) {
        
        $ListItemQuery = "<View Scope='RecursiveAll'><Query><Where><Eq><FieldRef Name='$($sourceDataQueryProperty)'/><Value Type='Text'>$($sourceDataQueryPropertyValue)</Value></Eq></Where></Query></View>"
        $allItemsToCopy = (Get-PnPListItem -List $sourceLibrary -Query $ListItemQuery -PageSize 1000 -Connection $sourceCtx).FieldValues

        $sourceList = Get-PnPList -Identity $sourceLibrary -Connection $sourceCtx
        
        foreach ($currentItem in $allItemsToCopy) {
            # Write log
            [PSCustomObject]@{
                Filename = $currentItem.FileLeafRef
                UniqueId = $currentItem.UniqueId
                SourceItemId = $currentItem.ID
                SourceFileRef = $currentItem.FileRef
                SourceFileDirRef = $currentItem.FileDirRef
                SourceFileDirRefRelative = $currentItem.FileDirRef.Replace($sourceList.RootFolder.ServerRelativeUrl, $sourceLibrary)
                TargetFileDirRefRelative = $currentItem.FileDirRef.Replace($sourceList.RootFolder.ServerRelativeUrl, $targetLibrary)
                CopiedProperties = ""
                Status = "Not copied"
            } | Export-Excel $PathToFileCopyLog -Append
        }
    }
}


function CreateFoldersInTarget
{
    param(
        [Parameter(Mandatory=$true)]
        [string]$PathToFileCopyLog
    )

    # Read file with folders
    $logFile = Import-Excel -Path $PathToFileCopyLog

    # Get unique folders
    $uniqueFolders = $logFile.TargetFileDirRefRelative | Sort-Object -Unique

    # Create folder structure in target
    Write-Host -ForegroundColor White "Creating folders in target: $($uniqueFolders.Count)"
    foreach ($folder in $uniqueFolders) {
        Write-Host -ForegroundColor White "Creating folder: $($folder)"
        $folderResult = Resolve-PnPFolder -SiteRelativePath $folder -Connection $targetCtx
    }
    Write-Host -ForegroundColor Green "DONE"
}


function Copy-Files
{
    param(
        [Parameter(Mandatory=$true)]
        [string]$PathToFileCopyLog
    )

    # Read file with folders
    $logFile = Import-Excel -Path $PathToFileCopyLog

    $itemsToCopy = $logFile | Where-Object { $_.Status -ne "Copied" }

    Write-Host -ForegroundColor White "Starting copy of files: $($itemsToCopy.Count)"

    $counter = 0
    foreach ($itemToCopy in $itemsToCopy) {
        $counter++
        Write-Host -ForegroundColor White "Copy job '$($counter)/$($itemsToCopy.Count)': $($itemToCopy.Filename)"

        # Read properties
        $fileAsListItem = $null
        $fileAsListItem = Get-PnPListItem -List $sourceLibrary -UniqueId $itemToCopy.UniqueId -Connection $sourceCtx

        # Read file
        $fileAsMemStream = $null
        $fileAsMemStream = Get-PnPFile -Url $itemToCopy.SourceFileRef -AsMemoryStream -Connection $sourceCtx

        # Get item properties from source
        $propertiesHashtable = @{}
        $propertiesAsString = $null
        foreach($prop in $propertiesToMigrate){
            $propertiesHashtable[$prop] = $fileAsListItem.FieldValues.$prop
            $propertiesAsString = $propertiesAsString,"$($prop)=$($fileAsListItem.FieldValues.$prop)" -join ','
        }
    
        # Create file in target with properties
        $copyStatus = $null
        try {
            $result = Add-PnPFile -Folder $itemToCopy.TargetFileDirRefRelative -FileName $itemToCopy.Filename -Stream $fileAsMemStream -Values $propertiesHashtable -Connection $targetCtx
            $copyStatus = "Copied"
        }
        catch {
            $copyStatus = "Error"
        }
        
        # Udate the status in the file copy log
        $itemToCopy.Status = $copyStatus
        $itemToCopy.CopiedProperties = $propertiesAsString
        $logFile | Export-Excel -Path $PathToFileCopyLog
    }
    return $null
}

#######################
#######################

Write-Host -ForegroundColor Green "Starting file copy job"

$jobstart = Get-Date 

# Define logging file
$FileCopyLog = "$PSScriptRoot\CopyLibraryBetweenTenants-FileCopyLog.xlsx"

GetFileCopyLog -PathToFileCopyLog $FileCopyLog

CreateFoldersInTarget -PathToFileCopyLog $FileCopyLog

Copy-Files -PathToFileCopyLog $FileCopyLog

$jobend = Get-Date

$jobduration = New-TimeSpan -Start $jobstart -End $jobend

Write-Host -ForegroundColor White ""
Write-Host -ForegroundColor White "Job duration: '$($jobduration.Hours)'h '$($jobduration.Minutes)'min '$($jobduration.Seconds)'sec (system time: '$($jobduration)')"

Write-Host -ForegroundColor Green "DONE"

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Contributors

| Author(s) |
|-----------|
| Timo Vomstein |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-copy-library-across-tenants" aria-hidden="true" />