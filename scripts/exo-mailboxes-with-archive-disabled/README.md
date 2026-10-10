# Exchange Online Mailboxes with Archive Disabled

## Summary

This PowerShell script performs an assessment of Exchange Online mailboxes to identify those that do not have an archive mailbox enabled. It uses certificate-based application authentication to connect securely to Exchange Online and retrieves mailbox information using the Exchange Online PowerShell module.

The script evaluates the `ArchiveStatus` property, identifies mailboxes where the status is `None`, and exports the results to a timestamped CSV report. It also generates a log file documenting the assessment lifecycle, mailbox retrieval count, findings, output locations, and any errors encountered.

The script is designed for Microsoft 365 administrative assessments, tenant configuration reviews, and ongoing mailbox archive compliance monitoring.

## Why It Matters

Exchange Online archive mailboxes provide additional storage capacity and support organisational email retention strategies. Mailboxes without an enabled archive may require investigation to determine whether their configuration aligns with business, operational, and compliance requirements.

For example, an M365 Administrator performing a tenant-wide storage assessment can use this script to identify mailboxes without an enabled archive, review the findings with service owners, and determine whether archive provisioning is required.

The report provides a practical starting point for remediation planning and configuration governance without making changes to mailbox settings.

### Benefits

- **Tenant-wide visibility:** Assesses mailboxes across the Exchange Online organisation.
- **Configuration assessment:** Identifies mailboxes reporting an archive status of `None`.
- **Audit-ready reporting:** Produces a timestamped CSV file suitable for filtering, analysis, and distribution.
- **Operational traceability:** Records execution milestones, mailbox counts, results, and errors in a log file.
- **Secure authentication:** Uses certificate-based application authentication rather than interactive user sign-in.
- **Automation readiness:** Supports scheduled execution and integration into administrative assessment workflows.
- **Non-invasive execution:** Performs a read-only assessment and does not enable, disable, or modify archive mailboxes.

## Prerequisites

- Exchange Online PowerShell module (`ExchangeOnlineManagement`)
- Exchange Online application registration configured for certificate-based authentication
- Valid certificate associated with the application
- Appropriate Exchange Online application permissions and administrative configuration
- Access to the certificate private key from the system executing the script

## Configuration

Update the following variables before execution:

| Variable          | Description                                                |
| ----------------- | ---------------------------------------------------------- |
| `$ClientID`       | Azure AD Application (Client) ID                           |
| `$ThumbPrint`     | Certificate thumbprint                                     |
| `$Tenant`         | Microsoft 365 tenant name (e.g. `contoso.onmicrosoft.com`) |
| `$OutputFolder`   | Currently set to (`C:\Temp\MailboxReport`)                 |

# [PnP PowerShell](#tab/pnpps)

