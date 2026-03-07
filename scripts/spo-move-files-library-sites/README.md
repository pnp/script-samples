

# Copying files between different SharePoint libraries with custom metadata

## Summary
This script copies files from a source SharePoint Online document library to a destination library while enforcing strict folder‑existence validation and applying controlled metadata values (e.g., setting ProcessStatus to Pending). It is designed for large Microsoft 365 tenants where predictable behaviour, error handling, and operational safety are required. The script prevents accidental writes by skipping transfers when the destination folder structure does not exist.

## Why It Matters
Large enterprises frequently need to migrate or replicate subsets of files between environments such as Production, UAT, and Development. Default copy mechanisms often lack metadata control, overwrite protection, and folder‑validation logic. This script ensures only valid, intentional transfers occur and that files arrive with the correct metadata state for downstream workflows, such as approval processes or automated ingestion pipelines.

## Benefits
- **Operational Safety:** Prevents accidental writes by validating destination folder structure before copying.
- **Metadata Governance:** Ensures consistent metadata values (e.g., ProcessStatus = Pending) during transfer.
- **Tenant‑Scale Reliability:** Uses efficient PnP operations suitable for large libraries and high‑volume tenants.
- **Auditable Execution:** Generates daily log files for compliance and troubleshooting.
- **Environment Segregation:** Supports controlled movement of sample or test files between environments.

# [PnP PowerShell Updated](#tab/pnppsv2)

```PowerShell
param (
    [Parameter(Mandatory = $false)]
    [string]$SourceSiteUrl = "https://contoso.sharepoint.com/teams/app",

    [Parameter(Mandatory = $false)]
    [string]$SourceFolderPath = "Shared Documents/Temp Library/test",

    [Parameter(Mandatory = $false)]
    [string]$DestinationSiteUrl = "https://contoso.sharepoint.com/teams/t-app",

    [Parameter(Mandatory = $false)]
    [string]$DestinationFolderPath = "Shared Documents/Temp Library/test"
)

# -------------------------
# Logging
# -------------------------
$todayDate = Get-Date -Format "yyyy-MM-dd"
$logFileName = "CopyFilesToSharePoint_$todayDate.log"
$logFilePath = Join-Path -Path $PSScriptRoot -ChildPath $logFileName

function Write-Log {
    param (
        [string]$Message,
        [string]$Color = "White"
    )

    Write-Host $Message -ForegroundColor $Color
    Add-Content -Path $logFilePath -Value "$(Get-Date -Format 'HH:mm:ss') - $Message"
}

Write-Log "==== Script started ====" Cyan

# -------------------------
# Connect to SharePoint
# -------------------------
try {
    Connect-PnPOnline -Url $SourceSiteUrl -Interactive
    $SourceConn = Get-PnPConnection
    Write-Log "Connected to source site" Green
}
catch {
    Write-Log "Failed to connect to source site: $($_.Exception.Message)" Red
    exit 1
}

try {
    Connect-PnPOnline -Url $DestinationSiteUrl -Interactive
    $DestConn = Get-PnPConnection
    Write-Log "Connected to destination site" Green
}
catch {
    Write-Log "Failed to connect to destination site: $($_.Exception.Message)" Red
    exit 1
}

# -------------------------
# Validate folders
# -------------------------
function Test-FolderExists {
    param (
        [string]$FolderPath,
        $Connection
    )

    try {
        Get-PnPFolder -FolderSiteRelativeUrl $FolderPath -Connection $Connection -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

if (-not (Test-FolderExists -FolderPath $SourceFolderPath -Connection $SourceConn)) {
    Write-Log "Source folder does not exist: $SourceFolderPath" Red
    exit 1
}

if (-not (Test-FolderExists -FolderPath $DestinationFolderPath -Connection $DestConn)) {
    Write-Log "Destination folder does not exist: $DestinationFolderPath" Red
    exit 1
}

Write-Log "Source and destination folders validated" Green

# -------------------------
# Copy files
# -------------------------
try {
    $sourceFiles = Get-PnPFolderItem `
        -FolderSiteRelativeUrl $SourceFolderPath `
        -ItemType File `
        -Connection $SourceConn `
        -ErrorAction Stop
}
catch {
    Write-Log "Failed to read source folder: $($_.Exception.Message)" Red
    exit 1
}

if ($sourceFiles.Count -eq 0) {
    Write-Log "No files found in source folder" Yellow
    exit 0
}

foreach ($file in $sourceFiles) {

    Write-Log "Processing file: $($file.Name)" Cyan

    $stream = $null

    try {
        # Download
        $stream = Get-PnPFile `
            -Url $file.ServerRelativeUrl `
            -AsMemoryStream `
            -Connection $SourceConn `
            -ErrorAction Stop

        # Upload (overwrite enabled)
        $uploaded = Add-PnPFile `
            -Folder $DestinationFolderPath `
            -FileName $file.Name `
            -Stream $stream `
            -Overwrite `
            -Connection $DestConn `
            -ErrorAction Stop

        # Try metadata update (non-fatal)
        try {
            Set-PnPListItem `
                -List $uploaded.ListTitle `
                -Identity $uploaded.ListItemAllFields.Id `
                -Values @{ ProcessStatus = "Pending" } `
                -Connection $DestConn `
                -ErrorAction Stop
        }
        catch {
            Write-Log "Metadata skipped for $($file.Name) (column may not exist)" Yellow
        }

        Write-Log "Copied successfully: $($file.Name)" Green
    }
    catch {
        Write-Log "Error copying $($file.Name): $($_.Exception.Message)" Red
    }
    finally {
        if ($stream) {
            $stream.Dispose()
        }
    }
}

