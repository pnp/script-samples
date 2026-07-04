# Get Exchange Online Mailboxes Configured With Email Forwarding

## Professional Summary

This script identifies all Exchange Online mailboxes configured with email forwarding and exports the results to a timestamped CSV report.

The script authenticates to Exchange Online using an Azure AD App Registration and certificate-based authentication, making it suitable for unattended execution.

For each mailbox with forwarding enabled, the report includes:

- Mailbox Display Name
- Primary SMTP Address
- Mailbox Type
- Forwarding Destination
- Internal or External forwarding classification
- Forwarding Recipient (if applicable)
- SMTP Forwarding Address
- Deliver to Mailbox and Forward status
- Report execution date
- Report execution account

The report is exported to a configurable output location for auditing and operational review.

## Why it matters

Mailbox forwarding is commonly used for business processes, shared services, and user transitions. However, forwarding - particularly to external recipients - can introduce security, compliance, and data governance risks if not regularly monitored.

This report enables administrators to quickly identify forwarding configurations across the tenant, helping to detect:

- Unauthorised external forwarding
- Legacy mailbox configurations
- Forgotten forwarding rules after staff departures
- Shared mailboxes forwarding to individual users
- Potential data exfiltration risks
- Mail routing issues caused by incorrect forwarding settings

The script is well suited to scheduled compliance reporting or periodic Exchange Online health checks.

## Benefits

- Provides a tenant-wide inventory of mailbox forwarding.
- Identifies external forwarding destinations for security review.
- Supports Microsoft 365 governance and compliance initiatives.
- Assists with migration validation and post-project audits.
- Helps troubleshoot unexpected mail routing behaviour.
- Produces a consistent CSV report suitable for archiving or further analysis.
- Supports unattended execution using certificate-based authentication.

## Prerequisites

- PowerShell 7.x or Windows PowerShell 5.1
- Exchange Online PowerShell Module
- Microsoft Entra ID App Registration configured for certificate-based authentication
- Exchange.ManageAsApp permission granted
- Exchange Administrator (or equivalent application permissions)

## Usage

1. Configure tenant-specific values:
    - Client ID
    - Certificate Thumbprint
    - Tenant Name
    - Output Folder
2. Execute the script using a privileged administrative account context.
3. Review the generated CSV reports.

# [PnP PowerShell](#tab/pnpps)

