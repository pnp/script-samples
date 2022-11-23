---
plugin: add-to-gallery
---

# List all external users in all site collections

## Summary

This script helps you to list all external users in all SharePoint Online sites. It provides insights in who the users are, and if available who they where invited by.
 
# [SPO Management Shell](#tab/spoms-ps)

```powershell

$fileExportPath = "<PUTYOURPATHHERE.csv>"

Connect-SPOService https://<yourorg>-admin.sharepoint.com

$results = @()
Write-host "Retrieving all sites and check external users..."
$allSPOSites = Get-SPOSite -Limit ALL
$siteCount = $allSPOSites.Count

Write-Host "Processing $siteCount sites..."
#Loop through each site
$siteCounter = 0

foreach ($site in $allSPOSites) {
  $siteCounter++
  Write-Host "Processing $($site.Url)... ($siteCounter/$siteCount)"

  Write-host "Retrieving all external users ..."

  $users = Get-SPOExternalUser -SiteUrl $($site.Url)

  Write-host "  $($users.Count) external users ..." -ForegroundColor Yellow

  foreach ($user in $users) {
    
    $results = [pscustomobject][ordered]@{
      DisplayName = $user.DisplayName
      Email       = $user.Email
      WhenCreated = $user.WhenCreated
      Url         = $site.Url
    }

    $results | Export-Csv -Path $fileExportPath -NoTypeInformation -Append
  }
}


Write-Host "Completed."

```
[!INCLUDE [More about SPO Management Shell](../../docfx/includes/MORE-SPOMS.md)]

# [PnP PowerShell](#tab/pnpps)
```powershell

#Global Variable Declaration
$AdminURL = "https://domain-admin.sharepoint.com/"
$TenantURL = "https://domain.SharePoint.com"
$UserName = "chandani@domain.onmicrosoft.com"
$Password = "********"
$SecureStringPwd = $Password | ConvertTo-SecureString -AsPlainText -Force 
$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $UserName, $SecureStringPwd
$DateTime = "_{0:MM_dd_yy}_{0:HH_mm_ss}" -f (Get-Date)
$BasePath = "E:\Contribution\PnP-Scripts\GetExtenalUsers\Logs\"
$CSVPath = $BasePath + "\ExternalUsers" + $DateTime + ".csv"
$global:ExternalUsersData = @() 
Function LoginToAdminSite() {
    [cmdletbinding()]
    param([parameter(Mandatory = $true, ValueFromPipeline = $true)] $Credentials)
    Write-Host "Connecting to Tenant Admin Site '$($AdminURL)'..." -ForegroundColor Yellow
    Connect-PnPOnline -Url $AdminURL -Credentials $Credentials
    Write-Host "Connection Successfull to Tenant Admin Site :'$($AdminURL)'" -ForegroundColor Green
}
Function ConnectToSPSite() {
    try {
        $SiteCollection = Get-PnPTenantSite -Filter "Url -like '$TenantURL'" | Where { $_.SharingCapability -ne "Disabled" }
        foreach ($Site in $SiteCollection) {
            $SiteUrl = $Site.Url    
            Write-Host "Connecting to Site :'$($SiteUrl)'..." -ForegroundColor Yellow  
            Connect-PnPOnline -Url $SiteUrl -Credentials $Credentials
            Write-Host "Connection Successfull to site: '$($SiteUrl)'" -ForegroundColor Green              
            GetExternalUsers($SiteUrl)                        
        }
        ExportData       
    }
    catch {
        Write-Host "Error in connecting to Site:'$($SiteUrl)'" $_.Exception.Message -ForegroundColor Red               
    } 
}
Function GetExternalUsers($siteUrl) {
    try {
        $ExternalUsers = Get-PnPUser | Where { $_.LoginName -like "*#ext#*" -or $_.LoginName -like "*urn:spo:guest*" }   
        Write-host "Found '$($ExternalUsers.count)' External users" -ForegroundColor Gray
        ForEach ($User in $ExternalUsers) {
            $global:ExternalUsersData += New-Object PSObject -Property ([ordered]@{
                    SiteName  = $site.Title
                    SiteURL   = $SiteUrl
                    UserName  = $User.Title
                    Email     = $User.Email
                    LoginName = $User.LoginName
                })
        }          
    }
    catch {
        Write-Host "Error in getting external users :'$($siteUrl)'" $_.Exception.Message -ForegroundColor Red                 
    }        
}

Function ExportData {
    Write-Host "Exporting to CSV" -ForegroundColor Yellow           
    $global:ExternalUsersData | Export-Csv -Path $CSVPath -NoTypeInformation -Append
    Write-Host "Exported Successfully!" -ForegroundColor Green 
}

Function StartProcessing {   
    LoginToAdminSite($AdminURL) 
    ConnectToSPSite
}

StartProcessing

```
***

## Source Credit

Sample first appeared on [List all external users in all site collections | CLI for Microsoft 365](https://pnp.github.io/cli-microsoft365/sample-scripts/spo/list-site-externalusers/)

## Contributors

| Author(s) |
|-----------|
| Paul Bullock |
| Chandani Prajapati |
| Martin Lingstuyl |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-list-site-externalusers" aria-hidden="true" />
