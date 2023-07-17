---
plugin: add-to-gallery
---

# Tenant Site Inventory

## Summary

This script provides you the list of active sites in your tenant with their administrator and usage in MB.


# [PnP PowerShell](#tab/pnpps)

```powershell

 Connect-PnPOnline -Url "https://contoso-admin.sharepoint.com/" -Interactive
        
        # Get all SharePoint sites
        $sites = Get-PnPTenantSite
        
        # Create an array to store the results
        $results = @()
        
        # Iterate through each site and gather required information
        foreach ($site in $sites) {
            $siteUrl = $site.Url
            
            Connect-PnPOnline -Url $siteUrl -Interactive

            # Get site administrators
            $admins = Get-PnPSiteCollectionAdmin | Select-Object -ExpandProperty Title
        
            # Get site storage size
            $storageSize = Get-PnPTenantSite -Url $siteUrl | Select-Object -ExpandProperty StorageUsageCurrent
        
            # Create a custom object with the site information
            $siteInfo = [PSCustomObject]@{
                SiteUrl = $siteUrl
                Administrators = $admins -join ";"
                StorageSize = $storageSize.ToString() +" MB(s)"
            }
        
            # Add the site information to the results array
            $results += $siteInfo
        }
        
        # Output the results as a CSV file
        $results | Export-Csv -Path "SiteInventory.csv" -NoTypeInformation

        # Disconnect from SharePoint Online
        Disconnect-PnPOnline

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

## Contributors

| Author(s) |
|-----------|
| [Diksha Bhura](https://github.com/Diksha-Bhura) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-tenant-site-inventory" aria-hidden="true" />