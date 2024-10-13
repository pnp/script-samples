---
plugin: add-to-gallery
---

# Generate file count report

## Summary

I came across an interesting request on discord, someone wanted to report on the number of files in their SharePoint Online environment.

Not their storage usage, but the number of files, and the number across all sites, libraries and down to the folder level.

This script will generate a report of the number of files in each site, library and folder in your SharePoint Online environment.

## Example output (CSV)

| Type             | Id           | Path                                                                                       | WebUrl       | SiteTitle | DocumentLibraryTitle | DocumentLibraryUrl               | DocumentLibraryId | DirectFolderCount | DirectFilesCount | DirectItemCount | DirectPercentageOfDocLib | DirectPercentageOfSite | TotalFolderCount | TotalFilesCount | TotalItemCount | TotalPercentageOfDocLib | TotalPercentageOfSite |
| ---------------- | ------------ | ------------------------------------------------------------------------------------------ | ------------ | --------- | -------------------- | -------------------------------- | ----------------- | ----------------- | ---------------- | --------------- | ------------------------ | ---------------------- | ---------------- | --------------- | -------------- | ----------------------- | --------------------- |
| Site             |              | __Redacted__                                                                               | __Redacted__ | Intranet  |                      |                                  |                   | 0                 | 0                | 6               | 0%                       | 100%                   | 0                | 0               | 50044          | 0%                      | 100%                  |
| Document Library | __Redacted__ | /sites/sitename/Document Library                                                           | __Redacted__ | Intranet  | Document Library     | /sites/sitename/Document Library | __Redacted__      | 1                 | 41               | 42              | 97.67%                   | 0.08%                  | 1                | 42              | 43             | 100%                    | 0.09%                 |
| Folder           | __Redacted__ | /sites/sitename/Document Library/Open in app                                               | __Redacted__ | Intranet  | Document Library     | /sites/sitename/Document Library | __Redacted__      | 0                 | 1                | 1               | 2.33%                    | 0%                     | 0                | 1               | 1              | 2.33%                   | 0%                    |
| Document Library | __Redacted__ | /sites/sitename/Shared Documents                                                           | __Redacted__ | Intranet  | Documents            | /sites/sitename/Shared Documents | __Redacted__      | 0                 | 3                | 3               | 100%                     | 0.01%                  | 0                | 3               | 3              | 100%                    | 0.01%                 |
| Document Library | __Redacted__ | /sites/sitename/LoadsOfDocuments                                                           | __Redacted__ | Intranet  | LoadsOfDocuments     | /sites/sitename/LoadsOfDocuments | __Redacted__      | 0                 | 49991            | 49991           | 100%                     | 99.89%                 | 0                | 49991           | 49991          | 100%                    | 99.89%                |
| Document Library | __Redacted__ | /sites/sitename/SiteAssets                                                                 | __Redacted__ | Intranet  | Site Assets          | /sites/sitename/SiteAssets       | __Redacted__      | 2                 | 0                | 2               | 28.57%                   | 0%                     | 4                | 3               | 7              | 100%                    | 0.01%                 |
| Folder           | __Redacted__ | /sites/sitename/SiteAssets/SitePages                                                       | __Redacted__ | Intranet  | Site Assets          | /sites/sitename/SiteAssets       | __Redacted__      | 1                 | 0                | 1               | 14.29%                   | 0%                     | 1                | 1               | 2              | 28.57%                  | 0%                    |
| Folder           | __Redacted__ | /sites/sitename/SiteAssets/SitePages/Dan-Toft---Viva-is-coming-home-for-christmas-(almost) | __Redacted__ | Intranet  | Site Assets          | /sites/sitename/SiteAssets       | __Redacted__      | 0                 | 1                | 1               | 14.29%                   | 0%                     | 0                | 1               | 1              | 14.29%                  | 0%                    |
| Folder           | __Redacted__ | /sites/sitename/SiteAssets/Lists                                                           | __Redacted__ | Intranet  | Site Assets          | /sites/sitename/SiteAssets       | __Redacted__      | 1                 | 0                | 1               | 14.29%                   | 0%                     | 1                | 2               | 3              | 42.86%                  | 0.01%                 |
| Folder           | __Redacted__ | /sites/sitename/SiteAssets/Lists/ __Redacted__                                             | __Redacted__ | Intranet  | Site Assets          | /sites/sitename/SiteAssets       | __Redacted__      | 0                 | 2                | 2               | 28.57%                   | 0%                     | 0                | 2               | 2              | 28.57%                  | 0%                    |

