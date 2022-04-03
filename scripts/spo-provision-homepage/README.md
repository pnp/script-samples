---
plugin: add-to-gallery
---

# Provision Home Page to a SharePoint site 

## Summary

The script is to apply home page to a SharePoint site based on an already configured home page from another site

The sample using PnP PowerShell to export the page from the source site and provision and set the page as home page on a different site

# [PnP PowerShell](#tab/pnpps)
```powershell
   $srcUrl = Read-Host "Enter the source site url from which to copy the Home Page" #e.g.https://contoso.sharepoint.com/sites/Team1
   $destUrl = Read-Host "Enter the destination site url to which to provision the Home Page" #e.g.https://contoso.sharepoint.com/sites/testDemo
   $HomePageTemplateName = "ContosoHomePage"
try{
   $pageName = Read-Host "Enter the page name which you want to copy" ##e.g.ContosoHomePage
   Connect-PnPOnline -Url $srcUrl -interactive
   Set-location $PSScriptRoot
   Export-PnPPage -Force -Identity $pageName -Out $($HomePageTemplateName) 
}
catch{
  Write-Host -ForegroundColor Red 'Error ',':'$Error[0].ToString();
  sleep 10
} 


try{
$tempFilePath = Join-Path $PSScriptRoot $HomePageTemplateName
  Connect-PnPOnline -Url $destUrl -interactive
 Invoke-PnPSiteTemplate -Path $tempFilePath
 sleep 10
#set the page home page
 Set-PnPHomePage -RootFolderRelativeUrl SitePages/ContosoHomePage.aspx
 Write-Host "Home Page is successfully copied."
}
catch{
  Write-Host -ForegroundColor Red 'Error ',':'$Error[0].ToString();
}
 
```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Contributors

| Author(s) |
|-----------|
| Reshmee Auckloo |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-provision-homepage" aria-hidden="true" />
