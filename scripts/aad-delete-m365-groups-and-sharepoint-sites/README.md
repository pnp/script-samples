---
plugin: add-to-gallery
---

# Delete all Microsoft 365 groups and SharePoint sites

## Summary

Another example how you can delete all Microsoft 365 Groups and SharePoint Online sites in your development environment.
 
[!INCLUDE [Delete Warning](../../docfx/includes/DELETE-WARN.md)]

# [CLI for Microsoft 365 with PowerShell](#tab/cli-m365-ps)
```powershell
### Warning. Use with caution. This script deletes all M365 Groups and SPO Sites in your tenant
$devAccount = "<putyourupnhereforsecuritycheck>"
### Deletes the resources from the recyclebin. The CLI does not support this feature yet
$skipRecycleBin = $true

$m365Status = m365 status
Write-Host $m365Status
if ($m365Status -eq "Logged Out") {
  # Connection to Microsoft 365
  m365 login
  $m365Status = m365 status
}

# Check added as security measure
if ($m365Status[0].ToString().IndexOf($devAccount) -eq -1) {
  Write-Host "The user does not match the target development account. Stopping..." -ForegroundColor Red
  return;
}

Write-host "Retrieving all groups..."
$allGroups = m365 aad o365group list -o json | ConvertFrom-Json
$groupCount = $allGroups.Count

Write-Host "Processing $groupCount sites..."
#Loop through each site
$groupCounter = 0

foreach ($group in $allGroups) {
  $groupCounter++
  Write-Host "Deleting $($group.displayName)... ($groupCounter/$groupCount)"
  m365 aad o365group remove --id $group.id --confirm $true
}

Write-host "Retrieving all SPO sites..."
$allSites = m365 spo site classic list -o json --query "[?contains(Template,'SITEPAGEPUBLISHING') || contains(Template,'STS')]" | ConvertFrom-Json
$siteCount = $allSites.Count

Write-Host "Processing $siteCount sites..."
#Loop through each site
$siteCounter = 0

foreach ($site in $allSites) {
  $siteCounter++
  Write-Host "Deleting $($site.Url)... ($siteCounter/$siteCount)"
  m365 spo site remove --url $site.Url --skipRecycleBin $skipRecycleBin --confirm $true
}
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
***
# [PnP PowerShell](#tab/pnpps)
```powershell
$AdminCenterURL="https://contoso-admin.sharepoint.com/"
#Connect to SharePoint admin url using SPOService to retrieve all sites to be deleted
Connect-SPOService -Url $AdminCenterURL
#Connect to SharePoint admin url using PnPOnline to use PnP cmdlets to delete m365 groups and SharePoint sites
Connect-PnPOnline -Url $AdminCenterURL -Interactive

#retrieve all m365 group connected ( template "GROUP#0" sites to be deleted) sites beginning with https://contoso.sharepoint.com/sites/D-Test
$sites = Get-SPOSite  -Filter {Url -like  "https://contoso.sharepoint.com/sites/D-Test" -and Template -eq "GROUP#0" }
#displaying the sites returned 
$sites | Format-Table Title, Url, Template , GroupId

Read-Host -Prompt "Press Enter to start deleting (CTRL + C to exit)"
$sites | ForEach-Object{
Remove-PnPMicrosoft365Group  -Identity $_.GroupId
#allow time for m365 group to be deleted
Start-Sleep -Seconds 60
#delete the SharePoint site after the m365 group is deleted
Remove-PnPTenantSite -Url $_.Url -Force -SkipRecycleBin
#permanently delete the site and to allow a site to be created with the url of the site just deleted , i.e. to avoid message "This site address is available with modification"
Remove-SPODeletedSite -identity $_.Url -NoWait -Confirm:$false 
}
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***
## Source Credit

Sample first appeared on [Delete all Microsoft 365 groups and SharePoint sites | CLI for Microsoft 365](https://pnp.github.io/cli-microsoft365/sample-scripts/aad/delete-m365-groups-and-sharepoint-sites/)

## Contributors

| Author(s) |
|-----------|
| Patrick Lamber |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/aad-delete-m365-groups-and-sharepoint-sites" aria-hidden="true" />