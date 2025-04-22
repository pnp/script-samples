

# Export Inactive Sites Based On Days To CSV

## Summary
This sample demonstrates the process of exporting sites that have been inactive for a specified number of days (in this script, we've set it to the last 30 days) to a CSV file. The exported report encompasses all columns, such as URL, Title, Template, and more.

![Example Screenshot](assets/example.png)

# [PnP PowerShell](#tab/pnpps)

```powershell

$adminSiteURL = "https://domain-admin.sharepoint.com/"
$username = "username@domain.onmicrosoft.com"
$password = "********"
$secureStringPwd = $password | ConvertTo-SecureString -AsPlainText -Force 
$creds = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secureStringPwd
$dateTime = "_{0:MM_dd_yy}_{0:HH_mm_ss}" -f (Get-Date)
$basePath = "D:\Contributions\Scripts\Logs\"
$csvPath = $basePath + "\InActiveSites_PnP" + $dateTime + ".csv"
$global:inActiveSites = @()
$daysInActive = 30

Function Login() {
    [cmdletbinding()]
    param([parameter(Mandatory = $true, ValueFromPipeline = $true)] $creds)     
    Write-Host "Connecting to Site '$($adminSiteURL)'..." -ForegroundColor Yellow   
    Connect-PnPOnline -Url $adminSiteURL -Credential $creds
    Write-Host "Connection Successful!" -ForegroundColor Green 
}

Function GetInactiveSites {    
    try {
        Write-Host "Getting inactive sites..." -ForegroundColor Yellow 
        $siteCollections = Get-PnPTenantSite | Where-Object {$_.Url -notlike "-my.sharepoint.com" -and $_.Url -notlike "/portals/"}
         
        #calculate the Date
        $date = (Get-Date).AddDays(-$daysInActive).ToString("MM/dd/yyyy")
 
        #Get inactive sites based on modified date
        $global:inActiveSites = $siteCollections | Where {$_.LastContentModifiedDate -le $date} | Select *         
        Write-Host "Getting inactive sites successfully!"  -ForegroundColor Green 
    }
    catch {
        Write-Host "Error in getting inactive sites:" $_.Exception.Message -ForegroundColor Red                 
    }
    Write-Host "Exporting to CSV..."  -ForegroundColor Yellow 
    $global:inActiveSites | Export-Csv $csvPath -NoTypeInformation -Append
    Write-Host "Exported to CSV successfully!"  -ForegroundColor Green	
}

Function StartProcessing {
    Login($creds);
    GetInactiveSites
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
$basePath = "D:\Contributions\Scripts\Logs\"
$csvPath = $basePath + "\InActiveSites_SPO" + $dateTime + ".csv"
$global:inActiveSites = @()
$daysInActive = 30

Function Login() {
    [cmdletbinding()]
    param([parameter(Mandatory = $true, ValueFromPipeline = $true)] $creds)     
    Write-Host "Connecting to Site '$($adminSiteURL)'..." -ForegroundColor Yellow   
    Connect-SPOService -Url $adminSiteURL -Credential $creds
    Write-Host "Connection Successful!" -ForegroundColor Green 
}

Function GetInactiveSites {    
    try {
        Write-Host "Getting inactive sites..." -ForegroundColor Yellow 
        $siteCollections = Get-SPOSite -Filter { Url -notlike "-my.sharepoint.com" -and Url -notlike "/portals/" }
         
        #Calculate the Date
        $date = (Get-Date).AddDays(-$daysInActive).ToString("MM/dd/yyyy")
 
        #Get All Site collections where the content modified
        $global:inActiveSites = $siteCollections | Where {$_.LastContentModifiedDate -le $date} | Select *         
        Write-Host "Getting inactive sites successfully!"  -ForegroundColor Green 
    }
    catch {
        Write-Host "Error in getting inactive sites:" $_.Exception.Message -ForegroundColor Red                 
    }
    Write-Host "Exporting to CSV..."  -ForegroundColor Yellow 
    $global:inActiveSites | Export-Csv $csvPath -NoTypeInformation -Append
    Write-Host "Exported to CSV successfully!"  -ForegroundColor Green	
}

Function StartProcessing {
    Login($creds);
    GetInactiveSites
}

StartProcessing
```
[!INCLUDE [More about SPO Management Shell](../../docfx/includes/MORE-SPOMS.md)]
***
## Contributors

| Author(s) |
|-----------|
| Chandani Prajapati (https://github.com/chandaniprajapati) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/export-inactive-sites-based-on-days-to-csv" aria-hidden="true" />