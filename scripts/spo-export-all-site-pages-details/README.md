

# Export all site pages details from Site Pages library

## Summary

This PowerShell script uses the PnP PowerShell module to connect to a SharePoint Online site and extract metadata from the Site Pages library. It collects key information for each page—such as titles, URLs, authorship, creation and modification dates, layout type, and banner image details—and exports the results to a timestamped CSV file for reporting and analysis purposes.

## Why It Matters / Real-World Scenarios

Organizations often lack visibility into the volume, ownership, and status of modern SharePoint pages. This script enables administrators and site owners to:
- Perform content audits prior to migrations, restructures, or clean-up initiatives
- Identify outdated, unused, or orphaned pages
- Support governance and compliance reviews by providing page ownership and modification history
- Create an inventory of pages for site redesigns or information architecture planning

## Benefits of the Reported Data

- Improved Governance: Clear visibility into who created and last modified each page
- Operational Insight: Understand page usage patterns and content lifecycle
- Risk Reduction: Identify pages with missing ownership or stale content
- Decision Support: Enables data-driven decisions for site cleanup, archiving, or redesign
- Audit Readiness: Produces a structured, exportable record of SharePoint page metadata

## Implementation

- Open Windows PowerShell ISE
- Create a new file
- Write a script as below,
- First, we will connect to the site from which site we want to get Site Pages library details.
- Then we will get Site Pages details and export it to CSV.
 


# [PnP PowerShell V2](#tab/pnpps2)
```powershell

# ============================
# Configuration
# ============================
$SiteUrl  = "https://domain.sharepoint.com/"
$BasePath = "E:\Contribution\PnP-Scripts\Logs"
$DateTime = Get-Date -Format "MM_dd_yy_HH_mm_ss"
$CsvPath  = Join-Path $BasePath "SitePages_$DateTime.csv"

# Ensure log directory exists
if (-not (Test-Path $BasePath)) {
    New-Item -ItemType Directory -Path $BasePath | Out-Null
}

# ============================
# Connect to SharePoint
# ============================
function Connect-ToSharePoint {
    param (
        [Parameter(Mandatory)]
        [string]$Url
    )

    try {
        Write-Host "Connecting to $Url..." -ForegroundColor Yellow
        Connect-PnPOnline -Url $Url -Interactive
        Write-Host "Connected successfully!" -ForegroundColor Green
    }
    catch {
        throw "Failed to connect to SharePoint: $($_.Exception.Message)"
    }
}

# ============================
# Get Site Pages Metadata
# ============================
function Get-SitePagesDetails {
    try {
        Write-Host "Retrieving Site Pages..." -ForegroundColor Yellow

        $pages = Get-PnPListItem `
            -List "Site Pages" `
            -PageSize 500 `
            -Fields ID,Title,Description,PageLayoutType,FileRef,FileLeafRef,
                    Created_x0020_Date,Last_x0020_Modified,
                    Modified_x0020_By,Created_x0020_By,
                    Author,Editor,BannerImageUrl,File_x0020_Type

        $results = foreach ($page in $pages) {
            [PSCustomObject]@{
                ID              = $page.Id
                Title           = $page["Title"]
                Description     = $page["Description"]
                PageLayoutType  = $page["PageLayoutType"]
                FileRef         = $page["FileRef"]
                FileName        = $page["FileLeafRef"]
                Created         = $page["Created_x0020_Date"]
                Modified        = $page["Last_x0020_Modified"]
                CreatedBy       = $page["Author"]?.Email
                ModifiedBy      = $page["Editor"]?.Email
                BannerImageUrl  = $page["BannerImageUrl"]?.Url
                FileType        = $page["File_x0020_Type"]
            }
        }

        return $results
    }
    catch {
        throw "Error retrieving Site Pages: $($_.Exception.Message)"
    }
}

# ============================
# Export to CSV
# ============================
function Export-ToCsv {
    param (
        [Parameter(Mandatory)]
        [object[]]$Data,

        [Parameter(Mandatory)]
        [string]$Path
    )

    try {
        Write-Host "Exporting data to CSV..." -ForegroundColor Yellow
        $Data | Export-Csv -Path $Path -NoTypeInformation
        Write-Host "Export completed: $Path" -ForegroundColor Green
    }
    catch {
        throw "CSV export failed: $($_.Exception.Message)"
    }
}

