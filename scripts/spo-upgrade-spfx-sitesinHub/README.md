---
plugin: add-to-gallery
---

# Uploads and upgrades spfx package in all sites of a hub

## Summary

At the time of the submitting the sample there is no concept of a hub site app catalog 

  ![Example Screenshot](assets/example.png)

# [PnP PowerShell](#tab/pnpps)

```powershell
$adminCenterURL="https://contoso-admin.sharepoint.com"
$hubSiteUrl = https://contoso.sharepoint.com/sites/u-intranet
$dateTime = (Get-Date).toString("dd-MM-yyyy")
$invocation = (Get-Variable MyInvocation).Value
$directorypath = Split-Path $invocation.MyCommand.Path
$fileName = "\IntranetUpgradeSPFx-" + $dateTime + ".csv"
$OutPutView = $directorypath + $fileName
$packageName = "AddIn365 Intranet SPO Creative Kit SPFx solution"
$packagePath = "C:\temp\spfx-intranet-spo.sppkg" Connect-PnPOnline $adminCenterURL -Interactive $adminConnection  = Get-PnPConnection
$ViewCollection = @() $HubSiteID = (Get-PnPTenantSite  $hubSiteUrl).HubSiteId
#Get all site collections associated with the hub site
Get-PnPTenantSite -Detailed | select url | ForEach-Object {
  $Site = Get-PnPTenantSite $_.url
  If($Site.HubSiteId -eq $HubSiteId){
    Connect-PnPOnline -Url $Site.url -Interactive
     $ExportVw = New-Object PSObject
     $ExportVw | Add-Member -MemberType NoteProperty -name "Site URL" -value $Site.url
     $ExportVw | Add-Member -MemberType NoteProperty -name "Package Name" -value $packageName      
      
#ensure app catalog
      if(!(Get-PnPSiteCollectionAppCatalog -CurrentSite)){
        Add-PnPSiteCollectionAppCatalog
      }
     while(!(Get-PnPSiteCollectionAppCatalog -CurrentSite)){
        Start-Sleep -Seconds 20
     }

    add-pnpapp -Path $packagePath -Scope Site -Overwrite -Publish
     Start-Sleep -Seconds 5       # Get the current version of the SPFx package
    $currentPackage = Get-PnPApp -Identity $packageName -Scope Site
    Write-Host "Current package version on site $($site.Url): $($currentPackage.InstalledVersion)"
    # Get the latest version of the SPFx package
    Write-Host "Latest package version: $($currentPackage.AppCatalogVersion)"     # Update the package to the latest version
    if ($currentPackage.InstalledVersion -ne $currentPackage.AppCatalogVersion) {
        Write-Host "Upgrading package on site $($site.Url) to latest version..."
        Update-PnPApp -Identity $currentPackage.Id -Scope site
        $currentPackage = Get-PnPApp -Identity $packageName -Scope Site
        $ExportVw | Add-Member -MemberType NoteProperty -name "Package Version" -value $currentPackage.AppCatalogVersion
        $ViewCollection += $ExportVw
    } else {
        Write-Host "Package already up-to-date on site $($site.Url)."
    }
  }
} #Export the result Array to CSV file

$ViewCollection | Export-CSV $OutPutView -Force -NoTypeInformation #Disconnect-PnPOnline
```
![Results Screenshot](assets/preview.png)

> [!Note]
> SharePoint tenant admin right are required to be able add site design

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***

## Contributors

| Author(s) |
|-----------|
| Reshmee Auckloo |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-add-sitedesign-permissions" aria-hidden="true" />

