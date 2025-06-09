# Delete entire Hub site structure


## Summary

Sometimes you need to delete a hub site and all the sites associated with it. This script will do just that. It will remove all sites in the hub, unregister the hub site, and then remove the hub site itself.

![Example Screenshot](assets/example.png)


# [PnP PowerShell](#tab/pnpps)

```powershell

function Remove-HubAndSites {
    param (
        [string]$hubsiteUrl,
        $adminConnection
    )

    # Get all sites in the hub
    $sitesInHub = get-pnpHubSiteChild -Identity $hubsiteUrl -Connection $adminConnection -ErrorAction Stop

    # Loop through each site and remove it
    foreach ($site in $sitesInHub) 
    {
        try {
            Remove-PnPTenantSite -Url $site -Connection $adminConnection -Force #-SkipRecycleBin
            Write-Host "Removed site: $($site)"
        } catch 
        {
            Write-Host "Failed to remove site: $($site) - $_"
            throw $_
        }
    }

    # Unregister the hub site
    try {
        Unregister-PnPHubSite -Site $hubsiteUrl -Connection $adminConnection
        Write-Host "Unregistered hub site: $hubsiteUrl"
    } 
    catch 
    {
        Write-Host "Failed to unregister hub site: $hubsiteUrl - $_"
        throw $_
    }
    # Remove the hub site itself
    try 
    {
        Remove-PnPTenantSite -Url $hubsiteUrl -Connection $adminConnection -Force #-SkipRecycleBin
        Write-Host "Removed hub site: $hubsiteUrl"
    } 
    catch 
    {
        Write-Host "Failed to remove hub site: $hubsiteUrl - $_"
        throw $_
    }
}
$adminUrl = "https://contoso-admin.sharepoint.com/"
$PnPClientId = "the PnP Client ID for your app registration"
if($null -eq $adminconn)
{
    $adminconn = Connect-PnPOnline -Url $adminUrl -Interactive -ClientId $PnPClientId -ReturnConnection
}
else
{
    Write-Host "Using existing admin connection" -ForegroundColor Yellow
}

$hubSiteUrl = "https://contoso.sharepoint.com/sites/ANL11855"
# Call the function to remove the hub site and its associated sites
Remove-HubAndSites -hubsiteUrl $hubSiteUrl -adminConnection $adminconn

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***


## Contributors

| Author(s) |
|-----------|
| Kasper Larsen |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-delete-hub-and-sites" aria-hidden="true" />
