---
plugin: add-to-gallery
---

# Remove a Site Collection Admin User from all Site Collections

## Summary

This function will remove the designated user for every site in the tenant if he/she is a Site Collection Admin. This applies to Group-connected sites, non group-connected sites, or classic sites.

[!INCLUDE [Delete Warning](../../docfx/includes/DELETE-WARN.md)]

# [CLI for Microsoft 365 with PowerShell](#tab/cli-m365-ps)
```powershell
<#
.SYNOPSIS
    Remove Site Collection Admin
.DESCRIPTION
    This function will remove the designated user for every site in the tenant if he/she is a Site Collection Admin.
    This applies to Group-connected sites, non group-connected sites, or classic sites.
.EXAMPLE
    PS C:\> Remove-SiteCollectionAdminUser -UserToRemove "jsmith@contoso.com"
    This will remove the user jsmith@contoso.com as a Site Collection Admin on every site in the tenant.
.EXAMPLE
    PS C:\> Remove-SiteCollectionAdminUser -UserToRemove jdoe@contoso.com
    This will remove the user jdoe@contoso.com (works also without the quotes) as a Site Collection Admin on every site in the tenant.
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    This script will not remove the designated user if he/she is a Member of a group a Administrator on a site.
#>
function Remove-SiteCollectionAdminUser{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] 
        [string]$UserToRemove
    )
    $allSPOSites = m365 spo site classic list -o json | ConvertFrom-Json
    $siteCount = $allSPOSites.Count

    Write-Host "Processing $siteCount sites..." -f Green

    #Loop through each site
    foreach ($site in $allSPOSites) {
        
        Write-Host "Going through $($site.Url)" -f Yellow
        $users = m365 spo user list --webUrl $site.Url -o json | ConvertFrom-Json
        
        foreach($user in $UserToRemove){
            $owners = $users.value | Where-Object { $_.IsSiteAdmin -eq $true } 
            
            foreach ($owner in $owners) {
                if ($owner.Email -eq $UserToRemove) {
                    #Grab the ID
                    $userToRemoveID = $owner.Id
                    
                    #Remove the user 
                    Write-Host "User $($UserToRemove) is an Admin in $($site.Title). Removing..." -f Blue
                    m365 spo user remove --webUrl $($site.Url) --id $userToRemoveID --confirm
                }
            }
        }
    }
}
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
***

## Source Credit

Sample first appeared on [Remove a Site Collection Admin User from all Site Collections | CLI for Microsoft 365](https://pnp.github.io/cli-microsoft365/sample-scripts/spo/remove-siteCollection-admin-user/)

## Contributors

| Author(s) |
|-----------|
| Inspired by Salaudeen Rajack |
| Veronique Lengelle |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/spo-remove-siteCollection-admin-user" aria-hidden="true" />