# Get M365 Users with Direct SharePoint Permissions

## Summary

This script identifies users who have been granted direct permissions on SharePoint Online sites, rather than receiving access through groups. Direct permissions can bypass standard governance and make permission management more difficult to audit. By detecting these users, the script helps organizations maintain least-privilege access, ensure compliance with internal policies, and reduce the risk of unintended data exposure. The output provides a detailed, actionable report of sites, users, and assigned roles, enabling administrators to remediate or review access efficiently.

## Why It Matters

In production environments, managing SharePoint permissions through groups is best practice to maintain governance, security, and compliance. Users with direct site permissions can bypass these controls, creating potential security risks and complicating audits. This script identifies such users, providing administrators with a clear, actionable report. By highlighting direct permissions, it helps enforce **least-privilege access**, supports regulatory compliance, and ensures that SharePoint sites remain secure and properly managed.

## Key Benefits

- **Governance & Compliance:** Detect deviations from standard group-based access.  
- **Security & Risk Management:** Identify users with potentially excessive permissions.  
- **Audit & Reporting:** Generate a clear, auditable record of all direct permissions.  
- **Operational Efficiency:** Quickly remediate unmanaged permissions.  
- **Proactive Monitoring:** Maintain least-privilege access in production environments.  

# [PnP PowerShell](#tab/pnpps)

```powershell
# ------------------------------------------------------------
# Script: Find Users with Direct SharePoint Site Permissions
# Purpose: Report users assigned direct permissions at the
#          SharePoint site (root web) level.
# ------------------------------------------------------------

# ---------- Configuration ----------
$AdminCenterUrl = "https://contoso-admin.sharepoint.com"

$ClientID       = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$Thumbprint     = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$Tenant         = "contoso.onmicrosoft.com"

$OutputFolder   = "C:\Temp\SharePointReports"
$TimeStamp      = Get-Date -Format "yyyyMMdd_HHmmss"
$OutputFile     = Join-Path $OutputFolder "DirectSitePermissions_$TimeStamp.csv"

# ---------- Create Output Folder ----------
if (!(Test-Path $OutputFolder)) {
    New-Item -ItemType Directory -Path $OutputFolder | Out-Null
}

# ---------- Connect to SharePoint Admin ----------
Connect-PnPOnline `
    -Url $AdminCenterUrl `
    -ClientId $ClientID `
    -Thumbprint $Thumbprint `
    -Tenant $Tenant

# ---------- Retrieve Sites ----------
$Sites = Get-PnPTenantSite |
Where-Object {
    $_.Template -notmatch "RedirectSite"
}

$TotalSites = $Sites.Count
$CurrentSite = 0
$FailedSites = 0

$Results = foreach ($Site in $Sites) {

    $CurrentSite++

    Write-Progress `
        -Activity "Scanning SharePoint Sites" `
        -Status "$CurrentSite of $TotalSites" `
        -PercentComplete (($CurrentSite / $TotalSites) * 100)

    try {

        Connect-PnPOnline `
            -Url $Site.Url `
            -ClientId $ClientID `
            -Thumbprint $Thumbprint `
            -Tenant $Tenant

        $Web = Get-PnPWeb -Includes RoleAssignments

        foreach ($RoleAssignment in $Web.RoleAssignments) {

            Get-PnPProperty -ClientObject $RoleAssignment -Property Member,RoleDefinitionBindings

            if ($RoleAssignment.Member.PrincipalType -eq "User") {

                [PSCustomObject]@{

                    SiteTitle          = $Site.Title
                    SiteUrl            = $Site.Url

                    UserDisplayName    = $RoleAssignment.Member.Title
                    UserEmail          = $RoleAssignment.Member.Email
                    LoginName          = $RoleAssignment.Member.LoginName

                    IsExternalUser     = $RoleAssignment.Member.LoginName -match "#EXT#"

                    PermissionLevels   = (
                        $RoleAssignment.RoleDefinitionBindings |
                        Select-Object -ExpandProperty Name
                    ) -join ", "

                    CollectionDate     = Get-Date
                }

            }

        }

    }

    catch {

        $FailedSites++

        Write-Warning "Failed to process $($Site.Url)"

    }

}

# ---------- Export ----------
$Results |
Sort-Object SiteTitle, UserDisplayName |
Export-Csv `
    -Path $OutputFile `
    -NoTypeInformation `
    -Encoding UTF8

# ---------- Summary ----------
Write-Host ""
Write-Host "----------------------------------------" -ForegroundColor Cyan
Write-Host "SharePoint Direct Permission Report"
Write-Host "----------------------------------------" -ForegroundColor Cyan
Write-Host "Sites Scanned        : $TotalSites"
Write-Host "Failed Sites         : $FailedSites"
Write-Host "Permissions Found    : $($Results.Count)"
Write-Host "Report               : $OutputFile"
Write-Host "Completed            : $(Get-Date)"
Write-Host "----------------------------------------" -ForegroundColor Cyan

Disconnect-PnPOnline

```

## Contributors

|Author(s)|
|-----------|
|[Josiah Opiyo](https://github.com/ojopiyo)|

*Built with a focus on automation, governance, least privilege, and clean Microsoft 365 tenants-helping M365 admins gain visibility and reduce operational risk.*

## Version history

| Version | Date              | Comments                                                                                                                                                   |
| ------- | ----------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1.0     | December 03, 2025 | Initial release                                                                                                                                            |
| 2.0     | August 03, 2026   | Refactored for production use with improved performance, certificate authentication, error handling, reporting enhancements, and scalability improvements. |

### Version 2.0 Release Notes

| Area           | Improvement                                                                                                                 |
| -------------- | --------------------------------------------------------------------------------------------------------------------------- |
| Authentication | Replaced interactive authentication with certificate-based authentication for unattended execution.                         |
| Performance    | Removed inefficient `+=` array operations and adopted pipeline-based object processing for improved scalability.            |
| Error Handling | Added per-site `try/catch` blocks so inaccessible sites no longer terminate the script.                                     |
| Reporting      | Added timestamped CSV filenames and included the collection date in the output.                                             |
| Progress       | Added `Write-Progress` to display scan progress across all SharePoint sites.                                                |
| Scalability    | Optimised for Microsoft 365 tenants containing hundreds or thousands of SharePoint sites.                                   |
| Filtering      | Excludes SharePoint redirect sites from processing.                                                                         |
| Output         | Expanded the report to include display name, email address, login name, permission levels, and an external user indicator.  |
| Configuration  | Centralised configuration variables to improve readability and simplify maintenance.                                        |
| Sorting        | Results are sorted by site title and user before export.                                                                    |
| Summary        | Added an execution summary showing sites processed, failures, permissions identified, report location, and completion time. |
| Safety         | Script remains read-only and makes no changes to SharePoint permissions.                                                    |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
