---
plugin: add-to-gallery
---

# Remove delete option on a document library

## Summary

This sample script will show you how to remove the delete option on a document library to prevent users from accidentally deleting libraries if they have the "edit" permission.
The script will not prevent deletions rather, just disable the UI option.

![Example Screenshot](assets/example.png)

# [PnP PowerShell](#tab/pnpps)

```powershell

# Display name of SharePoint online list or document library
$libraryName = "My Document Library"

# SharePoint online site URL
$siteUrl = Read-Host -Prompt "Enter your SharePoint site URL (e.g https://contoso.sharepoint.com/sites/work)"

# Connect to SharePoint online site
Connect-PnPOnline -Url $siteUrl -Interactive

# Remove delete option on a document library
Set-PnPList -Identity $libraryName -AllowDeletion $false

Write-Host "Done! :-)" -ForegroundColor Green

# Disconnect SharePoint online connection
Disconnect-PnPOnline

```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365](#tab/cli-m365-ps)

```powershell

# Display name of SharePoint online list or document library
$libraryName = "My Document Library"

# SharePoint online site URL
$siteUrl = Read-Host -Prompt "Enter your SharePoint site URL (e.g https://contoso.sharepoint.com/sites/work)"

# Get Credentials to connect
$m365Status = m365 status
if ($m365Status -match "Logged Out") {
    m365 login
}

# Remove delete option on a document library
m365 spo list set --webUrl $siteUrl --title $libraryName --allowDeletion false

Write-Host "Done! :-)" -ForegroundColor Green

# Disconnect SharePoint online connection
m365 logout

```

[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

***

## Source Credit

Sample first appeared on [Prevent document library deletion | CaPa Creative Ltd](https://capacreative.co.uk/2018/09/17/prevent-document-library-deletion/)

## Contributors

| Author(s) |
|-----------|
| Paul Bullock |
| [Adam Wójcik](https://github.com/Adam-it)|
| [Ganesh Sanap](https://ganeshsanapblogs.wordpress.com/about) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/remove-delete-option-library" aria-hidden="true" />
