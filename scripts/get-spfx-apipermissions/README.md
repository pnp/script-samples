---
plugin: add-to-gallery-preparation
---

# GET API Permissions for SPFx solutions

> This script is part of [SharePoint solutions as a spyware](https://pnp.github.io/blog/post/spfx-solutions-as-spyware/) series, focusing on improving security posture of your tenant.

## Summary

To enhance your tenant's security posture, it's crucial to regularly review the API permissions requested by SPFx solutions and compare them with those granted to the "SharePoint Online Client Extensibility Web Application Principal".

This script analyzes tenant-level and site-level app catalogs and extracts **API Permissions requested by SPFx solutions**. It generates two reports:

-   summary of all **SPFx extensions installed** in SPO sites, including site url, solution name and all **API permissions declared in the manifest**.

    ![API permissions per solution](./assets/APIPermissions.png)

-   summary of API permissions assigned to the "SharePoint Online Client Extensibility Web Application Principal", including **SPFx solutions** that requested them.

    ![Is API permission used](./assets/APIpermissionsUsed.png)

The script also displays a warning if any API permissions are assigned using Application mode. This is unsupported.

> **Important**: The site-level app catalog, from a security perspective, functions like a regular list within a SharePoint Online site. This means that Global or SharePoint administrators do NOT have automatic access. Running the script as an administrator without first granting at least read access to the site would result in INCOMPLETE data.
>
> If the current user does not have access rights to a site hosting site-level app catalog, this script grants them Admin rights for the duration of script execution. The permissions are removed as soon as API Permissions are exported
>
> Site-level app catalog must be enabled by a SharePoint administrator, which gives you a chance to discuss security and governance with the site owner, and ensure you are authorized to perform regular audits of the spfx solutions.

It's important to remember that SPFx solutions may use any API permissions granted to the "SharePoint Online Client Extensibility Web Application Principal" without explicitly requesting them. Read more: [SharePoint solutions as a spyware](https://pnp.github.io/blog/post/spfx-solutions-as-spyware/).

## Prerequisites

-   The user running the script must have SharePoint Administrator role in order to access tenant-level app catalog, and to grant themselves (temporary) Owner rights to sites with site-level app catalog
-   The user also requires `Application.Read.All` to read permissions assigned to the SharePoint Online Client Extensibility Web Application Principal.
-   [Pnp.PowerShell](https://pnp.github.io/powershell/) version 2.5 and PowerShell 7.2 or later

# [PnP PowerShell](#tab/pnpps)

```powershell
param (
    [Parameter(Mandatory = $true)]
    [string] $domainName
)

Import-Module ImportExcel
Import-Module Microsoft.Graph.Authentication
Import-Module Microsoft.Graph.Applications

# Extract API Permissions requested by SPFx solutions
# Analyzes tenant-level and site-level app catalogs
# Important: site-level app catalog is, in terms of security, a regular SharePoint list within a SPO site. This means that Global/SharePoint
# administrators do NOT have read access.
# To avoid generating partial results, this script temporarily grants current user Site Admin rights (line 112) and removes them after api permissions are exported (line 132)

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
$xlsxFileName = ".\$($domainName)_APIPermissions.xlsx"

Clear-Host

Try {

    #####################################
    # Get API Permissions for SharePoint Online Client Extensibility Web Application Principal
    # This is executed first, because of the conflicts in PS modules: https://github.com/microsoftgraph/msgraph-sdk-powershell/issues/2285
    #####################################

    # Get API Permissions for SharePoint Online Client Extensibility Web Application Principal
    $spoAppName = "SharePoint Online Client Extensibility Web Application Principal"
    Connect-MgGraph -Scopes 'Application.Read.All' -NoWelcome
    $servicePrincipal = Get-MgServicePrincipal -Filter  "DisplayName eq '$spoAppName'"

    #Delegated permission grants authorizing this service principal to access an API on behalf of a signed-in user.
    $permissions = Get-MgServicePrincipalOauth2PermissionGrant -ServicePrincipalId $servicePrincipal.Id

    $permissionsDelegated = $permissions | ForEach-Object {
        # retrieve delegated permissions of the resource service principal
        $resource = Get-MgServicePrincipal -ServicePrincipalId $_.ResourceId

        [PSCustomObject]@{
            Scope       = $_.Scope
            ResourceId  = $_.ResourceId
            DisplayName = $resource.DisplayName
            AllUsers    = $_.ConsentType -eq "AllPrincipals"
        }
    }

    #this is NOT supported for the "SharePoint Online Client Extensibility Web Application Principal". Result should always be empty
    $permissionsApplication = get-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $servicePrincipal.Id
    If ($null -ne $permissionsApplication) {
        Write-Host ("Assigning Application permissions to the 'SharePoint Online Client Extensibility Web Application Principal' is NOT SUPPORTED") -ForegroundColor Red
    }


    #####################################
    # Parse SPFx solutions' manifests to read requested API permissions
    # Import-Module PnP.PowerShell called only now because of the conflicts in PS modules: https://github.com/microsoftgraph/msgraph-sdk-powershell/issues/2285
    #####################################
    Import-Module PnP.PowerShell

    # Connect
    Write-Host "Connect to SharePoint Admin site"
    Connect-PnPOnline -Url $adminUrl -Interactive
    $currentUserEmail = (Get-PnPProperty -ClientObject (Get-PnPWeb) -Property CurrentUser).Email

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
    $spfxPermissions = $appCatalogs | ForEach-Object {

        Write-Host "Connecting to $_"
        Connect-PnPOnline -Url $_ -Interactive

        Get-APIPermissions $_

        if ($_ -in $accessDenied) {
            Remove-PnPSiteCollectionAdmin -Owners $currentUserEmail
        }
    }

    #####################################
    # Generate results
    # $permissionsDelegated: API permissions (delegated) granted to the "SharePoint Online Client Extensibility Web Application Principal"
    # $permissionsApplication: API Permissions (application) granted to the "SharePoint Online Client Extensibility Web Application Principal". This should be always empty.
    # $spfxPermissions: API permissions requested by SPFx solutions. Only delegated permissions possible
    #####################################

    # 1. Export summary of all SPFx solutions and API permissions requested
    $spfxPermissions | Export-Excel $xlsxFileName -WorksheetName "SPFx Solutions" -TableName "SPFx_Solutions" -TableStyle Light1
    Write-Host "Exported SPFx summary"

    # 2. Export summary of all delegated permissions assigned to the SPO CEWAP and solutions they are required in
    #transform spfxPermissions to API,Permission, spfxFileName, spfxSolutionName
    $apiInSPFx = @()
    $spfxPermissions | Where-Object { $_.apiPermissions -ne "" } |  ForEach-Object {
        $fileName = $_.fileName
        $title = $_.title
        $_.apiPermissions -split ";" | Where-Object { $_ } | ForEach-Object {
            $p = $_ -split ",";
            $API = $p[0].Trim()
            $Permission = $p[1].Trim()

            $item = $apiInSPFx | Where-Object { $_.API -eq $API -and $_.Permission -eq $Permission }
            if ($null -eq $item) {
                $apiInSPFx += [PSCustomObject]@{
                    API        = $p[0].Trim()
                    Permission = $p[1].Trim()
                    fileName   = @($fileName)
                    title      = @($title)
                }
            }
            else {
                If ($item.fileName -notcontains $fileName) {
                    $item.fileName += $fileName
                    $item.title += $title
                }

            }
        }
    }
    $permissionsDelegatedExtended = $permissionsDelegated | ForEach-Object {
        $permission = $_
        $_.Scope -split " " | ForEach-Object {
            $scope = $_.Trim()
            $usedIn = $apiInSPFx | Where-Object { $_.API -eq $permission.DisplayName -and $_.Permission -eq $scope }
            $r = Get-MgServicePrincipal -ServicePrincipalId $permission.ResourceId -Property Oauth2PermissionScopes
            | Select-Object  -ExpandProperty Oauth2PermissionScopes
            | Where-Object { $_.Value -eq $scope }

            [PSCustomObject]@{
                API              = $permission.DisplayName
                Permission       = $scope
                UsedIn_FileName  = $usedIn.fileName -join ","
                UsedIn_Solution  = $usedIn.title -join ","
                ResourceId       = $permission.ResourceId
                ShortDescription = $r.AdminConsentDisplayName
                Description      = $r.AdminConsentDescription
            }
        }
    }
    $permissionsDelegatedExtended | Export-Excel $xlsxFileName -WorksheetName "API Permissions" -TableName "API_Permissions" -TableStyle Light1

    Write-Host "Exported API Permissions"

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
