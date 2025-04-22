

# Register an app in Azure Entry ID, login to SharePoint Online and set files links expiration in days

## Summary

This script shows how to register an app in Azure Entry ID, login to SharePoint Online and set files links expiration in days.

## Implementation

- Open Windows PowerShell
- Edit Script and add required parameters for Site URL, tenant
- Press run

# [PnP PowerShell](#tab/pnpps)
```powershell

###### Declare and Initialize Variables ######  

$tenant = "[tenant].onmicrosoft.com"
$url="https://[tenant].sharepoint.com/sites/[site name]"

###### Register an app in Azure Entry ID, store command in result to be able access certificate ######
$result = Register-PnPEntraIDApp -ApplicationName "PnP Rocks" -Tenant $tenant -interactive

Connect-PnPOnline $url -ClientId $result.'AzureAppId/ClientId'  -Tenant $tenant -CertificatePath $result.'Pfx file'

###### Set files links expiration in days ######
Set-PnPTenantSite -identity $url -RequestFilesLinkExpirationInDay 50

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]


***

## Contributors

| Author(s) |
|-----------|
| Valeras Narbutas |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-register-app-login-using-app" aria-hidden="true" />
