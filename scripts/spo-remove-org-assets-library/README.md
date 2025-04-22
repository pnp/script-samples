

# Remove SharePoint Organization Assets Library

## Summary

This sample script shows how to remove a SharePoint document library from organization assets libraries.

# [SPO Management Shell](#tab/spoms-ps)

```powershell
# URL of SharePoint document library
$libraryUrl = "https://contoso.sharepoint.com/sites/OrgAssets/Images"

# SharePoint online admin center URL
$adminCenterUrl = Read-Host -Prompt "Enter your SharePoint admin center site URL (e.g https://contoso-admin.sharepoint.com/)"

# Connect to SharePoint online admin center
Connect-SPOService -Url $adminCenterUrl

# Remove/unregister an organization asset library in SharePoint tenant
Remove-SPOOrgAssetsLibrary -LibraryUrl $libraryUrl

# Disconnect SharePoint online connection
Disconnect-SPOService
```

[!INCLUDE [More about SPO Management Shell](../../docfx/includes/MORE-SPOMS.md)]

# [PnP PowerShell](#tab/pnpps)

```powershell
# URL of SharePoint online document library
$libraryUrl = "https://contoso.sharepoint.com/sites/OrgAssets/CompanyLogos"

# SharePoint online admin center URL
$adminCenterUrl = Read-Host -Prompt "Enter your SharePoint admin center site URL (e.g https://contoso-admin.sharepoint.com/)"

# Connect to SharePoint online admin center
Connect-PnPOnline -Url $adminCenterUrl -Interactive

# Remove organization assets library from SharePoint Online
Remove-PnPOrgAssetsLibrary -LibraryUrl $libraryUrl

# Disconnect SharePoint online connection
Disconnect-PnPOnline
```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365](#tab/cli-m365-ps)

```powershell
# URL of SharePoint online document library
$libraryUrl = "https://contoso.sharepoint.com/sites/OrgAssets/CompanyLogos"

# Get Credentials to connect
$m365Status = m365 status
if ($m365Status -match "Logged Out") {
    m365 login
}

# Unregister a SharePoint document library from organization assets libraries
m365 spo orgassetslibrary remove --libraryUrl $libraryUrl --force

# Disconnect SharePoint online connection
m365 logout
```

[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

***

## Source Credit

Samples first appeared on:

- [Create an Organization Assets Library in SharePoint Online](https://ganeshsanapblogs.wordpress.com/2024/01/30/create-an-organization-assets-library-in-sharepoint-online/)
- [Remove an Organization Assets Library from SharePoint Online using PowerShell](https://ganeshsanapblogs.wordpress.com/2024/02/03/remove-an-organization-assets-library-from-sharepoint-online-using-powershell/)

## Contributors

| Author(s) |
|-----------|
| [Ganesh Sanap](https://ganeshsanapblogs.wordpress.com/) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-remove-org-assets-library" aria-hidden="true" />
