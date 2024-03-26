# Declare and initialize your app-only authentication details
$clientId = "xxxxx"
$tenantId = "xxxxx"
$thumbprint = "xxxx"
$TimeFilter = (Get-Date).AddYears(-4)

# Initialize audit log
$auditLog = @()
$timestamp = Get-Date -Format "MMddyyyyHHmmss"


Start-Transcript -Append ".\logs\SharePoint Custom Scan- $timestamp log.txt" -UseMinimalHeader -IncludeInvocationHeader

try {
    # Import CSV with SharePoint Site URLs
    $urls = Import-Csv -Path "<Path>\CustomSPUrls.csv"
    Write-Host "csv imported, starting process" -ForegroundColor green
    foreach ($url in $urls) {
        $timestamp = Get-Date -Format "MMddyyyyHHmmss"
        Connect-PnPOnline -Url $url.URL -ClientId $clientId -Thumbprint $thumbprint -Tenant $tenantId -ErrorAction Stop
        Write-Host "connected to site: $url at $timestamp" -ForegroundColor green
        Write-host "getting libraries" -ForegroundColor yellow
        $lib = $url.LibraryName  # Get specific document library
        Write-Host "starting scans" -ForegroundColor yellow
        $ScanFolder = $url.FolderName
        write-host "scanning $ScanFolder"
        $timestamp = Get-Date -Format "MMddyyyyHHmmss"
        Write-Host "Starting $lib at $timestamp " -ForegroundColor Blue | Format-List *
                       
            $items = Get-PnPListItem -List $lib -folderServerRelativeURL $ScanFolder -PageSize 1000 -ErrorAction Stop | Where {$_["Modified"] -Lt $TimeFilter}
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
            # Assuming $result is a collection of all your objects
            # Sort the results first by FilePath, then by LastModified
            $sortedResults = $result | Sort-Object -Property FilePath, LastModified

            $timestamp = Get-Date -Format "MMddyyyyHHmmss"
            Write-host "items placed in table at $timestamp, preparing to export" -ForegroundColor Green
            $ReportFileName = $url.DestFileName
            $localExportFullPath = ".\2.SharePoint Reports\$ReportFileName - $timestamp.xlsx"
            $sortedresults | Export-Excel -Path $localExportFullPath
            write-host "Local export complete, uploading to document library" -ForegroundColor Green
            $DestFolder = $url.Destination
            write-host "uploading to $DestFolder" -ForegroundColor Yellow
            Add-PnPFile -Path $localExportFullPath -Folder "$DestFolder" -ErrorAction Stop
            Write-host 'file uploaded!' -ForegroundColor green
            $timestamp = Get-Date -Format "MMddyyyyHHmmss"
            Write-host "Site complete at $timestamp, starting next site or ending" -ForegroundColor green
        }
        
    
} catch {
    Write-Host "An error occurred: $_"
}

Stop-Transcript