```powershell

# ============================================================
# ASSESSMENT: EXCHANGE ONLINE MAILBOXES WITH ARCHIVE DISABLED
# ============================================================

$ClientID   = "xxxxxxxxxxxxxxxxxxxxx"
$ThumbPrint = "xxxxxxxxxxxxxxxxxxxxx"
$Tenant     = "contoso.onmicrosoft.com"

$OutputFolder = "C:\Temp\MailboxesWithArchiveDisabled"

if (-not (Test-Path -LiteralPath $OutputFolder)) {
    New-Item -Path $OutputFolder -ItemType Directory -Force | Out-Null
}

$TimeStamp = Get-Date -Format "yyyyMMdd_HHmmss"
$CsvPath   = Join-Path $OutputFolder "MailboxesWithArchiveDisabled_$TimeStamp.csv"
$LogPath   = Join-Path $OutputFolder "MailboxesWithArchiveDisabled_$TimeStamp.log"

$Connected = $false

try {
    Add-Content -LiteralPath $LogPath -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Assessment started."

    # ======================================================================
    # CONNECT TO EXCHANGE ONLINE USING CERTIFICATE-BASED APP AUTHENTICATION
    # ======================================================================
    Import-Module ExchangeOnlineManagement -ErrorAction Stop

    Connect-ExchangeOnline `
        -AppId $ClientID `
        -CertificateThumbprint $ThumbPrint `
        -Organization $Tenant `
        -ShowBanner:$false `
        -ErrorAction Stop

    $Connected = $true

    Add-Content -LiteralPath $LogPath -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Connected to Exchange Online."
    # ======================================================================
    # RETRIEVE ALL MAILBOXES, INCLUDING THE ARCHIVESTATUS PROPERTY
    # ======================================================================
    $Mailboxes = @(
        Get-EXOMailbox `
            -ResultSize Unlimited `
            -Properties ArchiveStatus, RecipientTypeDetails `
            -ErrorAction Stop
    )

    Add-Content -LiteralPath $LogPath -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Retrieved $($Mailboxes.Count) mailboxes."

    # ============================================================================
    # IDENTIFY MAILBOXES WITHOUT AN IDENTIFY MAILBOXES WITHOUT AN ENABLED ARCHIVE
    # ============================================================================
    $Results = @(
        $Mailboxes |
            Where-Object { $_.ArchiveStatus -eq "None" } |
            Select-Object `
                DisplayName,
                PrimarySmtpAddress,
                UserPrincipalName,
                RecipientTypeDetails,
                ArchiveStatus
    )
    # ======================================================================
    # EXPORT RESULTS, INCLUDING HEADERS WHEN NO MAILBOXES MATCH
    # ======================================================================
    if ($Results.Count -gt 0) {
        $Results | Export-Csv -LiteralPath $CsvPath -NoTypeInformation -Encoding UTF8
    }
    else {
        "DisplayName,PrimarySmtpAddress,UserPrincipalName,RecipientTypeDetails,ArchiveStatus" |
            Set-Content -LiteralPath $CsvPath -Encoding UTF8
    }

    Add-Content -LiteralPath $LogPath -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Mailboxes with archive disabled: $($Results.Count)."
    Add-Content -LiteralPath $LogPath -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - CSV output: $CsvPath"
    Add-Content -LiteralPath $LogPath -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Assessment completed successfully."

    Write-Host "Assessment completed successfully." -ForegroundColor Green
    Write-Host "Total mailboxes assessed: $($Mailboxes.Count)"
    Write-Host "Mailboxes with archive disabled: $($Results.Count)"
    Write-Host "CSV report: $CsvPath"
    Write-Host "Log file: $LogPath"
}
catch {
    $ErrorMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - ERROR: $($_.Exception.Message)"
    Add-Content -LiteralPath $LogPath -Value $ErrorMessage
    Write-Error $ErrorMessage
}
finally {
    if ($Connected) {
        Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
        Add-Content -LiteralPath $LogPath -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Disconnected from Exchange Online."
    }
}


```

## Usage

1. Configure $ClientID, $ThumbPrint, and $Tenant with the appropriate application and tenant details.
2. Set $OutputFolder to a suitable location with sufficient storage and appropriate access controls.
3. Run the script under an identity that can access the configured certificate and output directory.
4. Review the generated CSV report and log file.

The script creates the output directory if it does not exist. Each execution generates timestamped output files to help preserve historical assessment results.

## Output

The script generates two files:

| File                                               | Description                                                          |
| -------------------------------------------------- | -------------------------------------------------------------------- |
| `MailboxesWithArchiveDisabled_yyyyMMdd_HHmmss.csv` | Mailbox records where ArchiveStatus is `None`                        |
| `MailboxesWithArchiveDisabled_yyyyMMdd_HHmmss.log` | Assessment progress, mailbox counts, output paths, and error details |

The CSV contains the following fields:

- `DisplayName`
- `PrimarySmtpAddress`
- `UserPrincipalName`
- `RecipientTypeDetails`
- `ArchiveStatus`

If no matching mailboxes are found, the script creates a CSV containing the column headers without any data rows.

## Notes

- **Assessment scope:** The report includes mailboxes returned by `Get-EXOMailbox -ResultSize Unlimited` for which `ArchiveStatus` is `None`. It should not be interpreted as a definitive inventory of every Exchange recipient type.
- **Archive status:** A status of `None` indicates that an archive is not currently reported as enabled. Validate individual cases against organisational requirements before taking action.
- **No remediation:** The script does not provision archives or change retention policies.
- **Large tenants:** Retrieving all mailboxes into memory is appropriate for many assessments. For exceptionally large environments, consider implementing paged processing and incremental CSV exports.
- **Error handling:** Errors are logged, and the Exchange Online session is disconnected when the connection was successfully established. For unattended automation, consider returning a non-zero process exit code when the assessment fails.
- **Credential management:** Do not commit production certificate details, private keys, or other credentials to source control.
- **Output protection:** Store reports in an appropriately secured location because mailbox identifiers and addresses may be operationally sensitive.

## Recommended Use

Run the assessment periodically as part of Exchange Online configuration reviews, archive provisioning assessments, and Microsoft 365 operational reporting. Use the results to support investigation and remediation decisions rather than treating the absence of an archive as an automatic configuration fault.

## Contributors

|Author(s)|
|-----------|
|[Josiah Opiyo](https://github.com/ojopiyo)|

*Built with a focus on automation, governance, least privilege, and clean Microsoft 365 tenants - helping M365 admins gain visibility and reduce operational risk.*

## Version history

|Version|Date|Comments|
|-------|----|--------|
|1.0|October 10, 2026|Initial release|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
