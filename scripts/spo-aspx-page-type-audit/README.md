# SharePoint Online ASPX Page Type Audit

## Summary

This PowerShell 7.4+ script audits ASPX pages within a specified SharePoint Online page library and classifies each page as **Modern** or **Classic**.

The script:

- Authenticates to SharePoint Online using an Entra ID application and certificate-based authentication.
- Validates the configured page library.
- Retrieves page library items and filters for **.aspx** files.
- Determines the page type using the SharePoint **ClientSideApplicationId** field.
- Exports page-level audit results to a timestamped CSV file.
- Creates a transcript log for operational troubleshooting and audit purposes.
- Provides execution metadata, including report ID, executing account, timestamps, and source site.

## Why It Matters

Microsoft is retiring and deprecating a number of legacy SharePoint capabilities in phases through 2026, including **SharePoint Alerts, SharePoint Add-Ins, and the legacy Azure Access Control Services (ACS) authentication model**. For organisations with long-lived SharePoint Online environments, legacy dependencies can remain embedded across intranet sites, HR onboarding, approval processes, finance workflows, and other business-critical solutions.

**Classic SharePoint pages** can be an important indicator of this technical debt. A classic ASPX page may depend on legacy scripts, customisations, web parts, add-ins, or other components that require assessment as part of a wider modernisation programme.

This audit provides an initial, repeatable inventory of **Modern vs. Classic ASPX pages**, helping administrators establish where legacy content exists before prioritising remediation.

Use the results to:

- Identify remaining classic ASPX pages that may require further assessment.
- Establish a baseline for SharePoint modernisation and migration programmes.
- Prioritise investigation based on business criticality and technical dependencies.
- Reduce the risk of broken business processes, governance gaps, and costly last-minute remediation.
- Support decisions around **transform, rebuild, retire, or retain** rather than migrating legacy content unnecessarily.
- Feed the resulting inventory into wider dependency and governance assessments.

## Requirements

- PowerShell **7.4 or later**
- **PnP.PowerShell** module
- Entra ID application registration
- Certificate with private key installed in the Windows certificate store
- Appropriate SharePoint Online application permissions
- Access to the target SharePoint Online site
- Configured:
  - *Client ID*
  - *Certificate thumbprint*
  - *Tenant*
  - *Site URL*
  - *Page library*

## Classification Logic

The script identifies ASPX files and evaluates the SharePoint **ClientSideApplicationId** field.

| Condition                                                                   | Classification  |
| --------------------------------------------------------------------------- | --------------- |
| `ClientSideApplicationId` matches the configured modern page application ID | Modern          |
| Any other value, including blank                                            | Classic         |

The modern page application ID used by the script is:

> b6917cb1-93a0-4b97-a84d-7cf49975d4ec

# [PnP PowerShell](#tab/pnpps)

```powershell

# ============================================================
# CONFIGURATION
# ============================================================

$ClientID   = "xxxxxxxxxxxxxxxxxxxxx"
$ThumbPrint = "xxxxxxxxxxxxxxxxxxxxx"
$Tenant     = "contoso.onmicrosoft.com"
$SiteUrl    = "https://contoso.sharepoint.com/sites/A"

# SharePoint page library.
# Modern SharePoint sites normally use "Site Pages".
# Publishing/classic sites may use "Pages".
$PageLibrary = "Site Pages"

# Modern SharePoint page application ID
$ModernPageApplicationId = "b6917cb1-93a0-4b97-a84d-7cf49975d4ec"

# ============================================================
# OUTPUT CONFIGURATION
# ============================================================

$OutputFolder = "C:\Temp\Report"

# Create output folder if required
try {
    if (-not (Test-Path -LiteralPath $OutputFolder)) {
        New-Item `
            -Path $OutputFolder `
            -ItemType Directory `
            -Force `
            -ErrorAction Stop |
            Out-Null
    }
}
catch {
    Write-Error "Unable to create or access output folder '$OutputFolder'. $($_.Exception.Message)"
    exit 1
}

# One timestamp is used for all files generated during this run
$TimeStamp = Get-Date -Format "yyyyMMdd_HHmmss"

$OutputFile = Join-Path `
    -Path $OutputFolder `
    -ChildPath "SharePoint-Page-Type-Report_$TimeStamp.csv"

$LogFile = Join-Path `
    -Path $OutputFolder `
    -ChildPath "SharePoint-Page-Type-Report_$TimeStamp.log"

# ============================================================
# AUDIT METADATA
# ============================================================

$ScriptStart = Get-Date
$RunBy       = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$RunDateTime = Get-Date
$ReportID    = [guid]::NewGuid()

$Connected = $false

# ============================================================
# START TRANSCRIPT
# ============================================================

try {
    Start-Transcript `
        -Path $LogFile `
        -Force `
        -ErrorAction Stop |
        Out-Null
}
catch {
    Write-Warning "Unable to start transcript: $($_.Exception.Message)"
}

