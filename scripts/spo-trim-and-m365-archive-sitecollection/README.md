---
plugin: add-to-gallery
---

# Trim file versions and archive Site Collection using Microsoft365 Archive

## Summary

As of time of writing, the Microsoft 365 Archive is just out of preview. The current out of the box way to archvive a site is to make the Site Collection read-only, but I would expect that the Microsoft 365 Archive will be the way to go in the future, at least when the feature has been enabled on your tenant :-)
In the meantime we have to do the archiving the proper way ourself and this script will trim file versions and then archive the site collection to the Microsoft 365 Archive.
![Example Screenshot](assets/example.png)


# [PnP PowerShell](#tab/pnpps)

```powershell

#sample showing how to trim file versions and archive a SharePoint Site collection

$siteUrl = "https://contoso.sharepoint.com/sites/contoso"
#use -interactive when working locally, managed identity when running in Azure and I guess you have to use a certificate when dealing with SAAS
$conn = Connect-PnPOnline -Url $siteUrl -Interactive -ReturnConnection

function DeleteVersions($siteUrl, $ListName, $listitemID, $versionsToKeep)
{
    try 
    {
        #get list of all lists in this site
        if($ListName)
        {
            $list = Get-PnPList -Identity $ListName -Connection $conn -ErrorAction SilentlyContinue
            if($list)
            {
                $listitems = Get-PnPListItem -List $list -Connection $conn
                if($listitemID)
                {
                    $listitem = $listitems | Where-Object {$_.ID -eq $listitemID}
                    if($listitem)
                    {
                        $file = Get-PnPFile  -Url $listitem["FileRef"] -AsFileObject -ErrorAction SilentlyContinue -Connection $conn           
                        if($file)
                        {
                            $fileversions = Get-PnPFileVersion -Url $listitem["FileRef"] -Connection $conn
                            if($fileversions)
                            {
                                if($fileversions.Count -gt $versionsToKeep)
                                {
                                    $DeleteVersionList = ($fileversions[0..$($fileversions.Count - $versionsToKeep)])
                                    $element = "" | Select-Object SiteUrl, siteName, ListTitle, itemName, fileType, Modified, versioncount, FileSize
                                    $element.SiteUrl = $siteUrl
                                    $element.siteName = $conn.Name
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
                                        Remove-PnPFileVersion -Url $listitem["FileRef"] -Identity $VersionToDelete.Id –Force -Connection $conn            
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
                        $file = Get-PnPFile  -Url $listitem["FileRef"] -AsFileObject -ErrorAction SilentlyContinue -Connection $conn           
                        if($file)
                        {
                            $fileversions = Get-PnPFileVersion -Url $listitem["FileRef"] -Connection $conn
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
                                        Remove-PnPFileVersion -Url $listitem["FileRef"] -Identity $VersionToDelete.Id –Force -Connection $conn            
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
        else 
        {
            # you can trim all lists in a site here
            $lists = Get-PnPList -Identity $ListName -Connection $conn -ErrorAction SilentlyContinue | Where-Object { $_.Hidden -eq $false -and $_.BaseType -eq "DocumentLibrary" }
            foreach($list in $lists)
            {
                DeleteVersions -siteUrl $siteUrl -ListName $list.Title -versionsToKeep $versionsToKeep -Connection $conn
            }
        }            
    }
    catch 
    {
        Write-Output "Ups an exception was thrown : $($_.Exception.Message)" -ForegroundColor Red
    }  
}

#trim file versions
DeleteVersions -siteUrl $siteUrl -versionsToKeep 5 -Connection $conn #trim all libraries to 5 versions
#archive the site collection
Set-PnPSiteArchiveState $siteUrl -ArchiveState Archived -Connection $conn


```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***


## Contributors

| Author(s) |
|-----------|
| Kasper Larsen |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-trim-and-m365-archive-sitecollection" aria-hidden="true" />
