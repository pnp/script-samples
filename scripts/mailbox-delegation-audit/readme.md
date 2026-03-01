# Mailbox Delegation Audit

## Professional Summary

This script connects to Exchange Online, enumerates all user and shared mailboxes, and produces a consolidated report of every delegate with:

- **FullAccess**
- **SendAs**
- **SendOnBehalf**

permissions per mailbox. The output is optimized for large tenants and can be exported to CSV or consumed by downstream governance and audit processes.

## Why it matters

In most organisations, mailbox delegation grows organically-shared mailboxes, executive assistants, team mailboxes, and legacy access that no one remembers granting. Over time, this creates risk: excessive access, stale permissions for leavers, and a lack of clear ownership.

This script gives Microsoft 365 engineers a single, authoritative view of who can read from, and send as/on behalf of, any mailbox. It supports:

- Access reviews for security and compliance
- Offboarding checks to ensure leavers lose access
- Audit evidence for internal and external regulators
- Cleanup projects to remove unnecessary delegation

## Benefits

- Centralised visibility: One report covering all key mailbox delegate permissions.
- Risk reduction: Quickly identify over-permissioned or unexpected delegates.
- Operational efficiency: Avoid manual, per-mailbox checks in the EAC.
- Audit-ready output: CSV-friendly structure for Power BI, Excel, or GRC tools.
- Scales to large tenants: Uses efficient querying and avoids unnecessary processing.

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



param(
    [Parameter(Mandatory)]
    [string]$TenantId,

    [Parameter(Mandatory)]
    [string]$ClientId,

    [Parameter(Mandatory)]
    [string]$CertificateThumbprint,

    [string]$OutputPath = ".\MailboxDelegatesReport.csv",

    [switch]$IncludeRoomAndEquipment
)

# Connect using App-Only Certificate Authentication
Connect-ExchangeOnline `
    -AppId $ClientId `
    -CertificateThumbprint $CertificateThumbprint `
    -Organization $TenantId `
    -ShowBanner:$false

# Determine mailbox types
$recipientTypes = @("UserMailbox", "SharedMailbox")
if ($IncludeRoomAndEquipment) {
    $recipientTypes += "RoomMailbox", "EquipmentMailbox"
}

# Retrieve mailboxes
$mailboxes = Get-ExoMailbox `
    -RecipientTypeDetails $recipientTypes `
    -ResultSize Unlimited `
    -Properties DisplayName, PrimarySmtpAddress, GrantSendOnBehalfTo

# Pre-size collection for performance
$Report = New-Object System.Collections.Generic.List[object]

foreach ($mailbox in $mailboxes) {

    $identity = $mailbox.PrimarySmtpAddress.ToString()

    # --- FullAccess ---
    $fullAccess = Get-ExoMailboxPermission -Identity $identity -ResultSize Unlimited |
        Where-Object {
            $_.AccessRights -contains "FullAccess" -and
            -not $_.IsInherited -and
            $_.User -ne "NT AUTHORITY\SELF"
        }

    foreach ($perm in $fullAccess) {
        $Report.Add([pscustomobject]@{
            MailboxIdentity    = $identity
            MailboxDisplayName = $mailbox.DisplayName
            RecipientType      = $mailbox.RecipientTypeDetails
            PermissionType     = "FullAccess"
            DelegateIdentity   = $perm.User
            IsInherited        = $perm.IsInherited
            AccessRights       = ($perm.AccessRights -join ",")
        })
    }

    # --- SendAs ---
    $sendAs = Get-ExoRecipientPermission -Identity $identity -ResultSize Unlimited |
        Where-Object {
            $_.AccessRights -contains "SendAs" -and
            -not $_.IsInherited -and
            $_.Trustee -ne "NT AUTHORITY\SELF"
        }

    foreach ($perm in $sendAs) {
        $Report.Add([pscustomobject]@{
            MailboxIdentity    = $identity
            MailboxDisplayName = $mailbox.DisplayName
            RecipientType      = $mailbox.RecipientTypeDetails
            PermissionType     = "SendAs"
            DelegateIdentity   = $perm.Trustee
            IsInherited        = $perm.IsInherited
            AccessRights       = ($perm.AccessRights -join ",")
        })
    }

    # --- SendOnBehalf ---
    if ($mailbox.GrantSendOnBehalfTo) {
        foreach ($delegate in $mailbox.GrantSendOnBehalfTo) {

            $resolved = Get-ExoRecipient -Identity $delegate -ErrorAction SilentlyContinue
            $delegateIdentity = if ($resolved) { $resolved.PrimarySmtpAddress } else { $delegate.ToString() }

            $Report.Add([pscustomobject]@{
                MailboxIdentity    = $identity
                MailboxDisplayName = $mailbox.DisplayName
                RecipientType      = $mailbox.RecipientTypeDetails
                PermissionType     = "SendOnBehalf"
                DelegateIdentity   = $delegateIdentity
                IsInherited        = $false
                AccessRights       = "SendOnBehalf"
            })
        }
    }
}

# Export
$Report |
    Sort-Object MailboxIdentity, PermissionType, DelegateIdentity |
    Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8

Write-Host "Mailbox delegate report generated: $OutputPath" -ForegroundColor Green


```

## Output

The script produces a structured dataset with:

- MailboxIdentity
- MailboxDisplayName
- RecipientType
- PermissionType
- DelegateIdentity
- IsInherited
- AccessRights

## Notes

- Run periodically and store historical CSVs to track permission drift over time.
- Consider feeding the CSV into Power BI for visual access review dashboards.
- For very large tenants, you can parallelise mailbox processing with ForEach-Object -Parallel in PowerShell 7, if your operational standards allow it.

## Contributors

| Author(s) |
|-----------|
| [Josiah Opiyo](https://github.com/ojopiyo) |

*Built with a focus on automation, governance, least privilege, and clean Microsoft 365 tenants-helping M365 admins gain visibility and reduce operational risk.*

## Version history

Version|Date|Comments
-------|----|--------
1.0|Mar 01, 2026|Initial release

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]

