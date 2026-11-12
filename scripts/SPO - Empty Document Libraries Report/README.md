# SPO - Empty Document Libraries Report

## Summary

This PowerShell script connects to a SharePoint Online site using PnP PowerShell and certificate-based app-only authentication, retrieves all visible document libraries, and identifies libraries containing zero items.

The script exports the results to a timestamped CSV report, including library details, item counts, last modified dates, and execution audit information.

The report provides SharePoint administrators with visibility of unused or potentially redundant document libraries, supporting ongoing site governance, information lifecycle management, and storage optimisation.

## Why It Matters

Over time, SharePoint Online environments accumulate document libraries that are no longer actively used. These may originate from legacy projects, abandoned workspaces, previous migrations, or changes to business processes.

- Identifying empty document libraries helps administrators:
- Identify unused SharePoint resources.
- Support site housekeeping and governance activities.
- Highlight potential candidates for review, consolidation, or removal.
- Reduce unnecessary administrative overhead.
- Improve visibility of SharePoint site structures.

For example, an administrator managing a SharePoint Online site following a migration may use this report to identify libraries that were created but never populated with documents.

## Prerequisites

- PowerShell with the PnP.PowerShell module installed.
- A Microsoft Entra ID application configured for certificate-based authentication.
- The application configured with the required SharePoint permissions and administrator consent.
- Access to the target SharePoint site and document libraries.
- A valid certificate available to the executing account, with its thumbprint configured in the script.
- Write permissions to the local report directory.

## Configuration

Configure the variables at the beginning of the script:

| Variable          | Description                                                      |
| ----------------- | ---------------------------------------------------------------- |
| `$ClientID`       | Azure AD Application (Client) ID                                 |
| `$ThumbPrint`     | Certificate thumbprint                                           |
| `$Tenant`         | Microsoft 365 tenant name (e.g. `contoso.onmicrosoft.com`)       |
| `$SiteUrl`        | Your Site URL i.e. `https://contoso.sharepoint.com/sites/Finance`|
| `$OutputFolder`   | Destination path for the CSV report.                             |

# [PnP PowerShell](#tab/pnpps)

```powershell

#Requires -Modules PnP.PowerShell

# ==========================================================
# Configuration
# ==========================================================

$ClientID   = "xxxxxxxxxxxxxxxxx"
$ThumbPrint = "xxxxxxxxxxxxxxxxx" 
$Tenant     = "contoso.onmicrosoft.com"

$SiteUrl    = "https://contoso.sharepoint.com/sites/TestEnvironment"

# ==========================================================
# Audit Information
# ==========================================================

$RunBy       = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$RunDateTime = Get-Date

# ==========================================================
# Output
# ==========================================================

$OutputFolder = "C:\Temp\Report"

if (-not (Test-Path $OutputFolder))
{
    New-Item -Path $OutputFolder -ItemType Directory -Force | Out-Null
}

$TimeStamp = Get-Date -Format "yyyyMMdd_HHmmss"

$OutputFile = Join-Path $OutputFolder "EmptyLibrariesReport_$TimeStamp.csv"

# ==========================================================
# Connect
# ==========================================================

try
{
    Connect-PnPOnline `
        -Url $SiteUrl `
        -ClientId $ClientID `
        -Thumbprint $ThumbPrint `
        -Tenant $Tenant
}
catch
{
    Write-Host "Connection failed: $($_.Exception.Message)" -ForegroundColor Red
    return
}

# ==========================================================
# Get Libraries
# ==========================================================

Write-Host "Scanning document libraries..." -ForegroundColor Cyan

$Libraries = Get-PnPList | Where-Object {
    $_.BaseType -eq "DocumentLibrary" -and
    $_.Hidden -eq $false
}

$Results = foreach ($Library in $Libraries)
{
    if ($Library.ItemCount -eq 0)
    {
        [PSCustomObject]@{
            SiteUrl          = $SiteUrl
            LibraryName      = $Library.Title
            LibraryUrl       = $Library.RootFolder.ServerRelativeUrl
            ItemCount        = $Library.ItemCount
            LastItemModified = $Library.LastItemModifiedDate
            RunBy            = $RunBy
            RunDateTime      = $RunDateTime
        }
    }
}

# ==========================================================
# Export
# ==========================================================

$Results |
Sort-Object LibraryName |
Export-Csv `
    -Path $OutputFile `
    -NoTypeInformation `
    -Encoding UTF8

# ==========================================================
# Summary
# ==========================================================

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Empty Libraries Report Complete"
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Site Scanned      : $SiteUrl"
Write-Host "Empty Libraries   : $($Results.Count)"
Write-Host "Run By            : $RunBy"
Write-Host "Run Date          : $RunDateTime"
Write-Host ""
Write-Host "Report saved to:"
Write-Host $OutputFile -ForegroundColor Green

Disconnect-PnPOnline

```

## Usage

1. Install the PnP.PowerShell module if it is not already installed.
2. Register an Entra ID application with the appropriate SharePoint permissions.
3. Configure certificate-based authentication.
4. Update the application credentials and target SharePoint site URL.
5. Execute the script using an account with access to the certificate's private key.

## Output

The script generates a timestamped CSV file in the configured output directory.

Example filename:

> EmptyLibrariesReport_20261112_135200.csv

The CSV contains the following fields:

| Field                   | Description                                                |
| ----------------------- | ---------------------------------------------------------- |
| `SiteUrl`               | SharePoint Online site URL                                 |
| `LibraryName`           | Document library name                                      |
| `LibraryUrl`            | Server-relative URL of the library                         |
| `ItemCount`             | Number of items reported by SharePoint                     |
| `LastItemModified`      | Last recorded item modification date                       |
| `RunBy`                 | Windows identity executing the script                      |
| `RunDateTime`           | Date and time the report was generated                     |

## Execution Summary

Upon completion, the script displays:

- SharePoint site scanned.
- Number of empty document libraries identified.
- Executing Windows identity.
- Report execution date and time.
- CSV report output location.

## Notes

- Only visible SharePoint document libraries are included in the scan.
- Hidden libraries are excluded from the results.
- Libraries are identified as empty using the SharePoint ItemCount property.
- The report covers the specified SharePoint site only; subsites and other site collections are not automatically scanned.
- An empty library is not necessarily obsolete and should be reviewed before deletion.
- The script uses certificate-based authentication, avoiding interactive authentication during execution.
- The output directory is created automatically if it does not already exist.
- Timestamped filenames help preserve historical reports and prevent accidental overwriting.

## Contributors

|Author(s)|
|-----------|
|[Josiah Opiyo](https://github.com/ojopiyo)|

*Built with a focus on automation, governance, least privilege, and clean Microsoft 365 tenants - helping M365 admins gain visibility and reduce operational risk.*

## Version history

|Version|Date|Comments|
|-------|----|--------|
|1.0|November 12, 2026|Initial release|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
