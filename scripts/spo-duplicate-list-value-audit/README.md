# SPO - Duplicate List Value Audit

## Summary

This PowerShell script connects to SharePoint Online using certificate-based app-only authentication, retrieves items from a specified SharePoint list, and identifies duplicate values in a configured column.

The script excludes null, empty, and whitespace-only values, trims leading and trailing whitespace, and groups matching values to identify duplicates. It generates a CSV report containing the duplicate value, occurrence count, SharePoint list item ID, site URL, list name, and column name.

The report supports data-quality reviews, duplicate record investigations, and SharePoint list maintenance across Microsoft 365 environments.

## Why It Matters

SharePoint lists are frequently used to maintain operational records, batch processing logs, recipient details, and business-critical reference data. Duplicate values can lead to repeated processing, inconsistent reporting, and unreliable downstream workflows.

For example, an administrator can use this script to audit the Recipient column in a Batch Log list to identify recipients recorded against multiple list items. The resulting report provides the item IDs required to investigate and remediate duplicate records.

### Benefits

- **Data quality:** Identifies repeated values within a SharePoint list column.
- **Operational visibility:** Reports duplicate values and their occurrence counts.
- **Auditability:** Includes site, list, column, and item-level identifiers.
- **Automation-ready:** Uses certificate-based authentication suitable for unattended execution.
- **Scalability:** Retrieves list items using paged queries rather than a single unpaged request.
- **Export flexibility:** Produces a CSV file suitable for Excel, PowerShell-based analysis, and operational reporting.
- **Non-destructive auditing:** Reads list data and exports findings without modifying SharePoint records.

## Prerequisites

- PowerShell with the PnP.PowerShell module installed.
- A Microsoft Entra ID application configured for certificate-based authentication.
- The application configured with the required SharePoint permissions and administrator consent.
- Access to the target SharePoint site and list.
- A valid certificate available to the executing account, with its thumbprint configured in the script.
- Write permissions to the local report directory.

## Configuration

Configure the variables at the beginning of the script:

| Variable          | Description                                                |
| ----------------- | ---------------------------------------------------------- |
| `$ClientID`       | Azure AD Application (Client) ID                           |
| `$ThumbPrint`     | Certificate thumbprint                                     |
| `$Tenant`         | Microsoft 365 tenant name (e.g. `contoso.onmicrosoft.com`) |
| `$SiteUrl`        | Your Site URL i.e. `https://contoso.sharepoint.com/sites/A`|
| `$ListName`       | Your List Name i.e. `ListName`                             |
| `$ColumnName`     | List column to inspect for duplicate values                |
| `$ReportPath`     | Destination path for the CSV report.                       |

# [PnP PowerShell](#tab/pnpps)

```powershell

# =========================================================
# CONFIGURATION
# =========================================================

$ClientID   = "xxxxxxxxx"
$ThumbPrint = "xxxxxxxxx" 
$Tenant     = "contoso.onmicrosoft.com"

$SiteUrl    = "https://regulator.sharepoint.com/sites/SiteName"
$ListName   = "Batch Log"
$ColumnName = "Recipient"

$ReportPath = "C:\Temp\Duplicate-Audit.csv"

# =========================================================
# VALIDATION
# =========================================================

# Ensure the report folder exists
$ReportFolder = Split-Path -Path $ReportPath -Parent

if (-not (Test-Path -Path $ReportFolder)) {
    New-Item -Path $ReportFolder -ItemType Directory -Force | Out-Null
    Write-Host "Created report folder: $ReportFolder" -ForegroundColor Yellow
}


# =========================================================
# CONNECT TO SHAREPOINT ONLINE
# =========================================================

Write-Host "Connecting to SharePoint Online..." -ForegroundColor Cyan

try {
    Connect-PnPOnline `
        -Url $SiteUrl `
        -ClientId $ClientID `
        -Thumbprint $ThumbPrint `
        -Tenant $Tenant `
        -ErrorAction Stop

    Write-Host "Connected successfully." -ForegroundColor Green
}
catch {
    Write-Error "Unable to connect to SharePoint Online. $($_.Exception.Message)"
    exit 1
}


# =========================================================
# RETRIEVE LIST ITEMS
# =========================================================

Write-Host "Retrieving items from '$ListName'..." -ForegroundColor Cyan

try {
    $Items = Get-PnPListItem `
        -List $ListName `
        -Fields "ID", $ColumnName `
        -PageSize 1000 `
        -ErrorAction Stop

    Write-Host "Retrieved $($Items.Count) list items." -ForegroundColor Green
}
catch {
    Write-Error "Unable to retrieve items from '$ListName'. $($_.Exception.Message)"
    Disconnect-PnPOnline
    exit 1
}


