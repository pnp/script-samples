

# Get Inactive SharePoint Sites Report

## Summary

This PowerShell script identifies SharePoint Online sites that have had no content activity for a defined period (default: 365 days). It generates a CSV report containing site metadata such as creation date, last activity date, storage usage, ownership, and sharing configuration, enabling administrators to assess inactive sites across the tenant efficiently.

## Why It Matters / Real-World Scenario

Over time, SharePoint tenants accumulate sites created for short-term projects, pilot initiatives, or teams that no longer exist. These inactive sites continue to consume storage, retain sensitive data, and remain accessible without oversight. During governance reviews or storage optimization initiatives, administrators need a reliable way to identify which sites are no longer actively used. This script provides a clear, data-driven view of inactive SharePoint sites so organizations can make informed decisions about archiving, retention, or deletion.

## Benefits
- Supports SharePoint lifecycle and archival strategies
- Identifies unused sites consuming storage and increasing cost
- Improves governance by highlighting outdated or abandoned sites
- Reduces security risk from forgotten content and permissions
- Produces audit-ready data for compliance and review exercises


# [PnP PowerShell](#tab/pnpps)

```powershell

param(
    [Parameter(Mandatory)]
    [string]$AdminUrl,

    [Parameter(Mandatory)]
    [string]$OutputFile,

    [int]$InactiveDays = 365
)

Connect-PnPOnline -Url $AdminUrl -Interactive

$cutoffDate = (Get-Date).AddDays(-$InactiveDays)

$sites = Get-PnPTenantSite -Detailed
$results = @()

foreach ($site in $sites) {
    try {
        if ($site.LastContentModifiedDate -lt $cutoffDate) {
            $results += [PSCustomObject]@{
                SiteUrl                  = $site.Url
                SiteName                 = $site.Title
                SiteType                 = $site.Template
                CreatedDate              = $site.CreationDate
                LastActivityDate         = $site.LastContentModifiedDate
                StorageUsageMB           = $site.StorageUsageCurrent
                Owner                    = $site.Owner
                SharingCapability        = $site.SharingCapability
            }
        }
    }
    catch {
        Write-Warning "Failed to process site: $($site.Url)"
    }
}

$results | Export-Csv -Path $OutputFile -NoTypeInformation -Encoding UTF8
Disconnect-PnPOnline


```


# [Usage](#tab/pnpps)

```powershell

.\Get-InactiveSharePointSites.ps1 `
    -AdminUrl "https://contoso-admin.sharepoint.com" `
    -OutputFile "C:\Reports\InactiveSharePointSites.csv" `
    -InactiveDays 365


```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***


## Output
The CSV report includes the following fields:
- SiteUrl
- SiteName
- SiteType
- CreatedDate
- LastActivityDate
- StorageUsageMB
- Owner
- SharingCapability

## Notes
- Activity is determined using LastContentModifiedDate, which reflects the last file or content change in the site
- The script is read-only and makes no changes to tenant data
- Designed for large tenants by relying on tenant-level queries rather than per-site connections

## Contributors

| Author(s) |
|-----------|
| [Josiah Opiyo](https://github.com/ojopiyo) |

*Built with a focus on automation, governance, least privilege, and clean Microsoft 365 tenants—helping M365 admins gain visibility and reduce operational risk.*

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-get-inactive-sites-report" aria-hidden="true" />