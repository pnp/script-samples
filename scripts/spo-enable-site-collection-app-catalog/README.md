

# Enable Site Collection App Catalog on a specific sites using CSV

## Summary

The script reads list of SharePoint site collection URLs from a CSV and enables the Site collection app catalog on them.

![Example Screenshot](assets/preview.png)

## Implementation

- Create csv file with the list of site collection URLs to enable app catalog
- Open Windows PowerShell ISE
- Create a new file
- Copy the code below
- Save the file and run it
- Make sure you must have access to the app catalog to apply

# [SPO Management Shell](#tab/spoms-ps)

```powershell
# Example: .\Enable-SiteCollectionAppCatalog.ps1 -AdminUrl "https://contoso-admin.sharepoint.com" -CsvPath ".\SiteURLs.csv"
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, HelpMessage = "URL of the SharePoint Admin Center, e.g.https://contoso-admin.sharepoint.com")]
    [string]$AdminUrl,
    [Parameter(Mandatory = $false, HelpMessage = "Path to CSV file with list of SharePoint sites to enable Site Collection App Catalog")]
    [string]$CsvPath = ".\SiteURLs.csv"
)

begin  {
    Write-Host "Connecting to SharePoint Admin Site '$($AdminUrl)'" -f Yellow
    Connect-SPOService -Url $AdminUrl
}
process {
    $data = Import-Csv -Path $CsvPath

    $data | Foreach-Object{
        Write-Host "Adding site collection app catalog to site '$($_.SiteUrl)'..." -f Yellow
        $site = Get-SPOSite $_.SiteUrl
        Add-SPOSiteCollectionAppCatalog -Site $site
    }
}
end {
    Disconnect-SPOService
    Write-Host "Finished" -ForegroundColor Green
}
```
[!INCLUDE [More about SPO Management Shell](../../docfx/includes/MORE-SPOMS.md)]

# [PnP PowerShell](#tab/pnpps)

```powershell
# Example: .\Enable-SiteCollectionAppCatalog.ps1 -AdminUrl "https://contoso-admin.sharepoint.com" -CsvPath ".\SiteURLs.csv"
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, HelpMessage = "URL of the SharePoint Admin Center, e.g.https://contoso-admin.sharepoint.com")]
    [string]$AdminUrl,
    [Parameter(Mandatory = $false, HelpMessage = "Path to CSV file with list of SharePoint sites to enable Site Collection App Catalog")]
    [string]$CsvPath = ".\SiteURLs.csv"
)

begin  {
    Write-Host "Connecting to SharePoint Admin Site '$($AdminUrl)'" -f Yellow
    Connect-PnPOnline -Url $AdminUrl
}
process {
    $data = Import-Csv -Path $CsvPath

    $data | Foreach-Object{
        Write-Host "Adding site collection app catalog to site '$($_.SiteUrl)'..." -f Yellow
        Add-PnPSiteCollectionAppCatalog -Site $_.SiteUrl
    }
}
end {
    Disconnect-PnPOnline
    Write-Host "Finished" -ForegroundColor Green
}
```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365](#tab/cli-m365-ps)
```powershell
# Example: .\Enable-SiteCollectionAppCatalog.ps1 -CsvPath ".\SiteURLs.csv"
[CmdletBinding()]
param (
    [Parameter(Mandatory = $false, HelpMessage = "Path to CSV file with list of SharePoint sites to enable Site Collection App Catalog")]
    [string]$CsvPath = ".\SiteURLs.csv"
)

begin  {
    #Log in to Microsoft 365
    Write-Host "Connecting to Tenant" -f Yellow

    $m365Status = m365 status
    if ($m365Status -match "Logged Out") {
        m365 login
    }

    Write-Host "Connection Successful!" -f Green
}
process {
    $data = Import-Csv -Path $CsvPath

    $data | Foreach-Object{
        Write-Host "Adding site collection app catalog to site '$($_.SiteUrl)'..." -f Yellow
        m365 spo site appcatalog add --siteUrl $_.SiteUrl
    }
}
end {
    m365 logout
    Write-Host "Finished" -ForegroundColor Green
}
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

# [CSV file sample](#tab/csv)
```csv
SiteUrl
https://contoso.sharepoint.com/sites/Audits
https://contoso.sharepoint.com/sites/Finance
https://contoso.sharepoint.com/sites/HR
https://contoso.sharepoint.com/sites/Innovations
https://contoso.sharepoint.com/sites/Retail
```

***

## Contributors

| Author(s) |
|-----------|
| [Nanddeep Nachan](https://github.com/nanddeepn) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-enable-site-collection-app-catalog" aria-hidden="true" />
