---
plugin: add-to-gallery
---

# Update User Profile Properties

## Summary

This script shows how to update user profile properties.

## Implementation

- Open Windows PowerShell ISE
- Create a new file
- Write a script as below,
- First, we will connect to a SharePoint Admin tenant.
	- then we will ask a user to enter location and skills (We can ask properties as per our requirements).
    - And then we will update current user profile properties.
 
# [PnP PowerShell](#tab/pnpps)
```powershell

$adminSiteURL = "https://domain-admin.sharepoint.com/"
$username = "chandani@domain.onmicrosoft.com"
$password = "********"
$secureStringPwd = $password | ConvertTo-SecureString -AsPlainText -Force 
$Creds = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secureStringPwd

Function Login() {
    [cmdletbinding()]
    param([parameter(Mandatory = $true, ValueFromPipeline = $true)] $Creds)
     
    Write-Host "Connecting to Tenant Admin Site '$($adminSiteURL)'" -f Yellow   
    Connect-PnPOnline -Url $adminSiteURL -Credentials $Creds
    Write-Host "Connection Successful" -f Green 
}

Function UpdateUserProfileProperties {
    try {
        $Location = Read-Host "Enter location" 
        $Skills = Read-Host "Enter skills by comma seprated(e.g. SPFx, PS)"          
        Write-Host "Updating user profile Properties for:" $username -f Yellow        
        Set-PnPUserProfileProperty -Account $username -PropertyName 'SPS-Location' -Value $Location 
        Set-PnPUserProfileProperty -Account $username -PropertyName "SPS-Skills" -Value $Skills       
        Write-Host "Updated user profile Properties for:" $username -f Green 
    }
    catch {
        Write-Host "Getting error in updating user profile Propertiese:" $_.Exception.Message -ForegroundColor Red                 
    }  
}

Function StartProcessing {
    Login($Creds);
    UpdateUserProfileProperties
}

StartProcessing

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365](#tab/cli-m365-ps)
```powershell
$username = "chandani@domain.onmicrosoft.com"

Function Login {
  Write-Host "Connecting to Tenant Site" -f Yellow   
  $m365Status = m365 status
  if ($m365Status -match "Logged Out") {
    m365 login
  }
  Write-Host "Connection Successful!" -f Green 
}

Function UpdateUserProfileProperties {
    try {
        $Location = Read-Host "Enter location" 
        $Skills = Read-Host "Enter skills by comma seprated(e.g. SPFx, PS)"          
        Write-Host "Updating user profile Properties for:" $username -f Yellow        
        m365 spo userprofile set --userName $username --propertyName 'SPS-Location' --propertyValue $Location 
        m365 spo userprofile set --userName $username --propertyName "SPS-Skills" --propertyValue $Skills       
        Write-Host "Updated user profile Properties for:" $username -f Green 
    }
    catch {
        Write-Host "Getting error in updating user profile Propertiese:" $_.Exception.Message -ForegroundColor Red                 
    }  
}

Function StartProcessing {
    Login
    UpdateUserProfileProperties
}

StartProcessing
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
***

## Contributors

| Author(s) |
|-----------|
| Chandani Prajapati |
| [Jasey Waegebaert](https://github.com/Jwaegebaert) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-update-user-profile-properties" aria-hidden="true" />
