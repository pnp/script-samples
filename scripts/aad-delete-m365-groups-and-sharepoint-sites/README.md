---
plugin: add-to-gallery
---

# Delete all Microsoft 365 groups and SharePoint sites

## Summary

This script sample shows how you can delete Microsoft 365 Groups and associated SharePoint Online sites in your development environment.
 
[!INCLUDE [Delete Warning](../../docfx/includes/DELETE-WARN.md)]

# [PnP PowerShell](#tab/pnpps)

```powershell
$AdminCenterURL="https://contoso-admin.sharepoint.com/"

#Connect to SharePoint admin URL using PnPOnline to use PnP cmdlets to delete M365 groups and SharePoint sites
Connect-PnPOnline -Url $AdminCenterURL -Interactive

#Retrieve all M365 group connected (template "GROUP#0" sites to be deleted) sites beginning with https://contoso.sharepoint.com/sites/D-Test
$sites = Get-PnPTenantSite -Filter {Url -like https://contoso.sharepoint.com/sites/D-Test} -Template 'GROUP#0'

#Displaying the sites returned to be deleted
$sites | Format-Table  Url, Template, GroupId

Read-Host -Prompt "Press Enter to start deleting m365 groups and sites (CTRL + C to exit)"

$sites | ForEach-Object {
    #Delete M365 group
    Remove-PnPMicrosoft365Group -Identity $_.GroupId

    #Allow time for M365 group to be deleted
    Start-Sleep -Seconds 60

    #Delete the SharePoint site after the M365 group is deleted
    Remove-PnPTenantSite -Url $_.Url -Force -SkipRecycleBin

    #Permanently remove the M365 group
    Remove-PnPDeletedMicrosoft365Group -Identity $_.GroupId

    #Permanently delete the site and to allow a site to be created with the same URL of the site just deleted, i.e. to avoid message "This site address is available with modification"
    Remove-PnPTenantDeletedSite -Identity $_.Url -Force
}

# Disconnect SharePoint online connection
Disconnect-PnPOnline
```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365](#tab/cli-m365-ps)

```powershell
#Get Credentials to connect
$m365Status = m365 status
if ($m365Status -match "Logged Out") {
    m365 login
}

#Retrieve all M365 groups where display name starts with "Permission" (you can use filter as per your requirements)
$groups = m365 entra m365group list --displayName Permission | ConvertFrom-Json

#Displaying the M365 groups returned to be deleted
$groups | Format-Table displayName, id, mail

Read-Host -Prompt "Press Enter to start deleting M365 groups and associated SharePoint sites (CTRL + C to exit)"

$groups | ForEach-Object {
	#Permanently delete M365 group and associated SharePoint site without prompting for confirmation and without moving it to the Recycle Bin
	Write-Host "Deleting M365 group: $($_.displayName)"
	m365 entra m365group remove --id $_.id --force --skipRecycleBin
}

#Disconnect SharePoint online connection
m365 logout
```

[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

***

## Contributors

| Author(s) |
|-----------|
| Reshmee Auckloo |
| [Ganesh Sanap](https://ganeshsanapblogs.wordpress.com/) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/aad-delete-m365-groups-and-sharepoint-sites" aria-hidden="true" />
