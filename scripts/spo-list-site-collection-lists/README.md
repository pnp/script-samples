---
plugin: add-to-gallery
---

# List site collections and their lists

## Summary

This script helps you to list and export all site collection and their lists SharePoint Online sites, ideal for getting insights into the size of your environment.
 
# [CLI for Microsoft 365 with PowerShell](#tab/cli-m365-ps)
```powershell
$fileExportPath = "<PUTYOURPATHHERE.csv>"

$m365Status = m365 status

if ($m365Status -eq "Logged Out") {
  # Connection to Microsoft 365
  m365 login
}

$results = @()
Write-host "Retrieving all sites..."
$allSPOSites = m365 spo site classic list -o json | ConvertFrom-Json
$siteCount = $allSPOSites.Count

Write-Host "Processing $siteCount sites..."
#Loop through each site
$siteCounter = 0

foreach ($site in $allSPOSites) {
  $siteCounter++
  Write-Host "Processing $($site.Url)... ($siteCounter/$siteCount)"

  $results += [pscustomobject][ordered]@{
    Type         = "site"
    Title        = $site.Title
    Url          = $site.Url
    StorageUsage = $site.StorageUsage
    Template     = $site.Template
  }

  Write-host "Retrieving all lists..."

  $allLists = m365 spo list list -u $site.url -o json | ConvertFrom-Json
  foreach ($list in $allLists) {

    $results += [pscustomobject][ordered]@{
      Type     = "list"
      Title    = $list.Title
      Url      = $list.Url
      Template = $list.BaseTemplate
    }
  }
}

Write-Host "Exporting file to $fileExportPath..."
$results | Export-Csv -Path $fileExportPath -NoTypeInformation
Write-Host "Completed."
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]


## Source Credit

Sample first appeared on [List site collections and their lists | CLI for Microsoft 365](https://pnp.github.io/cli-microsoft365/sample-scripts/spo/list-site-collection-lists/)

## Contributors

| Author(s) |
|-----------|
| Albert-Jan Schot |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/spo-list-site-collection-lists" aria-hidden="true" />