<h1 align="left">Get Azure AD (Entra ID) Guest Users with Elevated Permissions (M365)</h1>
<h3 align="left">Summary</h3>
<p align="left">
  This script audits and identifies Azure AD (Entra ID) guest (B2B) users who have been granted elevated permissions across Microsoft 365 services, including Entra ID directory roles, Microsoft Teams ownership, and SharePoint Online site collection administration. It generates a consolidated report to support security reviews, least-privilege enforcement, and external access governance.
</p>
<h3 align="left">Why It Matters</h3>
<p align="left">
  <ul>
    <li><b>Risk reduction:</b> Identifies external accounts with elevated access before they become a security issue.</li>
    <li><b>Compliance support:</b> Provides evidence for audits and regulatory requirements.</li>
    <li><b>Operational efficiency:</b> Consolidates checks across Entra ID, Teams, and SharePoint into one report.</li>
    <li><b>Governance enforcement:</b> Helps enforce least‑privilege and external access policies consistently.</li>
  </ul>
</p>
<h1 align="left">PnP Powershell</h1>
## Script

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