# =========================================================
# PREPARE VALUES FOR DUPLICATE ANALYSIS
# =========================================================

$Values = foreach ($Item in $Items) {

    $ColumnValue = $Item.FieldValues[$ColumnName]

    # Ignore null, empty and whitespace-only values
    if ($null -ne $ColumnValue -and -not [string]::IsNullOrWhiteSpace([string]$ColumnValue)) {

        [PSCustomObject]@{
            ListItemID = $Item.Id
            Value      = ([string]$ColumnValue).Trim()
        }
    }
}


# =========================================================
# IDENTIFY DUPLICATES
# =========================================================

$DuplicateGroups = $Values |
    Group-Object -Property Value |
    Where-Object { $_.Count -gt 1 }


# =========================================================
# BUILD CSV REPORT
# =========================================================

$Report = foreach ($DuplicateGroup in $DuplicateGroups) {

    foreach ($DuplicateItem in $DuplicateGroup.Group) {

        [PSCustomObject]@{
            SiteUrl        = $SiteUrl
            ListName       = $ListName
            ColumnName     = $ColumnName
            DuplicateValue = $DuplicateGroup.Name
            Occurrences    = $DuplicateGroup.Count
            ListItemID     = $DuplicateItem.ListItemID
        }
    }
}


# =========================================================
# EXPORT REPORT
# =========================================================

if ($Report.Count -gt 0) {

    $Report |
        Sort-Object DuplicateValue, ListItemID |
        Export-Csv `
            -Path $ReportPath `
            -NoTypeInformation `
            -Encoding UTF8 `
            -Force

    Write-Host ""
    Write-Host "Duplicate audit completed successfully." -ForegroundColor Green
    Write-Host "Duplicate values found: $($DuplicateGroups.Count)" -ForegroundColor Yellow
    Write-Host "Duplicate list items found: $($Report.Count)" -ForegroundColor Yellow
    Write-Host "Report exported to: $ReportPath" -ForegroundColor Cyan
}

```

## Usage

1. Configure the application ID, certificate thumbprint, tenant, site URL, list name, column name, and report path.
2. Ensure the executing account can access the certificate's private key and write to the report directory.
3. Run the script in a PowerShell session with PnP.PowerShell installed.

Example:

> .\Get-SharePointDuplicateAudit.ps1

The script creates the report directory if it does not exist, connects to SharePoint Online, retrieves the list items, identifies duplicate values, and exports the findings.

## Output

**Default report:** C:\Temp\Duplicate-Audit.csv

The CSV contains one row for each list item associated with a duplicate value.

### CSV Report Fields

| Field                   | Description                                                |
| ----------------------- | ---------------------------------------------------------- |
| `SiteUrl`               | URL of the audited SharePoint site.                        |
| `ListName`              | Name of the SharePoint list.                               |
| `ColumnName`            | Column evaluated for duplicates.                           |
| `DuplicateValue`        | Normalised value identified as a duplicate.                |
| `Occurrences`           | Total number of list items containing that value.          |
| `ListItemID`            | ID of the individual SharePoint list item.                 |

## Duplicate Detection Logic

- Null, empty, and whitespace-only values are excluded.
- Leading and trailing whitespace is removed before grouping.
- Values are grouped by the configured column value.
- Only values occurring more than once are included in the report.
- Each matching list item is exported separately, with the total occurrence count repeated for its duplicate group.
- The report is sorted by duplicate value and list item ID.

## Notes

- Read-only operation: The script does not delete, merge, or modify duplicate records.
- Comparison behaviour: The script trims surrounding whitespace but does not explicitly normalise case or internal whitespace. PowerShell string grouping is generally case-insensitive by default, so values differing only by letter case may be grouped together.
- Large lists: -PageSize 1000 retrieves items in pages, but the script still collects the retrieved items in memory before performing duplicate analysis. For very large lists, consider streaming or batching the analysis and evaluating SharePoint list-view threshold and throttling constraints.

## Contributors

|Author(s)|
|-----------|
|[Josiah Opiyo](https://github.com/ojopiyo)|

*Built with a focus on automation, governance, least privilege, and clean Microsoft 365 tenants - helping M365 admins gain visibility and reduce operational risk.*

## Version history

|Version|Date|Comments|
|-------|----|--------|
|1.0|October 18, 2026|Initial release|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
