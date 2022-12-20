---
plugin: add-to-gallery
---

# Remove orphaned redirect sites

## Summary

Changing the URL of a site results in a new site type: a Redirect Site. However this redirect site does not get removed if you delete the newly renamed site. This could result in orphaned redirect site collections that redirect to nothing. This script provides you with an overview of all orphaned redirect sites and allows you to quickly delete them.

[!INCLUDE [Delete Warning](../../docfx/includes/DELETE-WARN.md)]
 
# [PnP PowerShell](#tab/pnpps)
```powershell
$tenantAdminUrl = "https://contoso-admin.sharepoint.com" # Change to your tenant

Connect-PnPOnline -Url $tenantAdminUrl -Interactive

$sites = Get-PnPTenantSite -Template "RedirectSite#0"

$sites | ForEach-Object {
  Write-Host -f Green "Processing redirect site: " $_.Url
  $siteUrl = $_.Url

  $redirectSite = Invoke-WebRequest -Uri $_.Url -MaximumRedirection 0 -SkipHttpErrorCheck #Requires PowerShell 7 for -SkipHttpErrorCheck parameter
  $body = $null
  $siteUrl = $_.Url

  if($redirectSite.StatusCode -eq 308) {
    Try {
      [string]$newUrl = $redirectSite.Headers.Location;
      Write-Host -f Green " Redirects to: " $newUrl
      $body = Invoke-WebRequest -Uri $newUrl -SkipHttpErrorCheck #Requires PowerShell 7 for -SkipHttpErrorCheck parameter
    }
    Catch{
     Write-Host $_.Exception
    }
    Finally {
      If($body.StatusCode -eq "200"){
       Write-host -f Yellow "  Target location still exists"
      }
      If($body.StatusCode -eq "404"){
        Write-Host -f Red "  Target location no longer exists, should be removed"
        Remove-PnPTenantSite -Url $siteUrl -Force
      }
    }
  }
}

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***

## Contributors

| Author(s) |
|-----------|
| [Leon Armston](https://github.com/LeonArmston)|


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-remove-orphaned-redirect-sites" aria-hidden="true" />

