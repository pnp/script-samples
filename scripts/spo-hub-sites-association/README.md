---
plugin: add-to-gallery
---

# Hub Site Association 

## Summary

This sample shows how to associate sharepoint online site with hub site.

## Implementation

- Open Windows PowerShell ISE
- Create a new file
- Write a script as below,
- First, we will connect to Tenant admin site.
    - Then we read site url and hub site url from a user,
    - And then we will do hub site association.
 
![Example Screenshot](assets/preview.png)

# [PnP PowerShell](#tab/pnpps)
```powershell

$AdminSiteURL = "https://{domain}-admin.sharepoint.com/"
$Username = "USERID"
$Password = "********"
$SecureStringPwd = $password | ConvertTo-SecureString -AsPlainText -Force 
$Creds = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secureStringPwd

Function Login() {
    [cmdletbinding()]
    param([parameter(Mandatory = $true, ValueFromPipeline = $true)] $Creds)     
    Write-Host "Connecting to Tenant Admin Site '$($adminSiteURL)'" -f Yellow   
    Connect-PnPOnline -Url $adminSiteURL -Credentials $Creds
    Write-Host "Connection Successful" -f Green 
}

Function HubSiteAssociation {  
    try {  
        #read site url from user  
        $SiteUrl = Read-Host 'Enter Site Url'  
        #read hub site url from user  
        $HubSiteUrl = Read-Host 'Enter Hub Site Url'         
        Write-Host "Connecting to SharePoint site..." -ForegroundColor Yellow  
        #connect to the SharePoint site  
        Connect-PnpOnline -Url $SiteUrl -Credentials $Creds     
        Write-Host "Associate with a hub site..." -ForegroundColor Yellow           
        #hub site association           
        Add-PnPHubSiteAssociation -Site $SiteUrl -HubSite $HubSiteUrl   
        Write-Host "Hub site association completed..." -ForegroundColor Yellow  
    }  
    catch {  
        Write-Host "Error in hub site association:" $_.Exception.Message -ForegroundColor Red  
    }  
}


Function StartProcessing {
    Login($creds);
    HubSiteAssociation
}

StartProcessing

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [SPO Management Shell](#tab/spoms-ps)

```powershell

$AdminSiteURL = "https://{domain}-admin.sharepoint.com/"
$Username = "USERID"
$Password = "********"
$SecureStringPwd = $password | ConvertTo-SecureString -AsPlainText -Force 
$Creds = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secureStringPwd

Function Login() {
    [cmdletbinding()]
    param([parameter(Mandatory = $true, ValueFromPipeline = $true)] $Creds)     
    Write-Host "Connecting to Tenant Admin Site '$($adminSiteURL)'" -f Yellow   
    Connect-SPOService -Url $adminSiteURL -Credential $Creds
    Write-Host "Connection Successful" -f Green 
}

Function HubSiteAssociation {  
    try {  
        #read site url from user  
        $SiteUrl = Read-Host 'Enter Site Url'  
        #read hub site URL from user  
        $HubSiteUrl = Read-Host 'Enter Hub Site Url'         
        Write-Host "Connecting to SharePoint site..." -ForegroundColor Yellow  
        #connect to the SharePoint site  
        Connect-PnpOnline -Url $SiteUrl -Credentials $Creds     
        Write-Host "Associate with a hub site..." -ForegroundColor Yellow           
        #hub site association           
        Add-SPOHubSiteAssociation $SiteUrl -HubSite $HubSiteUrl   
        Write-Host "Hub site association completed..." -ForegroundColor Yellow  
    }  
    catch {  
        Write-Host "Error in hub site association:" $_.Exception.Message -ForegroundColor Red  
    }  
}


Function StartProcessing {
    Login($Creds);
    HubSiteAssociation
}

StartProcessing

```
[!INCLUDE [More about SPO Management Shell](../../docfx/includes/MORE-SPOMS.md)]

# [CLI for Microsoft 365](#tab/cli-m365-ps)
```powershell

Function Login() {
  Write-Host "Connecting to Tenant Site" -f Yellow   
  $m365Status = m365 status
  if ($m365Status -match "Logged Out") {
    m365 login
  }
  Write-Host "Connection Successful!" -f Green 
}

Function HubSiteAssociation {  
  try {  
    #read site url from user  
    $SiteUrl = Read-Host 'Enter Site Url'  
    #read hub site url from user  
    $HubSiteUrl = Read-Host 'Enter Hub Site Url'   
              
    #hub site association           
    Write-Host "Associate with a hub site..." -ForegroundColor Yellow    
    
    $hubSitesList = m365 spo hubsite list | ConvertFrom-Json
    $hubSite = $hubSitesList | Where-Object SiteUrl -Match $HubSiteUrl 
    m365 spo hubsite connect --url $SiteUrl --hubSiteId $hubSite.SiteId 

    Write-Host "Hub site association completed..." -ForegroundColor Yellow  
  }  
  catch {  
    Write-Host "Error in hub site association:" $_.Exception.Message -ForegroundColor Red  
  }  
}

Function StartProcessing {
  Login
  HubSiteAssociation
}

StartProcessing

```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

***

## Contributors

| Author(s) |
|-----------|
| Chandani Prajapati (https://github.com/chandaniprajapati) |
| [Jasey Waegebaert](https://github.com/Jwaegebaert) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-hub-sites-association" aria-hidden="true" />
