---
plugin: add-to-gallery
---

# Add App Catalog to SharePoint site

## Summary

When you just want to deploy certain SharePoint solution to a specific site, it's required to create an app catalog for that site. The below script will create it for the site. In the article referenced above you can check where you can use App catalog for the site instead of global app catalog.

![Example Screenshot](assets/example.png)

# [PnP PowerShell](#tab/pnpps)

```powershell

$site = "https://contoso.sharepoint.com/sites/site"
Connect-PnPOnline $site
Add-PnPSiteCollectionAppCatalog -Site $site
Write-output "App Catalog Created on " $site

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [SPO Management Shell](#tab/spoms-ps)

```powershell

$AdminSiteURL = "https://domain-admin.sharepoint.com"
$Username = "chandani@domain.onmicrosoft.com"
$Password = "******"
$SecureStringPwd = $Password | ConvertTo-SecureString -AsPlainText -Force 
$Cred = New-Object System.Management.Automation.PSCredential -ArgumentList $Username, $SecureStringPwd

Function Login() {
    [cmdletbinding()]
    param([parameter(Mandatory = $true, ValueFromPipeline = $true)] $creds)
    Write-Host "Connecting to Tenant Admin Site '$($AdminSiteURL)'" -f Yellow   
    Connect-SPOService -url $AdminCenterURL -Credential $Cred
    Write-Host "Connection Successfull" -f Green 
}

Function AddAppCatalogToSiteCollection {
    $SiteURL = Read-Host "Enter Site URL"
    $Site = Get-SPOSite $SiteURL 
    Write-Host "Adding SharePoint site collection app catalog..." -f Yellow
    Add-SPOSiteCollectionAppCatalog -Site $Site
    Write-Host "Added SharePoint site collection app catalog successfully..." -f Green
}

Function StartProcessing {
    Login($Cred);
    AddAppCatalogToSiteCollection
}

StartProcessing

```
[!INCLUDE [More about SPO Management Shell](../../docfx/includes/MORE-SPOMS.md)]
***

## Contributors

| Author(s) |
|-----------|
| Paul Bullock |
| Chandani Prajapati |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]

<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/add-app-catalogue-to-sp-site" aria-hidden="true" />
