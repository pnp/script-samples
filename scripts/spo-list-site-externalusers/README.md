---
plugin: add-to-gallery
---

# List all external users in all site collections

## Summary

This script helps you to list all external users in all SharePoint Online sites. It provides insights in who the users are, and if available who they where invited by.
 
# [CLI for Microsoft 365 with PowerShell](#tab/cli-m365-ps)
```powershell
$fileExportPath = "<PUTYOURPATHHERE.csv>"

$m365Status = m365 status

if ($m365Status -eq "Logged Out") {
  # Connection to Microsoft 365
  m365 login
}

$results = @()
Write-host "Retrieving all sites and check external users..."
$allSPOSites = m365 spo site classic list -o json | ConvertFrom-Json
$siteCount = $allSPOSites.Count

Write-Host "Processing $siteCount sites..."
#Loop through each site
$siteCounter = 0

foreach ($site in $allSPOSites) {
  $siteCounter++
  Write-Host "Processing $($site.Url)... ($siteCounter/$siteCount)"

  Write-host "Retrieving all external users ..."

  $users = m365 spo user list --webUrl $site.Url --output json --query "value[?contains(LoginName,'#ext#')]" | ConvertFrom-Json

  foreach ($user in $users) {
    $externalUserObject = m365 spo externaluser list --siteUrl $site.url -o json --query "[?AcceptedAs == '$($user.Email)']" | ConvertFrom-Json

    $results += [pscustomobject][ordered]@{
      UserPrincipalName = $user.UserPrincipalName
      Email             = $user.Email
      InvitedAs         = $externalUserObject.InvitedAs
      WhenCreated       = $externalUserObject.WhenCreated
      InvitedBy         = $externalUserObject.InvitedBy
      Url               = $site.Url
    }
  }
}

Write-Host "Exporting file to $fileExportPath..."
$results | Export-Csv -Path $fileExportPath -NoTypeInformation
Write-Host "Completed."
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

# [SPO Management Shell](#tab/spoms-ps)

```powershell

$fileExportPath = "<PUTYOURPATHHERE.csv>"

Connect-SPOService https://<yourorg>-admin.sharepoint.com

$results = @()
Write-host "Retrieving all sites and check external users..."
$allSPOSites = Get-SPOSite -Limit ALL
$siteCount = $allSPOSites.Count

Write-Host "Processing $siteCount sites..."
#Loop through each site
$siteCounter = 0

foreach ($site in $allSPOSites) {
  $siteCounter++
  Write-Host "Processing $($site.Url)... ($siteCounter/$siteCount)"

  Write-host "Retrieving all external users ..."

  $users = Get-SPOExternalUser -SiteUrl $($site.Url)

  Write-host "  $($users.Count) external users ..." -ForegroundColor Yellow

  foreach ($user in $users) {
    
    $results = [pscustomobject][ordered]@{
      DisplayName = $user.DisplayName
      Email       = $user.Email
      WhenCreated = $user.WhenCreated
      Url         = $site.Url
    }

    $results | Export-Csv -Path $fileExportPath -NoTypeInformation -Append
  }
}


Write-Host "Completed."

```
[!INCLUDE [More about SPO Management Shell](../../docfx/includes/MORE-SPOMS.md)]

***

## Source Credit

Sample first appeared on [List all external users in all site collections | CLI for Microsoft 365](https://pnp.github.io/cli-microsoft365/sample-scripts/spo/list-site-externalusers/)

## Contributors

| Author(s) |
|-----------|
| Albert-Jan Schot |
| Paul Bullock |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/spo-list-site-externalusers" aria-hidden="true" />