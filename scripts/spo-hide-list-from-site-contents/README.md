---
plugin: add-to-gallery
---

# Hide SharePoint list from Site Contents

## Summary

If you need to hide the SharePoint list from the UI this simple PowerShell script will hide a specific list from the site contents. This will prevent users from easily accessing the list while, for example, you are still setting it up.
 
# [PnP PowerShell](#tab/pnpps)

```powershell

# SharePoint online site url
$siteUrl = "https://contoso.sharepoint.com/sites/SPConnect"

# Display name of SharePoint online list
$listName = "My List"

# Connect to SharePoint online site
Connect-PnPOnline -url $siteUrl -Interactive

# Hide SharePoint online list from Site Contents
Set-PnPList -Identity $listName -Hidden $true

# Disconnect SharePoint online connection
Disconnect-PnPOnline

```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365](#tab/cli-m365-ps)

```powershell

# SharePoint online site url
$siteUrl = "https://contoso.sharepoint.com/sites/SPConnect"

# Display name of SharePoint online list
$listName = "My List"

# Get Credentials to connect
$m365Status = m365 status
if ($m365Status -match "Logged Out") {
   m365 login
}

# Hide SharePoint online list from Site Contents
m365 spo list set --webUrl $siteUrl --title $listName --hidden true

# Disconnect SharePoint online connection
m365 logout

```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

***

## Contributors

| Author(s) |
|-----------|
| Leon Armston |
| [Ganesh Sanap](https://ganeshsanapblogs.wordpress.com/about) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-hide-list-from-site-contents" aria-hidden="true" />