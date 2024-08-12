---
plugin: add-to-gallery-preparation
---

# GET API Permissions for SPFx solutions

## Summary

To enhance your tenant's security posture, it's crucial to regularly review the API permissions requested by SPFx solutions and compare them with those granted to the "SharePoint Online Client Extensibility Web Application Principal".

This script analyzes tenant-level and site-level app catalogs and extracts **API Permissions requested by SPFx solutions**. It generates two reports:

-   summary of all API permissions requested

    ![All API permissions summary](./assets/ApiPermissionsSummary.png)

-   summary of all SPFx extensions installed in SPO sites, including site url, solution name and all API permissions declared in the manifest.

    ![API permissions per solution](./assets/APIPermissions.png)

> **Important**: The site-level app catalog, from a security perspective, functions like a regular list within a SharePoint Online site. This means that Global or SharePoint administrators do NOT have automatic access. Running the script as an administrator without first granting at least read access to the site would result in INCOMPLETE data.
>
> If the current user does not have access rights to a site hosting site-level app catalog, this script grants them Admin rights for the duration of script execution. The permissions are removed as soon as API Permissions are exported
>
> Site-level app catalog must be enabled by a SharePoint administrator, which gives you a chance to discuss security and governance with the site owner, and ensure you are authorized to perform regular audits of the spfx solutions.

Remember that SPFx solutions may use any API permissions granted to the "SharePoint Online Client Extensibility Web Application Principal" without explicitly requesting them. Read more: [SharePoint solutions as a spyware](https://pnp.github.io/blog/post/spfx-solutions-as-spyware/).

## Prerequisites

-   The user running the script must have SharePoint administrator access

# [PnP PowerShell](#tab/pnpps)

```powershell
param (
    [Parameter(Mandatory = $true)]
    [string] $domainName
)
Import-Module ImportExcel
Import-Module PnP.PowerShell

# Extract API Permissions requested by SPFx solutions
# Analyzes tenant-level and site-level app catalogs
# Important: site-level app catalog is, in terms of security, a regular SharePoint list within a SPO site. This means that Global/SharePoint
# administrators do NOT have read access.
# To avoid generating partial results, this script temporarily grants current user Site Admin rights (line 72) and removes them after api permissions are exported (line 93)

function Get-APIPermissions {
    param (
        [string]$siteUrl
    )

    try {
        $list = Get-PnPList -Identity "/AppCatalog"
        $files = Get-PnPListItem -List $list

        foreach ($file in $files) {
            [PSCustomObject]@{
                siteURL        = $siteUrl
                fileName       = $file["FileLeafRef"]
                version        = "v$($file["AppVersion"])"
                apiPermissions = $file["WebApiPermissionScopesNote"]
                title          = $file["Title"]
                Error          = ""
            }
        }
    }
    catch {
        [PSCustomObject]@{
            siteURL        = $siteUrl
            fileName       = ""
            version        = ""
            apiPermissions = ""
            title          = ""
            Error          = $_.Exception.Message
        }
    }
}

$adminUrl = "https://$domainName-admin.sharepoint.com/"
$fileName = ".\$($domainName)_APIPermissions.xlsx"
$currentUserEmail = (Get-PnPProperty -ClientObject (Get-PnPWeb) -Property CurrentUser).Email
$excel = @()

Clear-Host

# Connect
Write-Host "Connect to SharePoint Admin site"
Connect-PnPOnline -Url $adminUrl -Interactive

Try {
    $siteCollectionAppCatalogs = Get-PnPSiteCollectionAppCatalog -ExcludeDeletedSites

    # Get sites where current user has no access
    $sitesAccessDenied = ($siteCollectionAppCatalogs
        | Where-Object { $_.ErrorMessage -eq "Access denied." }
        | Select-Object -Property AbsoluteUrl
    ).AbsoluteUrl

    # Access denied: add current user as a site administrator
    Write-Host "You don't have access to the following sites:"
    Write-Host $sitesAccessDenied
    $sitesAccessDenied | ForEach-Object {
        Write-Host "Granting access to $_"
        Set-PnPTenantSite -Identity $_ -Owners $currentUserEmail
    }

    # Get all app catalog urls (tenant level and site level)
    $appCatalogs = ($siteCollectionAppCatalogs
        | Select-Object -Property AbsoluteUrl
    ).AbsoluteUrl
    $appCatalogs += Get-PnPTenantAppCatalogUrl

    Write-Host " $($appCatalogs.Count) app catalogs found. Evaluating permissions"

    # App Catalogs: parse solutions, get api permissions
    $appCatalogs | ForEach-Object {

        Write-Host "Connecting to $_"
        Connect-PnPOnline -Url $_ -Interactive

        $arr = Get-APIPermissions $_
        $excel += $arr

        if ($_ -in $accessDenied) {
            Remove-PnPSiteCollectionAdmin -Owners $currentUserEmail
        }
    }
    $excel | Export-Excel $fileName -WorksheetName "SPFx Solutions" -TableName "SPFx_Solutions" -TableStyle Light1

    # API Permissions: get unique permissions
    if ($excel.Count -gt 0) {
        $apiPermissions = $excel.apiPermissions | ForEach-Object { $_ -split ";" } | Where-Object { $_ -ne "" } | ForEach-Object { $_.Trim() } | Select-Object -Unique
        $uniqueAPIPermissions = $apiPermissions | ForEach-Object {
            $p = $_ -split ",";
            [PSCustomObject]@{
                API        = $p[0]
                Permission = $p[1]
            }
        } | Sort-Object API

        $uniqueAPIPermissions | Export-Excel $fileName -WorksheetName "API Permissions" -TableName "API_Permissions" -TableStyle Light1
    }

}
Catch {
    Write-host -f Red "Error downloading API Permissions information:" $_.Exception.Message
}

Write-Host ("API Permissions exported") -ForegroundColor Green
Disconnect-PnPOnline
```

## Contributors

| Author(s)    |
| ------------ |
| Kinga Kazala |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/template-script-submission" aria-hidden="true" />
