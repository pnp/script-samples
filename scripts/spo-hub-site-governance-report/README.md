# SharePoint Hub Site Governance Report

## Summary

This PowerShell script generates a SharePoint Online Hub Site governance report using PnP.PowerShell and certificate-based app-only authentication. It connects to the SharePoint Admin Centre, retrieves all registered Hub Sites and their associated sites, identifies Site Collection Administrators, captures audit information such as the execution identity and timestamp, and exports the results to a timestamped CSV file. The script also includes error handling to ensure that issues retrieving information from individual Hub Sites do not prevent the overall report from completing.

## Why It Matters

As Microsoft 365 environments grow, SharePoint Hub Sites can become difficult to govern manually. Administrators need visibility into which sites are acting as Hubs, who administers those Hubs, and which sites are currently associated with them.

This report provides a repeatable tenant-level inventory that can support scenarios such as:

- Identifying Hub Sites without associated sites.
- Reviewing Hub Site administrative ownership.
- Validating Hub-to-site associations.
- Supporting SharePoint information architecture reviews.
- Preparing for tenant governance or restructuring exercises.
- Identifying ownership gaps or unexpected associations.
- Providing evidence for periodic governance reviews.

## Prerequisites

- PnP PowerShell installed.
- An Azure AD App Registration configured for certificate authentication.
- Certificate installed on the execution host.
- Appropriate SharePoint Online application permissions with admin consent.
- SharePoint Administrator or Global Administrator equivalent permissions for the registered application.

## Configuration

Update the following variables before execution:

| Variable          | Description                                                |
| ----------------- | ---------------------------------------------------------- |
| `$AdminURL`       | SharePoint Online Tenant Administration URL                |
| `$ClientID`       | Azure AD Application (Client) ID                           |
| `$ThumbPrint`     | Certificate thumbprint                                     |
| `$Tenant`         | Microsoft 365 tenant name (e.g. `contoso.onmicrosoft.com`) |

# [PnP PowerShell](#tab/pnpps)

```powershell
#Requires -Modules PnP.PowerShell

# ==========================================================
# Configuration
# ==========================================================

$ClientID   = "xxxxxxxxxxxxxxxxxxx"
$ThumbPrint = "xxxxxxxxxxxxxxxxxxxx" 
$Tenant     = "contoso.onmicrosoft.com"

$AdminUrl = "https://contoso-admin.sharepoint.com"

# ==========================================================
# Audit Information
# ==========================================================

$RunBy       = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$RunDateTime = Get-Date

# ==========================================================
# Report Location
# ==========================================================

$ReportFolder = "C:\Temp\Report"

if (-not (Test-Path $ReportFolder))
{
    New-Item -Path $ReportFolder -ItemType Directory -Force | Out-Null
}

$TimeStamp = Get-Date -Format "yyyyMMdd_HHmmss"

$ReportFile = Join-Path $ReportFolder "HubSiteGovernanceReport_$TimeStamp.csv"

# ==========================================================
# Connect to Admin Centre
# ==========================================================

Write-Host "Connecting to SharePoint Admin Centre..." -ForegroundColor Cyan

Connect-PnPOnline `
    -Url $AdminUrl `
    -ClientId $ClientID `
    -Thumbprint $ThumbPrint `
    -Tenant $Tenant

# ==========================================================
# Get Hub Sites
# ==========================================================

Write-Host "Retrieving Hub Sites..." -ForegroundColor Cyan

$HubSites = Get-PnPHubSite

$Results = [System.Collections.Generic.List[object]]::new()

foreach ($Hub in $HubSites)
{
    Write-Host "Processing Hub: $($Hub.Title)" -ForegroundColor Yellow

    # ------------------------------------------------------
    # Get Hub Owner(s)
    # ------------------------------------------------------

    $HubOwners = "Unavailable"

    try
    {
        Connect-PnPOnline `
            -Url $Hub.SiteUrl `
            -ClientId $ClientID `
            -Thumbprint $ThumbPrint `
            -Tenant $Tenant

        $Admins = Get-PnPSiteCollectionAdmin -ErrorAction SilentlyContinue

        if ($Admins)
        {
            $HubOwners = ($Admins.Email | Sort-Object -Unique) -join "; "
        }
    }
    catch
    {
        $HubOwners = "Unable to retrieve"
    }

    # ------------------------------------------------------
    # Get Associated Sites
    # ------------------------------------------------------

    try
    {
        $AssociatedSites = Get-PnPHubSiteChild -Identity $Hub.SiteUrl
    }
    catch
    {
        Write-Warning "Unable to retrieve associated sites for $($Hub.Title)"
        continue
    }

    if (!$AssociatedSites)
    {
        $Results.Add(
            [PSCustomObject]@{
                HubName            = $Hub.Title
                HubUrl             = $Hub.SiteUrl
                HubId              = $Hub.Id
                HubOwners          = $HubOwners

                AssociatedSite     = "No Associated Sites"
                AssociatedSiteUrl  = ""

                RunBy              = $RunBy
                RunDateTime        = $RunDateTime
            }
        )

        continue
    }

    foreach ($Child in $AssociatedSites)
    {
        $ChildTitle = $null
        $ChildUrl   = $null

        if ($Child.PSObject.Properties['Title'])
        {
            $ChildTitle = $Child.Title
        }

        if ($Child.PSObject.Properties['Url'])
        {
            $ChildUrl = $Child.Url
        }
        elseif ($Child.PSObject.Properties['SiteUrl'])
        {
            $ChildUrl = $Child.SiteUrl
        }

        $Results.Add(
            [PSCustomObject]@{
                HubName            = $Hub.Title
                HubUrl             = $Hub.SiteUrl
                HubId              = $Hub.Id
                HubOwners          = $HubOwners

                AssociatedSite     = $ChildTitle
                AssociatedSiteUrl  = $ChildUrl

                RunBy              = $RunBy
                RunDateTime        = $RunDateTime
            }
        )
    }
}

# ==========================================================
# Export
# ==========================================================

$Results |
Sort-Object HubName, AssociatedSite |
Export-Csv `
    -Path $ReportFile `
    -NoTypeInformation `
    -Encoding UTF8

