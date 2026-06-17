# SharePoint Online Recycle Bin Capacity and Retention Report (All Sites)

## Professional Summary

The SharePoint Online Recycle Bin Capacity and Retention Report provides centralized visibility into recycle bin utilization and retention status across all site collections within a Microsoft 365 tenant.

Using PnP PowerShell with app-only authentication, the script connects to each site collection, analyzes both First-Stage and Second-Stage Recycle Bin contents, calculates storage consumption, identifies upcoming purge events based on SharePoint Online retention timelines, and generates detailed CSV reports for operational review and governance reporting.

The solution enables administrators to monitor deleted content lifecycle management, identify storage consumption trends, and proactively manage data approaching permanent deletion.

## Why it matters

Organizations frequently receive requests to recover deleted files, folders, lists, or libraries from SharePoint Online. However, once content exceeds the recycle bin retention period, recovery is no longer possible.

Without centralized reporting, administrators often lack visibility into:

- Which sites contain large amounts of deleted content
- When recycle bin items will be permanently purged
- Which sites may require proactive owner notification
- How much tenant storage is consumed by deleted content

This report enables IT and governance teams to identify upcoming purge events, monitor storage utilization, and support recovery requests before content is permanently removed.

## Benefits

- Provides tenant-wide visibility into SharePoint Online recycle bin usage
- Identifies content nearing permanent deletion
- Supports governance and lifecycle management initiatives
- Assists with SharePoint storage capacity planning
- Helps reduce the risk of missed recovery opportunities
- Enables proactive communication with site owners
- Highlights sites with excessive deleted-content accumulation
- Produces exportable CSV reports for auditing and reporting purposes
- Supports operational health reviews and compliance monitoring

## Prerequisites

- PowerShell 7.x or Windows PowerShell 5.1
- PnP PowerShell module
- SharePoint Administrator permissions
- Microsoft Entra ID App Registration configured for certificate-based authentication
- Appropriate SharePoint Online application permissions granted and consented

## Usage

1. Configure tenant-specific values:
    - Admin Center URL
    - Client ID
    - Certificate Thumbprint
    - Tenant Name
    - Output Folder
2. Execute the script using a privileged administrative account context.
3. Review the generated CSV reports.

# [PnP PowerShell](#tab/pnpps)

