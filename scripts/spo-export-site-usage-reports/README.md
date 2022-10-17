---
plugin: add-to-gallery
---

# Get Site Usage Reports And Export It To CSV

## Summary

This script shows how to get all site collections with usgae information and Export to CSV.

## Implementation

- Open Windows PowerShell ISE
- Create a new file
- Write a script as below,
- First, we will connect to a SharePoint Admin tenant.
	- then we fetch sites with required information.
    - And then we will export it to CSV with some required properties.
 
# [PnP PowerShell](#tab/pnpps)
```powershell

$adminSiteURL = "https://domain-admin.sharepoint.com/"
$username = "chandani@domain.onmicrosoft.com"
$password = "********"
$secureStringPwd = $password | ConvertTo-SecureString -AsPlainText -Force 
$Creds = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secureStringPwd
$DateTime = "_{0:MM_dd_yy}_{0:HH_mm_ss}" -f (Get-Date)
$BasePath = "E:\Contribution\PnP-Scripts\"
$CSVPath = $BasePath + "\SiteReports" + $DateTime + ".csv"
$global:SiteReports = @()

Function Login() {
    [cmdletbinding()]
    param([parameter(Mandatory = $true, ValueFromPipeline = $true)] $Creds)
 
    #connect to O365 admin site
    Write-Host "Connecting to Tenant Admin Site '$($adminSiteURL)'" -f Yellow 
  
    Connect-PnPOnline -Url $adminSiteURL -Credentials $Creds
    Write-Host "Connecting successfully!..." -f Green 
}

Function GenerateReport {
    try {
        Write-Host "Getting site usage report..." -ForegroundColor Yellow
        $Reports = Get-PnPTenantSite  -Detailed | Select *       
        Write-Host "Getting site usage report successfully!..." -ForegroundColor Green

        foreach ($Report in $Reports) {
            $global:SiteReports += New-Object PSObject -Property ([ordered]@{               
                    'Title'                        = $Report.Title
                    'URL'                          = $Report.Url
                    'Description'                  = $Report.Description                    
                    'Resource Quota'               = $Report.ResourceQuota
                    'Resource Quota Warning Level' = $Report.ResourceQuotaWarningLevel
                    'Resource Usage Average'       = $Report.ResourceUsageAverage
                    'Resource Usage Current'       = $Report.ResourceUsageCurrent
                    'Owner'                        = $Report.Owner
                    'Owner Name'                   = $Report.OwnerName
                    'Storage Quota'                = $Report.StorageQuota
                    'Storage MaximumLevel'         = $Report.StorageMaximumLevel 
                    'Storage Usage Current'        = $Report.StorageUsageCurrent 
                    'Template'                     = $Report.Template
                    'Status'                       = $Report.Status
                    'Usage Bandwidth'              = $Report.Usage.Bandwidth
                    'Usage Hits'                   = $Report.Usage.Hits
                    'Usage Visits'                 = $Report.Usage.Visits
                    'Locale Id'                    = $Report.LocaleId
                    'Last Modified Date'           = $Report.LastContentModifiedDate
                    'Sharing Capability'           = $Report.SharingCapability 
                })
        }

    }
    catch {
        Write-Host "Error in getting site usage report:" $_.Exception.Message -ForegroundColor Red                 
    }
    Write-Host "Exporting to CSV..." -ForegroundColor Yellow
    $global:SiteReports | Export-Csv $CSVPath -NoTypeInformation -Append
    Write-Host "Exported successfully!..." -ForegroundColor Green   
}


Function StartProcessing {
    Login($Creds);      
    GenerateReport 
}

StartProcessing

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365](#tab/cli-m365-ps)
```powershell


$DateTime = "_{0:MM_dd_yy}_{0:HH_mm_ss}" -f (Get-Date)
$invocation = (Get-Variable MyInvocation).Value
$BasePath = Split-Path $invocation.MyCommand.Path
$CSVPath = $BasePath + "\SiteReports" + $DateTime + ".csv"
$global:SiteReports = @()


Function GenerateReport {
    try {
        Write-Host "Getting site usage report..." -ForegroundColor Yellow
        $Reports =  m365 spo site list -o json | ConvertFrom-Json     
        Write-Host "Getting site usage report successfully!..." -ForegroundColor Green

        foreach ($Report in $Reports) {
            $global:SiteReports += New-Object PSObject -Property ([ordered]@{               
                    'Title'                        = $Report.Title
                    'URL'                          = $Report.Url
                    'Description'                  = $Report.Description                    
                    'Resource Quota'               = $Report.ResourceQuota
                    'Resource Quota Warning Level' = $Report.ResourceQuotaWarningLevel
                    'Resource Usage Average'       = $Report.ResourceUsageAverage
                    'Resource Usage Current'       = $Report.ResourceUsageCurrent
                    'Owner'                        = $Report.Owner
                    'Owner Name'                   = $Report.OwnerName
                    'Storage Quota'                = $Report.StorageQuota
                    'Storage MaximumLevel'         = $Report.StorageMaximumLevel 
                    'Storage Usage Current'        = $Report.StorageUsageCurrent 
                    'Template'                     = $Report.Template
                    'Status'                       = $Report.Status
                    'Usage Bandwidth'              = $Report.Usage.Bandwidth
                    'Usage Hits'                   = $Report.Usage.Hits
                    'Usage Visits'                 = $Report.Usage.Visits
                    'Locale Id'                    = $Report.LocaleId
                    'Last Modified Date'           = $Report.LastContentModifiedDate 
                    'Sharing Capability'           = $Report.SharingCapability 
                })
        }

    }
    catch {
        Write-Host "Error in getting site usage report:" $_.Exception.Message -ForegroundColor Red                 
    }
    Write-Host "Exporting to CSV..." -ForegroundColor Yellow
    $global:SiteReports | Export-Csv $CSVPath -NoTypeInformation -Append
    Write-Host "Exported successfully!..." -ForegroundColor Green   
}

     $m365Status = m365 status
    if (!$m365Status) {
        # Connection to Microsoft 365
        m365 login
    }

    GenerateReport 

```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

***

## Contributors

| Author(s) |
|-----------|
| Chandani Prajapati |
| Reshmee Auckloo |
[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-export-site-usage-reports" aria-hidden="true" />