# ==========================================================
# Summary
# ==========================================================

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "Hub Site Governance Report Complete"
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""

Write-Host "Hub Sites Found     : $($HubSites.Count)"
Write-Host "Rows Exported       : $($Results.Count)"
Write-Host "Run By              : $RunBy"
Write-Host "Run Date            : $RunDateTime"
Write-Host ""
Write-Host "Report:"
Write-Host $ReportFile -ForegroundColor Green

Disconnect-PnPOnline

```

## Usage

Run the script from a PowerShell session where the required certificate and PnP.PowerShell module are available.

The generated report follows this naming convention:

> HubSiteGovernanceReport_yyyyMMdd_HHmmss.csv

## Output

The CSV contains one row per Hub Site / associated-site relationship.

| Column             | Description                                                |
| -----------------  | ---------------------------------------------------------- |
| `HubName`          | Display name of the Hub Site                               |
| `HubUrl`           | URL of the Hub Site                                        |
| `HubId`            | Unique Hub Site identifier                                 |
| `HubOwners`        | Email addresses of Site Collection Administrators          |
| `AssociatedSite`   | Title of the associated site                               |
| `AssociatedSiteUrl`| Title of the associated site                               |
| `RunBy`            | Title of the associated site                               |
| `RunDateTime`      | Title of the associated site                               |

## Notes

- `$HubOwners` is populated from **Site Collection Administrator** accounts; it should not be interpreted as a dedicated SharePoint Hub Site ownership property.
- The script reconnects to each Hub Site to retrieve administrator information.
- If administrator retrieval fails, the report records **Unable to retrieve** rather than terminating.
- If associated-site retrieval fails, the Hub Site is skipped and a warning is displayed.
-**Export-Csv** produces a flat dataset suitable for downstream reporting.
- For large tenants or scheduled execution, consider running the script under a dedicated automation identity rather than an interactive administrator account.
- Certificate-based authentication should use an appropriately secured certificate and least-privilege application permissions.

## Contributors

|Author(s)|
|-----------|
|[Josiah Opiyo](https://github.com/ojopiyo)|

*Built with a focus on automation, governance, least privilege, and clean Microsoft 365 tenants-helping M365 admins gain visibility and reduce operational risk.*

## Version history

|Version|Date|Comments|
|-------|----|--------|
|1.0|September 01, 2026|Initial release|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
