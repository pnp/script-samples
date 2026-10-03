# Exchange Online Deleted & Recoverable Items Assessment

## Summary

This PowerShell script connects to **Exchange Online using certificate-based app-only authentication**, enumerates all user mailboxes, and measures the storage consumed by:

- Deleted Items
- Recoverable Items
- Combined Deleted/Recoverable content

The script ranks mailboxes by total deleted/recoverable storage consumption and exports the **top 100 mailboxes** to a timestamped CSV report. Processing activity and errors are recorded in a corresponding log file.

## Why It Matters

Deleted and recoverable mailbox content can consume significant mailbox storage without being immediately visible during routine mailbox reviews.

This assessment provides M365 administrators with visibility into mailboxes containing unusually large volumes of deleted or recoverable data. It can support:

- Mailbox storage investigations
- Capacity and quota management
- Retention and lifecycle reviews
- Recoverable Items investigations
- Mailbox cleanup assessments
- Troubleshooting unexpected mailbox size growth
- Operational or compliance-driven mailbox assessments

### Benefits

- Identifies high-consumption mailboxes by ranking them by total deleted/recoverable storage.
- Separates Deleted Items from Recoverable Items, making the source of consumption easier to investigate.
- Provides item counts alongside storage measurements.
- Scales across the tenant by processing all user mailboxes.
- Produces an auditable CSV report suitable for further analysis or operational reporting.
- Provides execution logging to identify mailbox-level processing failures.
- Uses app-only authentication, supporting unattended administrative execution.

## Prerequisites

- Exchange Online PowerShell module (ExchangeOnlineManagement)
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
| `$TopN = 100`     | You can tweak this to your requirement                     |
| `$OutputFolder`   | Currently set to (`C:\Temp\MailboxReport`)                 |

`$TopN` controls the number of highest-consuming mailboxes included in the final report.

# [PnP PowerShell](#tab/pnpps)

```powershell

# ============================================================
# CONFIGURATION
# ============================================================

$ClientID   = "xxxxxxxxxxxxxxxxxxxxx"
$ThumbPrint = "xxxxxxxxxxxxxxxxxxxxx"
$Tenant     = "contoso.onmicrosoft.com"

$TopN = 100

# ============================================================
# OUTPUT CONFIGURATION
# ============================================================

$OutputFolder = "C:\Temp\MailboxReport"

if (-not (Test-Path -LiteralPath $OutputFolder)) {
    New-Item -Path $OutputFolder -ItemType Directory -Force | Out-Null
}

$TimeStamp = Get-Date -Format "yyyyMMdd_HHmmss"

$AssessmentFile = Join-Path `
    $OutputFolder `
    "LargestDeletedRecoverable_$TimeStamp.csv"

$LogFile = Join-Path `
    $OutputFolder `
    "LargestDeletedRecoverable_$TimeStamp.log"

# ============================================================
# LOGGING
# ============================================================

function Write-Log {
    param([string]$Message)

    $Line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message"

    Add-Content -Path $LogFile -Value $Line
    Write-Host $Line
}

# ============================================================
# CONNECT
# ============================================================

try {

    Import-Module ExchangeOnlineManagement -ErrorAction Stop

    Write-Log "Connecting to Exchange Online..."

    Connect-ExchangeOnline `
        -AppId $ClientID `
        -CertificateThumbprint $ThumbPrint `
        -Organization $Tenant `
        -ShowBanner:$false `
        -ErrorAction Stop

    Write-Log "Connected successfully."

    # ========================================================
    # GET USER MAILBOXES
    # ========================================================

    $Mailboxes = Get-EXOMailbox `
        -ResultSize Unlimited `
        -RecipientTypeDetails UserMailbox `
        -Properties DisplayName,UserPrincipalName,PrimarySmtpAddress `
        -ErrorAction Stop

    Write-Log "Found $(@($Mailboxes).Count) user mailboxes."

    # ========================================================
    # COLLECT DELETED / RECOVERABLE ITEMS
    # ========================================================

    $Results = foreach ($Mailbox in $Mailboxes) {

        try {

            # ------------------------------------------------
            # Deleted Items
            # ------------------------------------------------

            $DeletedFolders = Get-EXOMailboxFolderStatistics `
                -Identity $Mailbox.UserPrincipalName `
                -FolderScope DeletedItems `
                -ErrorAction Stop

            $DeletedBytes = 0
            $DeletedCount = 0

            foreach ($Folder in $DeletedFolders) {

                if ($Folder.FolderSize) {
                    $DeletedBytes += $Folder.FolderSize.Value.ToBytes()
                }

                if ($Folder.ItemsInFolder) {
                    $DeletedCount += $Folder.ItemsInFolder
                }
            }

            # ------------------------------------------------
            # Recoverable Items
            # ------------------------------------------------

            $RecoverableFolders = Get-EXOMailboxFolderStatistics `
                -Identity $Mailbox.UserPrincipalName `
                -FolderScope RecoverableItems `
                -ErrorAction Stop

            $RecoverableBytes = 0
            $RecoverableCount = 0

            foreach ($Folder in $RecoverableFolders) {

                if ($Folder.FolderSize) {
                    $RecoverableBytes += $Folder.FolderSize.Value.ToBytes()
                }

                if ($Folder.ItemsInFolder) {
                    $RecoverableCount += $Folder.ItemsInFolder
                }
            }

            # ------------------------------------------------
            # Combined
            # ------------------------------------------------

            $TotalBytes = `
                $DeletedBytes + $RecoverableBytes

            $TotalCount = `
                $DeletedCount + $RecoverableCount

            [PSCustomObject]@{
                DisplayName          = $Mailbox.DisplayName
                UserPrincipalName    = $Mailbox.UserPrincipalName
                PrimarySmtpAddress   = $Mailbox.PrimarySmtpAddress

                DeletedItemsGB      = [math]::Round(
                    $DeletedBytes / 1GB, 2
                )

                DeletedItemsCount   = $DeletedCount

                RecoverableItemsGB  = [math]::Round(
                    $RecoverableBytes / 1GB, 2
                )

                RecoverableItemsCount = $RecoverableCount

                TotalDeletedGB      = [math]::Round(
                    $TotalBytes / 1GB, 2
                )

                TotalDeletedCount   = $TotalCount
            }
        }
        catch {

            Write-Log `
                "WARNING: Failed to process $($Mailbox.UserPrincipalName): $($_.Exception.Message)"
        }
    }

    # ========================================================
    # TOP N
    # ========================================================

    $TopMailboxes = $Results |
        Sort-Object TotalDeletedGB -Descending |
        Select-Object -First $TopN

    $Rank = 1

    $TopMailboxes | ForEach-Object {

        $_ | Add-Member `
            -MemberType NoteProperty `
            -Name Rank `
            -Value $Rank

        $Rank++
    }

    # ========================================================
    # EXPORT
    # ========================================================

    $TopMailboxes |
        Select-Object `
            Rank,
            DisplayName,
            UserPrincipalName,
            PrimarySmtpAddress,
            DeletedItemsGB,
            DeletedItemsCount,
            RecoverableItemsGB,
            RecoverableItemsCount,
            TotalDeletedGB,
            TotalDeletedCount |
        Export-Csv `
            -Path $AssessmentFile `
            -NoTypeInformation `
            -Encoding UTF8

    # ========================================================
    # SUMMARY
    # ========================================================

    Write-Log "Assessment completed."
    Write-Log "Top $($TopMailboxes.Count) mailboxes exported."
    Write-Log "Report: $AssessmentFile"

    if ($TopMailboxes.Count -gt 0) {

        Write-Host ""
        Write-Host "Largest Deleted/Recoverable Items:"
        Write-Host ""
        Write-Host "$($TopMailboxes[0].DisplayName)"
        Write-Host "Total: $($TopMailboxes[0].TotalDeletedGB) GB"
        Write-Host "Deleted Items: $($TopMailboxes[0].DeletedItemsGB) GB"
        Write-Host "Recoverable Items: $($TopMailboxes[0].RecoverableItemsGB) GB"
        Write-Host ""
    }
}
catch {

    Write-Log "ERROR: $($_.Exception.Message)"
    throw
}
finally {

    Disconnect-ExchangeOnline `
        -Confirm:$false `
        -ErrorAction SilentlyContinue

    Write-Log "Disconnected from Exchange Online."
}


