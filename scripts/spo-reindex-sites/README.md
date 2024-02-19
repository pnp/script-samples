---
plugin: add-to-gallery
---

# Reindex SharePoint sites

## Summary

 
 
# [PnP PowerShell](#tab/pnpps)

```powershell

# SharePoint online admin center URL
$SPOAdmminSite = "https://contoso-admin.sharepoint.com"

$themesToKeep = "Contoso Explorers", "Multicolored theme"

# Connect to SharePoint online admin center
Connect-PnPOnline -Url $SPOAdmminSite -Interactive

# Get all themes from the current tenant
$themes = Get-PnPTenantTheme

$themes = $themes | where {-not ($themesToKeep -contains $_.name)}
$themes | Format-Table name

if ($themes.Count -eq 0) { break }

Read-Host -Prompt "Press Enter to start deleting $($themes.Count) themes (CTRL + C to exit)"
$progress = 0
$total = $themes.Count

foreach ($theme in $themes)
{
  $progress++
  write-host $progress / $total":" $theme.name
  
  # Delete custom color themes from SharePoint
  Remove-PnPTenantTheme -Identity "$($theme.name)"
}

# Disconnect SharePoint online connection
Disconnect-PnPOnline

```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [SPO Management Shell](#tab/spoms-ps)

```powershell

# SharePoint online admin center URL
$SPOAdmminSite = "https://contoso-admin.sharepoint.com"

$themesToKeep = "Contoso Explorers", "Multicolored theme"

# Connect to SharePoint online admin center
Connect-SPOService -Url $SPOAdmminSite

# Get all themes from the current tenant
$themes = Get-SPOTheme

$themes = $themes | where {-not ($themesToKeep -contains $_.name)}
$themes | Format-Table name

if ($themes.Count -eq 0) { break }

Read-Host -Prompt "Press Enter to start deleting $($themes.Count) themes (CTRL + C to exit)"
$progress = 0
$total = $themes.Count

foreach ($theme in $themes)
{
  $progress++
  write-host $progress / $total":" $theme.name
  
  # Delete custom color themes from SharePoint
  Remove-SPOTheme -Identity "$($theme.name)"
}

# Disconnect SharePoint online connection
Disconnect-SPOService

```

[!INCLUDE [More about SPO Management Shell](../../docfx/includes/MORE-SPOMS.md)]

# [CLI for Microsoft 365](#tab/cli-m365-ps)

```powershell

# Get Credentials to connect
$m365Status = m365 status
if ($m365Status -match "Logged Out") {
   m365 login
}

$themesToKeep = "Contoso Explorers", "Multicolored theme"

# Get all themes from the current tenant
$themes = m365 spo theme list | ConvertFrom-Json

$themes = $themes | where {-not ($themesToKeep -contains $_.name)}
$themes | Format-Table name

if ($themes.Count -eq 0) { break }

Read-Host -Prompt "Press Enter to start deleting $($themes.Count) themes (CTRL + C to exit)"
$progress = 0
$total = $themes.Count

foreach ($theme in $themes)
{
  $progress++
  write-host $progress / $total":" $theme.name
  
  # Delete custom color themes from SharePoint
  m365 spo theme remove --name "$($theme.name)" --confirm
}

# Disconnect SharePoint online connection
m365 logout

```

[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

***

## Contributors

| Author(s) |
|-----------|
| [Leon Armston](https://github.com/LeonArmston)|
| [Ganesh Sanap](https://ganeshsanapblogs.wordpress.com/about) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-remove-custom-themes" aria-hidden="true" />