## Dictionary for the output

| Column | Description |
| ------ | ----------- |
| Type | The type of the object, Site, Document Library or Folder |
| Id | The ID of the object |
| Path | The server relative path to the object |
| WebUrl | The site collection URL of the object |
| SiteTitle | The title of the site collection |
| DocumentLibraryTitle | The title of the document library |
| DocumentLibraryUrl | The server relative URL to the document library |
| DocumentLibraryId | The ID of the document library |
| DirectFolderCount | The number of folders "directly", or "first layer" under the object |
| DirectFilesCount | The number of files "directly", or "first layer" under the object |
| DirectItemCount | The total number of items (folders and documents) "directly", or "first layer" under the object |
| DirectPercentageOfDocLib | The percentage of the total number of items in the document library, that are stored directly under the current object |
| DirectPercentageOfSite | The percentage of the total number of items in the site collection, that are stored directly under the current object |
| TotalFolderCount | The total number of folders under the object, all sub-folders included |
| TotalFilesCount | The total number of files under the object, all sub-folders included |
| TotalItemCount | The total number of items (folders and documents) under the object, all sub-folders included |
| TotalPercentageOfDocLib | The percentage of the total number of items in the document library, that are stored under the current object |
| TotalPercentageOfSite | The percentage of the total number of items in the site collection, that are stored under the current object |

# [PnP PowerShell](#tab/pnpps)

