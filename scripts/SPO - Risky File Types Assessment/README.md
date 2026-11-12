# SPO - Risky File Types Assessment

## Summary

This PowerShell script performs a security-focused assessment of a specified SharePoint Online document library to identify files with potentially risky or executable file extensions.

Using the PnP.PowerShell module and certificate-based Entra ID application authentication, the script connects to SharePoint Online, enumerates library contents using paginated retrieval, and identifies files matching a predefined list of potentially risky extensions.

Identified files are enriched with metadata, including file size, creator, last modified date, modifier, library location, and direct file URL.

The results are exported to a timestamped CSV report, with a corresponding execution log containing assessment progress, file counts by extension, and total identified storage consumption.

## Why It Matters

SharePoint Online is frequently used to store and distribute business-critical documents across departments and external collaboration environments.

Although SharePoint provides security controls and file-type restrictions, potentially dangerous file types may still exist within document libraries due to legacy content, migration activities, administrative exceptions, or changing business requirements.

For example, a Finance department may discover executable files, PowerShell scripts, compressed archives, or disk images stored within its document repository.

These files may introduce security, compliance, and governance concerns, particularly when their presence is unexpected or their business purpose cannot be established.

This assessment enables Microsoft 365 Administrators and Security Teams to identify potentially risky file types, investigate ownership, validate business justification, and take appropriate remediation actions.

### Benefits

- **Security Visibility:** Identifies potentially risky file types stored within SharePoint Online document libraries.
- **Governance and Compliance:** Supports periodic security reviews and internal data governance assessments.
- **File Ownership Tracking:** Identifies the original creator and last modifying user to support investigations.
- **Storage Analysis:** Calculates the storage consumption associated with identified files.
- **Targeted Investigation:** Provides direct file URLs to simplify administrative review and remediation.
- **Auditability:** Generates timestamped CSV reports and execution logs for historical reference.
- **Operational Efficiency:** Uses paginated retrieval to support assessments of larger SharePoint document libraries.
- **Repeatable Assessments:** Enables administrators to perform scheduled or ad hoc file-type reviews.

## Prerequisites

- PowerShell with the PnP.PowerShell module installed.
- A Microsoft Entra ID application configured for certificate-based authentication.
- The application configured with the required SharePoint permissions and administrator consent.
- Access to the target SharePoint site and document library.
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
| `$ListName`       | Document library to assess                                       |
| `$OutputFolder`   | Destination path for the CSV report.                             |

# [PnP PowerShell](#tab/pnpps)

```powershell

# ============================================================
# CONFIGURATION
# ============================================================

$ClientID   = "xxxxxxxxxxxxxxxxxxxxx"
$ThumbPrint = "xxxxxxxxxxxxxxxxxxxxx"
$Tenant     = "contoso.onmicrosoft.com"

$SiteUrl    = "https://contoso.sharepoint.com/sites/Finance"
$ListName   = "Documents"

$OutputFolder = "C:\Temp\RiskyFileTypesAssessment"

#endregion

# ============================================================
# FILE TYPES TO FLAG
# ============================================================

$RiskyExtensions = @{

    "exe" = "Executable"
    "msi" = "Windows Installer"
    "bat" = "Batch Script"
    "cmd" = "Command Script"
    "ps1" = "PowerShell Script"
    "psm1" = "PowerShell Module"
    "vbs" = "VBScript"
    "js"  = "JavaScript"
    "zip" = "Compressed Archive"
    "rar" = "Compressed Archive"
    "7z"  = "Compressed Archive"
    "iso" = "Disk Image"
    "img" = "Disk Image"
    "reg" = "Registry File"
    "dll" = "Application Library"
    "apk" = "Android Package"
    "jar" = "Java Archive"
    "torrent" = "Torrent File"
}

# ============================================================
# INITIALISATION
# ============================================================

if (-not (Test-Path $OutputFolder)) {

    New-Item `
        -Path $OutputFolder `
        -ItemType Directory `
        -Force | Out-Null
}

$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

$CsvFile = Join-Path `
    $OutputFolder `
    "RiskyFileTypes_$Timestamp.csv"

$LogFile = Join-Path `
    $OutputFolder `
    "RiskyFileTypes_$Timestamp.log"

# ============================================================
# LOGGING
# ============================================================

