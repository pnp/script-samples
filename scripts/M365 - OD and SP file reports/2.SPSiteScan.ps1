# Declare and initialize your app-only authentication details
$clientId = "xxxxxx"
$tenantId = "xxxxx"
$thumbprint = "xxxxxx"
$TimeFilter = (Get-Date).AddYears(-4)

# Initialize audit log
$auditLog = @()
$timestamp = Get-Date -Format "MMddyyyyHHmmss"


Start-Transcript -Append ".\logs\SharePoint Scan- $timestamp log.txt" -UseMinimalHeader -IncludeInvocationHeader

try {
    # Import CSV with SharePoint Site URLs
    $urls = Import-Csv -Path "<Path>\Script2SPURLs.csv"
    Write-Host "csv imported, starting process" -ForegroundColor green
    foreach ($url in $urls) {
        $timestamp = Get-Date -Format "MMddyyyyHHmmss"
        Connect-PnPOnline -Url $url.URL -ClientId $clientId -Thumbprint $thumbprint -Tenant $tenantId -ErrorAction Stop
        Write-Host "connected to site: $url at $timestamp" -ForegroundColor green
        Write-host "getting libraries" -ForegroundColor yellow
        $libs = Get-PnPList | Where-Object { $_.BaseType -eq "DocumentLibrary" }  # Get only document libraries
        Write-Host "libraries found, starting scans" -ForegroundColor yellow
       
        foreach ($lib in $libs) {
            
            #if ($lib.RootFolder.ServerRelativeUrl -notlike "*_catalogs/hubsite*") {
            if (-Not $lib.Hidden -And $lib.BaseTemplate -Ne 115 -And $lib.Title -Ne 'Style Library'){
                $libTitle = $lib.Title
                $timestamp = Get-Date -Format "MMddyyyyHHmmss"
            Write-Host "Starting $libTitle at $timestamp " -ForegroundColor Blue | Format-List *
                       
            $items = Get-PnPListItem -List $lib.Title -PageSize 1000 -ErrorAction Stop | Where {$_["Modified"] -Lt $TimeFilter}
            $timestamp = Get-Date -Format "MMddyyyyHHmmss"
            Write-Host "items finished scanning at $timestamp, creating table" -ForegroundColor green
            $result = @()

            foreach ($item in $items) {
                $result += [PSCustomObject]@{
                    "FilePath"        = $item["FileDirRef"]
                    "FileName"        = $item["FileLeafRef"]
                    "LastModified"    = $item["Modified"]
                    "CreatedBy"       = $item["Author"].LookupValue
                    "ModifiedBy"      = $item["Editor"].LookupValue
                    "Created"         = $item["Created"]
                    "Size"            = $item["File_x0020_Size"]
                    "RetentionLabel"  = $item["ComplianceAssetId"]
                }
            }
            $timestamp = Get-Date -Format "MMddyyyyHHmmss"

            # Assuming $result is a collection of all your objects
            # Sort the results first by FilePath, then by LastModified
            $sortedResults = $result | Sort-Object -Property FilePath, LastModified

            Write-host "items placed in table at $timestamp, preparing to export" -ForegroundColor Green
            $localExportFullPath = ".\2.SharePoint Reports\1.File Report - $libTitle - $timestamp.xlsx"
            $sortedresults | Export-Excel -Path $localExportFullPath
            write-host "Local export complete, uploading to document library" -ForegroundColor Green
            $folderUrl = $lib.RootFolder.ServerRelativeUrl.Trim()
            write-host "uploading to $folderURL" -ForegroundColor Yellow
            Add-PnPFile -Path $localExportFullPath -Folder "$folderUrl" -ErrorAction Stop
            Write-host 'file uploaded, starting next library'
            }}
            $timestamp = Get-Date -Format "MMddyyyyHHmmss"
        Write-host "Site complete at $timestamp, starting next site or ending" -ForegroundColor green
    }
} catch {
    Write-Host "An error occurred: $_"
}

Stop-Transcript