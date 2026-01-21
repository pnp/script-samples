# MFA Enforcement Gaps

## Professional Summary

This script identifies users in a Microsoft 365 tenant who are not effectively protected by Multi-Factor Authentication (MFA). It highlights accounts with no registered MFA methods and flags users explicitly excluded from Conditional Access (CA) policies, providing a clear view of MFA enforcement gaps across the organisation.

The output supports security hardening, audit readiness, and governance decision-making with minimal operational overhead.

## Why It Matters

In many tenants, MFA is assumed to be “on” globally, yet exceptions quietly accumulate over time:
legacy service accounts, temporary exclusions, break-glass users, or staff onboarded before policy maturity.

These gaps are often discovered **only during incidents or audits**.

This script surfaces those risks proactively, allowing security teams to:
- Detect silent exposure before compromise
- Validate Conditional Access design assumptions
- Demonstrate effective access controls to auditors and stakeholders

## Benefits

- Protects work accounts by exposing users without strong authentication
- Reduces cyber risk by identifying high-impact misconfigurations
- Improves compliance posture aligned with ISO 27001, GDPR best practices, and Zero Trust
- Strengthens defence in depth by validating MFA + Conditional Access together
- Improves audit outcomes with evidence-based reporting
- Builds confidence in identity security controls with measurable insight

# [PnP PowerShell](#tab/pnpps)

```powershell

$ErrorActionPreference = 'Stop'

# ==============================
# Authentication Configuration
# ==============================

$TenantId    = ""   # e.g. contoso.onmicrosoft.com
$ClientId   = ""   # App Registration Client ID
$Thumbprint = ""   # Certificate Thumbprint

$requiredScopes = @(
    'User.Read.All',
    'Directory.Read.All',
    'Policy.Read.All',
    'AuthenticationMethod.Read.All'
)

# ==============================
# Connect to Microsoft Graph
# ==============================

$graphContext = Get-MgContext

if (-not $graphContext) {

    if ($TenantId -and $ClientId -and $Thumbprint) {

        Connect-MgGraph `
            -TenantId $TenantId `
            -ClientId $ClientId `
            -CertificateThumbprint $Thumbprint `
            -NoWelcome

    } else {

        Connect-MgGraph `
            -Scopes $requiredScopes `
            -NoWelcome
    }
}

# ==============================
# Data Collection
# ==============================

$users = Get-MgUser -All -Property Id,DisplayName,UserPrincipalName,AccountEnabled,UserType

$enabledCAPolicies = Get-MgConditionalAccessPolicy -All |
    Where-Object { $_.State -eq 'enabled' }

$excludedUserIds = $enabledCAPolicies |
    ForEach-Object { $_.Conditions.Users.ExcludeUsers } |
    Where-Object { $_ } |
    Select-Object -Unique

# ==============================
# MFA Evaluation
# ==============================

$results = foreach ($user in $users) {

    if (-not $user.AccountEnabled -or $user.UserType -ne 'Member') {
        continue
    }

    $authMethods = Get-MgUserAuthenticationMethod -UserId $user.Id

    $hasStrongMfa = $authMethods |
        Where-Object {
            $_.'@odata.type' -match 'microsoftAuthenticator|fido2|phoneAuthenticationMethod'
        }

    [PSCustomObject]@{
        DisplayName       = $user.DisplayName
        UserPrincipalName = $user.UserPrincipalName
        MFARegistered     = [bool]$hasStrongMfa
        ExcludedFromCA    = $excludedUserIds -contains $user.Id
        RiskStatus        = if (-not $hasStrongMfa -or ($excludedUserIds -contains $user.Id)) {
                                'MFA Gap'
                            } else {
                                'Protected'
                            }
    }
}

# ==============================
# Output
# ==============================

$results |
    Where-Object { $_.RiskStatus -eq 'MFA Gap' } |
    Sort-Object ExcludedFromCA, MFARegistered |
    Export-Csv -Path '.\MFA-Enforcement-Gaps.csv' -NoTypeInformation -Encoding UTF8


```



## Usage
1. Run from a secure admin workstation
2. Ensure the executing identity has:
    - Global Reader or Security Reader
    - Graph API consent for required scopes
3. Review the generated CSV:
    - Prioritise users excluded from Conditional Access
    - Validate whether exclusions are intentional and justified

## Output
**MFA-Enforcement-Gaps.csv**

| Column | Description |
|-----------|-----------|
| DisplayName |	User display name |
| UserPrincipalName |	Sign-in identity |
| MFARegistered |	Strong MFA methods detected |
| ExcludedFromCA |	Explicit CA exclusion |
| RiskIndicator |	MFA Gap / Protected |

## Notes

- This script focuses on effective MFA protection, not legacy per-user MFA states
- Conditional Access exclusions represent the highest risk signal
- Designed to scale across large tenants using Graph paging and filtering
- Suitable for scheduled execution and security reporting pipelines


## Contributors

| Author(s) |
|-----------|
| [Josiah Opiyo](https://github.com/ojopiyo) |

*Built with a focus on automation, governance, least privilege, and clean Microsoft 365 tenants—helping M365 admins gain visibility and reduce operational risk.*


## Version history

Version|Date|Comments
-------|----|--------
1.0|Jan 21, 2026|Initial release


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]

