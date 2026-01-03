# Audit Azure AD (Entra ID) Role Assignments

## Summary

This script audits all privileged Entra ID directory role assignments across a Microsoft 365 tenant using Microsoft Graph. It enumerates role assignments (direct and group-based), resolves the assigned principals (users, groups, service principals), and exports a clean, audit-ready report suitable for large tenants.

## Why It Matters

Security reviews, compliance attestations, and least-privilege initiatives require a single source of truth for who holds privileged access. Over time, directory roles are often granted via groups, inherited, or left assigned to inactive identities. This audit provides the evidence needed to identify excessive privilege, remediate risk, and satisfy auditors.

## Benefits
- **Complete visibility** into privileged role assignments (not limited to currently activated roles).
- **Detects risky patterns** (guest users, service principals, group-based elevation).
- **Audit-ready output** for compliance and governance reviews.
- **Scales to large tenants** using Microsoft Graph paging.

# [PowerShell Script](#tab/pnpps)

```powershell

param(
    [Parameter(Mandatory)]
    [string]$OutputPath
)

Connect-MgGraph -Scopes @(
    "RoleManagement.Read.Directory",
    "Directory.Read.All",
    "User.Read.All",
    "Group.Read.All"
)

$roleDefinitions = Get-MgRoleManagementDirectoryRoleDefinition -All |
    Select-Object Id, DisplayName

$roleDefinitionLookup = @{}
foreach ($rd in $roleDefinitions) {
    $roleDefinitionLookup[$rd.Id] = $rd.DisplayName
}

$assignments = Get-MgRoleManagementDirectoryRoleAssignment -All

$results = foreach ($assignment in $assignments) {

    $roleName = $roleDefinitionLookup[$assignment.RoleDefinitionId]

    $principalType = $assignment.PrincipalType
    $principalId   = $assignment.PrincipalId

    $principalName = $null
    $principalUPN  = $null
    $principalAppId = $null

    switch ($principalType) {
        "User" {
            $user = Get-MgUser -UserId $principalId -ErrorAction SilentlyContinue
            if ($user) {
                $principalName = $user.DisplayName
                $principalUPN  = $user.UserPrincipalName
            }
        }
        "Group" {
            $group = Get-MgGroup -GroupId $principalId -ErrorAction SilentlyContinue
            if ($group) {
                $principalName = $group.DisplayName
            }
        }
        "ServicePrincipal" {
            $sp = Get-MgServicePrincipal -ServicePrincipalId $principalId -ErrorAction SilentlyContinue
            if ($sp) {
                $principalName  = $sp.DisplayName
                $principalAppId = $sp.AppId
            }
        }
    }

    [PSCustomObject]@{
        RoleName        = $roleName
        RoleDefinitionId= $assignment.RoleDefinitionId
        AssignmentId    = $assignment.Id
        AssignmentType  = if ($assignment.PrincipalType -eq "Group") { "GroupBased" } else { "Direct" }
        PrincipalType   = $principalType
        PrincipalName   = $principalName
        UserPrincipalName = $principalUPN
        AppId           = $principalAppId
        Scope           = $assignment.DirectoryScopeId
    }
}

$results |
    Sort-Object RoleName, PrincipalType, PrincipalName |
    Export-Csv -Path $OutputPath -NoTypeInformation

```

# [Usage](#tab/pnpps)

```powershell

# Prerequisites (once)
Install-Module Microsoft.Graph -Scope CurrentUser

# Permissions required (delegated or app):
# RoleManagement.Read.Directory, Directory.Read.All, User.Read.All, Group.Read.All

# Run
.\Audit-EntraRoleAssignments.ps1 -OutputPath ".\EntraRoleAssignments.csv"

```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Output
The CSV report includes the following fields:
- Role name and scope.
- Assignment type (Direct / Group).
- Principal type (User / Group / ServicePrincipal).
- Principal details (UPN/AppId/DisplayName).
- Assignment ID.

## Notes
- Group-based assignments list the **group** as the principal (by design). Expand group membership separately if needed.
- PIM **eligibility vs active** can be added by querying PIM endpoints if required.

## Contributors

| Author(s) |
|-----------|
| [Josiah Opiyo](https://github.com/ojopiyo) |

*Built with a focus on automation, governance, least privilege, and clean Microsoft 365 tenants—helping M365 admins gain visibility and reduce operational risk.*


## Version history

Version|Date|Comments
-------|----|--------
1.0|Jan 03, 2026|Initial release


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]