try {

    # ========================================================
    # HEADER
    # ========================================================

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host " SharePoint Page Type Audit" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "Report ID     : $ReportID"
    Write-Host "Run by        : $RunBy"
    Write-Host "Started       : $RunDateTime"
    Write-Host "Site          : $SiteUrl"
    Write-Host "Page library  : $PageLibrary"
    Write-Host "Output folder : $OutputFolder"
    Write-Host ""

    # ========================================================
    # VALIDATE CONFIGURATION
    # ========================================================

    if ([string]::IsNullOrWhiteSpace($ClientID)) {
        throw "ClientID has not been configured."
    }

    if ([string]::IsNullOrWhiteSpace($ThumbPrint)) {
        throw "ThumbPrint has not been configured."
    }

    if ([string]::IsNullOrWhiteSpace($Tenant)) {
        throw "Tenant has not been configured."
    }

    if ([string]::IsNullOrWhiteSpace($SiteUrl)) {
        throw "SiteUrl has not been configured."
    }

    # ========================================================
    # CONNECT TO SHAREPOINT
    # ========================================================

    Write-Host "Connecting to SharePoint..." -ForegroundColor Cyan

    try {
        Connect-PnPOnline `
            -Url $SiteUrl `
            -ClientId $ClientID `
            -Thumbprint $ThumbPrint `
            -Tenant $Tenant `
            -ErrorAction Stop

        $Connected = $true

        Write-Host "Connected successfully." -ForegroundColor Green
    }
    catch {
        throw "Connection to '$SiteUrl' failed. $($_.Exception.Message)"
    }

    # ========================================================
    # VALIDATE PAGE LIBRARY
    # ========================================================

    Write-Host ""
    Write-Host "Validating page library '$PageLibrary'..." -ForegroundColor Cyan

    try {
        $Library = Get-PnPList `
            -Identity $PageLibrary `
            -ErrorAction Stop
    }
    catch {

        Write-Host ""
        Write-Host "The '$PageLibrary' library was not found." `
            -ForegroundColor Red

        Write-Host ""
        Write-Host "Document libraries available on this site:" `
            -ForegroundColor Yellow

        Get-PnPList |
            Where-Object {
                $_.BaseType -eq "DocumentLibrary" -and
                -not $_.Hidden
            } |
            Select-Object Title, ItemCount, Hidden |
            Sort-Object Title |
            Format-Table -AutoSize

        throw "Required page library '$PageLibrary' was not found."
    }

    Write-Host "Page library found: $($Library.Title)" `
        -ForegroundColor Green

    Write-Host "Library item count: $($Library.ItemCount)"

    # ========================================================
    # GET PAGE ITEMS
    # ========================================================

    Write-Host ""
    Write-Host "Reading items from '$PageLibrary'..." -ForegroundColor Cyan

    try {
        $Items = @(
            Get-PnPListItem `
                -List $Library.Id `
                -PageSize 500 `
                -Fields `
                    "FileLeafRef",
                    "FileRef",
                    "FSObjType",
                    "Title",
                    "ClientSideApplicationId",
                    "Created",
                    "Modified" `
                -ErrorAction Stop
        )
    }
    catch {
        throw "Unable to read items from '$PageLibrary'. $($_.Exception.Message)"
    }

    Write-Host "Items retrieved: $($Items.Count)"

    # ========================================================
    # CLASSIFY ASPX PAGES
    # ========================================================

    Write-Host ""
    Write-Host "Classifying ASPX pages..." -ForegroundColor Cyan

    $Report = foreach ($Item in $Items) {

        $FileName = [string]$Item.FieldValues["FileLeafRef"]

        # Skip folders and anything that is not an ASPX page
        if (
            $Item.FileSystemObjectType -ne "File" -or
            [string]::IsNullOrWhiteSpace($FileName) -or
            $FileName -notlike "*.aspx"
        ) {
            continue
        }

        $ClientSideApplicationId = [string]$Item.FieldValues[
            "ClientSideApplicationId"
        ]

        if (
            $ClientSideApplicationId -eq $ModernPageApplicationId
        ) {
            $PageType = "Modern"
        }
        else {
            $PageType = "Classic"
        }

        [PSCustomObject]@{
            ReportID                = $ReportID
            SiteUrl                 = $SiteUrl
            Library                 = $PageLibrary
            PageName                = $FileName
            Title                   = [string]$Item.FieldValues["Title"]
            PageType                = $PageType
            ClientSideApplicationId = $ClientSideApplicationId
            PageUrl                 = [string]$Item.FieldValues["FileRef"]
            Created                 = $Item.FieldValues["Created"]
            Modified                = $Item.FieldValues["Modified"]
            AuditedBy               = $RunBy
            AuditDateTime           = $RunDateTime
        }
    }

    $Report = @(
        $Report |
            Sort-Object PageType, PageName
    )

    # ========================================================
    # CHECK RESULTS
    # ========================================================

    if ($Report.Count -eq 0) {

        Write-Host ""
        Write-Host "No ASPX pages were found in '$PageLibrary'." `
            -ForegroundColor Yellow

        Write-Host ""
        Write-Host "If this is a classic publishing site, try:" `
            -ForegroundColor Yellow

        Write-Host '$PageLibrary = "Pages"' `
            -ForegroundColor Yellow

        return
    }

    # ========================================================
    # COUNTS
    # ========================================================

    $ModernCount = @(
        $Report |
            Where-Object { $_.PageType -eq "Modern" }
    ).Count

    $ClassicCount = @(
        $Report |
            Where-Object { $_.PageType -eq "Classic" }
    ).Count

    # ========================================================
    # EXPORT CSV
    # ========================================================

    Write-Host ""
    Write-Host "Exporting report..." -ForegroundColor Cyan

    $Report |
        Export-Csv `
            -Path $OutputFile `
            -NoTypeInformation `
            -Encoding UTF8 `
            -Force `
            -ErrorAction Stop

    # ========================================================
    # RESULTS
    # ========================================================

    $ScriptEnd = Get-Date
    $Duration  = $ScriptEnd - $ScriptStart

    Write-Host ""
    Write-Host "============================================================" `
        -ForegroundColor Cyan

    Write-Host " Page classification results" `
        -ForegroundColor Cyan

    Write-Host "============================================================"

    Write-Host "Report ID     : $ReportID"
    Write-Host "Library       : $PageLibrary"
    Write-Host "Total pages   : $($Report.Count)"
    Write-Host "Modern pages  : $ModernCount" -ForegroundColor Green
    Write-Host "Classic pages : $ClassicCount" -ForegroundColor Yellow
    Write-Host "Report        : $OutputFile"
    Write-Host "Log           : $LogFile"
    Write-Host "Duration      : $($Duration.ToString('hh\:mm\:ss'))"

    Write-Host ""
    Write-Host "Page summary:" -ForegroundColor Cyan
    Write-Host ""

    $Report |
        Select-Object PageName, PageType, Modified, PageUrl |
        Format-Table -AutoSize

    Write-Host ""
    Write-Host "Audit completed successfully." -ForegroundColor Green
}
catch {

    Write-Host ""
    Write-Host "============================================================" `
        -ForegroundColor Red

    Write-Host " AUDIT FAILED" -ForegroundColor Red

    Write-Host "============================================================"
    Write-Host ""

    Write-Host $_.Exception.Message -ForegroundColor Red

    Write-Host ""
    Write-Host "Check the transcript log:" -ForegroundColor Yellow
    Write-Host $LogFile

    exit 1
}


```

## Output

Results are written to:

> C:\Temp\Report

Each execution generates:

- **SharePoint-Page-Type-Report_YYYYMMDD_HHMMSS.csv**
- **SharePoint-Page-Type-Report_YYYYMMDD_HHMMSS.log**

The CSV contains information including:

- Report ID
- Site URL
- Page library
- Page name
- Page title
- Page type
- Client-side application ID
- Page URL
- Created date
- Modified date
- Auditing account
- Audit timestamp

## Notes

- The script is read-only against SharePoint content; it does not modify or delete pages.
- Authentication uses certificate-based app-only authentication rather than interactive credentials.
- The script only classifies **.aspx** files within the configured library.
- A page classified as **Classic** should be treated as an audit finding rather than definitive proof that the page requires migration; further validation may be appropriate for complex SharePoint implementations.
- The output directory is created automatically if it does not already exist.
- A unique **ReportID** allows individual audit runs to be correlated across exported reports and logs.
- The transcript provides additional diagnostic information if authentication, library discovery, or item retrieval fails.

## Contributors

|Author(s)|
|-----------|
|[Josiah Opiyo](https://github.com/ojopiyo)|

*Built with a focus on automation, governance, least privilege, and clean Microsoft 365 tenants - helping M365 admins gain visibility and reduce operational risk.*

## Version history

|Version|Date|Comments|
|-------|----|--------|
|1.0|September 09, 2026|Initial release|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
