# Find Files which are not searchable

The script gets the crawl log information to determine indexing recency and check whether the file is actually searchable. The underlying cause can vary, and in many cases you may need to raise a support case with Microsoft for deeper investigation if reindexing the site or library does not fix the issues.

## Summary

# [PnP PowerShell](#tab/pnpps)

```powershell
cls
#Requires -Modules PnP.PowerShell
Clear-Host

# ===== Settings =====
$clientId     = "xxxxxx"
$dateTime     = Get-Date -Format "yyyy-MM-dd-HH-mm-ss"
$tenantUrl    = "https://contoso.sharepoint.com"

# NEW: File extensions to exclude (case-insensitive) as they can't be searched using their Path metadata, e.g. Path:FileUrl
$ExcludedExtensions = @('.png', '.jpg', '.jpeg', '.xltx', '.one', '.onetoc2', '.gif','.mp4','.agent')

$invocation     = Get-Variable -Name MyInvocation -ValueOnly
$directoryPath  = Split-Path $invocation.MyCommand.Path
$csvPath        = Join-Path $directoryPath "sites1.csv"   # CSV must have a column 'SiteUrl' containing a list of site urls

# Ensure output folder exists
$outputFolder = Join-Path $directoryPath "output_files"
if (-not (Test-Path $outputFolder)) { New-Item -ItemType Directory -Path $outputFolder | Out-Null }
$outputCsv    = Join-Path $outputFolder ("NonSearchableIndexable-" + $dateTime + ".csv")

# Lists/libraries to exclude
$ExcludedLists = @(
    "Access Requests","App Packages","appdata","appfiles","Apps in Testing","Cache Profiles","Composed Looks",
    "Content and Structure Reports","Content type publishing error log","Converted Forms","Device Channels",
    "Form Templates","fpdatasources","Get started with Apps for Office and SharePoint","List Template Gallery",
    "Long Running Operation Status","Maintenance Log Library","Images","site collection images","Master Docs",
    "Master Page Gallery","MicroFeed","NintexFormXml","Quick Deploy Items","Relationships List","Reusable Content",
    "Reporting Metadata","Reporting Templates","Search Config List","Site Assets","Preservation Hold Library",
    "Site Pages","Solution Gallery","Style Library","Suggested Content Browser Locations","Theme Gallery",
    "TaxonomyHiddenList","User Information List","Web Part Gallery","wfpub","wfsvc","Workflow History",
    "Workflow Tasks","Pages"
)

# ===== Safety checks =====
if (-not (Test-Path $csvPath)) {
    Write-Error "CSV not found at $csvPath. Ensure it exists and includes a 'SiteUrl' column."
    exit 1
}

# ===== Helpers =====
function Normalize-Url {
    param([string]$Url)
    if ([string]::IsNullOrWhiteSpace($Url)) { return $null }
    return ($Url.Trim().TrimEnd('/') ).ToLowerInvariant()
}
function Get-UrlVariants {
    param([string]$Url)
    if ([string]::IsNullOrWhiteSpace($Url)) { return @() }
    $u = $Url.Trim()
    $variants = New-Object System.Collections.Generic.List[string]
    $variants.Add((Normalize-Url $u))
    # Add encoded/decode space variants
    $variants.Add((Normalize-Url ($u -replace ' ', '%20')))
    $variants.Add((Normalize-Url ($u -replace '%20', ' ')))
    $variants | Where-Object { $_ } | Select-Object -Unique
}

# ===== Collect results =====
$results = New-Object System.Collections.Generic.List[object]
$sites   = Import-Csv -Path $csvPath   # expects column "SiteUrl"

foreach ($s in $sites) {
    $siteUrl = $s.SiteUrl
    if ([string]::IsNullOrWhiteSpace($siteUrl)) { continue }

    Write-Host "Connecting to site: $siteUrl" -ForegroundColor Cyan

    try {
        # Connect interactively with the client ID
        Connect-PnPOnline -ClientId $clientId -Url $siteUrl -Interactive

        # Get only visible document libraries (exclude hidden/system libraries)
        $libraries = Get-PnPList -Includes BaseType, BaseTemplate, Hidden, Title, ItemCount, RootFolder `
        | Where-Object {
                $_.Hidden -eq $false -and
                $_.BaseType -eq "DocumentLibrary" -and
                $_.Title -notin $ExcludedLists
            }

        foreach ($library in $libraries) {
            $libraryAbsUrl = ($tenantUrl.TrimEnd('/')) + $library.RootFolder.ServerRelativeUrl
            Write-Host "  Library: $($library.Title)" -ForegroundColor Yellow

            # Pull only fields we need and page for large lists
            $listItems = Get-PnPListItem -List $library -PageSize 500 `
                                         -Fields "FileRef","FSObjType"  `
                                         -ErrorAction SilentlyContinue

            # ==== SEARCH RESULTS (library scope) ====
            $kql = "Path:`"$libraryAbsUrl`""
            $searchresults = $null
            try {
                $searchresults = Submit-PnPSearchQuery `
                    -Query $kql `
                    -All `
                    -SelectProperties @("Title","Path","LastModifiedTime") `
                    -SortList @{ "LastModifiedTime" = "Descending" } `
                    -ErrorAction SilentlyContinue
            } catch {}

            # Build a fast lookup of paths from search results
            $searchPathSet = New-Object 'System.Collections.Generic.HashSet[string]'
            if ($searchresults) {
                $searchRows = @()
                if ($searchresults.ResultRows) { $searchRows = $searchresults.ResultRows }

                foreach ($row in $searchRows) {
                    $p = $null
                    if ($row -is [System.Collections.IDictionary])      { $p = [string]$row["Path"] }
                    elseif ($row.PSObject.Properties.Match("Path"))     { $p = [string]$row.Path }
                    if ($p) {
                        # OPTIONAL: skip excluded extensions to keep the set cleaner
                        $ext = [System.IO.Path]::GetExtension($p)
                        if ($ext -and ($ExcludedExtensions -contains $ext.ToLower())) { continue }
                        $null = $searchPathSet.Add((Normalize-Url $p))
                    }
                }
            }

            # ==== CRAWL LOG (library scope) ====
            $crawlresults = $null
            $crawlMap = @{}   # url (normalized) -> [DateTime] max last indexed time
            try {
                $crawlresults = Get-PnPSearchCrawlLog -Filter $libraryAbsUrl -RowLimit (($library.ItemCount * 2)+10)
                if ($crawlresults) {
                    foreach ($cr in $crawlresults) {
                        $urlVal = $cr.Url
                        if (-not $urlVal) { continue }

                        # OPTIONAL: skip excluded extensions here as well
                        $ext = [System.IO.Path]::GetExtension($urlVal)
                        if ($ext -and ($ExcludedExtensions -contains $ext.ToLower())) { continue }

                        $lastIdx = $null
                        try { $lastIdx = [datetime]$cr.CrawlTime } catch {}

                        $nUrl = Normalize-Url $urlVal
                        if ($nUrl) {
                            if (-not $crawlMap.ContainsKey($nUrl)) {
                                $crawlMap[$nUrl] = $lastIdx
                            } else {
                                if ($lastIdx -and $crawlMap[$nUrl] -and ($lastIdx -gt $crawlMap[$nUrl])) {
                                    $crawlMap[$nUrl] = $lastIdx
                                } elseif ($lastIdx -and -not $crawlMap[$nUrl]) {
                                    $crawlMap[$nUrl] = $lastIdx
                                }
                            }
                        }
                    }
                }
            } catch {
                Write-Verbose "Crawl log query failed for $libraryAbsUrl : $($_.Exception.Message)"
            }

            # ==== Evaluate each file ====
            foreach ($item in $listItems) {
                # FSObjType: 0=file, 1=folder
                if ($item.FieldValues["FSObjType"] -ne 0) { continue }

                $serverRelative = $item.FieldValues["FileRef"]
                if ([string]::IsNullOrWhiteSpace($serverRelative)) { continue }

                # NEW: Skip unwanted extensions up front
                $ext = [System.IO.Path]::GetExtension($serverRelative)
                if ($ext -and ($ExcludedExtensions -contains $ext.ToLower())) { continue }

                $fullUrl = ($tenantUrl.TrimEnd('/')) + $serverRelative
                $urlVariants = Get-UrlVariants -Url $fullUrl

                # SEARCHABLE? (if any variant appears in search results)
                $searchable = "No"
                foreach ($v in $urlVariants) {
                    if ($searchPathSet.Contains($v)) { $searchable = "Yes"; break }
                }

                # INDEXED? (if any variant appears in crawl log map)
                $indexed = "No"
                $lastIndexedTime = $null
                foreach ($v in $urlVariants) {
                    if ($crawlMap.ContainsKey($v)) {
                        $indexed = "Yes"
                        $lastIndexedTime = $crawlMap[$v]
                        break
                    }
                }

                if (!($indexed -eq "Yes" -and $searchable -eq "Yes")) { 
                    $results.Add([pscustomobject]@{
                        SiteUrl                = $siteUrl
                        LibraryTitle           = $library.Title
                        LibraryUrl             = $libraryAbsUrl
                        FileServerRelativePath = $serverRelative
                        FullUrl                = $fullUrl
                        Indexed                = $indexed
                        LastIndexedTime        = $lastIndexedTime
                        Searchable             = $searchable
                    })
                }
            }
        }
    }
    catch {
        Write-Warning "Failed on site $siteUrl. Error: $($_.Exception.Message)"
        continue
    }
}
# ===== Export =====
$results | Export-Csv -Path $outputCsv -NoTypeInformation -Encoding UTF8
Write-Host "Export complete: $outputCsv" -ForegroundColor Green

```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]


## Source Credit

Sample idea first appeared on [Get-PnPSearchCrawlLog. Search as alternatives with gotchas. Not a replacement for crawl log](https://reshmeeauckloo.com/posts/powershell-sharepoint-files-indexable-searchable/). 

## Contributors

| Author(s) |
|-----------|
| [Reshmee Auckloo](https://github.com/reshmee011) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-crawllog-indexed-searchable" aria-hidden="true" />