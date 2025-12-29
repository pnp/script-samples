---
plugin: add-to-gallery
---

# Get Azure AD (Entra ID) Guest Users with Elevated Permissions (M365)


## Summary

This script audits and identifies Azure AD (Entra ID) guest (B2B) users who have been granted elevated permissions across Microsoft 365 services, including Entra ID directory roles, Microsoft Teams ownership, and SharePoint Online site collection administration. It generates a consolidated report to support security reviews, least-privilege enforcement, and external access governance.

### Why It Matters

- **Risk reduction:** Identifies external accounts with elevated access before they become a security issue.
- **Compliance support:** Provides evidence for audits and regulatory requirements.
- **Operational efficiency:** Consolidates checks across Entra ID, Teams, and SharePoint into one report.
- **Governance enforcement:** Helps enforce least‑privilege and external access policies consistently.

# [PnP PowerShell](#tab/pnpps)

```powershell

# ------------------------------------------------------------
# Configuration
# ------------------------------------------------------------
$TenantAdminUrl = "https://contoso-admin.sharepoint.com"
$OutputPath = "C:\Temp\GuestUsersWithExcessivePermissions.csv"

# ------------------------------------------------------------
# Connect
# ------------------------------------------------------------
if (-not $conn) {
    $conn = Connect-PnPOnline -Url $TenantAdminUrl -Interactive -ReturnConnection
}

# ------------------------------------------------------------
# Helper: Get all guest users
# ------------------------------------------------------------
function Get-GuestUsers {
    param([Parameter(Mandatory)] $Connection)

    Invoke-PnPGraphMethod -Url "users?`$filter=userType eq 'Guest'&`$select=id,displayName,userPrincipalName,userType" `
        -Connection $Connection
}

# ------------------------------------------------------------
# Helper: Get Entra ID directory roles for guests
# ------------------------------------------------------------
function Get-GuestDirectoryRoles {
    param(
        [Parameter(Mandatory)] $Connection,
        [Parameter(Mandatory)] $Guests
    )

    $results = @()

    $roles = Invoke-PnPGraphMethod -Url "directoryRoles" -Connection $Connection

    foreach ($role in $roles.value) {
        $members = Invoke-PnPGraphMethod -Url "directoryRoles/$($role.id)/members" -Connection $Connection

        foreach ($member in $members.value) {
            if ($member.userType -eq "Guest") {
                $results += [PSCustomObject]@{
                    DisplayName        = $member.displayName
                    UserPrincipalName  = $member.userPrincipalName
                    PermissionType     = "AAD Role"
                    AssignedRole       = $role.displayName
                    Resource           = "Tenant"
                }
            }
        }
    }

    return $results
}

# ------------------------------------------------------------
# Helper: Get Teams owned by guests
# ------------------------------------------------------------
function Get-GuestTeamOwners {
    param([Parameter(Mandatory)] $Connection)

    $results = @()
    $groups = Invoke-PnPGraphMethod -Url "groups?`$filter=resourceProvisioningOptions/Any(x:x eq 'Team')" `
        -Connection $Connection

    foreach ($group in $groups.value) {
        $owners = Invoke-PnPGraphMethod -Url "groups/$($group.id)/owners" -Connection $Connection

        foreach ($owner in $owners.value) {
            if ($owner.userType -eq "Guest") {
                $results += [PSCustomObject]@{
                    DisplayName        = $owner.displayName
                    UserPrincipalName  = $owner.userPrincipalName
                    PermissionType     = "Teams"
                    AssignedRole       = "Owner"
                    Resource           = $group.displayName
                }
            }
        }
    }

    return $results
}

# ------------------------------------------------------------
# Helper: Get SharePoint Site Collection Admins (guests only)
# ------------------------------------------------------------
function Get-GuestSPOAdmins {
    param([Parameter(Mandatory)] $Connection)

    $results = @()
    $sites = Get-PnPTenantSite -Connection $Connection

    foreach ($site in $sites) {
        try {
            Connect-PnPOnline -Url $site.Url -Connection $Connection
            $admins = Get-PnPSiteCollectionAdmin

            foreach ($admin in $admins) {
                if ($admin.PrincipalType -eq "User" -and $admin.LoginName -like "*#EXT#*") {
                    $results += [PSCustomObject]@{
                        DisplayName        = $admin.Title
                        UserPrincipalName  = $admin.Email
                        PermissionType     = "SharePoint"
                        AssignedRole       = "Site Collection Administrator"
                        Resource           = $site.Url
                    }
                }
            }
        }
        catch {
            Write-Warning "Failed to process site $($site.Url)"
        }
    }

    return $results
}

# ------------------------------------------------------------
# Main Execution
# ------------------------------------------------------------
Write-Host "Retrieving guest users..." -ForegroundColor Cyan
$guestUsers = Get-GuestUsers -Connection $conn

Write-Host "Checking Entra ID directory roles..." -ForegroundColor Cyan
$aadRoles = Get-GuestDirectoryRoles -Connection $conn -Guests $guestUsers.value

Write-Host "Checking Microsoft Teams ownership..." -ForegroundColor Cyan
$teamsOwners = Get-GuestTeamOwners -Connection $conn

Write-Host "Checking SharePoint site collection administrators..." -ForegroundColor Cyan
$spoAdmins = Get-GuestSPOAdmins -Connection $conn

# ------------------------------------------------------------
# Consolidate Results
# ------------------------------------------------------------
$finalResults = @()
$finalResults += $aadRoles
$finalResults += $teamsOwners
$finalResults += $spoAdmins

# ------------------------------------------------------------
# Export
# ------------------------------------------------------------
$finalResults |
    Sort-Object UserPrincipalName, PermissionType |
    Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8

Write-Host "Completed. Results exported to $OutputPath" -ForegroundColor Green

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***


## Contributors

| Author(s) |
|-----------|
| Josiah Opiyo |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/aspo-get-entra-id-guest-users-with-elevated-permissions-m365" aria-hidden="true" />
