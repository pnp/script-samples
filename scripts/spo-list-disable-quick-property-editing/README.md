---
plugin: add-to-gallery
---

# Disable Quick property editing (Grid view) from SharePoint list

## Summary

This sample script will show you how to disable the Quick property editing (Grid view) from SharePoint list.

![Example Screenshot](assets/example.png)

# [PnP PowerShell](#tab/pnpps)

```powershell

# Display name of SharePoint online list or document library
$listName = "My SharePoint List"

# SharePoint online site URL
$siteUrl = Read-Host -Prompt "Enter your SharePoint site URL (e.g https://contoso.sharepoint.com/sites/pnppowershell)"

# Connect to SharePoint online site
Connect-PnPOnline -Url $siteUrl -Interactive

# Disable Quick property editing (Grid view) from SharePoint list
Set-PnPList -Identity $listName -DisableGridEditing $true

Write-Host "Done! :-)" -ForegroundColor Green

# Disconnect SharePoint online connection
Disconnect-PnPOnline

```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365](#tab/cli-m365-ps)

```powershell

# Display name of SharePoint online list or document library
$listName = "My SharePoint List"

# SharePoint online site URL
$siteUrl = Read-Host -Prompt "Enter your SharePoint site URL (e.g https://contoso.sharepoint.com/sites/cliformicrosoft365)"

# Get Credentials to connect
$m365Status = m365 status
if ($m365Status -match "Logged Out") {
    m365 login
}

# Disable Quick property editing (Grid view) from SharePoint list
m365 spo list set --webUrl $siteUrl --title $listName --disableGridEditing true

Write-Host "Done! :-)" -ForegroundColor Green

# Disconnect SharePoint online connection
m365 logout

```

[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

***

## Contributors

| Author(s) |
|-----------|
| [Ganesh Sanap](https://ganeshsanapblogs.wordpress.com/about) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-list-disable-quick-property-editing" aria-hidden="true" />
