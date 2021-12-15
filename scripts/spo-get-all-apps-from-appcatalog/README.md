---
plugin: add-to-gallery
---

# Get SharePoint List Or Library Permissions And Export It To CSV

## Summary

This script shows how to get all apps from the app catalog and Export to CSV.

## Implementation

- Open Windows PowerShell ISE
- Create a new file
- Write a script as below,
- First, we will connect to a SharePoint Admin tenant.
	- then we fetch all apps from the app catalog.
    - And then we will export it to CSV with some required properties.
 
# [PnP PowerShell](#tab/pnpps)
```powershell

$adminSiteURL = "https://domain-admin.sharepoint.com/"
$username = "chandani@domain.onmicrosoft.com"
$password = "********"
$secureStringPwd = $password | ConvertTo-SecureString -AsPlainText -Force 
$creds = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secureStringPwd
$basePath = "E:\Contribution\PnP-Scripts\GetAllApps"
$dateTime = "{0:MM_dd_yy}_{0:HH_mm_ss}" -f (Get-Date)
$csvPath = $basePath + "\apps" + $dateTime + ".csv"

Function Login() {
    [cmdletbinding()]
    param([parameter(Mandatory = $true, ValueFromPipeline = $true)] $creds)
 
    #connect to O365 admin site
    Write-Host "Connecting to Tenant Admin Site '$($adminSiteURL)'" -f Yellow 
  
    Connect-PnPOnline -Url $adminSiteURL -Credentials $Creds
    Write-Host "Connection Successfull" -f Green 
}


Function ExportAllApps {

    Write-Host "Getting apps..." -f Yellow 
    $AllApps = Get-PnPApp 
    Write-Host "Successfully fetched all apps" -f Green

    Write-Host "Exporting..." -f Yellow
    $AllApps | Export-Csv -Path $csvPath -NoTypeInformation -Append   
    Write-Host "Exported successfully" -f Green
}

Function StartProcessing {
    Login($creds);
    ExportAllApps
}

StartProcessing

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***


## Contributors

| Author(s) |
|-----------|
| Chandani Prajapati |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/spo-get-all-apps-from-appcatalog" aria-hidden="true" />