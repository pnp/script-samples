

# Debugging SharePoint Search by inspecting crawl log

This script helps identify files that appear in the crawl logs but are still not searchable. The underlying cause can vary, and in many cases you may need to raise a support case with Microsoft for deeper investigation.

In our scenario, the issue was caused by sensitivity labels already applied to files that had been moved from another location. This created a conflict with the sensitivity label inherited from the parent library, which prevented the files from being indexed correctly.

A key indicator was that the `SPItemModifiedTime` field was blank in the crawl log, a symptom that often correlates with search indexing problems. To confirm the issue, I also performed a search query to verify that the affected files were indeed not discoverable.

## Summary

# [PnP PowerShell](#tab/pnpps)

```powershell
cls

# ===== Settings =====
$clientId    = "xxxxxxxx"
$dateTime    = Get-Date -Format "yyyy-MM-dd-HH-mm-ss"

$invocation      = Get-Variable -Name MyInvocation -ValueOnly
$directoryPath   = Split-Path $invocation.MyCommand.Path
$csvPath         = Join-Path $directoryPath "Sites.csv"     # CSV must have a column 'SiteUrl'

# Ensure output folder exists
$outputFolder    = Join-Path $directoryPath "output_files"
if (-not (Test-Path $outputFolder)) { New-Item -ItemType Directory -Path $outputFolder | Out-Null }
$outputCsv       = Join-Path $outputFolder ("CrawlLog-SPItemModifiedTime-Null-" + $dateTime + ".csv")

# System/ignored lists
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

# ===== Collect results =====
$results = New-Object System.Collections.Generic.List[object]
$sites   = Import-Csv -Path $csvPath   # expects column "SiteUrl"

foreach ($s in $sites) {
    $siteUrl = $s.SiteUrl
    Write-Host "Connecting to site: $siteUrl" -ForegroundColor Cyan

    # Connect interactively with the client ID (adjust auth as needed for your tenant)
    Connect-PnPOnline -ClientId $clientId -Url $siteUrl -Interactive

    # Get only visible document libraries
    $lists = Get-PnPList -Includes BaseType, BaseTemplate, Hidden, Title, ItemCount, RootFolder |
        Where-Object {
            $_.Hidden -eq $false -and
            $_.BaseType -eq "DocumentLibrary" -and
            $_.Title -notin $ExcludedLists
        }

    foreach ($library in $lists) {
        # Build library URL: e.g. https://tenant/sites/site/Shared Documents
        $libraryUrl = ($siteUrl.TrimEnd('/')) + '/' +  $library.rootfolder.Name
        Write-Host "Querying library: $($library.Title)" -ForegroundColor Yellow

        # Keep row limit reasonable to avoid huge payloads
        $rowLimit = $library.ItemCount

        # Pull crawl log entries; filter to items with null/empty SPItemModifiedTime
        $entries = Get-PnPSearchCrawlLog -Filter $libraryUrl -RowLimit $rowLimit -RawFormat |
            Where-Object { $_.SPItemModifiedTime -eq $null }

        # Shape results for export; include FullUrl (fallback to DocumentUrl if missing)
        $output = $entries | Where-Object {$_.FullUrl -ne $libraryUrl -and $_.FullUrl -notlike "*`/Forms/Default.aspx" -and $_.FullUrl -notlike "*.aspx*" -and $_.FullUrl -notlike "*.one*"}
        
        foreach($result in $output)
        {   
            # Filter to a site/library path$result.FullUrl and select extra properties
            try{
            $kql = "Path:`"$($result.FullUrl)`""
            $searchr = Submit-PnPSearchQuery -Query $kql -All -SelectProperties @(
            "Title","Path"
            ) -SortList @{LastModifiedTime="Descending"}
     
            if($searchr.Rowcount -lt 1)
            {
            # Create a PSCustomObject row
                    $projected = [pscustomobject]@{
                        FullUrl            = $result.FullUrl
                        DocumentUrl        = $libraryUrl
                        SPItemModifiedTime = $result.SPItemModifiedTime
                        ErrorCode          = $result.ErrorCode
                    }        
                $results.Add($projected)
    
            }
        }
        catch{
            Write-Error "$($_.Exception.Message) for $($result.FullUrl)"
        }
        }    
    }
   # Disconnect-PnPOnline
}

# ===== Export =====
$results | Export-Csv -Path $outputCsv -NoTypeInformation -Encoding UTF8
Write-Host "Export complete: $outputCsv" -ForegroundColor Green

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]


## Source Credit

Sample idea first appeared on [Debugging SharePoint Search with PnP PowerShell and Crawl Logs](https://reshmeeauckloo.com/posts/powershell-sharepoint-debugging-crawllog/). 

## Contributors

| Author(s) |
|-----------|
| [Reshmee Auckloo](https://github.com/reshmee011) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-crawllog-search-debugging" aria-hidden="true" />