```powershell


# ==========================================
# Recycle Bin Report - All Sites
# Adds: Time-left (days) & next purge dates per bin
# ==========================================

# ---------- Configuration ----------
$AdminCenterUrl = "https://contoso-admin.sharepoint.com"
$ClientID       = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$ThumbPrint     = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"  
$Tenant         = "contoso.onmicrosoft.com"  

$OutputFolder   = "C:\Temp\Recycle_Bin"
$Timestamp      = (Get-Date).ToString("yyyyMMdd_HHmmss")
$MainReportFile = Join-Path $OutputFolder "RecycleBinReport_$Timestamp.csv"
$SummaryFile    = Join-Path $OutputFolder "RecycleBinReport_Summary_$Timestamp.csv"

# Constants
$RetentionDays = 93
$now = Get-Date

# ---------- Connect to Admin Center ----------
Connect-PnPOnline -Url $AdminCenterUrl -ClientId $ClientID -Thumbprint $ThumbPrint -Tenant $Tenant
$AdminContext = Get-PnPContext

# Ensure output folder exists
if (-not (Test-Path -Path $OutputFolder)) {
    New-Item -Path $OutputFolder -ItemType Directory -Force | Out-Null
}

# ---------- Get all sites ----------
$sites = Get-PnPTenantSite
$siteCount = $sites.Count
Write-Host "Discovered $siteCount site(s)." -ForegroundColor Cyan

# ---------- Prep output ----------
$report = New-Object System.Collections.Generic.List[object]
$idx = 0

foreach ($site in $sites) {
    $idx++
    Write-Progress -Activity "Processing sites" -Status "[$idx/$siteCount] $($site.Url)" -PercentComplete (($idx / $siteCount) * 100)

    Write-Host "Processing $($site.Url)" -ForegroundColor Cyan

    try {
        # Connect to the target site using App-Only
        Connect-PnPOnline -Url $site.Url -ClientId $ClientID -Thumbprint $ThumbPrint -Tenant $Tenant

        # ----- First-stage recycle bin -----
        $firstItems = Get-PnPRecycleBinItem
        $firstSize  = ($firstItems | Measure-Object -Property Size -Sum).Sum
        if ($null -eq $firstSize) { $firstSize = 0 }

        # Compute time-left and next purge stats (first stage)
        $firstStats = $null
        if ($firstItems -and $firstItems.Count -gt 0) {
            $firstStats = $firstItems | ForEach-Object {
                $deleted = $_.DeletedDate
                $purge   = $deleted.AddDays($RetentionDays)
                $daysLeft = [int][math]::Ceiling(($purge - $now).TotalDays)
                if ($daysLeft -lt 0) { $daysLeft = 0 } # clamp at 0
                [pscustomobject]@{
                    DaysLeft = $daysLeft
                    PurgeOn  = $purge
                }
            }
        }

        $firstMinDaysLeft    = if ($firstStats) { ($firstStats | Measure-Object -Property DaysLeft -Minimum).Minimum } else { $null }
        $firstNextPurge      = if ($firstStats) { ($firstStats | Sort-Object PurgeOn | Select-Object -First 1 -ExpandProperty PurgeOn) } else { $null }
        $firstExpiring7      = if ($firstStats) { ($firstStats | Where-Object { $_.DaysLeft -le 7 -and $_.DaysLeft -gt 0 }).Count } else { 0 }
        $firstExpiring30     = if ($firstStats) { ($firstStats | Where-Object { $_.DaysLeft -le 30 -and $_.DaysLeft -gt 0 }).Count } else { 0 }

        # ----- Second-stage recycle bin -----
        $secondItems = Get-PnPRecycleBinItem -SecondStage
        $secondSize  = ($secondItems | Measure-Object -Property Size -Sum).Sum
        if ($null -eq $secondSize) { $secondSize = 0 }

        # Compute time-left and next purge stats (second stage)
        $secondStats = $null
        if ($secondItems -and $secondItems.Count -gt 0) {
            $secondStats = $secondItems | ForEach-Object {
                $deleted = $_.DeletedDate
                $purge   = $deleted.AddDays($RetentionDays)
                $daysLeft = [int][math]::Ceiling(($purge - $now).TotalDays)
                if ($daysLeft -lt 0) { $daysLeft = 0 }
                [pscustomobject]@{
                    DaysLeft = $daysLeft
                    PurgeOn  = $purge
                }
            }
        }

        $secondMinDaysLeft   = if ($secondStats) { ($secondStats | Measure-Object -Property DaysLeft -Minimum).Minimum } else { $null }
        $secondNextPurge     = if ($secondStats) { ($secondStats | Sort-Object PurgeOn | Select-Object -First 1 -ExpandProperty PurgeOn) } else { $null }
        $secondExpiring7     = if ($secondStats) { ($secondStats | Where-Object { $_.DaysLeft -le 7 -and $_.DaysLeft -gt 0 }).Count } else { 0 }
        $secondExpiring30    = if ($secondStats) { ($secondStats | Where-Object { $_.DaysLeft -le 30 -and $_.DaysLeft -gt 0 }).Count } else { 0 }

        # Convert to MB
        $firstMB  = [math]::Round(($firstSize / 1MB), 2)
        $secondMB = [math]::Round(($secondSize / 1MB), 2)
        $totalMB  = [math]::Round(($firstMB + $secondMB), 2)

        # Add success row
        $report.Add([PSCustomObject]@{
            SiteUrl                   = $site.Url
            FirstStageMB              = [double]$firstMB
            SecondStageMB             = [double]$secondMB
            TotalRecycleBinMB         = [double]$totalMB
            MinDaysLeftFirstStage     = $firstMinDaysLeft
            NextPurgeDateFirstStage   = if ($firstNextPurge) { $firstNextPurge.ToString("yyyy-MM-dd HH:mm") } else { $null }
            Expiring7DaysFirstStage   = $firstExpiring7
            Expiring30DaysFirstStage  = $firstExpiring30
            MinDaysLeftSecondStage    = $secondMinDaysLeft
            NextPurgeDateSecondStage  = if ($secondNextPurge) { $secondNextPurge.ToString("yyyy-MM-dd HH:mm") } else { $null }
            Expiring7DaysSecondStage  = $secondExpiring7
            Expiring30DaysSecondStage = $secondExpiring30
            Status                    = "Success"
        })

        Write-Host ("✔ {0}: {1} MB total | Next purge: F1 {2} / F2 {3}" -f $site.Url, $totalMB, $firstNextPurge, $secondNextPurge) -ForegroundColor Green
    }
    catch {
        # Capture a clear reason
        $reason = $_.Exception.Message
        if ($null -ne $_.Exception.InnerException -and -not [string]::IsNullOrWhiteSpace($_.Exception.InnerException.Message)) {
            $reason = $_.Exception.InnerException.Message
        }

        # Add failure row with zeroed sizes + reason
        $report.Add([PSCustomObject]@{
            SiteUrl                   = $site.Url
            FirstStageMB              = [double]0
            SecondStageMB             = [double]0
            TotalRecycleBinMB         = [double]0
            MinDaysLeftFirstStage     = $null
            NextPurgeDateFirstStage   = $null
            Expiring7DaysFirstStage   = $null
            Expiring30DaysFirstStage  = $null
            MinDaysLeftSecondStage    = $null
            NextPurgeDateSecondStage  = $null
            Expiring7DaysSecondStage  = $null
            Expiring30DaysSecondStage = $null
            Status                    = $reason
        })

        Write-Host "❌ $($site.Url): $reason" -ForegroundColor Red
    }
    finally {
        # Restore Admin context for next tenant operation
        Set-PnPContext -Context $AdminContext
    }
}

# ---------- Summary ----------
$attempted    = $siteCount
$successCount = ($report | Where-Object { $_.Status -eq "Success" }).Count
$failureCount = $attempted - $successCount

$sumFirstMB   = [math]::Round((($report | Where-Object { $_.Status -eq "Success" }) | Measure-Object -Property FirstStageMB -Sum).Sum, 2)
$sumSecondMB  = [math]::Round((($report | Where-Object { $_.Status -eq "Success" }) | Measure-Object -Property SecondStageMB -Sum).Sum, 2)
$sumTotalMB   = [math]::Round((($report | Where-Object { $_.Status -eq "Success" }) | Measure-Object -Property TotalRecycleBinMB -Sum).Sum, 2)

$summary = [PSCustomObject]@{
    AttemptedSites       = $attempted
    SuccessSites         = $successCount
    FailedSites          = $failureCount
    TotalFirstStageMB    = $sumFirstMB
    TotalSecondStageMB   = $sumSecondMB
    TotalRecycleBinMB    = $sumTotalMB
    GeneratedOnUtc       = (Get-Date).ToUniversalTime().ToString("s") + "Z"
}

# ---------- Export ----------
$report  | Export-Csv -Path $MainReportFile -NoTypeInformation -Encoding UTF8
$summary | Export-Csv -Path $SummaryFile    -NoTypeInformation -Encoding UTF8

Write-Host "`nMain report saved:   $MainReportFile" -ForegroundColor Cyan
Write-Host "Summary report saved: $SummaryFile" -ForegroundColor Cyan