```

## Output

Two timestamped files are generated in the configured output directory:

> LargestDeletedRecoverable_yyyyMMdd_HHmmss.csv and LargestDeletedRecoverable_yyyyMMdd_HHmmss.log

### CSV Report Fields

| Field                   | Description                                                |
| ----------------------- | ---------------------------------------------------------- |
| `Rank`                  | Mailbox ranking based on total deleted/recoverable storage |
| `DisplayName`           | Mailbox display name                                       |
| `UserPrincipalName`     | Mailbox UPN                                                |
| `PrimarySmtpAddress`    | Primary SMTP address                                       |
| `DeletedItemsGB`        | Deleted Items storage in GB                                |
| `DeletedItemsCount`     | Number of Deleted Items                                    |
| `RecoverableItemsGB`    | Recoverable Items storage in GB                            |
| `RecoverableItemsCount` | Number of Recoverable Items                                |
| `TotalDeletedGB`        | Combined Deleted Items and Recoverable Items storage       |
| `TotalDeletedCount`     | Combined item count                                        |

### Logging & Error Handling

The script uses a dedicated logging function to record:

- Connection status
- Mailbox processing failures
- Assessment completion
- Report location
- Top mailbox information
- Fatal execution errors
- Exchange Online disconnection

A failure processing an individual mailbox is logged as a warning and does not terminate the entire assessment.

## Notes

- The report is limited to user mailboxes through RecipientTypeDetails UserMailbox.
- Folder statistics are queried individually for each mailbox, so execution time will increase with tenant size.
- Storage values are calculated from Exchange Online folder statistics and converted to GB.
- The script reports the top N mailboxes, rather than exporting every mailbox.
- Credentials and certificate private keys should not be embedded in the script or stored in source control.
- For production deployment, consider storing configuration separately and managing the certificate through an appropriate certificate store or automation platform.
- The generated CSV contains mailbox identifiers and should be handled according to your organisation's data-handling requirements.

## Contributors

|Author(s)|
|-----------|
|[Josiah Opiyo](https://github.com/ojopiyo)|

*Built with a focus on automation, governance, least privilege, and clean Microsoft 365 tenants - helping M365 admins gain visibility and reduce operational risk.*

## Version history

|Version|Date|Comments|
|-------|----|--------|
|1.0|September 21, 2026|Initial release|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
