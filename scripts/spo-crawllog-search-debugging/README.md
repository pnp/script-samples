# Debugging SharePoint Search by Inspecting Crawl Log

```powershell
#requires -Modules PnP.PowerShell

============================================================
    Configuration 
============================================================

$ClientID = "xxxxxxxxxxxxxxxxxxxxx"
$ThumbPrint = "xxxxxxxxxxxxxxxxxxxxx"
$Tenant = "contoso.onmicrosoft.com"

$OutputFolder = "C:\Temp\SharePointSearchIndexingAssessment"

CSV containing a column named "SiteUrl"

$SiteCsvPath = Join-Path $PSScriptRoot "Sites.csv"

Maximum crawl-log entries requested per library

$CrawlLogRowLimit = 50000

============================================================
    Output
============================================================

if (-not (Test-Path -LiteralPath $OutputFolder)) {
New-Item -Path $OutputFolder -ItemType Directory -Force | Out-Null
}

$TimeStamp = Get-Date -Format "yyyyMMdd_HHmmss"

$OutputCsv = Join-Path $OutputFolder `
"SharePointSearchIndexingAssessment_$TimeStamp.csv"

$LogFile = Join-Path $OutputFolder `
"SharePointSearchIndexingAssessment_$TimeStamp.log"

============================================================
    Excluded SharePoint Lists/Libraries
============================================================

$ExcludedLists = @(
"Access Requests",
"App Packages",
"appdata",
"appfiles",
"Apps in Testing",
"Cache Profiles",
"Composed Looks",
"Content and Structure Reports",
"Content type publishing error log",
"Converted Forms",
"Device Channels",
"Form Templates",
"fpdatasources",
"Get started with Apps for Office and SharePoint",
"List Template Gallery",
"Long Running Operation Status",
"Maintenance Log Library",
"Images",
"site collection images",
"Master Docs",
"Master Page Gallery",
"MicroFeed",
"NintexFormXml",
"Quick Deploy Items",
"Relationships List",
"Reusable Content",
"Reporting Metadata",
"Reporting Templates",
"Search Config List",
"Site Assets",
"Site Pages",
"Preservation Hold Library",
"Solution Gallery",
"Style Library",
"Suggested Content Browser Locations",
"TaxonomyHiddenList",
"User Information List",
"Web Part Gallery",
"wfpub",
"wfsvc",
"Workflow History",
"Workflow Tasks",
"Pages"
)

============================================================
    Functions
============================================================

function Write-Log {
param (
[Parameter(Mandatory)]
[string]$Message,

    [ValidateSet("INFO", "WARNING", "ERROR")]
    [string]$Level = "INFO"
)

$LogMessage = "{0} [{1}] {2}" -f `
    (Get-Date -Format "yyyy-MM-dd HH:mm:ss"),
    $Level,
    $Message

Add-Content -LiteralPath $LogFile -Value $LogMessage

switch ($Level) {
    "INFO" {
        Write-Host $LogMessage -ForegroundColor Gray
    }

    "WARNING" {
        Write-Host $LogMessage -ForegroundColor Yellow
    }

    "ERROR" {
        Write-Host $LogMessage -ForegroundColor Red
    }
}


}

============================================================
    Validation
============================================================

if (-not (Test-Path -LiteralPath $SiteCsvPath)) {
throw "Site CSV not found: $SiteCsvPath"
}

$sites = Import-Csv -LiteralPath $SiteCsvPath

if (-not $sites) {
throw "No sites were found in: $SiteCsvPath"
}

if (-not ($sites[0].PSObject.Properties.Name -contains "SiteUrl")) {
throw "The site CSV must contain a column named 'SiteUrl'."
}

============================================================
    Results 
============================================================

$Results = [System.Collections.Generic.List[object]]::new()

$SiteNumber = 0
$SiteCount = $sites.Count

============================================================
    Assessment
============================================================