# ---------- Console Summary ----------
Write-Host "`n===== SUMMARY =====" -ForegroundColor Yellow
$summary | Format-List
Write-Host "`nFailed sites (if any):" -ForegroundColor Yellow
$report | Where-Object { $_.Status -ne "Success" } | Select-Object SiteUrl, Status | Format-Table -AutoSize


```

## Output

### Detailed Report

#### RecycleBinReport_yyyyMMdd_HHmmss.csv

Contains one row per site collection with:
- Site URL
- First-Stage Recycle Bin Size (MB)
- Second-Stage Recycle Bin Size (MB)
- Total Recycle Bin Size (MB)
- Earliest purge date
- Minimum days remaining before purge
- Items expiring within 7 days
- Items expiring within 30 days
- Processing status

### Summary Report

#### RecycleBinReport_Summary_yyyyMMdd_HHmmss.csv

Provides:
- Total sites processed
- Successful site scans
- Failed site scans
- Aggregate First-Stage storage usage
- Aggregate Second-Stage storage usage
- Total recycle bin storage consumption
- Report generation timestamp

## Notes

- The script assumes the standard SharePoint Online recycle bin retention period of 93 days.
- Purge dates are calculated using the item's deletion timestamp plus the configured retention period.
- Site processing continues even if individual sites encounter errors.
- Failed sites are captured within the report for troubleshooting and remediation.
- Results may vary slightly from actual purge execution timing due to Microsoft 365 background processing.

## Contributors

 Author(s) |
-----------|
 [Josiah Opiyo](https://github.com/ojopiyo) |

*Built with a focus on automation, governance, least privilege, and clean Microsoft 365 tenants-helping M365 admins gain visibility and reduce operational risk.*

## Version history

Version|Date|Comments
-------|----|--------
1.0|June 17, 2026|Initial release

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