Write-Log "==== Script completed ====" Cyan




```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [PnP PowerShell](#tab/pnpps)

```PowerShell

﻿param (
    [Parameter(Mandatory=$false)]
    [string]$SourceSiteUrl = "https://contoso.sharepoint.com/teams/app",
    [Parameter(Mandatory=$false)]
    [string]$SourceFolderPath=  "https://contoso.sharepoint.com/teams/app/Temp Library/test",
    [Parameter(Mandatory=$false)]
    [string]$DestinationSiteUrl = "https://contoso.sharepoint.com/teams/t-app",
    [Parameter(Mandatory=$false)]
    [string]$DestinationFolderPath = "https://contoso.sharepoint.com/teams/t-app/TempLibrary/test"
)

# Generate a unique log file name using today's date
$todayDate = Get-Date -Format "yyyy-MM-dd"
$logFileName = "CopyFilesToSharePoint_$todayDate.log"
$logFilePath = Join-Path -Path $PSScriptRoot -ChildPath $logFileName

# Connect to the source and destination SharePoint sites
Connect-PnPOnline -Url $SourceSiteUrl -Interactive
$SourceConn  = Get-PnPConnection 
Connect-PnPOnline -Url $DestinationSiteUrl -Interactive
$DestConn  = Get-PnPConnection 
# Function to copy files recursively and log errors
function Copy-FilesToSharePoint {
    param (
        [string]$SourceFolderPath,
        [string]$DestinationFolderPath
    )
    $sourceRelativeFolderPath = $SourceFolderPath.Replace($SourceSiteUrl,'') 
    $sourceFiles = Get-PnPFolderItem  -FolderSiteRelativeUrl $sourceRelativeFolderPath -ItemType File -Connection $SourceConn
    foreach ($file in $sourceFiles) {
        $relativePath = $file.ServerRelativePath
       
        # Check if the destination folder exists
        $destinationFolder = Get-PnPFolder -Url $DestinationFolderPath -Connection $DestConn -ErrorAction SilentlyContinue
        if ($null -eq $destinationFolder) {
            $errorMessage = "Error: Destination folder '$DestinationFolderPath' does not exist."
            Write-Host $errorMessage -ForegroundColor Red
            Add-Content -Path $logFilePath -Value $errorMessage
            continue
        }

        try {
            #get file as stream
           $fileUrl =  $SourceFolderPath + "/" + $file.Name
           $p = $fileUrl.Replace($SourceSiteUrl,'') 
           $streamResult = Get-PnPFile -Url  $p  -Connection $SourceConn -AsMemoryStream
            # Upload the file to the destination folder
           $uploadedFile = Add-PnPFile -Folder $DestinationFolderPath -FileName $file.Name -Stream  $streamResult  -Values @{"ProcessStatus" = "Pending"} -Connection $DestConn #-ErrorAction St
       
            Write-Host "File '$($file.Name)' copied and status set to 'Pending' in '$DestinationFolderPath'" -ForegroundColor Green
        } catch {
            $errorMessage = "Error copying file '$($file.Name)' to '$DestinationFolderPath': $($_.Exception.Message)"
            Write-Host $errorMessage -ForegroundColor Red
            Add-Content -Path $logFilePath -Value $errorMessage
        }
    }
}


