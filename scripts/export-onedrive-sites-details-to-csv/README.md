---
plugin: add-to-gallery
---

# Export OneDrive Sites

## Summary
This sample shows how to export all onedrive sites to CSV. This report includes all columns. for eg. Url, Owner, Storage and etc.

![Example Screenshot](assets/example.png)

# [PnP PowerShell](#tab/pnpps)

```powershell

$adminSiteURL = "https://domain-admin.sharepoint.com/"
$username = "username@domain.onmicrosoft.com"
$password = "********"
$secureStringPwd = $password | ConvertTo-SecureString -AsPlainText -Force 
$creds = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secureStringPwd
$dateTime = "_{0:MM_dd_yy}_{0:HH_mm_ss}" -f (Get-Date)
$basePath = "E:\Contribution\PnP-Scripts\Logs\"
$csvPath = $basePath + "\OneDriveSites_PnP" + $dateTime + ".csv"
$global:onedriveSitesCollection = @()

Function Login() {
    [cmdletbinding()]
    param([parameter(Mandatory = $true, ValueFromPipeline = $true)] $creds)     
    Write-Host "Connecting to Site '$($adminSiteURL)'" -f Yellow   
    Connect-PnPOnline -Url $adminSiteURL -Credential $creds
    Write-Host "Connection Successful" -f Green 
}

Function GetOnedriveSitesDeails {    
    try {
        Write-Host "Getting onedrive sites..."  -ForegroundColor Yellow 
        $global:onedriveSitesCollection = Get-PnPTenantSite -IncludeOneDriveSites -Filter "Url -like '-my.sharepoint.com/personal/'" | select *          
    }
    catch {
        Write-Host "Error in getting onedrive sites:" $_.Exception.Message -ForegroundColor Red                 
    }
    Write-Host "Exporting to CSV..."  -ForegroundColor Yellow 
    $global:onedriveSitesCollection | Export-Csv $csvPath -NoTypeInformation -Append
    Write-Host "Exported to CSV successfully!"  -ForegroundColor Green	

}

Function StartProcessing {
    Login($creds);
    GetOnedriveSitesDeails
}

StartProcessing
```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [SPO Management Shell](#tab/spoms-ps)

```powershell
$adminSiteURL = "https://domain-admin.sharepoint.com/"
$username = "username@domain.onmicrosoft.com"
$password = "********"
$secureStringPwd = $password | ConvertTo-SecureString -AsPlainText -Force 
$creds = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secureStringPwd
$dateTime = "_{0:MM_dd_yy}_{0:HH_mm_ss}" -f (Get-Date)
$basePath = "E:\Contribution\PnP-Scripts\Logs\"
$csvPath = $basePath + "\OneDriveSites_SPO" + $dateTime + ".csv"
$global:onedriveSitesCollection = @()

Function Login() {
    [cmdletbinding()]
    param([parameter(Mandatory = $true, ValueFromPipeline = $true)] $creds)     
    Write-Host "Connecting to Site '$($adminSiteURL)'" -f Yellow   
    Connect-SPOService -Url $adminSiteURL -Credential $creds
    Write-Host "Connection Successful" -f Green 
}

Function GetOnedriveSitesDeails {    
    try {
        Write-Host "Getting onedrive sites..."  -ForegroundColor Yellow 
        $global:onedriveSitesCollection = Get-SPOSite -Template "SPSPERS" -limit ALL -includepersonalsite $True | select *        
    }
    catch {
        Write-Host "Error in getting onedrive sites:" $_.Exception.Message -ForegroundColor Red                 
    }
    Write-Host "Exporting to CSV..."  -ForegroundColor Yellow 
    $global:onedriveSitesCollection | Export-Csv $csvPath -NoTypeInformation -Append
    Write-Host "Exported to CSV successfully!"  -ForegroundColor Green	

}

Function StartProcessing {
    Login($creds);
    GetOnedriveSitesDeails
}

StartProcessing
```
[!INCLUDE [More about SPO Management Shell](../../docfx/includes/MORE-SPOMS.md)]
***


## Contributors

| Author(s) |
|-----------|
| Chandani Prajapati |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/export-onedrive-sites-details-to-csv" aria-hidden="true" />