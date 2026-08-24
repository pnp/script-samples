# Export SharePoint Access Request Settings

## Summary

This PowerShell script audits SharePoint Online access request settings across all site collections and subsites in a Microsoft 365 tenant.

It uses PnP PowerShell app-only certificate authentication, retrieves the relevant SharePoint web properties, identifies whether access requests are enabled, disabled, or inherited, and determines whether requests are configured for a specific email address or the site's associated Owners group.

The results are exported to a CSV file for administrative review, compliance analysis, and remediation planning.

The script uses Get-PnPSubWeb -IncludeRootWeb -Recurse to enumerate root webs and nested subsites.

## Why It Matters

Access Request settings determine where users' requests for access to SharePoint sites are directed.

In a large Microsoft 365 environment, these settings can become inconsistent following site migrations, ownership changes, legacy site creation, or changes to site permissions.

For example, an administrator may need to identify:

- Sites where access requests are enabled.
- Sites sending requests to individual email addresses.
- Sites relying on their associated Owners group.
- Sites where settings are inherited from a parent web.
- Sites where access requests have been explicitly disabled.

The resulting CSV provides a tenant-wide inventory that can be reviewed before standardising or remediating access request configuration.

## Benefits

- **Tenant-wide visibility** - Audits all included site collections and nested subsites.
- **Centralised reporting** - Produces a single CSV for analysis and evidence.
- **Identifies configuration differences** - Highlights email-based, Owners-group, disabled, and inherited configurations.
- **Supports governance** - Helps identify legacy or inconsistent access request configurations.
- **Automation-ready** - Uses certificate-based app-only authentication rather than interactive sign-in.
- **Suitable for large environments** - Results are collected in memory and exported once rather than repeatedly writing to the CSV.
- **Minimal permissions footprint** - The script only retrieves the information required for the audit.

Get-PnPGroup -AssociatedOwnerGroup is the PnP-supported method used to retrieve the associated Owners group.

# [PnP PowerShell](#tab/pnpps)

```powershell
# ======================================================
# Configuration
# ======================================================

$TenantAdminURL = "https://contoso-admin.sharepoint.com"
$ClientID       = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$ThumbPrint     = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$Tenant         = "contoso.onmicrosoft.com"

# ======================================================
# Script Information 
# ======================================================
$RunDate = Get-Date -Format "yyyy-MM-dd HH\:mm\:ss"
$RunBy   = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

# ---------- Output ----------

$CSVPath = "C:\Temp\AccessRequestData.csv"
$Results = @()
# ======================================================
# Connect to SharePoint Online (App-Only) 
# ======================================================

Connect-PnPOnline -Url $TenantAdminURL -ClientId $ClientID -Tenant $Tenant -Thumbprint $ThumbPrint

# Remove old CSV if present

if (Test-Path $CSVPath) {
    Remove-Item $CSVPath -Force
}

# ======================================================
# Get All Site Collections
# ======================================================

$SiteCollections = Get-PnPTenantSite | Where-Object {
    $_.Template -notin @(
        "SRCHCEN#0",
        "REDIRECTSITE#0",
        "SPSMSITEHOST#0",
        "APPCATALOG#0",
        "POINTPUBLISHINGHUB#0",
        "EDISC#0",
        "STS#-1"
    )
}

# ======================================================
# Function: Get Access Request Settings
# ======================================================

function Get-AccessRequestConfig {
    param($Web)

    Write-Host -ForegroundColor Yellow "Checking: $($Web.Url)"

    $AccessRequest       = ""
    $EmailOrGroup        = ""
    $AccessRequestConfig = ""

    if ($Web.HasUniqueRoleAssignments) {

        if (-not [string]::IsNullOrEmpty($Web.RequestAccessEmail)) {

            $AccessRequest       = "Enabled"
            $EmailOrGroup        = "Email"
            $AccessRequestConfig = $Web.RequestAccessEmail
        }
        elseif ($Web.UseAccessRequestDefault) {

            $AccessRequest = "Enabled"
            $EmailOrGroup  = "Default Owner Group"

            $OwnersGroup = Get-PnPGroup -AssociatedOwnerGroup -ErrorAction SilentlyContinue

            if ($null -ne $OwnersGroup) {
                $AccessRequestConfig = $OwnersGroup.Title
            }
        }
        else {
            $AccessRequest = "Disabled"
        }
    }
    else {
        $AccessRequest = "Inherited"
    }

    return [PSCustomObject]@{
        RunDate             = $RunDate
        RunBy               = $RunBy
        WebUrl              = $Web.Url
        AccessRequest       = $AccessRequest
        EmailOrGroup        = $EmailOrGroup
        AccessRequestConfig = $AccessRequestConfig
    }
}

# ======================================================
# Process Each Site Collection
# ======================================================

foreach ($Site in $SiteCollections) {

    Write-Host -ForegroundColor Cyan "Connecting to site: $($Site.Url)"

    try {

        Connect-PnPOnline `
            -Url $Site.Url `
            -ClientId $ClientID `
            -Tenant $Tenant `
            -Thumbprint $ThumbPrint `
            -ErrorAction Stop

        $Webs = Get-PnPSubWeb -IncludeRootWeb -Recurse -Includes `
            HasUniqueRoleAssignments, RequestAccessEmail, UseAccessRequestDefault `
            -ErrorAction Stop

        foreach ($Web in $Webs) {
            $Results += Get-AccessRequestConfig -Web $Web
        }
    }
    catch {
        Write-Host -ForegroundColor Red "Error processing $($Site.Url): $($_.Exception.Message)"
    }
}

# ======================================================
# Export Final Report 
# ======================================================

$Results | Export-Csv -Path $CSVPath -NoTypeInformation -Encoding UTF8

Write-Host -ForegroundColor Green "Access Request Report generated: $CSVPath"

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Output

Default output: *C:\Temp\AccessRequestData.csv*

The CSV contains:

| Column                | Description                                   |
| --------------------- | --------------------------------------------- |
| `RunDate`             | Date and time the audit was executed          |
| `RunBy`               | Windows account running the script            |
| `WebUrl`              | SharePoint site or subsite URL                |
| `AccessRequest`       | `Enabled`, `Disabled`, or `Inherited`         |
| `EmailOrGroup`        | `Email` or `Default Owner Group`              |
| `AccessRequestConfig` | Configured email address or Owners group name |

## Interpretation

| AccessRequest | Meaning                                                                           |
| ------------- | --------------------------------------------------------------------------------- |
| `Enabled`     | Access requests are enabled for the web                                           |
| `Disabled`    | Access requests are explicitly disabled                                           |
| `Inherited`   | The web does not have unique permissions and inherits permissions from its parent |

## Notes

- Requires PnP.PowerShell.
- Uses certificate-based app-only authentication.
- The certificate must be accessible to the account running PowerShell.
- The script does not modify SharePoint configuration.
- Existing CSV output is removed before the new report is generated.
- The script is intended as an audit/reporting tool, not a remediation script.
- For very large tenants, avoid unnecessary additional properties or per-web operations because they increase SharePoint requests.

## Contributors

|Author(s)|
|-----------|
|[Josiah Opiyo](https://github.com/ojopiyo)|

*Built with a focus on automation, governance, least privilege, and clean Microsoft 365 tenants-helping M365 admins gain visibility and reduce operational risk.*

## Version history

|Version|Date|Comments|
|-------|----|--------|
|1.0|August 08, 2026|Initial release|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/export-spo-access-request-settings" aria-hidden="true" />