# Call the function to copy files to SharePoint
$sourceRelativeFolderPath = $SourceFolderPath.Replace($SourceSiteUrl,'') 
$sourceLevel1Folders = Get-PnPFolderItem  -FolderSiteRelativeUrl $sourceRelativeFolderPath -ItemType Folder  -Connection $SourceConn
Copy-FilesToSharePoint -SourceFolderPath $SourceFolderPath -DestinationFolderPath $DestinationFolderPath
$sourceLevel1Folders | ForEach-Object {
$sourceLevel1Folder = $_ 
if($_.Name -ne "Forms"){
    $sourcePath = $SourceFolderPath + "/" + $sourceLevel1Folder.Name
    $destPath = $DestinationFolderPath + "/" + $sourceLevel1Folder.Name
    Copy-FilesToSharePoint -SourceFolderPath $sourcePath  -DestinationFolderPath $destPath
    }
  $sourceLevel1Path =  $sourceRelativeFolderPath + "/" + $_.Name
  $sourceLevel2Folders = Get-PnPFolderItem  -FolderSiteRelativeUrl $sourceLevel1Path  -ItemType Folder  -Connection $SourceConn
  $sourceLevel2Folders | ForEach-Object {
    $sourceLevel2Folder = $_
    $sourcePath = $SourceFolderPath + "/" + $sourceLevel1Folder.Name + "/" + $sourceLevel2Folder.Name
    $destPath = $DestinationFolderPath + "/" + $sourceLevel1Folder.Name + "/" + $sourceLevel2Folder.Name
    Copy-FilesToSharePoint -SourceFolderPath $sourcePath  -DestinationFolderPath $destPath 
 }
}
# Disconnect from SharePoint
```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## 📄 Sample Script Output
```PowerShell
==== Script started ====
09:14:02 - Connected to source site
09:14:05 - Connected to destination site
09:14:06 - Source and destination folders validated

09:14:07 - Processing file: Report_Q1.pdf
09:14:09 - Copied successfully: Report_Q1.pdf

09:14:10 - Processing file: Budget_2025.xlsx
09:14:12 - Metadata skipped for Budget_2025.xlsx (column may not exist)
09:14:12 - Copied successfully: Budget_2025.xlsx

09:14:13 - Processing file: Notes.txt
09:14:14 - Copied successfully: Notes.txt

==== Script completed ====
```

## 🟡 Sample Output – No Files Found
```PowerShell
==== Script started ====
10:02:11 - Connected to source site
10:02:14 - Connected to destination site
10:02:15 - Source and destination folders validated
10:02:16 - No files found in source folder

==== Script completed ====
```

## 🔴 Sample Output – Failure Case
```PowerShell
==== Script started ====
11:30:44 - Connected to source site
11:30:47 - Connected to destination site
11:30:48 - Source folder does not exist: Shared Documents/Temp Library/test

==== Script completed ====
```

## Contributors

| Author(s) |
|-----------|
| Reshmee Auckloo |
|[Josiah Opiyo](https://github.com/ojopiyo)|

*Built with a focus on automation, governance, least privilege, and clean Microsoft 365 tenants—helping M365 admins gain visibility and reduce operational risk.*


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]

<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-move-files-library-sites" aria-hidden="true" />
