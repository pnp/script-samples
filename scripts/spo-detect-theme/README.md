---
plugin: add-to-gallery
---

# Detect theme installed in SharePoint Site

## Summary
Get currently installed theme in SharePoint site 

# [PnP PowerShell](#tab/pnpps)
```powershell
# Make sure necessary modules are installed
# PnP PowerShell to get access to M365 tenent
Install-Module PnP.PowerShell
Connect-PnPOnline -Url $siteURL
$siteURL = "https://tenent.sharepoint.com/sites/Dataverse"
$web = Get-PnPWeb -Includes PrimaryColor
$themes = Get-PnPTenantTheme
$selectedTheme = $themes | where {$_.Palette.themePrimary -eq $web.PrimaryColor}
if($selectedTheme.Count -eq 1){
    Write-Host "Installed Theme Name:"$selectedTheme.Name -ForegroundColor Green 
}
else{
    Write-Host "Theme does not found" -ForegroundColor red 
}
```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Contributors

| Author(s) |
|-----------|
| [Dipen Shah](https://github.com/dips365) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/bulk-undelete-from-recyclebin" aria-hidden="true" />

