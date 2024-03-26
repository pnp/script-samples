# Declare and initialize your app-only authentication details
$clientId = "XXXX"
$tenantId = "XXXX"
$thumbprint = "XXXX"
$TimeFilter = (Get-Date).AddYears(-4)



# Initialize audit log
$auditLog = @()
$timestamp = Get-Date -Format "MMddyyyyHHmmss"


Start-Transcript -Append ".\logs\OneDrive $timestamp log.txt"



try {
    # Import CSV with OneDrive URLs
    Write-host "Starting Script at - $timestamp"
    $urls = Import-Csv -Path "<Path>\OneDriveURLs.csv"
    Write-Host "csv imported, starting process" -ForegroundColor green
    foreach ($url in $urls) {
        # Try to establish a connection
    Connect-PnPOnline -Url $url.URL -ClientId $clientId -Thumbprint $thumbprint -Tenant $tenantId -ErrorAction Stop
     
        $timestamp = Get-Date -Format "MMddyyyyHHmmss"        
        Write-Host "connection to $url successful at $timestamp" -ForegroundColor Green
        
            
$timestamp = Get-Date -Format "MMddyyyyHHmmss"
Write-Host "starting to get items at $timestamp"
          $items = Get-PnPListItem -List "Documents" -PageSize 1000 -ErrorAction Stop | Where {$_["Modified"] -Lt $TimeFilter}
           #$items = Get-PnPListItem -List "Documents" -Query $camlQuery 
           $itemcount = $items.count 
           write-host "found $itemcount items."
            $timestamp = Get-Date -Format "MMddyyyyHHmmss"
            write-host "items done scanning at $timestamp"
            Write-host "iterating through items and organizing. Please wait." -ForegroundColor green
            $result = @()

            foreach ($item in $Items) {
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

            Write-Host "Items iterated through at $timestamp" -ForegroundColor Green
            
            # Extract username from OneDrive URL
            $userName = $url.URL -replace '.*?/personal/', ''
            Write-Host "username is $userName"
            # Export to XLSX (locally)
            write-host "exporting to Excel"
            $localExportFullPath = ".\1.OneDrive Reports\1.OneDrive File Report $userName - $timestamp.xlsx"
            $sortedresults | Export-Excel -Path $localExportFullPath
            Write-Host "File exported to temp location" -ForegroundColor green

            # Upload the file to OneDrive
            Add-PnPFile -Path $localExportFullPath -Folder "Documents" -ErrorAction Stop
            Write-Host "File uploaded to OneDrive" -ForegroundColor Green
            $timestamp = Get-Date -Format "MMddyyyyHHmmss"
            write-host "User completed at $timestamp"
            # Add entry to audit log
            #$auditLog += "Processed OneDrive URL: $($url.URL) at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        #}
    }
} catch {
    Write-Host "An error occurred: $_"
}



stop-Transcript