foreach ($site in $sites) {

$SiteNumber++
$SiteUrl = $site.SiteUrl

if ([string]::IsNullOrWhiteSpace($SiteUrl)) {
    Write-Log "Skipping blank SiteUrl entry." "WARNING"
    continue
}

Write-Log "[$SiteNumber/$SiteCount] Connecting to $SiteUrl"

try {

    Connect-PnPOnline `
        -Url $SiteUrl `
        -ClientId $ClientID `
        -Tenant $Tenant `
        -Thumbprint $ThumbPrint `
        -ErrorAction Stop

    Write-Log "Connected to $SiteUrl"

    # Get visible document libraries only
    $Libraries = Get-PnPList `
        -Includes BaseType, BaseTemplate, Hidden, Title, ItemCount, RootFolder `
        -ErrorAction Stop |
        Where-Object {
            $_.Hidden -eq $false -and
            $_.BaseType -eq "DocumentLibrary" -and
            $_.Title -notin $ExcludedLists
        }

    foreach ($Library in $Libraries) {

        try {

            # Use the actual SharePoint root folder URL
            $LibraryUrl = $SiteUrl.TrimEnd("/") +
                "/" +
                $Library.RootFolder.Name

            Write-Log "Processing library: $($Library.Title)"

            # Avoid requesting more crawl-log rows than necessary,
            # while still allowing large libraries to be assessed.
            $RowLimit = [Math]::Min(
                [int]$Library.ItemCount,
                $CrawlLogRowLimit
            )

            # A library with no items has nothing to assess.
            if ($RowLimit -le 0) {
                Write-Log "Skipping empty library: $($Library.Title)"
                continue
            }

            $CrawlEntries = Get-PnPSearchCrawlLog `
                -Filter $LibraryUrl `
                -RowLimit $RowLimit `
                -RawFormat `
                -ErrorAction Stop

            # Candidate crawl-log entries:
            # SPItemModifiedTime is blank.
            $Candidates = $CrawlEntries | Where-Object {
                [string]::IsNullOrWhiteSpace(
                    [string]$_.SPItemModifiedTime
                )
            }

            if (-not $Candidates) {
                continue
            }

            Write-Log "$($Candidates.Count) candidate crawl-log entries found in $($Library.Title)"

            foreach ($Candidate in $Candidates) {

                $FileUrl = $Candidate.FullUrl

                if ([string]::IsNullOrWhiteSpace($FileUrl)) {
                    continue
                }

                # Exclude library root and known non-document URLs.
                if ($FileUrl -eq $LibraryUrl) {
                    continue
                }

                if ($FileUrl -like "*/Forms/Default.aspx") {
                    continue
                }

                if ($FileUrl -like "*.aspx*") {
                    continue
                }

                if ($FileUrl -like "*.one*") {
                    continue
                }

                Write-Log "Validating search visibility: $FileUrl"

                try {

                    # Query the SharePoint Search index for the exact URL.
                    # A result confirms that Search currently knows about
                    # the item. No result confirms the candidate finding.
                    $SearchQuery = 'Path:"{0}"' -f $FileUrl

                    $SearchResult = Submit-PnPSearchQuery `
                        -Query $SearchQuery `
                        -MaxResults 1 `
                        -SelectProperties @(
                            "Title",
                            "Path"
                        ) `
                        -ErrorAction Stop

                    $SearchResultCount = 0

                    if ($null -ne $SearchResult.ResultRows) {
                        $SearchResultCount = @(
                            $SearchResult.ResultRows
                        ).Count
                    }
                    elseif ($null -ne $SearchResult.RowCount) {
                        $SearchResultCount = [int]$SearchResult.RowCount
                    }

                    # Only report when Search could not find the item.
                    if ($SearchResultCount -eq 0) {

                        $Result = [PSCustomObject]@{

                            SiteUrl            = $SiteUrl
                            LibraryName        = $Library.Title
                            LibraryUrl         = $LibraryUrl
                            FileUrl            = $FileUrl
                            SPItemModifiedTime = $Candidate.SPItemModifiedTime
                            CrawlTime          = $Candidate.CrawlTime
                            ErrorCode          = $Candidate.ErrorCode
                            SearchResultCount  = $SearchResultCount
                            Finding            = "Potential Search indexing issue"
                        }

                        $Results.Add($Result)

                        Write-Log "FINDING: File appears in crawl log but is not searchable: $FileUrl" "WARNING"
                    }
                }
                catch {

                    Write-Log `
                        "Search validation failed for $FileUrl - $($_.Exception.Message)" `
                        "ERROR"
                }
            }
        }
        catch {

            Write-Log `
                "Failed to process library '$($Library.Title)' on $SiteUrl - $($_.Exception.Message)" `
                "ERROR"
        }
    }
}
catch {

    Write-Log `
        "Failed to process site $SiteUrl - $($_.Exception.Message)" `
        "ERROR"
}
finally {

    Disconnect-PnPOnline -ErrorAction SilentlyContinue

    Write-Log "Disconnected from $SiteUrl"
}


}

============================================================
    Export
============================================================

if ($Results.Count -gt 0) {

$Results |
    Export-Csv `
        -LiteralPath $OutputCsv `
        -NoTypeInformation `
        -Encoding UTF8

Write-Log "Assessment complete. $($Results.Count) findings exported to $OutputCsv"


}
else {

Write-Log "Assessment complete. No potential search indexing issues were identified."

# Still create the CSV with the expected headers.
$EmptyResult = [PSCustomObject]@{
    SiteUrl            = $null
    LibraryName        = $null
    LibraryUrl         = $null
    FileUrl            = $null
    SPItemModifiedTime = $null
    CrawlTime          = $null
    ErrorCode          = $null
    SearchResultCount  = $null
    Finding            = $null
}

$EmptyResult |
    Export-Csv `
        -LiteralPath $OutputCsv `
        -NoTypeInformation `
        -Encoding UTF8


}

Write-Host ""
Write-Host "Assessment finished." -ForegroundColor Green
Write-Host "Findings CSV : $OutputCsv" -ForegroundColor Green
Write-Host "Log file : $LogFile" -ForegroundColor Green




```

## Output

A timestamped file is generated in the configured output directory:

> SharePointSearchIndexingAssessment_20260928_164000.csv

### CSV Report Fields

| FindingId | AssessmentDate | SiteUrl | LibraryName | FileName | FileUrl | CrawlLogStatus | SPItemModifiedTime | CrawlTime | SearchStatus | SearchResultCount | CrawlErrorCode | Finding |
| -------- | --------------- | -------------------------------------------- | ----------- | ------------------------ | ------------------------------------------------------------------------------- | -------------- | ------------------ | --------- | ------------ | ----------------- | -------------- | ------- |
| 1 | 20260928_164000 | <https://contoso.sharepoint.com/sites/Finance> | Documents | Annual Report 2025.docx | <https://contoso.sharepoint.com/sites/Finance/Documents/Annual Report 2025.docx> | Found | Blank | 2026-09-28T14:32:11Z | Not Found | 0 | 0 | Crawl log entry has blank SPItemModifiedTime and file was not returned by SharePoint Search |
| 2 | 20260928_164000 | <https://contoso.sharepoint.com/sites/Projects> | Shared Documents | Project Plan.docx | <https://contoso.sharepoint.com/sites/Projects/Shared Documents/Project Plan.docx> | Found | Blank | 2026-09-28T14:41:03Z | Not Found | 0 | 0 | Crawl log entry has blank SPItemModifiedTime and file was not returned by SharePoint Search |

### Column Descriptions

| Column | Description |
| ------ | ------------ |
| `FindingId` | Unique sequential identifier for the finding in the assessment run. |
| `AssessmentDate` | Timestamp identifying when the assessment was performed. |
| `SiteUrl` | SharePoint site containing the affected file. |
| `LibraryName` | Document library containing the file. |
| `FileName` | Name of the affected file. |
| `FileUrl` | Full URL of the affected file. |
| `CrawlLogStatus` | Confirms that the file was identified in the SharePoint crawl log. |
| `SPItemModifiedTime` | Value reported by the crawl log. A value of Blank is the key indicator used by this assessment. |
| `CrawlTime` | Time associated with the crawl-log entry |
| `SearchStatus` | Result of the independent SharePoint Search validation. Not Found means the exact file URL was not returned. |
| `SearchResultCount` | Number of Search results returned for the validation query. The assessment expects 0 for a finding. |
| `CrawlErrorCode` | Error code reported by the SharePoint crawl log |
| `Finding` | Human-readable explanation of why the file was flagged. |

## Notes

### Crawl-log limit

The script uses:

> $CrawlLogRowLimit = 50000

This is a configurable safeguard for large libraries.

If your environment contains libraries where more than 50,000 relevant crawl-log entries need to be assessed, the crawl-log retrieval approach should be revisited rather than simply assuming that increasing the number indefinitely is appropriate.

## Contributors

|Author(s)|
|-----------|
|[Reshmee Auckloo](https://github.com/reshmee011)|
|[Josiah Opiyo](https://github.com/ojopiyo)|

*Built with a focus on automation, governance, least privilege, and clean Microsoft 365 tenants - helping M365 admins gain visibility and reduce operational risk.*

## Version history

|Version|Date|Comments|
|-------|----|--------|
|1.0|December 14, 2025|Initial release|
|2.0|September 28, 2026|Refactored version|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
