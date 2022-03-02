---
plugin: add-to-gallery
---

# List site collection owners

## Summary

This script helps you to list and export all site collection owners in your SharePoint Online sites.
 
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
$counter = 0
foreach($site in $allSPOSites){
    $counter++
    Write-Host "Processing $($site.Url)... ($counter/$siteCount)"
    $users = m365 spo user list --webUrl $site.Url -o json | ConvertFrom-Json
    $owners = $users.value | where { $_.IsSiteAdmin -eq $true } 
    
    foreach($owner in $owners){
        $results += [pscustomobject][ordered]@{
            SiteUrl = $site.Url
            LoginName = $owner.LoginName
            Title = $owner.Title
            Email = $owner.Email
        }
    }
}
Write-Host "Exporting file to $fileExportPath..."
$results | Export-Csv -Path $fileExportPath -NoTypeInformation
Write-Host "Completed."
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]


## Source Credit

Sample first appeared on [List site collection owners | CLI for Microsoft 365](https://pnp.github.io/cli-microsoft365/sample-scripts/spo/list-site-collection-owners/)

## Contributors

| Author(s) |
|-----------|
| Patrick Lamber |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-list-site-collection-owners" aria-hidden="true" />
