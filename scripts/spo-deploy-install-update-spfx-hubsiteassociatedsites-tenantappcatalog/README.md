---
plugin: add-to-gallery
---

# Deploys and Installs SharePoint Framework (SPFx) solutions to Hub Site and Associated Sites using the tenant app catalog

## Summary

At the time of submitting this script sample there is no concept of a hub site app catalog. However you may want to install or upgrade a SPFx solution to all sites within a hub for example all sites linked to the intranet hub. This sample is applicable for a SPFx solution that needs to be deployed and upgraded across all sites in a hub using the tenant app catalog. There is a similar script [Deploys and Installs SharePoint Framework (SPFx) solutions to Hub Site and Associated Sites that deploys the app to individual site collection app catalog](../spo-deploy-install-update-spfx-hubsite-associatedsites/README.md)

![Example Screenshot](assets/example.png)

### Prerequisites

- The user account that runs the script must have Global tenant administrator access. If running the script as SharePoint administrator the cmdlet "Approve-PnPTenantServicePrincipalPermissionRequest" will fail.

- Before running the script, edit the script and update the variable values in the Config Variables section, such as Admin Center URL, Hub Site URL, the CSV output file path and alternatively the sppkg packages Folder.

This script snippet automates the deployment and potential upgrades of SPFx packages across associated sites of a hub site, leveraging the tenant-level app catalog. It navigates through each associated site, checks for existing packages, installs or upgrades them as needed, and records the deployment details for reporting purposes.

# [PnP PowerShell](#tab/pnpps)

```powershell
$AdminCenterURL="https://contoso-admin.sharepoint.com"
$tenantAppCatalogUrl = "https://contoso.sharepoint.com/sites/appcatalog"
$hubSiteUrl = "https://contoso.sharepoint.com"
$dateTime = (Get-Date).toString("dd-MM-yyyy")
$invocation = (Get-Variable MyInvocation).Value
$directorypath = Split-Path $invocation.MyCommand.Path
$fileName = "\Log_Tenant-" + $dateTime + ".csv"
$OutPutView = $directorypath + $fileName
 
$sppkgFolder = "./packages"
 $sppkgFolder = "./packages"

cd $PSScriptRoot
$packageFiles = Get-ChildItem $sppkgFolder

Connect-PnPOnline $tenantAppCatalogUrl -Interactive
$appCatConnection = Get-PnPConnection

Connect-PnPOnline $AdminCenterURL -Interactive
$adminConnection = Get-PnPConnection

$SiteAppUpdateCollection = @()

$associatedSites = Get-PnPHubSiteChild -Identity $hubSiteUrl -Connection $adminConnection

foreach ($package in $packageFiles) {
    $packageName = $package.PSChildName
    Write-Host ("Installing {0}..." -f $packageName) -ForegroundColor Yellow
    # deploy sppkg assuming app catalog is already configured
    Add-pnpapp -Path ("{0}/{1}" -f $sppkgFolder, $package.PSChildName) -Scope Tenant -Overwrite -Publish
}

$associatedSites += $hubSiteUrl # Add the hub site to the list of associated sites

# Get all site collections associated with the hub site
$associatedSites | ForEach-Object {
    $Site = Get-PnPTenantSite $_ -Connection $adminConnection
    Connect-PnPOnline -Url $Site.url -Interactive
    $siteConnection = Get-PnPConnection
    foreach ($package in $packageFiles) {
        $ExportVw = New-Object PSObject
        $ExportVw | Add-Member -MemberType NoteProperty -name "Site URL" -value $Site.url
        $packageName = $package.PSChildName

        Write-Host "Deploying packages $packageName to $($Site.url)" -ForegroundColor Yellow

        $ExportVw | Add-Member -MemberType NoteProperty -name "Package Name" -value $packageName
        # Find Name of app from installed package
        $RestMethodUrl = '/_api/web/lists/getbytitle(''Apps%20for%20SharePoint'')/items?$select=Title,LinkFilename'
        $apps = (Invoke-PnPSPRestMethod -Url $RestMethodUrl -Method Get -Connection $appCatConnection).Value
        $appTitle = ($apps | where-object { $_.LinkFilename -eq $packageName } | select Title).Title

        $currentPackage = Get-PnPApp -Identity $appTitle -scope Tenant

        # Install App to the Site if not already installed
        $web = Get-PnPWeb -Includes AppTiles -Connection $siteConnection
        $app = $web.AppTiles | where-object { $_.Title -eq $currentPackage.Title }
        if (!$app) {
            Install-PnPApp -Identity $currentPackage.Id -Connection $siteConnection

        } else {
            $currentPackage = Get-PnPApp -Identity $appTitle -Connection $siteConnection
            Write-Host "Current package version on site $($site.Url): $($currentPackage.InstalledVersion)"

            Write-Host "Latest package version: $($currentPackage.AppCatalogVersion)"

            # Update the package to the latest version
            if ($currentPackage.InstalledVersion -ne $currentPackage.AppCatalogVersion) {
                Write-Host "Upgrading package on site $($site.Url) to latest version..."
                Update-PnPApp -Identity $currentPackage.Id
                $currentPackage = Get-PnPApp -Identity $appTitle -Connection $siteConnection
                $ExportVw | Add-Member -MemberType NoteProperty -name "Package Version" -value $currentPackage.AppCatalogVersion
            } else {
                Write-Host "Package already up-to-date on site $($site.Url)."
            }
        }
    }
    $SiteAppUpdateCollection += $ExportVw
}

# Export the result Array to CSV file
$SiteAppUpdateCollection | Export-CSV $OutPutView -Force -NoTypeInformation

start-sleep -Seconds 30
foreach ($package in $packageFiles) {
    $packageName = $package.PSChildName
    Write-Host ("Approving {0}..." -f $packageName) -ForegroundColor Yellow
    $RestMethodUrl = '/_api/web/lists/getbytitle(''Apps%20for%20SharePoint'')/items?$select=Title,LinkFilename'
    $apps = (Invoke-PnPSPRestMethod -Url $RestMethodUrl -Method Get -Connection $appCatConnection).Value
    $appTitle = ($apps | where-object { $_.LinkFilename -eq $packageName } | select Title).Title

    # deploy sppkg assuming app catalog is already configured
    $permRequests = Get-PnPTenantServicePrincipalPermissionRequests | where-object { $_.PackageName -eq $appTitle }

    $permRequests | ForEach-Object {
        Write-Host "Approving permission request for $($_.Resource) at scope $($_.Scope) and package $appTitle..."
        Approve-PnPTenantServicePrincipalPermissionRequest -RequestId $_.Id.Guid -Force -ErrorAction Ignore
    }
}

```

> [!Note]
> SharePoint admin rights are required to run the script

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***

## Source Credit

Sample first appeared on [Deploying SPFx Packages from Tenant App Catalog to Hub Site and Associated Sites](https://reshmeeauckloo.com/posts/powershell_spfxdeploytohubfromtenant/)

## Contributors

| Author(s) |
|-----------|
| [Reshmee Auckloo](https://github.com/reshmee011) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-deploy-install-update-spfx-hubsiteassociatedsites-tenantAppCatalog" aria-hidden="true" />