# SharePoint Bulk File Rename Script

## Summary

This PowerShell script provides a controlled method for renaming multiple files within a SharePoint Online document library. The required file changes are defined in a CSV input file, allowing an administrator to process several file renames during a single execution.

The script connects to SharePoint Online using certificate-based application authentication and uses PnP PowerShell to rename each file. During execution, it displays progress, reports the outcome of each row, and creates a detailed CSV audit report.

The audit report records:

- Who initiated the script
- When the script was run
- The SharePoint site against which it was executed
- The original filename
- The original site-relative file path
- The requested new filename
- Whether the rename succeeded or failed
- The date and time each row was processed
- Any error returned for an unsuccessful rename
- A unique Run ID linking all changes made during the same execution

## Why It Matters

Renaming files manually can be time-consuming and may result in inconsistent naming, accidental omissions, or limited evidence of what was changed. This script helps reduce those risks by processing file changes from a structured CSV file and recording the outcome of each attempted rename.

Typical use cases include:

- Applying an agreed document naming convention
- Correcting inconsistent or outdated filenames
- Removing unsuitable characters or wording from filenames
- Adding version, year, department, or document-type information
- Supporting document-library migration or remediation activities
- Renaming a defined set of files following a content audit
- Standardising filenames to improve search and content discovery

### Benefits

- Bulk remediation - Rename large numbers of SharePoint files without manually processing each file.
- Auditable changes - Every operation records the original URL, original name, new name, status, timestamp, and error information.
- Repeatable execution - CSV-driven processing makes the operation suitable for controlled administrative workflows.
- Failure visibility - Individual failures do not prevent subsequent rows from being processed.
- Tenant administration - Uses PnP.PowerShell and certificate-based application authentication, making it suitable for unattended administrative processes.
- Operational reporting - Provides a summary of successful and failed operations alongside a detailed CSV audit report.

## Prerequisites

- PowerShell **7.4 or later**
- **PnP.PowerShell** module
- Entra ID application registration
- Certificate with private key installed in the Windows certificate store
- Appropriate SharePoint Online application permissions
- Access to the target SharePoint Online site
- Configured:
  - *Client ID*
  - *ThumbPrint*
  - *Tenant*
  - *Site Url*
- The input CSV exists at the configured path and contains the following:
  - *SiteRelativeUrl*
  - *NewName*
- The output location exists

## Configuration

Configure the variables at the beginning of the script:

| Variable          | Description                                                                    |
| ----------------- | ------------------------------------------------------------------------------ |
| `$ClientID`       | Azure AD Application (Client) ID                                               |
| `$ThumbPrint`     | Certificate thumbprint                                                         |
| `$Tenant`         | Microsoft 365 tenant name (e.g. `contoso.onmicrosoft.com`)                     |
| `$SiteUrl`        | Your Site URL i.e. `https://contoso.sharepoint.com/sites/TestEnvironment`      |
| `$CsvPath`        | Your CSV Path Location i.e. `C:\Temp\Rename-Files.csv`                         |
| `$ReportPath`     | An appropriate audit location i.e. `C:\Temp\Rename-Files-Audit.csv` |

# [PnP PowerShell](#tab/pnpps)

