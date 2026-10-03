# Hide SPO List using PnP PowerShell

## Summary

This PowerShell script automates the process of hiding a SharePoint Online list and generating an audit record of the administrative action.

It uses PnP PowerShell with certificate-based application authentication to connect to a specified SharePoint Online site, sets the target list's Hidden property to $true, and exports an audit record containing the action date, executing user, site URL, list name, and action performed.

The generated CSV report provides a lightweight, timestamped record suitable for operational auditing and change tracking.

## Why It Matters

SharePoint lists may contain application configuration, integration data, staging information, or other administrative content that should not be exposed through normal SharePoint navigation.

A common administrative scenario is hiding a configuration list from the standard SharePoint user interface while retaining the list and its data for application or administrative use.

This script provides a repeatable approach to:

- Hide a designated SharePoint list without deleting its contents.
- Perform the change using non-interactive certificate authentication.
- Record who performed the action and when it occurred.
- Produce a timestamped audit file for operational records or change management.

## Prerequisites

- Exchange Online PowerShell module (ExchangeOnlineManagement)
- Exchange Online application registration configured for certificate-based authentication
- Valid certificate associated with the application
- Appropriate Exchange Online application permissions and administrative configuration
- Access to the certificate private key from the system executing the script

## Configuration

Configure the variables at the beginning of the script:

| Variable          | Description                                                       |
| ----------------- | ----------------------------------------------------------------- |
| `$ClientID`       | Azure AD Application (Client) ID                                  |
| `$ThumbPrint`     | Certificate thumbprint                                            |
| `$Tenant`         | Microsoft 365 tenant name (e.g. `contoso.onmicrosoft.com`)        |
| `$SiteUrl`        | Your Site URL i.e. `https://contoso.sharepoint.com/sites/YourSite`|
| `$ListName`       | Your List Name i.e. `ListName`                                    |

The script can then be executed from a PowerShell session or incorporated into an administrative automation process.

The executing identity must have sufficient permissions to connect to the SharePoint site and modify the target list.

# [PnP PowerShell](#tab/pnpps)

```powershell

# ============================================================
# CONFIGURATION
# ============================================================

$ClientID   = "xxxxxxxxxxxxxxxxxxxxx"
$ThumbPrint = "xxxxxxxxxxxxxxxxxxxxx"
$Tenant     = "contoso.onmicrosoft.com"

$SiteUrl  = "https://contoso.sharepoint.com/sites/YourSite"
$ListName = "YourList"

$OutputFolder = "C:\Temp\SharePointListAudit"

if (-not (Test-Path -LiteralPath $OutputFolder)) {
    New-Item -Path $OutputFolder -ItemType Directory -Force | Out-Null
}

$TimeStamp = Get-Date -Format "yyyyMMdd_HHmmss"
$CsvFile = Join-Path $OutputFolder "SharePointListAudit_$TimeStamp.csv"

# ============================================================
# WHO AND WHEN
# ============================================================

$ActionBy = $env:USERNAME
$ActionDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# ============================================================
# CONNECT
# ============================================================

Connect-PnPOnline `
    -Url $SiteUrl `
    -ClientId $ClientID `
    -Thumbprint $ThumbPrint `
    -Tenant $Tenant

# ============================================================
# HIDE SHAREPOINT LIST
# ============================================================

Set-PnPList -Identity $ListName -Hidden $true

# ============================================================
# CREATE AUDIT RECORD
# ============================================================

[PSCustomObject]@{
    ActionDate = $ActionDate
    ActionBy   = $ActionBy
    SiteUrl    = $SiteUrl
    ListName   = $ListName
    Action     = "Hide List"
} | Export-Csv `
    -Path $CsvFile `
    -NoTypeInformation `
    -Encoding UTF8

# ============================================================
# DISCONNECT
# ============================================================

Disconnect-PnPOnline

Write-Host "List '$ListName' hidden successfully."
Write-Host "Audit report: $CsvFile"

```

## Output

A timestamped CSV file is created in the configured output directory:

> SharePointListAudit_yyyyMMdd_HHmmss.csv

Example record:

### CSV Report Fields

| Field                   | Description                                                |
| ----------------------- | ---------------------------------------------------------- |
| `ActionDate`            | Date and time the operation was performed                  |
| `ActionBy`              | Windows/PowerShell environment username                    |
| `SiteUrl`               | SharePoint Online site containing the list                 |
| `ListName`              | List modified by the script                                |
| `Action`                | Administrative action performed                            |

## Notes

- Set-PnPList -Hidden $true hides the list; it does not delete the list or its data.
- The script assumes the target list already exists.
- $env:USERNAME identifies the local execution context, not necessarily the identity represented by the Entra ID application used for SharePoint authentication.
- The output directory is created automatically if it does not exist.
- Disconnect-PnPOnline terminates the PnP PowerShell connection after the operation.
- For production automation, avoid storing client IDs, certificate material, or other credentials directly in scripts where possible.
- Consider adding structured error handling and logging if this script is used as part of a larger operational process.

## Contributors

|Author(s)|
|-----------|
|[Josiah Opiyo](https://github.com/ojopiyo)|

*Built with a focus on automation, governance, least privilege, and clean Microsoft 365 tenants - helping M365 admins gain visibility and reduce operational risk.*

## Version history

|Version|Date|Comments|
|-------|----|--------|
|1.0|October 03, 2026|Initial release|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
