<#
    .DESCRIPTION
    This script extracts API Permissions requested by SPFx solutions, and the API permissions assigned 
    to the SharePoint Online Client Extensibility Web Application Principal.
    It then analyzes tenant-level and site-level app catalogs and parses SPFx solutions' manifests to 
    read requested API permissions.
    Finally it generates report containing:
    - a summary of all SPFx solutions and API permissions requested
    - a list of all delegated permissions assigned to the SPO CEWAP and solutions they are required in
#>
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
