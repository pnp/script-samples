---
plugin: add-to-gallery
---

# Delete all Microsoft 365 groups and SharePoint sites

## Summary

Another example how you can delete all Microsoft 365 Groups and SharePoint Online sites in your development environment.
 
[!INCLUDE [Delete Warning](../../docfx/includes/DELETE-WARN.md)]


# [PnP PowerShell](#tab/pnpps)
```powershell
$AdminCenterURL="https://contoso-admin.sharepoint.com/"
#Connect to SharePoint admin url using PnPOnline to use PnP cmdlets to delete m365 groups and SharePoint sites
Connect-PnPOnline -Url $AdminCenterURL -Interactive

#retrieve all m365 group connected ( template "GROUP#0" sites to be deleted) sites beginning with https://contoso.sharepoint.com/sites/D-Test
$sites = Get-PnPTenantSite -Filter {Url -like https://contoso.sharepoint.com/sites/D-Test} -Template 'GROUP#0'

#displaying the sites returned to be deleted
$sites | Format-Table  Url, Template , GroupId

Read-Host -Prompt "Press Enter to start deleting m365 groups and sites (CTRL + C to exit)"
$sites | ForEach-Object{
Remove-PnPMicrosoft365Group  -Identity $_.GroupId
#allow time for m365 group to be deleted
Start-Sleep -Seconds 60
#delete the SharePoint site after the m365 group is deleted
Remove-PnPTenantSite -Url $_.Url -Force -SkipRecycleBin
#permanently remove the m365 group
Remove-PnPDeletedMicrosoft365Group -Identity $_.GroupId

#permanently delete the site and to allow a site to be created with the url of the site just deleted , i.e. to avoid message "This site address is available with modification"
Remove-PnPTenantDeletedSite -Identity $_.Url -Force
}
```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Contributors

| Author(s) |
|-----------|
| Reshmee Auckloo 


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/aad-delete-m365-groups-and-sharepoint-sites" aria-hidden="true" />
