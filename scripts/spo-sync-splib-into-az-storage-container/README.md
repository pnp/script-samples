---
plugin: add-to-gallery
---

# Sync SharePoint Document Library Documents with Azure Storage Container

## Summary

This PowerShell script shows how to download and sync documents in a SharePoint Document Library into an Azure Storage Container using Office 365 CLI and Azure CLI commands.
 Prerequisites:
 - [CLI for Microsoft 365](https://pnp.github.io/cli-microsoft365/)
 - [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/?view=azure-cli-latest)
 - SharePoint Online Site
 - Document Library with documents
 - Azure Storage Container
 - Azure Storage Account Key with required permission to upload documents
 
![Example Screenshot](assets/example.png)
 
# [CLI for Microsoft 365 with PowerShell](#tab/cli-m365-ps)
```powershell
$spolHostName = "https://tenant-name.sharepoint.com"
$spolSiteRelativeUrl = "/sites/site-name"
$spolDocLibTitle = "document-library-title"
$azStorageAccountKey = "*****************"
$azStorageAccountName = "azure-storage-account-name"
$azStorageContainerName = "azure-storage-container-name"
$localBaseFolderName = "local-base-folder-name"

$localFileDownloadFolderPath = $PSScriptRoot
$spolSiteUrl = $spolHostName + $spolSiteRelativeUrl

$spolLibItems = o365 spo listitem list --webUrl $spolSiteUrl --title $spolDocLibTitle --fields 'FileRef,FileLeafRef' --filter "FSObjType eq 0" -o json | ConvertFrom-Json

if ($spolLibItems.Count -gt 0) {
  ForEach ($spolLibItem in $spolLibItems) {
    $spolLibFileRelativeUrl = $spolLibItem.FileRef
    $spolFileName = $spolLibItem.FileLeafRef

    $spolLibFolderRelativeUrl = $spolLibFileRelativeUrl.Substring(0, $spolLibFileRelativeUrl.lastIndexOf('/'))

    $localDownloadFolderPath = Join-Path $localFileDownloadFolderPath $localBaseFolderName $spolLibFolderRelativeUrl

    If (!(test-path $localDownloadFolderPath)) {
      $message = "Target local folder $localDownloadFolderPath not exist"
      Write-Host $message -ForegroundColor Yellow

      New-Item -ItemType Directory -Force -Path $localDownloadFolderPath | Out-Null

      $message = "Created target local folder at $localDownloadFolderPath"
      Write-Host $message -ForegroundColor Green
    }
    else {
      $message = "Target local folder exist at $localDownloadFolderPath"
      Write-Host $message -ForegroundColor Blue
    }

    $localFilePath = Join-Path $localDownloadFolderPath $spolFileName

    $message = "Processing SharePoint file $spolFileName"
    Write-Host $message -ForegroundColor Green

    o365 spo file get --webUrl $spolSiteUrl --url $spolLibFileRelativeUrl --asFile --path $localFilePath

    $message = "Downloaded SharePoint file at $localFilePath"
    Write-Host $message -ForegroundColor Green
  }

  $localFolderToSync = Join-Path $localFileDownloadFolderPath $localBaseFolderName
  az storage blob sync --account-key $azStorageAccountKey --account-name $azStorageAccountName -c $azStorageContainerName -s $localFolderToSync --only-show-errors | Out-Null

  $message = "Syncing local folder $localFolderToSync with Azure Storage Container $azStorageContainerName is completed"
  Write-Host $message -ForegroundColor Green
}
else {
  Write-Host "No files in $spolDocLibTitle library" -ForegroundColor Yellow
}
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
***

## Source Credit

Sample first appeared on [Sync SharePoint Document Library Documents with Azure Storage Container | CLI for Microsoft 365](https://pnp.github.io/cli-microsoft365/sample-scripts/spo/sync-splib-into-az-storage-container/)

## Contributors

| Author(s) |
|-----------|
| Joseph Velliah |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/spo-sync-splib-into-az-storage-container" aria-hidden="true" />