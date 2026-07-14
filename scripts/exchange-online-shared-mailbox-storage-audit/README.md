# Exchange Online Shared Mailbox Storage Audit (Threshold-Based Reporting Script)

## Professional Summary

This PowerShell script connects to Microsoft Exchange Online using app-based authentication and retrieves all shared mailboxes within a Microsoft 365 tenant. It calculates mailbox sizes in gigabytes, compares them against a defined storage threshold, and generates a structured CSV report containing only mailboxes exceeding that limit.

The script includes real-time progress tracking, error-resilient mailbox processing, and execution metadata such as total scan count and execution duration.

### What it does

Identifies shared mailboxes in Exchange Online that exceed a defined storage threshold (e.g., 40 GB), then exports detailed statistics (size, item count, last logon time) to a timestamped CSV file for administrative review and governance reporting.

## Why it matters

In enterprise Microsoft 365 environments, unmanaged mailbox growth can lead to performance degradation, compliance risks, and storage inefficiencies. Shared mailboxes are often overlooked because they do not have a direct user owner actively monitoring growth.

This script supports governance scenarios such as:

- Identifying oversized shared mailboxes impacting Exchange Online performance
- Supporting mailbox cleanup and archiving initiatives
- Preparing for tenant migrations or storage optimization projects
- Enforcing internal compliance policies on mailbox size limits
- Assisting service desk and messaging teams with proactive capacity management

## Benefits

- Proactive storage governance: Quickly identifies mailboxes exceeding defined thresholds
- Operational visibility: Provides clear reporting on mailbox growth and usage patterns
- Reduced risk: Helps prevent service disruption due to oversized mailboxes
- Audit readiness: Produces exportable CSV data suitable for compliance and reporting
- Automation-friendly: Can be integrated into scheduled tasks or monitoring workflows
- Improved efficiency: Eliminates manual mailbox size checking in Exchange Admin Center

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

# Requires -Modules ExchangeOnlineManagement

#==========================================
# Configuration
#==========================================

$ClientID   = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
$ThumbPrint = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$Tenant     = "contoso.onmicrosoft.com"

# Mailbox size threshold (GB)
$ThresholdGB = 40

# Output
$OutputFolder = "C:\Temp\Mailbox"
$TimeStamp    = Get-Date -Format "yyyyMMdd_HHmmss"

# Metadata
$StartTime = Get-Date

# Create output folder if it doesn't exist
if (!(Test-Path $OutputFolder))
{
    New-Item -ItemType Directory -Path $OutputFolder | Out-Null
}

$CsvFile = Join-Path $OutputFolder "SharedMailboxes_Over_${ThresholdGB}GB_$TimeStamp.csv"

try
{
    #==========================================
    # Connect to Exchange Online
    #==========================================

    Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan

    Connect-ExchangeOnline `
        -AppId $ClientID `
        -CertificateThumbprint $ThumbPrint `
        -Organization $Tenant `
        -ShowBanner:$false `
        -ErrorAction Stop

    Write-Host "Connected." -ForegroundColor Green

    #==========================================
    # Get Shared Mailboxes
    #==========================================

    Write-Host "Retrieving shared mailboxes..." -ForegroundColor Cyan

    $mailboxes = Get-EXOMailbox `
        -RecipientTypeDetails SharedMailbox `
        -ResultSize Unlimited `
        -Properties DisplayName,PrimarySmtpAddress

    $Results = @()
    $TotalMailboxes = $mailboxes.Count
    $Scanned = 0

    foreach ($mailbox in $mailboxes)
    {
        $Scanned++

        Write-Progress `
            -Activity "Scanning shared mailboxes" `
            -Status "$Scanned of $TotalMailboxes : $($mailbox.DisplayName)" `
            -PercentComplete (($Scanned / $TotalMailboxes) * 100)

        Write-Host "Checking $($mailbox.DisplayName)..."

        try
        {
            $stats = Get-EXOMailboxStatistics -Identity $mailbox.UserPrincipalName -ErrorAction Stop

            $SizeBytes = $stats.TotalItemSize.Value.ToBytes()
            $SizeGB = [math]::Round(($SizeBytes / 1GB),2)

            if ($SizeGB -ge $ThresholdGB)
            {
                $Results += [PSCustomObject]@{
                    DisplayName   = $mailbox.DisplayName
                    EmailAddress  = $mailbox.PrimarySmtpAddress
                    SizeGB        = $SizeGB
                    ItemCount     = $stats.ItemCount
                    LastLogonTime = $stats.LastLogonTime
                }

                Write-Host "  -> $SizeGB GB" -ForegroundColor Yellow
            }
        }
        catch
        {
            Write-Warning "Failed to retrieve statistics for '$($mailbox.DisplayName)': $($_.Exception.Message)"
        }
    }

    Write-Progress -Activity "Scanning shared mailboxes" -Completed

    #==========================================
    # Export Results
    #==========================================

    if ($Results.Count -gt 0)
    {
        $Results |
            Sort-Object SizeGB -Descending |
            Export-Csv -Path $CsvFile -NoTypeInformation -Encoding UTF8

        Write-Host ""
        Write-Host "==========================================" -ForegroundColor Green
        Write-Host "Report complete." -ForegroundColor Green
        Write-Host "Total shared mailboxes scanned : $Scanned"
        Write-Host "Mailboxes over $ThresholdGB GB : $($Results.Count)"
        Write-Host "CSV saved to:"
        Write-Host $CsvFile -ForegroundColor Cyan
        Write-Host "=========================================="
    }
    else
    {
        Write-Host ""
        Write-Host "==========================================" -ForegroundColor Yellow
        Write-Host "No shared mailboxes were found over $ThresholdGB GB."
        Write-Host "Total shared mailboxes scanned : $Scanned"
        Write-Host "=========================================="
    }
}
catch
{
    Write-Error "Script failed: $($_.Exception.Message)"
}
finally
{
    $EndTime = Get-Date

    Write-Host ""
    Write-Host "Started : $StartTime"
    Write-Host "Finished: $EndTime"
    Write-Host ("Elapsed : {0:hh\:mm\:ss}" -f ($EndTime - $StartTime))

    Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
}

```

## Output

### CSV Report Location

C:\Temp\Mailbox\

### File Naming Convention

SharedMailboxes_Over_<ThresholdGB>GB_<Timestamp>.csv

### Report Contents

- Display Name
- Primary SMTP Address
- Mailbox Size (GB)
- Item Count
- Last Logon Time

## Notes

- The script uses Get-EXOMailbox and Get-EXOMailboxStatistics, which are optimized for Exchange Online performance.
- Progress tracking is displayed during execution for large tenant environments.
- Failed mailbox queries are handled gracefully and logged as warnings without interrupting execution.
- If no mailboxes exceed the threshold, a controlled "No results" output is displayed instead of generating an empty file.
- Execution metadata (start time, end time, duration) is included for audit and troubleshooting purposes.

## Contributors

|Author(s) |
|-----------|
|[Josiah Opiyo](https://github.com/ojopiyo)|

*Built with a focus on automation, governance, least privilege, and clean Microsoft 365 tenants-helping M365 admins gain visibility and reduce operational risk.*

## Version history

|Version|Date|Comments|
|-------|----|--------|
|1.0|July 05, 2026|Initial release|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/exchange-online-shared-mailbox-storage-audit" aria-hidden="true" />
