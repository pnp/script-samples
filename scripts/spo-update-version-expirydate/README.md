# Update file major versions to never expire

## Summary

SharePoint Online’s automatic version deletion feature is designed to help organizations manage storage by automatically removing old file versions. When you enable automatic version trimming at the tenant level, SharePoint sets expiration dates on file versions before they’re permanently deleted.

However, there are scenarios where you might want to preserve specific versions indefinitely—perhaps they contain critical information, represent important milestones, or are required for compliance purposes. The script will set file major versions to never expire.

If it requires the expiry date to be an alternative date, you could use the following snippet

```PowerShell
Set-PnPFileVersion -List "Documents" -Identity 1 -Version "1.0" -ExpirationDate "2025-12-31"
```

# [PnP PowerShell](#tab/pnpps)

```powershell
param (
    [Parameter(Mandatory = $true)]
    [string]$SiteUrl,

    [Parameter(Mandatory = $true)]
    [string]$LibraryName
)

# Connect interactively to SharePoint
Connect-PnPOnline -Url $SiteUrl -Interactive

# Get all files in the specified document library
Write-Host "Fetching files from library: $LibraryName ..." -ForegroundColor Cyan
$files = Get-PnPListItem -List $LibraryName -PageSize 1000 -Fields "FileRef", "FileLeafRef" | Where-Object { $_.FieldValues.FileRef -ne $null }

if ($files.Count -eq 0) {
    Write-Host "No files found in library '$LibraryName'." -ForegroundColor Yellow
    exit
}

foreach ($file in $files) {
    $fileRef = $file.FieldValues.FileRef
    $encodedFileUrl = [System.Uri]::EscapeDataString($fileRef)

    Write-Host "`nProcessing file: $fileRef" -ForegroundColor White

    # Get all versions of the current file
    $versionsUrl = "/_api/web/GetFileByServerRelativePath(DecodedUrl='$encodedFileUrl')/versions?$select=ID,VersionLabel"
    $versionsResponse = Invoke-PnPSPRestMethod -Url $versionsUrl -Method Get

    if ($versionsResponse.value.Count -eq 0) {
        Write-Host "  No versions found for file." -ForegroundColor Yellow
        continue
    }

    # Filter only major versions (X.0)
    $majorVersions = $versionsResponse.value | Where-Object {
        $_.VersionLabel -match '^\d+\.0$'
    }

    if ($majorVersions.Count -eq 0) {
        Write-Host "  No major versions found." -ForegroundColor DarkYellow
        continue
    }

    foreach ($version in $majorVersions) {
        $versionId = $version.ID
        $versionLabel = $version.VersionLabel

        Set-PnPFileVersion -List $LibraryName -Identity 1 -Version $versionId -ExpirationDate $null
        Write-Host "  ✅ Retained major version $versionLabel (ID $versionId) for file." -ForegroundColor Green
    }
}
```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***

## Source Credit

Sample first appeared on [How to Set SharePoint File Versions to Never Expire Using PowerShell](https://reshmeeauckloo.com/posts/powershell-set-fileversion-expiration-date/)

## Contributors

| Author(s) |
|-----------|
| [Reshmee Auckloo](https://github.com/reshmee011) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-update-version-expirydate" aria-hidden="true" />
