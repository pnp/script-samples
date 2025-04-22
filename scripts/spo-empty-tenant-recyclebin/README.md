

# Empty the tenant recycle bin

## Summary

Your deleted modern SharePoint sites are not going to disappear from the UI before they have been removed from the tenant recycle bin. You can either wait for three months, delete them manually via the SharePoint admin center, or run the script below.
 
[!INCLUDE [Delete Warning](../../docfx/includes/DELETE-WARN.md)]

# [PnP PowerShell](#tab/pnpps)

```powershell

# SharePoint online admin center site url
$adminSiteUrl = "https://contoso-admin.sharepoint.com"

# Connect to SharePoint online admin center
Connect-PnPOnline -Url $adminSiteUrl -Interactive

# Get all deleted sites from tenant recycle bin
$deletedSites = Get-PnPTenantRecycleBinItem
$deletedSites | Format-Table Url

if ($deletedSites.Count -eq 0) 
{ 
  break 
}

Read-Host -Prompt "Press Enter to start deleting (CTRL + C to exit)"

$progress = 0
$total = $deletedSites.Count

foreach ($deletedSite in $deletedSites)
{
  $progress++
  Write-Host $progress / $total":" $deletedSite.Url

  # Permanently delete site collection from the tenant recycle bin
  Clear-PnPTenantRecycleBinItem -Url $deletedSite.Url -Wait -Force
}

# Disconnect SharePoint online connection
Disconnect-PnPOnline

```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365](#tab/cli-m365-ps)

```powershell

# Get Credentials to connect
$m365Status = m365 status
if ($m365Status -match "Logged Out") {
   m365 login
}

# Get all deleted sites from tenant recycle bin
$deletedSites = m365 spo tenant recyclebinitem list | ConvertFrom-Json
$deletedSites | Format-Table Url

if ($deletedSites.Count -eq 0) 
{ 
  break 
}

Read-Host -Prompt "Press Enter to start deleting (CTRL + C to exit)"

$progress = 0
$total = $deletedSites.Count

foreach ($deletedSite in $deletedSites)
{
  $progress++
  Write-Host $progress / $total":" $deletedSite.Url

  # Permanently delete site collection from the tenant recycle bin
  m365 spo tenant recyclebinitem remove --siteUrl $deletedSite.Url --wait --confirm
}

# Disconnect SharePoint online connection
m365 logout

```

[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

# [SPO Management Shell](#tab/spoms-ps)

```powershell

# SharePoint online admin center site url
$adminSiteUrl = "https://contoso-admin.sharepoint.com"

# Connect to SharePoint online admin center
Connect-SPOService -Url $adminSiteUrl

# Get all deleted sites from tenant recycle bin
$deletedSites = Get-SPODeletedSite
$deletedSites | Format-Table Url

if ($deletedSites.Count -eq 0) 
{ 
  break 
}

Read-Host -Prompt "Press Enter to start deleting (CTRL + C to exit)"

$progress = 0
$total = $deletedSites.Count

foreach ($deletedSite in $deletedSites)
{
  $progress++
  Write-Host $progress / $total":" $deletedSite.Url

  # Permanently delete site collection from the tenant recycle bin
  Remove-SPODeletedSite -Identity $deletedSite.Url -Confirm
}

# Disconnect SharePoint online connection
Disconnect-SPOService

```

[!INCLUDE [More about SPO Management Shell](../../docfx/includes/MORE-SPOMS.md)]

***

## Source Credit

Sample first appeared on [Empty the tenant recycle bin | CLI for Microsoft 365](https://pnp.github.io/cli-microsoft365/sample-scripts/spo/empty-tenant-recyclebin/)

## Contributors

| Author(s) |
|-----------|
| [Leon Armston](https://github.com/LeonArmston)|
| [Ganesh Sanap](https://ganeshsanapblogs.wordpress.com/about) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-empty-tenant-recyclebin" aria-hidden="true" />
