# Conditional Access Policy Impact Analysis

## Professional Summary

This script analyzes Microsoft Entra ID Conditional Access policies and produces an impact assessment report before policy modifications are implemented. It identifies enabled policies, targeted users and groups, included applications, grant controls, session controls, and potential administrative lockout risks.

The report helps administrators validate Conditional Access changes, understand policy scope, and reduce the likelihood of tenant-wide authentication disruptions during security hardening initiatives.

## Why it matters

Conditional Access is one of the most critical security controls in Microsoft 365. A misconfigured policy can unintentionally block administrators, service accounts, executives, remote users, or entire business units from accessing Microsoft 365 services.

Before enabling, modifying, or consolidating policies, organizations should perform an impact assessment to understand:

- Which users and groups are affected
- Which cloud applications are targeted
- Whether emergency access accounts are excluded
- Potential administrator lockout scenarios
- Overlapping or conflicting policy assignments

## Benefits

- Prevents accidental administrator lockouts
- Identifies high-risk policy configurations
- Improves Conditional Access governance
- Supports CAB and change review processes
- Accelerates security assessments
- Creates an exportable report for documentation and auditing
- Scales efficiently across large Microsoft 365 tenants

## Usage

1. Register an Azure AD App
2. Assign Exchange.ManageAsApp application permissions
3. Upload a certificate and note:
    - Client ID
    - Tenant ID
    - Certificate Thumbprint
4. Run the script from a secure automation host
5. Review or export the $Report object

# [PnP PowerShell](#tab/pnpps)

```powershell


Import-Module Microsoft.Graph.Identity.SignIns

$ReportPath = ".\ConditionalAccessImpactAnalysis.csv"

Connect-MgGraph -Scopes `
    "Policy.Read.All",
    "Directory.Read.All",
    "Group.Read.All"

$policies = Get-MgIdentityConditionalAccessPolicy -All
$directoryRoles = Get-MgDirectoryRole -All

$adminGroupIds = @()

foreach ($role in $directoryRoles) {
    $members = Get-MgDirectoryRoleMember -DirectoryRoleId $role.Id -All -ErrorAction SilentlyContinue

    foreach ($member in $members) {
        if ($member.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.group') {
            $adminGroupIds += $member.Id
        }
    }
}

$results = foreach ($policy in $policies) {

    $conditions = $policy.Conditions
    $users = $conditions.Users

    $includedUsers = ($users.IncludeUsers -join '; ')
    $excludedUsers = ($users.ExcludeUsers -join '; ')
    $includedGroups = ($users.IncludeGroups -join '; ')
    $excludedGroups = ($users.ExcludeGroups -join '; ')

    $targetsAdmins = $false

    if ($users.IncludeUsers -contains "All") {
        $targetsAdmins = $true
    }

    if ($users.IncludeGroups) {
        foreach ($groupId in $users.IncludeGroups) {
            if ($groupId -in $adminGroupIds) {
                $targetsAdmins = $true
                break
            }
        }
    }

    $emergencyAccessExcluded = $false

    if (
        $users.ExcludeUsers.Count -gt 0 -or
        $users.ExcludeGroups.Count -gt 0
    ) {
        $emergencyAccessExcluded = $true
    }

    $applications = if ($conditions.Applications.IncludeApplications) {
        $conditions.Applications.IncludeApplications -join '; '
    }
    else {
        "Not Specified"
    }

    $grantControls = if ($policy.GrantControls.BuiltInControls) {
        $policy.GrantControls.BuiltInControls -join '; '
    }
    else {
        "None"
    }

    $sessionControls = @()

    if ($policy.SessionControls.SignInFrequency) {
        $sessionControls += "SignInFrequency"
    }

    if ($policy.SessionControls.PersistentBrowser) {
        $sessionControls += "PersistentBrowser"
    }

    if ($policy.SessionControls.ApplicationEnforcedRestrictions) {
        $sessionControls += "ApplicationRestrictions"
    }

    if ($policy.SessionControls.CloudAppSecurity) {
        $sessionControls += "CloudAppSecurity"
    }

    [PSCustomObject]@{
        PolicyName                = $policy.DisplayName
        State                     = $policy.State
        IncludedUsers             = $includedUsers
        ExcludedUsers             = $excludedUsers
        IncludedGroups            = $includedGroups
        ExcludedGroups            = $excludedGroups
        Applications              = $applications
        GrantControls             = $grantControls
        SessionControls           = ($sessionControls -join '; ')
        TargetsAdministrators     = $targetsAdmins
        EmergencyAccessExcluded   = $emergencyAccessExcluded
        CreatedDateTime           = $policy.CreatedDateTime
        ModifiedDateTime          = $policy.ModifiedDateTime
    }
}

$results |
    Sort-Object PolicyName |
    Export-Csv -Path $ReportPath -NoTypeInformation -Encoding UTF8

Write-Host ""
Write-Host "Conditional Access Impact Analysis Complete" -ForegroundColor Green
Write-Host "Report: $ReportPath"
Write-Host "Policies Analyzed: $($results.Count)"


```

# [PowerShell](#tab/pnpps)

```powershell


.\ConditionalAccessImpactAnalysis.ps1

```

Required Microsoft Graph permissions:

- Policy.Read.All
- Directory.Read.All
- Group.Read.All

## Output

CSV report containing:

Column|Description|
-------|----|
PolicyName|Conditional Access policy name|
State|Enabled, Disabled, Report-Only|
IncludedUsers|Targeted users|
ExcludedUsers|Excluded users|
IncludedGroups|Targeted groups|
ExcludedGroups|Excluded groups|
Applications|Targeted cloud applications|
GrantControls|MFA, Compliant Device, Hybrid Join, etc.|
SessionControls|Session restrictions configured|
TargetsAdministrators|Indicates potential admin impact|
EmergencyAccessExcluded|Indicates whether exclusions exist|
CreatedDateTime|Policy creation date|
ModifiedDateTime|Last modification date|

## Notes

- Designed for Microsoft Entra ID Conditional Access.
- Uses Microsoft Graph PowerShell SDK.
- Suitable for pre-change reviews, CAB approvals, security audits, and governance assessments.
- Review emergency access account exclusions before enabling any policy targeting all users or privileged administrators.
- Consider scheduling periodic exports to establish a historical baseline of Conditional Access configurations.

## Contributors

 Author(s) |
-----------|
 [Josiah Opiyo](https://github.com/ojopiyo) |

*Built with a focus on automation, governance, least privilege, and clean Microsoft 365 tenants-helping M365 admins gain visibility and reduce operational risk.*

## Version history

Version|Date|Comments
-------|----|--------
1.0|June 02, 2026|Initial release

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
