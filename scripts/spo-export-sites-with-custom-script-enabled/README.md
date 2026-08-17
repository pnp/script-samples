# SharePoint Online - Export Sites with Custom Script Enabled

## Professional Summary

This PowerShell script connects to the SharePoint Online Admin Center using certificate-based authentication and audits all SharePoint Online site collections to identify sites where Custom Script is enabled. The results are exported to a timestamped CSV report containing key site metadata, including site name, URL, owner, template, creation date, and execution metadata for audit purposes.

The script is designed for Microsoft 365 administrators who require a tenant-wide inventory of sites that permit custom scripting, enabling governance, security, and compliance reviews.

## Why it matters

Custom Script allows users to add or modify JavaScript, master pages, and other customizations within SharePoint Online. While this capability is required for some legacy business solutions, it also increases the potential attack surface and may bypass modern SharePoint development practices.

Many organizations intentionally disable Custom Script across their tenant to improve security, standardization, and supportability. However, exceptions are often granted for legacy applications, migration projects, or business-critical solutions.

Maintaining an accurate inventory of sites where Custom Script is enabled helps administrators:

- Identify legacy or non-standard SharePoint implementations.
- Validate compliance with organizational governance policies.
- Support security assessments and audit activities.
- Plan modernization initiatives by locating sites that rely on classic customization techniques.
- Reduce operational risk by reviewing sites that permit unsupported or legacy customizations.

## Prerequisites

- PowerShell 7.x or Windows PowerShell 5.1
- PnP.PowerShell module installed
- SharePoint Administrator or Global Administrator permissions
- Microsoft Entra ID App Registration configured for certificate-based authentication
- Certificate installed on the execution host
- Appropriate Microsoft Graph and SharePoint application permissions granted

# [PnP PowerShell](#tab/pnpps)

```powershell
#==========================================
# Configuration 
#==========================================

$ClientID   = "xxxxxxxxxxxxxxxx"
$ThumbPrint = "xxxxxxxxxxxxxxxx" 
$Tenant     = "contoso.onmicrosoft.com"

$AdminUrl = "https://contoso-admin.sharepoint.com"

#==========================================
# Audit Metadata
#==========================================

$RunBy     = $env:USERNAME
$RunDate   = Get-Date
$ReportID  = [Guid]::NewGuid()

#==========================================
# Output 
#==========================================

$OutputFolder = "C:\Temp\Report"
$TimeStamp    = Get-Date -Format "yyyyMMdd_HHmmss"
$OutputFile   = Join-Path $OutputFolder "CustomScriptEnabledSites_$TimeStamp.csv"

if (!(Test-Path $OutputFolder)) {
    New-Item -Path $OutputFolder -ItemType Directory -Force | Out-Null
}

#==========================================
# Connect
#==========================================

try {
    Connect-PnPOnline -Url $AdminUrl -ClientId $ClientID -Thumbprint $ThumbPrint -Tenant $Tenant
}
catch {
    Write-Host "Connection failed: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

#==========================================
# Retrieve Sites
#==========================================

Write-Host "Retrieving tenant sites..." -ForegroundColor Cyan

$Sites   = Get-PnPTenantSite -Detailed
$Results = [System.Collections.Generic.List[object]]::new()

foreach ($Site in $Sites) {

    # Custom Script Enabled = 1
    if ($Site.DenyAddAndCustomizePages -eq 1) {

        $Results.Add([PSCustomObject]@{
            SiteName     = $Site.Title
            SiteUrl      = $Site.Url
            Owner        = $Site.Owner
            Template     = $Site.Template
            CreatedDate  = $Site.CreationDate

            CustomScriptEnabled = $true

            RunBy        = $RunBy
            RunDate      = $RunDate
            ReportID     = $ReportID
        })
    }
}

#==========================================
# Export
#==========================================

$Results |
    Sort-Object SiteName |
    Export-Csv -Path $OutputFile -NoTypeInformation -Encoding UTF8

#==========================================
# Summary
#==========================================

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Custom Script Enabled Sites Report Complete"
Write-Host "============================================" -ForegroundColor Cyan

Write-Host "Sites Scanned : $($Sites.Count)"
Write-Host "Custom Script Enabled Sites : $($Results.Count)"
Write-Host "Report ID     : $ReportID"
Write-Host "Run By        : $RunBy"
Write-Host "Run Date      : $RunDate"
Write-Host ""
Write-Host "Report saved to:"
Write-Host $OutputFile -ForegroundColor Green

Disconnect-PnPOnline


```

## Authentication

The script authenticates using certificate-based application authentication, making it suitable for:

- Scheduled Tasks
- Azure Automation
- Azure Functions
- Unattended administrative execution
- Secure enterprise automation

No interactive sign-in is required.

## Usage

1. Configure the following variables:
    - Client ID
    - Certificate Thumbprint
    - Tenant Name
    - SharePoint Admin Center URL
2. Execute the script.
3. Review the generated CSV report located in the configured output directory.

## Output

### CSV Report Location

C:\Temp\Report\

### Report Contents

The script generates a CSV report containing:

| Column              | Description                    |
| ------------------- | ------------------------------ |
| SiteName            | SharePoint site title          |
| SiteUrl             | Site collection URL            |
| Owner               | Primary site owner             |
| Template            | Site template                  |
| CreatedDate         | Site creation date             |
| CustomScriptEnabled | Indicates Custom Script status |
| RunBy               | User executing the script      |
| RunDate             | Script execution date/time     |
| ReportID            | Unique execution identifier    |

## Notes

- The report is read-only and makes no changes to the Microsoft 365 tenant.
- Hidden, redirected, and special-purpose SharePoint sites may also be returned depending on tenant configuration.
- Ensure the executing identity has sufficient permissions to enumerate all SharePoint Online site collections.
- Verify that the script checks DenyAddAndCustomizePages -eq 0 when reporting sites with Custom Script enabled.

## Contributors

|Author(s)|
|-----------|
|[Josiah Opiyo](https://github.com/ojopiyo)|

*Built with a focus on automation, governance, least privilege, and clean Microsoft 365 tenants-helping M365 admins gain visibility and reduce operational risk.*

## Version history

|Version|Date|Comments|
|-------|----|--------|
|1.0|August 02, 2026|Initial release|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