```powershell

#Requires -Modules PnP.PowerShell

# ============================================================
# AUTHENTICATION
# ============================================================
$ClientID   = "xxxxxxxxxxxxxxxxxxxxxxxx"
$ThumbPrint = "xxxxxxxxxxxxxxxxxxxxxxxx"
$Tenant     = "contoso.onmicrosoft.com"

# ============================================================
# CONFIGURATION
# ============================================================
$SiteUrl    = "https://contoso.sharepoint.com/sites/TestEnvironment"
$CsvPath    = "C:\Temp\Rename-Files.csv"
$ReportPath = "C:\Temp\Rename-Files-Audit.csv"

# ============================================================
# AUDIT INFORMATION
# ============================================================
$RunId      = :NewGuid().ToString()
$RunBy      = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$RunDate    = Get-Date

# ============================================================
# CONNECT TO SHAREPOINT
# ============================================================
Connect-PnPOnline `
    -Url $SiteUrl `
    -ClientId $ClientID `
    -Thumbprint $ThumbPrint `
    -Tenant $Tenant

# ============================================================
# IMPORT THE CSV
# ============================================================
$CsvData = @(Import-Csv -Path $CsvPath)

$TotalRows   = $CsvData.Count
$CurrentRow  = 0
$Success     = 0
$Failed      = 0
$AuditReport = @()

foreach ($File in $CsvData) {

    $CurrentRow++

    Write-Progress `
        -Activity "Renaming SharePoint files" `
        -Status "$CurrentRow of $TotalRows" `
        -PercentComplete (($CurrentRow / $TotalRows) * 100)

    $OldUrl  = $File.SiteRelativeUrl
    $OldName = Split-Path -Path $OldUrl -Leaf
    $NewName = $File.NewName
    $Status  = ""
    $ErrorMessage = ""

    try {
        Rename-PnPFile `
            -SiteRelativeUrl $OldUrl `
            -TargetFileName $NewName `
            -Force `
            -ErrorAction Stop

        $Status = "Success"
        $Success++

        Write-Host "[$CurrentRow of $TotalRows] Renamed '$OldName' to '$NewName'" `
            -ForegroundColor Green
    }
    catch {
        $Status = "Failed"
        $ErrorMessage = $_.Exception.Message
        $Failed++

        Write-Host "[$CurrentRow of $TotalRows] Failed: '$OldName'" `
            -ForegroundColor Red
    }

    $AuditReport += [PSCustomObject]@{
        RunId             = $RunId
        RunBy             = $RunBy
        RunDate           = $RunDate
        SiteUrl           = $SiteUrl
        RowNumber         = $CurrentRow
        OriginalFileName  = $OldName
        OriginalFileUrl   = $OldUrl
        NewFileName       = $NewName
        Status            = $Status
        ProcessedDateTime = Get-Date
        ErrorMessage      = $ErrorMessage
    }
}

Write-Progress -Activity "Renaming SharePoint files" -Completed

# ============================================================
# EXPORT THE AUDIT REPORT
# ============================================================
$AuditReport |
    Export-Csv `
        -Path $ReportPath `
        -NoTypeInformation `
        -Encoding UTF8
# ============================================================
# DISPLAY SUMMARY
# ============================================================
Write-Host ""
Write-Host "Import complete" -ForegroundColor Cyan
Write-Host "Run by: $RunBy"
Write-Host "Total rows: $TotalRows"
Write-Host "Successful: $Success" -ForegroundColor Green
Write-Host "Failed: $Failed" -ForegroundColor Red
Write-Host "Audit report: $ReportPath"


```

## Output

The script generates an audit CSV containing:

| Field                   | Description                                                |
| ----------------------- | ---------------------------------------------------------- |
| `RunId`                 | Unique identifier for the execution                        |
| `RunBy`                 | Windows identity executing the script                      |
| `RunDate`               | Start time of the execution                                |
| `SiteUrl`               | SharePoint site being processed                            |
| `RowNumber`             | Source CSV row being processed                             |
| `OriginalFileName`      | Existing file name                                         |
| `OriginalFileUrl`       | Existing site-relative file URL                            |
| `NewFileName`           | Requested new file name                                    |
| `Status`                | Success or Failed                                          |
| `ProcessedDateTime`     | Time the individual operation completed                    |
| `ErrorMessage`          | Error returned when the operation fails                    |

## Production Considerations

For large Microsoft 365 tenants, the input CSV should be validated before execution. Invalid URLs, duplicate operations, missing file names, and unsupported file-name characters should be identified before making changes.

The script processes files sequentially. This deliberately avoids uncontrolled parallel operations against SharePoint Online, which can increase the likelihood of throttling and transient failures.

For very large workloads, consider implementing controlled batching, retry handling for transient SharePoint throttling, and checkpointing so that an interrupted run can resume without unnecessarily reprocessing completed operations.

## Notes

- Force allows the requested rename operation to proceed where supported by SharePoint.
- The script does not delete or overwrite source files; it performs file rename operations.
- Failed rows are recorded in the audit report while processing continues.
- The RunId allows individual executions to be correlated across audit reports.
- For unattended automation, the certificate and application identity should be managed securely rather than embedding certificate secrets in the script.
- Test the CSV against a non-production site or a small representative dataset before performing a large production rename operation.

## Contributors

|Author(s)|
|-----------|
|[Josiah Opiyo](https://github.com/ojopiyo)|

*Built with a focus on automation, governance, least privilege, and clean Microsoft 365 tenants - helping M365 admins gain visibility and reduce operational risk.*

## Version history

|Version|Date|Comments|
|-------|----|--------|
|1.0|October 07, 2026|Initial release|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