function Write-Log {

    param(
        [string]$Message,

        [ValidateSet("INFO","WARN","ERROR")]
        [string]$Level = "INFO"
    )

    $Entry = "{0} [{1}] {2}" -f `
        (Get-Date -Format "yyyy-MM-dd HH:mm:ss"),
        $Level,
        $Message

    Add-Content `
        -Path $LogFile `
        -Value $Entry

    Write-Host $Entry
}

# ============================================================
# MAIN
# ============================================================

$Connection = $null

try {

    Write-Log "Starting risky file type assessment."

    Import-Module PnP.PowerShell -ErrorAction Stop

    $Connection = Connect-PnPOnline `
        -Url $SiteUrl `
        -ClientId $ClientID `
        -Thumbprint $ThumbPrint `
        -Tenant $Tenant `
        -ReturnConnection `
        -ErrorAction Stop

    Write-Log "Successfully connected."

    $WebUrl = (Get-PnPWeb -Connection $Connection).Url

    $TenantRoot = ([System.Uri]$WebUrl).GetLeftPart(
        [System.UriPartial]::Authority
    )

    $Results = [System.Collections.Generic.List[object]]::new()

    Get-PnPListItem `
        -List $ListName `
        -PageSize 2000 `
        -Fields @(
            "FileRef",
            "FileLeafRef",
            "File_x0020_Size",
            "Modified",
            "Editor",
            "Author"
        ) `
        -Connection $Connection |

    ForEach-Object {

        $Item = $_

        if ($Item.FileSystemObjectType -ne "File") {
            return
        }

        $FileName = $Item["FileLeafRef"]

        $Extension = (
            [System.IO.Path]::GetExtension(
                $FileName
            )
        ).TrimStart('.').ToLower()

        if (-not $RiskyExtensions.ContainsKey($Extension)) {
            return
        }

        $SizeMB = 0

        if ($Item["File_x0020_Size"]) {

            $SizeMB = [Math]::Round(
                ($Item["File_x0020_Size"] / 1MB),
                2
            )
        }

        $Results.Add(
            [PSCustomObject]@{

                SiteUrl          = $SiteUrl
                Library          = $ListName
                FileName         = $FileName
                Extension        = $Extension
                RiskCategory     = $RiskyExtensions[$Extension]
                SizeMB           = $SizeMB
                CreatedBy        = if ($Item["Author"]) {
                    $Item["Author"].LookupValue
                }

                ModifiedBy       = if ($Item["Editor"]) {
                    $Item["Editor"].LookupValue
                }

                Modified         = $Item["Modified"]
                RelativeUrl      = $Item["FileRef"]
                FullUrl          = "$TenantRoot$($Item['FileRef'])"
            }
        )
    }

    # ========================================================
    # EXPORT
    # ========================================================

    $Results |
        Sort-Object Extension, SizeMB -Descending |
        Export-Csv `
            -Path $CsvFile `
            -NoTypeInformation `
            -Encoding UTF8

    Write-Log "Results exported to $CsvFile"

    # ========================================================
    # SUMMARY
    # ========================================================

    Write-Log "==========================================="
    Write-Log "RISKY FILE TYPES SUMMARY"
    Write-Log "==========================================="

    Write-Log "Flagged Files: $($Results.Count)"

    foreach ($Extension in $RiskyExtensions.Keys |
        Sort-Object) {

        $Count = (
            $Results |
            Where-Object Extension -eq $Extension
        ).Count

        if ($Count -gt 0) {

            Write-Log (
                "{0}: {1}" -f
                $Extension,
                $Count
            )
        }
    }

    $TotalSize = (
        $Results |
        Measure-Object `
            -Property SizeMB `
            -Sum
    ).Sum

    Write-Log "Total Storage Consumed: $([math]::Round($TotalSize,2)) MB"

    Write-Log "Assessment completed successfully."
}
catch {

    Write-Log $_.Exception.Message "ERROR"
    
    Disconnect-PnPOnline `
    Write-Log "Disconnected from SharePoint Online."

}

Write-Host ""
Write-Host "Assessment complete." -ForegroundColor Green
Write-Host "CSV : $CsvFile"
Write-Host "LOG : $LogFile"
Write-Host "Flagged Files : $($Results.Count)"

```

## Usage

Execute the script from a PowerShell session. The script will:

1. Initialise the output directory.
2. Create timestamped CSV and log filenames.
3. Import the PnP.PowerShell module.
4. Authenticate to the specified SharePoint Online site.
5. Retrieve document library items using pagination.
6. Identify files matching the configured risky extensions.
7. Collect relevant file metadata.
8. Export the assessment results to CSV.
9. Generate a summary containing file counts and storage consumption.
10. Record execution details in the log file.

## Output

The script generates two files for each execution.

1. **CSV Assessment Report**

Example filename:

> RiskyFileTypes_20261112_120000.csv

The CSV contains the following fields:

| Field                   | Description                                                |
| ----------------------- | ---------------------------------------------------------- |
| `SiteUrl`               | SharePoint Online site URL                                 |
| `Library`               | Document library name                                      |
| `FileName`              | Identified file name                                       |
| `Extension`             | File extension                                             |
| `RiskCategory`          | Classification of the file type                            |
| `SizeMB`                | File size in megabytes                                     |
| `CreatedBy`             | Original file creator                                      |
| `ModifiedBy`            | Last modifying user                                        |
| `Modified`              | Last modified date                                         |
| `RelativeUrl`           | SharePoint server-relative file URL                        |
| `FullUrl`               | Absolute SharePoint file URL                               |

2. **Execution Log**

Example filename:

> RiskyFileTypes_20261112_120000.log

The log records:

- Assessment start and completion.
- SharePoint connection status.
- Export location.
- Identified file count.
- File counts by extension.
- Total storage consumed by identified files.
- Execution errors.

## Notes

- **Read-only assessment:** The script identifies and reports files without modifying, deleting, or moving SharePoint content.
- **Extension-based detection:** Classification is based on file extensions rather than file signatures or actual file contents.
- **Pagination:** Uses a page size of 2,000 items to support larger document libraries.
- **Application authentication:** Uses certificate-based authentication rather than interactive administrator sign-in.
- **Scope limitation:** The assessment covers only the configured SharePoint site and document library. It does not automatically scan subsites, other libraries, OneDrive, or Microsoft Teams storage.
- **Security classification:** Flagged extensions indicate potentially risky file types, not confirmed malicious files.
- **Reporting:** CSV and log files are timestamped to avoid overwriting previous assessment results.

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
