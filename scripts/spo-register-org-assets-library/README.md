

# Register SharePoint Organization Assets Library

## Summary

This sample script shows how to register a SharePoint document library as an organization assets library.

# [SPO Management Shell](#tab/spoms-ps)

```powershell
# URL of SharePoint document library
$libraryUrl = "https://contoso.sharepoint.com/sites/OrgAssets/Images"

# Type of Organization asset library - ImageDocumentLibrary or OfficeTemplateLibrary
$orgAssetType = "ImageDocumentLibrary"

# SharePoint online admin center URL
$adminCenterUrl = Read-Host -Prompt "Enter your SharePoint admin center site URL (e.g https://contoso-admin.sharepoint.com/)"

# Connect to SharePoint online admin center
Connect-SPOService -Url $adminCenterUrl

# Register document library as an organization asset library
Add-SPOOrgAssetsLibrary -LibraryURL $libraryUrl -OrgAssetType $orgAssetType

# Disconnect SharePoint online connection
Disconnect-SPOService
```

[!INCLUDE [More about SPO Management Shell](../../docfx/includes/MORE-SPOMS.md)]

# [PnP PowerShell](#tab/pnpps)

```powershell
# URL of SharePoint online document library
$libraryUrl = "https://contoso.sharepoint.com/sites/OrgAssets/CompanyLogos"

# Type of Organization assets library - ImageDocumentLibrary or OfficeTemplateLibrary
$orgAssetType = "ImageDocumentLibrary"

# SharePoint online admin center URL
$adminCenterUrl = Read-Host -Prompt "Enter your SharePoint admin center site URL (e.g https://contoso-admin.sharepoint.com/)"

# Connect to SharePoint online admin center
Connect-PnPOnline -Url $adminCenterUrl -Interactive

# Register a document library as an organization assets library
Add-PnPOrgAssetsLibrary -LibraryUrl $libraryUrl -OrgAssetType $orgAssetType

# Disconnect SharePoint online connection
Disconnect-PnPOnline
```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365](#tab/cli-m365-ps)

```powershell
# URL of SharePoint online document library
$libraryUrl = "https://contoso.sharepoint.com/sites/OrgAssets/CompanyLogos"

# Type of Organization asset library - ImageDocumentLibrary or OfficeTemplateLibrary
$orgAssetType = "ImageDocumentLibrary"

# Get Credentials to connect
$m365Status = m365 status
if ($m365Status -match "Logged Out") {
    m365 login
}

# Register a SharePoint document library as an organization asset library
m365 spo orgassetslibrary add --libraryUrl $libraryUrl --orgAssetType $orgAssetType

# Disconnect SharePoint online connection
m365 logout
```

[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

***

## Source Credit

Samples first appeared on:

- [Create an Organization Assets Library in SharePoint Online](https://ganeshsanapblogs.wordpress.com/2024/01/30/create-an-organization-assets-library-in-sharepoint-online/)
- [Register SharePoint Document Library as an Organization Assets Library using PowerShell](https://ganeshsanapblogs.wordpress.com/2024/02/03/register-sharepoint-document-library-as-an-organization-assets-library-using-powershell/)

## Contributors

| Author(s) |
|-----------|
| [Ganesh Sanap](https://ganeshsanapblogs.wordpress.com/) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-register-org-assets-library" aria-hidden="true" />
