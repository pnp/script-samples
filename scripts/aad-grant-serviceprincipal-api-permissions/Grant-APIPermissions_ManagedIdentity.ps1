<#
    .DESCRIPTION
    The Set-ManagedIdentityAPIPermissions function grants the following roles to the Managed Identity used for automation:
    - 'Application.Read.All',
    - 'Sites.Selected' 
    Once the 'Lists.SelectedOperations.Selected' is available productively, the 'Sites.Selected'  scope can be replaced

    The Set-SPOSiteAppCatalogPermissions function grants System-Assigned Managed Identity read access to 
    - root level SharePoint Site
    - tenant-level app catalog
    - sites with site-level app catalog

    .PARAMETER spId
    Object Id of system-managed identity.
    Navigate to the Azure Runbook, open Accoutn Setting group, select Identity and copy the Object (principal) ID value

    .PARAMETER domainName


    .NOTES
    The function 'Set-APIPermissions' is based on https://github.com/gerickes/tutorial-managed-identity
    and updated to use Microsoft Graph Powershell (https://learn.microsoft.com/en-us/powershell/microsoftgraph/azuread-msoline-cmdlet-map?view=graph-powershell-1.0)    

    Overview of Selected permissions in OneDrive and SharePoint: https://learn.microsoft.com/en-us/graph/permissions-selected-overview?tabs=powershell
    Assigning application permissions to lists, list items, folders, or files breaks inheritance on the assigned resource, 
    so be mindful of service limits for unique permissions in your solution design. Permissions at the site collection level do not break inheritance 
    because this is the root of permission inheritance.

    Microsoft Graph Permissions Explorer: https://graphpermissions.merill.net/permission/

    Lists and categorizes privilege for delegated permissions (OAuth2PermissionGrants) and application permissions (AppRoleAssignments).
    Export-MsIdAppConsentGrantReport https://azuread.github.io/MSIdentityTools/commands/Export-MsIdAppConsentGrantReport

#>
param(
    [string]$spId,
    [string]$tenantName
)
Import-Module Microsoft.Graph.Authentication
Import-Module Microsoft.Graph.Applications
    
<#
    .DESCRIPTION
    The Set-ManagedIdentityAPIPermissions function grants the following roles to the Managed Identity used for automation:
    -  Microsoft Graph
    - 'Application.Read.All',
    - 'Sites.Selected'                     # once 'Lists.SelectedOperations.Selected' is released, scope can be changed

    .NOTES
    IMPORTANT: The DelegatedPermissionGrant.ReadWrite.All permission allows an app or a service to manage permission grants 
    and elevate privileges for any app, user, or group in your organization. Only appropriate users should access apps that 
    have been granted this permission.

    TODO: Once the 'Lists.SelectedOperations.Selected' is available productively (now in beta),
    the 'Sites.Selected' can be replaced with 'Lists.SelectedOperations.Selected'
#>
function Set-ManagedIdentityAPIPermissions {
    param(
        [string]$spId
    )
    $permissionMap = @{
        '00000003-0000-0000-c000-000000000000' = @( # Microsoft Graph
            'Application.Read.All',
            "DelegatedPermissionGrant.ReadWrite.All"
            'Sites.Selected'                     # once 'Lists.SelectedOperations.Selected' is released, scope can be changed
        )
    }

    Connect-MgGraph  -Scopes "AppRoleAssignment.ReadWrite.All" , 'Application.Read.All'

    Get-MgServicePrincipal -All  | Where-Object { $_.AppId -in $permissionMap.Keys } -PipelineVariable SP | ForEach-Object {
        $SP.AppRoles | Where-Object { $_.Value -in $permissionMap[$SP.AppId] -and $_.AllowedMemberTypes -contains "Application" } -PipelineVariable AppRole | ForEach-Object {
            try {
                $params = @{
                    principalId = $spId
                    resourceId  = $SP.Id
                    appRoleId   = $AppRole.Id
                }
                New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $spId -BodyParameter $params -ErrorAction:SilentlyContinue
            }
            catch {
                throw $_.Exception
            }
        }
    }
}


<#
The Set-SPOSiteAppCatalogPermissions function grants Managed Identity Read acess to the following SPO sites:
- root site : this is required for the Azure Runbook to connect to SharePoint and request app catalogs
- tenant level app catalog
- all detected site level app catalogs
#>
function Set-SPOSiteAppCatalogPermissions {
    param(
        [string]$tenantName,
        [string]$spId
    )
    $adminUrl = "https://$tenantName-admin.sharepoint.com/"

    Import-Module PnP.PowerShell
    Write-Host "Connect to SharePoint Admin site: $adminUrl "
    Connect-PnPOnline -Url $adminUrl -Interactive

    # get Service Principal to retrieve AppId
    $sp = Get-MgServicePrincipal -ServicePrincipalId $spId #script will stop if service principal does not exist

    Get-PnPSiteCollectionAppCatalog -ExcludeDeletedSites -PipelineVariable SiteAppCatalog | ForEach-Object {
        Grant-PnPAzureADAppSitePermission -AppId $sp.AppId -DisplayName $sp.DisplayName -Permissions Read -Site $SiteAppCatalog.SiteID.Guid
    }
    $tenantLevelAppCatalog = Get-PnPTenantAppCatalogUrl
    Grant-PnPAzureADAppSitePermission -AppId $sp.AppId -DisplayName $sp.DisplayName -Permissions Read -Site $tenantLevelAppCatalog
    Grant-PnPAzureADAppSitePermission -AppId $sp.AppId -DisplayName $sp.DisplayName -Permissions Read -Site "https://$tenantName.sharepoint.com/"

}

Set-ManagedIdentityAPIPermissions -spId $spId 
Set-SPOSiteAppCatalogPermissions -tenantName $tenantName -spId $spId 

