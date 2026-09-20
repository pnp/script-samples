# Exchange Online Mailbox Size Assessment

## Professional Summary

PowerShell script that connects to Exchange Online using **app-only certificate authentication**, retrieves all user mailboxes, collects mailbox statistics, and identifies the **top 100 largest mailboxes**.

The script exports mailbox size, item count, logon information, and mailbox identity details to a timestamped CSV report. Operational activity and mailbox-level retrieval errors are recorded in a timestamped log file.

## Why It Matters

Large mailboxes can affect **Exchange Online storage management, retention planning, migration activities, and mailbox lifecycle decisions**.

This assessment provides administrators with a repeatable way to identify the largest user mailboxes in an organisation. The resulting data can be used to investigate unusually large mailboxes, review retention and deletion requirements, and support capacity or migration planning.

### Benefits

- **Identifies high-volume mailboxes** - Quickly highlights the largest user mailboxes.
- **Supports storage management** - Provides mailbox size and item-count data for operational analysis.
- **Enables proactive administration** - Helps administrators identify mailboxes requiring further investigation.
- **Supports migration planning** - Provides useful sizing information before mailbox migrations or tenant-related projects.
- **Provides auditability** - Timestamped CSV and log files preserve the results of each assessment.
- **Handles individual failures** - Failure to retrieve statistics for one mailbox does not stop processing of the remaining mailboxes.
- **Automation-ready authentication** - Uses certificate-based app authentication rather than interactive administrator credentials.

## Prerequisites

- Exchange Online PowerShell module: **ExchangeOnlineManagement**
- Microsoft Entra ID application registration
- Certificate configured for application authentication
- Appropriate Exchange Online application permissions and access configuration
- PowerShell environment capable of running the Exchange Online module
- Permission to create/write to the configured output directory

## Usage

Update the configuration values before execution:

| Variable          | Description                                                |
| ----------------- | ---------------------------------------------------------- |
| `$ClientID`       | Azure AD Application (Client) ID                           |
| `$ThumbPrint`     | Certificate thumbprint                                     |
| `$Tenant`         | Microsoft 365 tenant name (e.g. `contoso.onmicrosoft.com`) |
| `$TopN = 100`     | You can tweak this to your requirement                     |
| `$OutputFolder`   | Currently set to (`C:\Temp\MailboxReport`)                 |

Run the script from a PowerShell session with access to the configured certificate.

The `$TopN` value can be changed to control how many of the largest mailboxes are included in the report.

# [PowerShell](#tab/ps)

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
    "LargestMailboxes_$TimeStamp.csv"

$LogFile = Join-Path `
    $OutputFolder `
    "LargestMailboxes-Assessment_$TimeStamp.log"

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
    # GET MAILBOXES
    # ========================================================

    Write-Log "Retrieving mailboxes..."

    $Mailboxes = Get-EXOMailbox `
        -ResultSize Unlimited `
        -RecipientTypeDetails UserMailbox `
        -Properties DisplayName,UserPrincipalName,PrimarySmtpAddress `
        -ErrorAction Stop

    Write-Log "Found $(@($Mailboxes).Count) user mailboxes."

    # ========================================================
    # GET STATISTICS
    # ========================================================

    $Results = foreach ($Mailbox in $Mailboxes) {

        try {

            $Stats = Get-EXOMailboxStatistics `
                -Identity $Mailbox.UserPrincipalName `
                -ErrorAction Stop

            if ($Stats.TotalItemSize) {

                $SizeBytes = $Stats.TotalItemSize.Value.ToBytes()

                [PSCustomObject]@{
                    DisplayName        = $Mailbox.DisplayName
                    UserPrincipalName  = $Mailbox.UserPrincipalName
                    PrimarySmtpAddress = $Mailbox.PrimarySmtpAddress
                    MailboxSizeGB     = [math]::Round($SizeBytes / 1GB, 2)
                    ItemCount         = $Stats.ItemCount
                    LastLogonTime     = $Stats.LastLogonTime
                }
            }
        }
        catch {

            Write-Log `
                "WARNING: Failed to retrieve $($Mailbox.UserPrincipalName): $($_.Exception.Message)"
        }
    }

    # ========================================================
    # TOP N
    # ========================================================

    $TopMailboxes = $Results |
        Sort-Object MailboxSizeGB -Descending |
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
            MailboxSizeGB,
            ItemCount,
            LastLogonTime |
        Export-Csv `
            -Path $AssessmentFile `
            -NoTypeInformation `
            -Encoding UTF8

    Write-Log "Top $($TopMailboxes.Count) largest mailboxes exported."

    Write-Host ""
    Write-Host "Largest mailbox:"
    Write-Host "$($TopMailboxes[0].DisplayName) - $($TopMailboxes[0].MailboxSizeGB) GB"
    Write-Host ""
    Write-Host "Report: $AssessmentFile"
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

The script generates two timestamped files:

### CSV Assessment Report

> LargestMailboxes_yyyyMMdd_HHmmss.csv

Contains:

- Rank
- Display name
- User principal name
- Primary SMTP address
- Mailbox size in GB
- Item count
- Last logon time

### Assessment Log

> LargestMailboxes-Assessment_yyyyMMdd_HHmmss.log

Records:

- Exchange Online connection status
- Number of mailboxes discovered
- Mailbox processing warnings
- Export status
- Errors encountered during execution
- Exchange Online disconnection status

## Processing Overview

1. Creates the configured output directory if required.
2. Imports the Exchange Online PowerShell module.
3. Establishes an authenticated Exchange Online session.
4. Retrieves all **UserMailbox** objects.
5. Retrieves statistics for each mailbox.
6. Converts mailbox size to GB.
7. Sorts mailboxes by size in descending order.
8. Selects the configured top N mailboxes.
9. Assigns a ranking to each mailbox.
10. Exports the assessment to CSV.
11. Disconnects from Exchange Online.

## Notes

- The assessment covers **user mailboxes only**; shared, room, equipment, and other recipient types are excluded.
- Mailbox statistics are retrieved individually, so larger tenants may require additional execution time.
- Individual mailbox statistic failures are logged and do not terminate the overall assessment.
- The script uses **Get-EXOMailbox** and **Get-EXOMailboxStatistics**, which are appropriate Exchange Online REST-backed cmdlets for modern Exchange Online administration.
- Application authentication should use a certificate stored and managed according to the organisation's security standards.
- The script currently contains the application ID and certificate thumbprint in its configuration section; production implementations should consider securely managing configuration and secrets rather than embedding sensitive authentication material directly in scripts.

***

## Contributors

| Author(s)|
|-----------|
|[Josiah Opiyo](https://github.com/ojopiyo)|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/exchange-mailbox-size-assessment" aria-hidden="true" />