```powershell

# ------------------------------------------------------------
# Mailboxes with Forwarding Enabled - Audit Report
# Exchange Online App Authentication
# ------------------------------------------------------------

# ---------- Configuration ----------
$ClientID      = "xxxxxxxxxxxxxxxxxxxxxxxxx"
$ThumbPrint    = "xxxxxxxxxxxxxxxxxxxxxxxxx"
$Tenant        = "contoso.onmicrosoft.com"

$OutputFolder  = "C:\Temp\Outlook"

# Your accepted email domains (used to determine Internal vs External forwarding)
$AcceptedDomains = @(
    "contoso.com",
    "contoso.onmicrosoft.com"
)

# ---------- Report Information ----------
$ReportName    = "Mailboxes with Forwarding Enabled"
$ReportRunDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$ReportRunBy   = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

$DateStamp     = Get-Date -Format "yyyy-MM-dd_HHmmss"
$OutputFile    = Join-Path $OutputFolder "MailboxesWithForwarding_$DateStamp.csv"

# ---------- Create Output Folder ----------
if (!(Test-Path $OutputFolder)) {
    Write-Host "Creating output folder..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $OutputFolder | Out-Null
}

try {

    # ---------- Connect ----------
    Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan

    Connect-ExchangeOnline `
        -AppId $ClientID `
        -CertificateThumbprint $ThumbPrint `
        -Organization $Tenant `
        -ShowBanner:$false `
        -ErrorAction Stop

    Write-Host "Connected successfully." -ForegroundColor Green

    # ---------- Retrieve Mailboxes ----------
    Write-Host "Retrieving mailboxes..." -ForegroundColor Cyan

    $mailboxes = Get-EXOMailbox `
        -ResultSize Unlimited `
        -Properties ForwardingAddress,ForwardingSmtpAddress,DeliverToMailboxAndForward

    $total = $mailboxes.Count
    $counter = 0

    Write-Host "Processing $total mailbox(es)..." -ForegroundColor Cyan

    $results = foreach ($mailbox in $mailboxes) {

        $counter++

        Write-Progress `
            -Activity "Checking Mailboxes" `
            -Status "$counter of $total" `
            -PercentComplete (($counter / $total) * 100)

        if ($mailbox.ForwardingAddress -or $mailbox.ForwardingSmtpAddress) {

            # Determine forwarding destination
            if ($mailbox.ForwardingAddress) {
                $ForwardTo = $mailbox.ForwardingAddress.PrimarySmtpAddress
                $ForwardingRecipient = $mailbox.ForwardingAddress.Name
            }
            else {
                $ForwardTo = $mailbox.ForwardingSmtpAddress
                $ForwardingRecipient = ""
            }

            # Determine Internal / External
            $ForwardType = "Unknown"

            if ($ForwardTo) {

                $ForwardDomain = ($ForwardTo.ToString().Split("@")[-1]).ToLower()

                if ($AcceptedDomains -contains $ForwardDomain) {
                    $ForwardType = "Internal"
                }
                else {
                    $ForwardType = "External"
                }
            }

            [PSCustomObject]@{

                ReportName                 = $ReportName
                ReportRunDate              = $ReportRunDate
                ReportRunBy                = $ReportRunBy

                DisplayName                = $mailbox.DisplayName
                PrimarySmtpAddress         = $mailbox.PrimarySmtpAddress
                MailboxType                = $mailbox.RecipientTypeDetails

                ForwardTo                  = $ForwardTo
                ForwardType                = $ForwardType
                ForwardingRecipient        = $ForwardingRecipient
                ForwardingSmtpAddress      = $mailbox.ForwardingSmtpAddress

                DeliverToMailboxAndForward = $mailbox.DeliverToMailboxAndForward
            }

        }

    }

    Write-Progress -Activity "Checking Mailboxes" -Completed

    # ---------- Export ----------
    if ($results) {

        $results |
            Sort-Object DisplayName |
            Export-Csv -Path $OutputFile -NoTypeInformation -Encoding UTF8

        Write-Host ""
        Write-Host "=============================================" -ForegroundColor Green
        Write-Host "Report Complete" -ForegroundColor Green
        Write-Host "=============================================" -ForegroundColor Green
        Write-Host "Mailboxes with forwarding : $($results.Count)"
        Write-Host "Report saved to           : $OutputFile"
        Write-Host "Run by                    : $ReportRunBy"
        Write-Host "Run date                  : $ReportRunDate"
    }
    else {

        Write-Host ""
        Write-Host "No mailboxes with forwarding enabled were found." -ForegroundColor Green
    }

}
catch {

    Write-Host ""
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red

}
finally {

    Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue

}

```

## Output

### Detailed Report

The script generates a timestamped CSV file similar to:

MailboxesWithForwarding_yyyyMMdd_HHmmss.csv

The report contains the following fields:

| Column                     | Description                                                |
| -------------------------- | ---------------------------------------------------------- |
| ReportName                 | Name of the report                                         |
| ReportRunDate              | Date and time the report was generated                     |
| ReportRunBy                | Windows account executing the script                       |
| DisplayName                | Mailbox display name                                       |
| PrimarySmtpAddress         | Primary email address                                      |
| MailboxType                | Exchange mailbox type                                      |
| ForwardTo                  | Destination address receiving forwarded mail               |
| ForwardType                | Internal or External                                       |
| ForwardingRecipient        | Internal Exchange recipient (if configured)                |
| ForwardingSmtpAddress      | SMTP forwarding address                                    |
| DeliverToMailboxAndForward | Indicates whether mail is retained in the original mailbox |

## Typical Use Cases

- Exchange Online security audits
- Governance reporting
- Compliance reviews
- Tenant health checks
- Migration validation
- Quarterly mailbox audits
- Operational documentation
- Incident investigations

## Notes

- Only mailboxes with forwarding configured are included in the report.
- Internal versus External forwarding is determined using the tenant's accepted email domains.
- The script automatically disconnects from Exchange Online when processing is complete.
- The script is designed for unattended execution using certificate-based authentication and can be scheduled using Task Scheduler, Azure Automation, or similar orchestration platforms.

## Contributors

|Author(s) |
|-----------|
|[Josiah Opiyo](https://github.com/ojopiyo)|

*Built with a focus on automation, governance, least privilege, and clean Microsoft 365 tenants-helping M365 admins gain visibility and reduce operational risk.*

## Version history

|Version|Date|Comments|
|-------|----|--------|
|1.0|July 04, 2026|Initial release|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