# ============================
# Main Execution
# ============================
try {
    Connect-ToSharePoint -Url $SiteUrl
    $SitePages = Get-SitePagesDetails
    Export-ToCsv -Data $SitePages -Path $CsvPath
}
catch {
    Write-Host $_ -ForegroundColor Red
}


```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [PnP PowerShell](#tab/pnpps)
```powershell
$siteURL = "https://domain.sharepoint.com/"
$username = "username@domain.onmicrosoft.com"
$password = "********"
$secureStringPwd = $password | ConvertTo-SecureString -AsPlainText -Force 
$creds = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secureStringPwd
$dateTime = "_{0:MM_dd_yy}_{0:HH_mm_ss}" -f (Get-Date)
$basePath = "E:\Contribution\PnP-Scripts\Logs\"
$csvPath = $basePath + "\SitePages" + $dateTime + ".csv"
$global:sitePagesCollection = @()

Function Login() {
    [cmdletbinding()]
    param([parameter(Mandatory = $true, ValueFromPipeline = $true)] $creds)     
    Write-Host "Connecting to Site '$($siteURL)'" -f Yellow   
    Connect-PnPOnline -Url $siteURL -Credential $creds
    Write-Host "Connection Successful" -f Green 
}

Function GetSitePagesDetails {    
    try {
        Write-Host "Getting site pages information..."  -ForegroundColor Yellow 
        $sitePages = Get-PnPListItem -List "Site Pages"     
        ForEach ($Page in $sitePages) {
            $sitePagesInfo = New-Object PSObject -Property ([Ordered] @{
                    'ID'               = $Page.ID
                    'Title'            = $Page.FieldValues.Title
                    'Description'      = $Page.FieldValues.Description
                    'Page Layout Type' = $Page.FieldValues.PageLayoutType
                    'FileRef'          = $Page.FieldValues.FileRef  
                    'FileLeafRef'      = $Page.FieldValues.FileLeafRef      
                    'Created'          = Get-Date -Date $Page.FieldValues.Created_x0020_Date -Format "dddd MM/dd/yyyy HH:mm"
                    'Modified'         = Get-Date -Date $Page.FieldValues.Last_x0020_Modified -Format "dddd MM/dd/yyyy HH:mm"
                    'Modified By'      = $Page.FieldValues.Modified_x0020_By
                    'Created By'       = $Page.FieldValues.Created_x0020_By
                    'Author'           = $Page.FieldValues.Author.Email
                    'Editor'           = $Page.FieldValues.Editor.Email
                    'BannerImage Url'  = $Page.FieldValues.BannerImageUrl.Url   
                    'File_x0020_Type'  = $Page.FieldValues.File_x0020_Type   
                })
            $global:sitePagesCollection += $sitePagesInfo
        }
    }
    catch {
        Write-Host "Error in getting site pages:" $_.Exception.Message -ForegroundColor Red                 
    }
    Write-Host "Exporting to CSV..."  -ForegroundColor Yellow 
    $global:SitePagesCollection | Export-Csv $csvPath -NoTypeInformation -Append
    Write-Host "Exported to CSV successfully!"  -ForegroundColor Green	

}

Function StartProcessing {
    Login($creds);
    GetSitePagesDetails
}

StartProcessing
```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***

## Output

- **Format**: CSV
- **Location**: Configurable output directory
- **File Naming**: Timestamped (prevents overwriting previous reports)

## Notes
- Requires appropriate permissions to read the Site Pages library
- Supports modern authentication (MFA-compatible)
- Designed for single-site execution but easily extendable to multiple sites

## Contributors

| Author(s) |
|-----------|
| [Chandani Prajapati](https://github.com/chandaniprajapati) |
| [Josiah Opiyo](https://github.com/ojopiyo) |

*Built with a focus on automation, governance, least privilege, and clean Microsoft 365 tenants—helping M365 admins gain visibility and reduce operational risk.*



[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-export-all-site-pages-details" aria-hidden="true" />
