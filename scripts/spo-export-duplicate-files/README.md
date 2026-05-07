# SharePoint Online - Export Duplicate Files

## Summary

This is a simple PowerShell script that loops thorough all the files in a SharePoint Online Tenant, and compares the file Hashes of all your files, in order to identify any duplicate files, while the script does not delete them, it'll export a nice overview for you to review.

**NOTE** the proper way to do this would be using [Microsoft Graph Data Connect](https://learn.microsoft.com/en-us/graph/data-connect-concept-overview), but I'm cheap, and only needed it on my development tenant, so I wrote this script instead, but the concept remains the same.

**NOTE** I Ran this using delegated permissions, but if you want the full overview of all files, you should run this using application permissions, as delegated permissions will only return files that the user has access to.

# [PnP PowerShell](#tab/pnpps)

```powershell
$ErrorActionPreference = "Stop"
$SharePointRootSiteUrl = "http://<tenant>.sharepoint.com/"


Connect-PnPOnline -Interactive -Url $SharePointRootSiteUrl -ClientId "<ClientId>";

$allFiles = New-Object System.Collections.ArrayList;


$sites = Invoke-PnPGraphMethod -Url "https://graph.microsoft.com/v1.0/sites/?`$search=`"http*`"&`$select=id,webUrl,displayName&`$top=100" -All;

foreach ($site in $sites.value) {
    Write-Host "> Site: $($site.displayName) - ($($site.webUrl))"
    $drives = Invoke-PnPGraphMethod -Url "https://graph.microsoft.com/v1.0/sites/$($site.id)/drives?`$select=id,webUrl,name&`$top=100" -All;

    foreach ($drive in $drives.value) {
        Write-Host "`t> Drive: $($drive.name) - ($($drive.webUrl))";

        ## Would've loved to use a $select=file,id,webUrl,size,name but that breaks for some reason when using PnP PowerShell
        $files = Invoke-PnPGraphMethod -Url "https://graph.microsoft.com/v1.0/sites/$($site.id)/drives/$($drive.id)/items?`$filter=file ne null" -All;

        foreach ($file in $files.value | Where-Object { $_.file -ne $null }) {
            Write-Host "`t`t>File: $($file.name)";

            $allFiles.Add([PSCustomObject]@{
                    SiteId     = $site.id
                    DriveId    = $drive.id
                    FileId     = $file.id
                    FileName   = $file.name
                    FileWebUrl = $file.webUrl
                    FileSize   = $file.size
                    FileHash   = $file.file.hashes.quickXorHash
                }) | Out-Null
        }
        Write-Host "`t> Finished processing files in drive: $($drive.name)"
    }
    Write-Host "> Finished processing drives in site: $($site.displayName)"   
}

Write-Host "Finished loading all files"

$grouped = $allFiles | Where-Object {$null -ne $_.FileHash} | Group-Object -Property FileHash | Where-Object { $_.Count -gt 1 } | Sort-Object -Property Count -Descending;

foreach($group in $grouped){
    Write-Host "Duplicate files with hash: $($group.Name)"
    foreach($file in $group.Group){
        Write-Host "`t> $($file.FileName) - $($file.FileWebUrl)"
    }
    Write-Host ""
}


```

***

## Contributors

| Author(s)                       |
| ------------------------------- |
| [Dan Toft](https://Dan-toft.dk) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-export-duplicate-files" aria-hidden="true" />