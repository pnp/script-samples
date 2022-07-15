---
plugin: add-to-gallery
---

# List external users across all sites and in what site groups they are

## Summary

This script shows how you can check if external users are added to site groups. It will show all external users across all site collections and the site groups they where added to.

![Example Screenshot](assets/example.png)
 
# [CLI for Microsoft 365 with PowerShell](#tab/cli-m365-ps)
```powershell

$m365Status = m365 status --output text

if ($m365Status -eq "Logged Out") {
  m365 login
}

Write-Host "Retrieving all sites and check external users..." -ForegroundColor Green

$sites = m365 spo site classic list -o json | ConvertFrom-Json
$siteCount = $sites.Count
$siteCounter = 0
$results = [System.Collections.ArrayList]::new()

$spoAccessToken = m365 util accesstoken get --resource sharepoint --new | ConvertFrom-Json

Write-Host "Processing $siteCount sites..."

foreach ($site in $sites) {
  $siteCounter++  
  Write-Host "$siteCounter/$siteCount - Get external users in site groups for $($site.Url)..." -ForegroundColor Green

  $response = Invoke-WebRequest -Uri "$($site.Url)/_api/web/siteusers?`$filter=IsShareByEmailGuestUser eq true&`$expand=Groups&`$select=Title,LoginName,Email,Groups/LoginName" -Method Get -Headers @{ Authorization = "Bearer $spoAccessToken"; Accept = "application/json;odata=nometadata" }
  $users = $response.Content | ConvertFrom-Json  

  foreach($user in $users.value) {
    foreach($group in $user.Groups) {
      $obj = [PSCustomObject][ordered]@{
          Title = $user.Title;
          Email = $user.Email;
          LoginName = $user.LoginName;
          Group = $group.LoginName;
      }
      $results.Add($obj) | Out-Null
    }
  }
}

Write-Host "Exporting list..." -ForegroundColor Green
$results | Export-Csv -Path "./cli-external-users-in-sitegroups.csv" -NoTypeInformation

```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

# [PnP PowerShell](#tab/pnpps)
```powershell

Connect-PnPOnline "https://contoso-admin.sharepoint.com" -Interactive

Write-Host "Retrieving all sites and check external users..." -ForegroundColor Green

$sites = Get-PnPTenantSite
$siteCount = $sites.Count
$siteCounter = 0
$results = [System.Collections.ArrayList]::new()

Write-Host "Processing $siteCount sites..."

foreach($site in $sites) {
  $siteCounter++
  Write-Host "$siteCounter/$siteCount - Get external users in site groups for $($site.Url)..." -ForegroundColor Green
  
  Connect-PnPOnline -Url $site.Url -Interactive
    
  $users = (Invoke-PnPSPRestMethod -Method Get -Url "$($site.Url)/_api/web/siteusers?`$filter=IsShareByEmailGuestUser eq true&`$expand=Groups&`$select=Title,LoginName,Email,Groups/LoginName" -ContentType "application/json;odata=nometadata" -Raw -ErrorAction Ignore | ConvertFrom-Json)

  foreach($user in $users.value) {
    foreach($group in $user.Groups) {      
      $obj = [PSCustomObject][ordered]@{
          Title = $user.Title;
          Email = $user.Email;
          LoginName = $user.LoginName;
          Group = $group.LoginName;
      }
      $results.Add($obj) | Out-Null
    }
  }
}

Write-Host "Exporting list..." -ForegroundColor Green
$results | Export-Csv -Path "./pnp-external-users-in-sitegroups.csv" -NoTypeInformation

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***

## Contributors

| Author(s) |
|-----------|
| Martin Lingstuyl |
| Bart-Jan Dekker |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-list-site-externalusers-in-groups" aria-hidden="true" />