```powershell

$DOCUMENT_LIBRARY_BASETEMPLATE = 101
$FOLDER_OBJECT_TYPE = 1


$TenantAdminUrl = "https://2v8lc2-admin.sharepoint.com/"
$ClientId = "#####"
$Thumbprint = "#####"


Write-Host "Connecting to Tenant Admin Site..."
Connect-PnPOnline -Url $TenantAdminUrl -Thumbprint $Thumbprint -ClientId $ClientId
$Sites = Get-PnPTenantSite | Where-Object { $_.Template -ne "RedirectSite#0" -and $_.Template -ne "SPSMSITEHOST#0" }


$Report = @()


Write-Host "Processing $($sites.Count) sites..."
foreach ($Site in $Sites) {
    Write-Host "> $($Site.Url)" -ForegroundColor Blue
    $Connection = Connect-PnPOnline -Url $Site.Url -Thumbprint $Thumbprint -ClientId $ClientId -ReturnConnection
    $Lists = Get-PnPList -Connection $Connection | Where-Object { $_.BaseTemplate -eq $DOCUMENT_LIBRARY_BASETEMPLATE -and $_.Hidden -eq $false }
  
    $TotalSiteItemCount = $Lists | ForEach-Object { $_.ItemCount } | Measure-Object -Sum | Select-Object -ExpandProperty Sum
    $Report += [PSCustomObject]@{
        Type                     = "Site"
        Id                       = $Site.Id
        Path                     = $Site.Url
        WebUrl                   = $Site.Url
        SiteTitle                = $Site.Title
        DocumentLibraryTitle     = ""
        DocumentLibraryUrl       = ""
        DocumentLibraryId        = ""
        DirectFolderCount        = 0
        DirectFilesCount         = 0
        DirectItemCount          = $Lists.Count
        DirectPercentageOfDocLib = "0%"
        DirectPercentageOfSite   = "100%"
        TotalFolderCount         = 0
        TotalFilesCount          = 0
        TotalItemCount           = $TotalSiteItemCount
        TotalPercentageOfDocLib  = "0%"
        TotalPercentageOfSite    = "100%"
    }


    foreach ($List in $Lists) {
        write-host "`t> $($List.Title)"

        if ($List.ItemCount -gt 0) {
            $Items = Get-PnPListItem -List $List -Fields "FileRef", "FileDirRef", "ItemChildCount", "FFSObjType", "ID", "FolderChildCount" -PageSize 5000 -Connection $Connection
           
            $Folders = $Items | Where-Object { $_.FieldValues.FSObjType -eq $FOLDER_OBJECT_TYPE } | Sort-Object -Property FileRef
            $Files = $Items | Where-Object { $_.FieldValues.FSObjType -ne $FOLDER_OBJECT_TYPE } | Sort-Object -Property FileRef

            $RootLevelFolderCount = $Folders | Where-Object { $_.FieldValues.FileDirRef -eq $List.RootFolder.ServerRelativeUrl } | Measure-Object | Select-Object -ExpandProperty Count
            $RootLevelFileCount = $Files | Where-Object { $_.FieldValues.FileDirRef -eq $List.RootFolder.ServerRelativeUrl } | Measure-Object | Select-Object -ExpandProperty Count
            $RootLevelItemCount = $RootLevelFolderCount + $RootLevelFileCount

            $Report += [PSCustomObject]@{
                Type                     = "Document Library"
                Id                       = $List.Id
                Path                     = $List.RootFolder.ServerRelativeUrl
                WebUrl                   = $Site.Url
                SiteTitle                = $Site.Title
                DocumentLibraryTitle     = $List.Title
                DocumentLibraryUrl       = $List.RootFolder.ServerRelativeUrl
                DocumentLibraryId        = $List.Id
                DirectFolderCount        = $RootLevelFolderCount
                DirectFilesCount         = $RootLevelFileCount
                DirectItemCount          = $RootLevelItemCount
                DirectPercentageOfDocLib = $RootLevelItemCount -gt 0 ? "$([Math]::Round(($RootLevelItemCount / $List.ItemCount) * 100, 2))%" : "0%"
                DirectPercentageOfSite   = $TotalSiteItemCount -gt 0 ? "$([Math]::Round(($RootLevelItemCount / $TotalSiteItemCount) * 100, 2))%" : "0%"
                TotalFolderCount         = $Folders.Count
                TotalFilesCount          = $Files.Count
                TotalItemCount           = $List.ItemCount
                TotalPercentageOfDocLib  = $List.ItemCount -gt 0 ? "$([Math]::Round(($List.ItemCount / $List.ItemCount) * 100, 2) ?? 0)%" : "0%"
                TotalPercentageOfSite    = $List.ItemCount -gt 0 ? "$([Math]::Round(($List.ItemCount / $TotalSiteItemCount) * 100, 2) ?? 0)%" : "0%"
            }
    


            foreach ($Folder in $Folders) {  
                Write-Host "`t`t> $($Folder.FieldValues.FileRef)"
                
                $TotalSubFolderCount = $Folders | Where-Object { $_.FieldValues.FileRef.StartsWith($folder.FieldValues.FileRef + "/") } | Measure-Object | Select-Object -ExpandProperty Count
                $TotalSubFilesCount = $Files | Where-Object { $_.FieldValues.FileRef.StartsWith($folder.FieldValues.FileRef) } | Measure-Object | Select-Object -ExpandProperty Count
                $TotalItemCount = $TotalSubFolderCount + $TotalSubFilesCount

                $DirectItemCount = ([int]$Folder.FieldValues.ItemChildCount + [int]$Folder.FieldValues.FolderChildCount)

                $Report += [PSCustomObject]@{
                    Type                     = "Folder"
                    Id                       = $Folder.Id
                    Path                     = $Folder.FieldValues.FileRef
                    WebUrl                   = $Site.Url
                    SiteTitle                = $Site.Title
                    DocumentLibraryTitle     = $List.Title
                    DocumentLibraryUrl       = $List.RootFolder.ServerRelativeUrl
                    DocumentLibraryId        = $List.Id
                    DirectFilesCount         = $Folder.FieldValues.ItemChildCount
                    DirectFolderCount        = $Folder.FieldValues.FolderChildCount
                    DirectItemCount          = $DirectItemCount
                    DirectPercentageOfDocLib = $DirectItemCount -gt 0 ? "$([Math]::Round(($DirectItemCount / $List.ItemCount) * 100, 2))%" : "0%"
                    DirectPercentageOfSite   = $DirectItemCount -gt 0 ? "$([Math]::Round(($DirectItemCount / $TotalSiteItemCount) * 100, 2))%" : "0%"
                    TotalFolderCount         = $TotalSubFolderCount
                    TotalFilesCount          = $TotalSubFilesCount
                    TotalItemCount           = $TotalItemCount
                    TotalPercentageOfDocLib  = $TotalItemCount -gt 0 ? "$([Math]::Round(($TotalItemCount / $List.ItemCount) * 100, 2))%" : "0%"
                    TotalPercentageOfSite    = $TotalItemCount -gt 0 ? "$([Math]::Round(($TotalItemCount / $TotalSiteItemCount) * 100, 2))%" : "0%"
                }
            }
        }
    }
}

$Report | Select-Object * | Export-Csv -Path "Report.csv" -NoTypeInformation
Invoke-Item -Path "Report.csv"

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***

## Contributors

| Author(s)                       |
| ------------------------------- |
| [Dan Toft](https://dan-toft.dk) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-generate-sp-file-count-report" aria-hidden="true" />