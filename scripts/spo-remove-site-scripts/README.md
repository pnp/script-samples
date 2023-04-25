---
plugin: add-to-gallery
---

# Delete custom SharePoint site scripts

## Summary

Site designs and especially site scripts can be something that ends up just hanging around in your tenant for a long time even though you no longer need them for anything. Use the scripts below to get rid of them. You might also find some site scripts that are not linked to any site design and hence never get executed!
 
[!INCLUDE [Delete Warning](../../docfx/includes/DELETE-WARN.md)]

# [SPO Management Shell](#tab/spoms-ps)

```powershell
Connect-SPOService "https://contoso-admin.sharepoint.com"

$keepThese = "Base Site Settings", "English Region", "Standard Site Columns", "Standard Libraries"
$siteScripts = Get-SPOSiteScript
$siteScripts = $siteScripts | Where-Object { -not ($keepThese -contains $_.Title)}

if ($siteScripts.Count -eq 0) { break }

$siteScripts | Format-Table Title, SiteScriptIds, Description
Read-Host -Prompt "Press Enter to start deleting (CTRL + C to exit)"
$progress = 0
$total = $siteScripts.Count

foreach ($siteScript in $siteScripts)
{
  $progress++
  Write-Host $progress / $total":" $siteScript.Title
  Remove-SPOSiteScript $siteScript.Id
}
```
[!INCLUDE [More about SPO Management Shell](../../docfx/includes/MORE-SPOMS.md)]

# [PnP PowerShell](#tab/pnpps)

```powershell

# SharePoint online admin site url
$siteUrl = "https://contoso-admin.sharepoint.com/"	

# Connect to SharePoint online site
Connect-PnPOnline -Url $siteUrl -Interactive

$keepThese = "Base Site Settings", "English Region", "Standard Site Columns", "Standard Libraries"

# Get all site scripts from the current tenant
$siteScripts = Get-PnPSiteScript

$siteScripts = $siteScripts | Where-Object { -not ($keepThese -contains $_.Title)}

if ($siteScripts.Count -eq 0) { break }

$siteScripts | Format-Table Title, SiteScriptIds, Description
Read-Host -Prompt "Press Enter to start deleting (CTRL + C to exit)"

$progress = 0
$total = $siteScripts.Count

foreach ($siteScript in $siteScripts)
{
  $progress++
  Write-Host $progress / $total":" $siteScript.Title
  Remove-PnPSiteScript -Identity $siteScript.Id
}

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365](#tab/cli-m365-ps)

```powershell

# Get Credentials to connect
$m365Status = m365 status
if ($m365Status -match "Logged Out") {
   m365 login
}

$keepThese = "Base Site Settings", "English Region", "Standard Site Columns", "Standard Libraries"

# Get all site scripts from the current tenant
$siteScripts = m365 spo sitescript list | ConvertFrom-Json

$siteScripts = $siteScripts | Where-Object { -not ($keepThese -contains $_.Title)}

if ($siteScripts.Count -eq 0) { break }

$siteScripts | Format-Table Title, SiteScriptIds, Description
Read-Host -Prompt "Press Enter to start deleting (CTRL + C to exit)"
$progress = 0
$total = $siteScripts.Count

foreach ($siteScript in $siteScripts)
{
  $progress++
  Write-Host $progress / $total":" $siteScript.Title
  m365 spo sitescript remove --id $siteScript.Id
}

```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

***

## Contributors

| Author(s) |
|-----------|
| Paul Bullock |
| [Ganesh Sanap](https://ganeshsanapblogs.wordpress.com/about) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-remove-site-scripts" aria-hidden="true" />
