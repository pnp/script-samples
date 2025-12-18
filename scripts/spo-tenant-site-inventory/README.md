

# List of active sites in Tenant with Admins and storage used

## Summary

This script provides you the list of active sites in your tenant with their administrator and usage in MB.

## Why It Matters / Real-World Scenario

In many Microsoft 365 tenants, SharePoint sites can quickly grow in number, with varying levels of administrative access and external sharing. Without visibility, it’s easy for unused or inactive sites to remain accessible, or for administrators to have unnecessary access to sensitive content.

For example, an organization may have hundreds of departmental and project sites, some of which have never been used or have files shared externally. Security and compliance teams need to know:
- Which sites have active administrators.
- Which sites have sensitive data shared externally.
- How recently sites have been used.
- The age of sites for lifecycle and archiving decisions.

This script addresses these challenges by providing a single, comprehensive report. It allows administrators to identify inactive or outdated sites, review external sharing risks, and ensure that administrative permissions are appropriate. The insights generated help enforce least-privilege access, improve governance, and support compliance audits across the tenant.

# [PnP PowerShell](#tab/pnpps)

```powershell

param(
    [Parameter(Mandatory=$true)]
    [string]$AdminURL,

    [Parameter(Mandatory=$true)]
    [string]$OutputFile,

    [switch]$IncludeLastActivity,

    [switch]$IncludeExternalSharing
)

# Connect once to Admin Center
Connect-PnPOnline -Url $AdminURL -Interactive

# Get all SharePoint sites once
$sites = Get-PnPTenantSite -IncludeOneDriveSites -Detailed
$results = @()

foreach ($site in $sites) {
    try {
        Write-Host "Processing site: $($site.Url)" -ForegroundColor Green

        # Get site collection admins directly from the tenant-wide site object
        $admins = $site.Owner | ForEach-Object { $_.Title }

        # Storage usage from tenant site object
        $storageSize = $site.StorageUsageCurrent
        $createdDate = $site.CreationDate

        $lastActivity = $null
        $externalSharing = $null

        if ($IncludeLastActivity) {
            # Connect to site once to get last modified item
            Connect-PnPOnline -Url $site.Url -Interactive
            $lastItem = Get-PnPListItem -List "Documents" -PageSize 1 -SortField "Modified" -SortOrder Descending -ErrorAction SilentlyContinue
            if ($lastItem) {
                $lastActivity = $lastItem.FieldValues.Modified
            }
        }

        if ($IncludeExternalSharing) {
            Connect-PnPOnline -Url $site.Url -Interactive
            $externalFiles = Get-PnPSharingForSite -Detailed | Where-Object { $_.SharedWithUsers -match "External" }
            $externalSharing = if ($externalFiles) { "Yes" } else { "No" }
        }

        $siteInfo = [PSCustomObject]@{
            SiteUrl = $site.Url
            SiteName = $site.Title
            Administrators = $admins -join ";"
            StorageSizeMB = $storageSize
            CreatedDate = $createdDate
            LastActivity = $lastActivity
            ExternalSharing = $externalSharing
        }

        $results += $siteInfo
    }
    catch {
        Write-Host "Error processing site $($site.Url): $_" -ForegroundColor Red
    }
}

# Export once
$results | Export-Csv -Path $OutputFile -NoTypeInformation -Encoding UTF8
Disconnect-PnPOnline
Write-Host "Site inventory exported to $OutputFile" -ForegroundColor Green


```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

## Contributors

| Author(s) |
|-----------|
| [Diksha Bhura](https://github.com/Diksha-Bhura) |
| [Josiah Opiyo](https://github.com/ojopiyo) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-tenant-site-inventory" aria-hidden="true" />
