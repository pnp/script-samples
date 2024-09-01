---
plugin: add-to-gallery
---

# File Version Trimmer

## Summary

SharePoint storage is expensive and often we don't need 500 versions of a huge PowerPoint file. One option could be to change the default number of file versions from 500 to e.g. 50. However, if you already have a file with 250 versions this change WILL NOT remove existing versions.
This sample shows how you can trim back the number of file versions in a specific Document Library in a Site Collection. 
Be aware that the change will take up to 24 hours to be visible in the SharePoint Admin center.

![Example Screenshot](assets/example.png)


# [PnP PowerShell](#tab/pnpps)

```powershell
$ClientId = "XXXXXX"
$TenantName = "contoso.onmicrosoft.com"
$thumbprint = "ZZZZZZZ"
$SharePointAdminSiteURL = "https://contoso-admin.sharepoint.com"

$conn = Connect-PnPOnline -Url $SharePointAdminSiteURL -ClientId $ClientId -Tenant $TenantName -CertificatePath "C:\Users\you\certificate.pfx" -CertificatePassword (ConvertTo-SecureString -AsPlainText -Force "CentificatePassword") -ReturnConnection

#Set Variables
$outputPath = "C:\temp\versiontrimmer\" 
$arraylist = New-Object System.Collections.ArrayList

function DeleteVersions($siteUrl, $ListName, $listitemID, $versionsToKeep)
{
    try 
    {
        $siteconn = Connect-PnPOnline -Url $siteUrl -ClientId $ClientId -Tenant $TenantName -CertificatePath "C:\Users\KasperLarsen\IAGovApp.pfx" -CertificatePassword (ConvertTo-SecureString -AsPlainText -Force "IAGovApp") -ReturnConnection

        #get list of all lists in this site
        if($ListName)
        {
            $list = Get-PnPList -Identity $ListName -Connection $siteconn -ErrorAction SilentlyContinue
            if($list)
            {
                $listitems = Get-PnPListItem -List $list -Connection $siteconn
                if($listitemID)
                {
                    $listitem = $listitems | Where-Object {$_.ID -eq $listitemID}
                    if($listitem)
                    {
                        $file = Get-PnPFile  -Url $listitem["FileRef"] -AsFileObject -ErrorAction SilentlyContinue -Connection $siteconn           
                        if($file)
                        {
                            $fileversions = Get-PnPFileVersion -Url $listitem["FileRef"] -Connection $siteconn
                            if($fileversions)
                            {
                                if($fileversions.Count -gt $versionsToKeep)
                                {
                                    $DeleteVersionList = ($fileversions[0..$($fileversions.Count - $versionsToKeep)])
                                    $element = "" | Select-Object SiteUrl, siteName, ListTitle, itemName, fileType, Modified, versioncount, FileSize
                                    $element.SiteUrl = $siteUrl
                                    $element.siteName = $siteconn.Name
                                    $element.ListTitle = $list.Title
                                    $element.itemName = $file.Name
                                    $fileextention = $item["FileLeafRef"].Substring($item["FileLeafRef"].LastIndexOf(".")+1)
                                    $element.fileType = $fileextention
                                    $element.Modified = $file.TimeLastModified.tostring()
                                    $element.versioncount = $fileversions.Count
                                    $element.fileSize = $file.Length
                                    
                                    $arraylist.Add($element) | Out-Null                        
                                    
                                    foreach($VersionToDelete in $DeleteVersionList) 
                                    {
                                        Remove-PnPFileVersion -Url $listitem["FileRef"] -Identity $VersionToDelete.Id –Force -Connection $siteconn            
                                    }
                                }
                                else {
                                    write-host "no versions to delete"
                                }
                            }                            
                        }
                        else {
                            write-host "file not found" -ForegroundColor Red
                        }
                    }
                }
                else 
                {
                    foreach($listitem in $listitems)
                    {
                        $file = Get-PnPFile  -Url $listitem["FileRef"] -AsFileObject -ErrorAction SilentlyContinue -Connection $siteconn           
                        if($file)
                        {
                            $fileversions = Get-PnPFileVersion -Url $listitem["FileRef"] -Connection $siteconn
                            if($fileversions)
                            {
                                Write-Host "fileversions found $($fileversions.Count)"
                                if($fileversions.Count -gt $versionsToKeep)
                                {
                                    $number =$fileversions.Count - $versionsToKeep
                                    $DeleteVersionList = ($fileversions[0..$number])
                                    $element = "" | Select-Object SiteUrl, ListTitle, itemName, fileType, Modified, versioncount, FileSize
                                    $element.SiteUrl = $siteUrl
                                    $element.ListTitle = $list.Title
                                    $element.itemName = $file.Name
                                    $fileextention = $listitem["FileLeafRef"].Substring($listitem["FileLeafRef"].LastIndexOf(".")+1)
                                    $element.fileType = $fileextention
                                    $element.Modified = $file.TimeLastModified.tostring()
                                    $element.versioncount = $fileversions.Count
                                    $element.fileSize = $file.Length
                                    
                                    $arraylist.Add($element) | Out-Null
                                    foreach($VersionToDelete in $DeleteVersionList) 
                                    {
                                        Remove-PnPFileVersion -Url $listitem["FileRef"] -Identity $VersionToDelete.Id –Force -Connection $siteconn            
                                    }
                                }
                                else {
                                    write-host "no versions to delete"
                                }                                
                            }
                            else {
                                write-host "fileversions not found" -ForegroundColor Yellow
                            }                            
                        }
                        else {
                            write-host "file not found" -ForegroundColor Yellow
                        }
                    }
                }
            }            
        }
        else {
            # you can trim all lists in a site here
        }            
    }
    catch 
    {
        Write-Output "Ups an exception was thrown : $($_.Exception.Message)" -ForegroundColor Red
    }  
}

function Get-SiteCollections
{
    # this function is just a way to get the site collections that are in scope for the trimming
    $SiteCollections = Get-PnPTenantSite -Connection $conn  
    Disconnect-PnPOnline -Connection $conn
    return $SiteCollections
}

# $allsitecollections = Get-SiteCollections
# foreach($SiteCollection in $SiteCollections)
# {
#     DeleteVersions -siteUrl $SiteCollection.Url -ListName "Shared Documents" -listitemID 1 -versionsToKeep 20   
# }


#get total storage use for this site collection
$siteUrl = "https://contoso.sharepoint.com/sites/aSpecificSiteCollection"
$site = Get-PnPTenantSite -Connection $conn -Url $siteUrl -Detailed
$siteStorage = $site.StorageUsageCurrent
$siteStorage = $siteStorage / 1024 
$siteStorage = [Math]::Round($siteStorage,2)
write-host "site storage $siteStorage GB"

DeleteVersions -siteUrl $siteUrl -ListName "DocLibMajors"  -versionsToKeep 10
$arraylist | Export-Csv -Path "C:\temp\versiontrimmer.csv" -NoTypeInformation -Force -Encoding utf8BOM -Delimiter "|"
```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [PnP PowerShell Enhanced Version Control Batch Delete Job](#tab/pnpps)

```PowerShell
param (
    [string]$siteURL,
    [string]$library,
    [int]$deleteOlderThanDays,
    [int]$majorVersionsToKeep,
    [int]$majorWithMinorVersionsToKeep,
    [switch]$Automatic
)

if (-not $siteURL) {
    $siteURL = Read-Host "Please enter Site URL"
}

if (-not $library) {
    $library = Read-Host "Please enter the library name, i.e. Documents or leave blank for the whole site"
}

if (-not $Automatic) {
    if (-not $deleteOlderThanDays) {
        $deleteOlderThanDays = Read-Host "Enter the number of days to keep versions for or leave blank or 0 to keep major minor versions"
        if ($deleteOlderThanDays -eq "") {
            $deleteOlderThanDays = 0
        }
        if ($deleteOlderThanDays -eq 0) {
            $majorVersionsToKeep = Read-Host "Enter the number of major versions to keep"
            $majorWithMinorVersionsToKeep = Read-Host "Enter the number of major versions with minor versions to keep"
        }
    } else {
        Write-Host "DeleteOlderThanDays is specified. Skipping prompts for major versions to keep."
    }
} else {
    Write-Host "Automatic is specified. Skipping other prompts."
}

Connect-PnPOnline -url $siteURL -Interactive

if ($library) {
    if ($Automatic) {
        New-PnPLibraryFileVersionBatchDeleteJob -Identity $library -Automatic -force
    } else {
        if ($deleteOlderThanDays -and $deleteOlderThanDays -gt 0) {
            New-PnPLibraryFileVersionBatchDeleteJob -Identity $library -deletebeforedays $deleteOlderThanDays -force
        } else {
            New-PnPLibraryFileVersionBatchDeleteJob -Identity $library -MajorVersionLimit $majorVersionsToKeep -MajorWithMinorVersionsLimit $majorWithMinorVersionsToKeep -force
        }
    }
    Get-PnPLibraryFileVersionBatchDeleteJobStatus -Identity $library
} else {
    if ($Automatic) {
        New-PnPSiteFileVersionBatchDeleteJob -Automatic -force
    } else {
        if ($deleteOlderThanDays) {
            New-PnPSiteFileVersionBatchDeleteJob -deletebeforedays $deleteOlderThanDays -force
        } else {
            New-PnPSiteFileVersionBatchDeleteJob -MajorVersionLimit $majorVersionsToKeep -MajorWithMinorVersionsLimit $majorWithMinorVersionsToKeep -force
        }
    }
    Get-PnPSiteFileVersionBatchDeleteJobStatus
}
```

# [CLI for Microsoft 365](#tab/cli-m365-ps)

```powershell
    #Log in to Microsoft 365
    Write-Host "Connecting to Tenant" -f Yellow
    
    $m365Status = m365 status
    if ($m365Status -match "Logged Out") {
        m365 login
    }
    
    $siteURL = Read-Host "Please enter Site URL"
    $folderUrl = Read-Host "Please enter the server- or site-relative URL of the parent folder"
    $versionsToKeep = Read-Host "Please enter the number of versions to keep"
    
    $filesProcessed = @()   
    
    # Get all files in the list
    $files = m365 spo file list --webUrl $siteURL --folderUrl $folderUrl --recursive --output json | ConvertFrom-Json
    foreach ($file in $files) {
        $fileVersions = m365 spo file version list --webUrl $siteURL --fileUrl $file.ServerRelativeUrl | ConvertFrom-Json
    
        if ($fileVersions.Count -gt $versionsToKeep) {
            $number = $fileVersions.Count - $versionsToKeep - 1
            $removeVersionList = ($fileversions[0..$number])
    
            foreach ($versionToDelete in $removeVersionList) {
                Write-Host "Removing version $($versionToDelete.VersionLabel) from the file $($file.Name)..."
                m365 spo file version remove --webUrl $siteURL --fileUrl $file.ServerRelativeUrl --label $versionToDelete.VersionLabel --confirm
            }
            
            $filesProcessed += [PSCustomObject]@{
                SiteUrl   = $siteURL
                FolderUrl = $folderUrl
                FileName  = $file.Name
                FileUrl   = $file.ServerRelativeUrl
                Versions  = $fileVersions.Count
            }
        }
    }
    
    $filesProcessed | Export-Csv -Path ".\VersionTrimmer.csv" -NoTypeInformation -Encoding utf8
    
    m365 logout
    Write-Host "Finished"
```

[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

***
## Source Credit

The 'PnP PowerShell Enhanced Version Control Batch Delete Job' sample first appeared on [Enhanced Version Controls/Intelligent Versioning Trim with PowerShell](https://reshmeeauckloo.com/posts/powershell-enhanced-versioning-controls-trim/)

## Contributors

| Author(s) |
|-----------|
| Kasper Larsen |
| [Nanddeep Nachan](https://github.com/nanddeepn) |
| [Reshmee Auckloo (script)](https://github.com/reshmee011)|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-file-version-trimmer" aria-hidden="true" />
