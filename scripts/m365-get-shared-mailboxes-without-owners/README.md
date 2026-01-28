

# Get Shared Mailboxes Without Owners

## Summary

This script identifies **shared mailboxes that have no assigned owners or members** by analysing mailbox permissions in Exchange Online. It detects shared mailboxes where no user (other than system accounts) has **FullAccess** permissions, indicating the mailbox is effectively unmanaged.

The output can be used for **governance reviews, access audits, compliance reporting, and remediation planning** in large Microsoft 365 tenants.

## Why It Matters

In many organisations, shared mailboxes are created for teams, projects, or business functions. Over time, users leave, teams are restructured, or ownership is never formally assigned.

Unowned shared mailboxes can:
- Contain sensitive or regulated data
- Remain accessible to unintended users
- Fail internal access control or audit requirements
- Become unmanaged attack surfaces

This script enables administrators to **proactively identify and remediate orphaned shared mailboxes** before they become a security or compliance risk.

## Benefits
- Improves mailbox ownership governance
- Supports security and compliance audits
- Reduces risk of unauthorised data access
- Helps maintain least-privilege access
- Scales efficiently for large Microsoft 365 tenants


# [Exchange](#tab/exc)

```powershell

Connect-ExchangeOnline -ShowBanner:$false

$sharedMailboxes = Get-Mailbox -RecipientTypeDetails SharedMailbox -ResultSize Unlimited
$results = @()

foreach ($mailbox in $sharedMailboxes) {

    $permissions = Get-MailboxPermission -Identity $mailbox.Identity |
        Where-Object {
            $_.AccessRights -contains "FullAccess" -and
            $_.IsInherited -eq $false -and
            $_.User -notlike "NT AUTHORITY\SELF"
        }

    if ($permissions.Count -eq 0) {
        $results += [PSCustomObject]@{
            DisplayName       = $mailbox.DisplayName
            PrimarySmtpAddress = $mailbox.PrimarySmtpAddress
            MailboxGuid       = $mailbox.Guid
        }
    }
}

$results


```


# [Usage](#tab/pnpps)

1. Connect to Exchange Online with sufficient permissions:
    - Exchange Administrator or Global Administrator
2. Run the script
3. Review the output in the console or pipe it to export formats, for example:

```powershell

$results | Export-Csv ".\SharedMailboxesWithoutOwners.csv" -NoTypeInformation


```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***


## Output
The script returns objects with the following properties:
- **DisplayName**
- **PrimarySmtpAddress**
- **MailboxGuid**

Each row represents a shared mailbox with **no assigned owners or members**.

## Notes
- The script evaluates **explicit FullAccess permissions only**
- Mailboxes managed exclusively via groups will appear as owned only if group permissions are assigned directly
- Designed for large tenants using server-side filtering and minimal object expansion
- Can be safely scheduled or integrated into governance reporting workflows

## Contributors

| Author(s) |
|-----------|
| [Josiah Opiyo](https://github.com/ojopiyo) |

*Built with a focus on automation, governance, least privilege, and clean Microsoft 365 tenants—helping M365 admins gain visibility and reduce operational risk.*


## Version history

Version|Date|Comments
-------|----|--------
1.0|Jan 11, 2026|Initial release


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/m365-get-shared-mailboxes-without-owners" aria-hidden="true" />