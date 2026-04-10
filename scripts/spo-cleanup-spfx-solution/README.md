# Cleanup a SPFx Solution from every Site and App Catalog

## Summary

This script fully removes a SPFx solution from a SharePoint Online tenant. It iterates over all site collections, uninstalls the app where it is deployed, and clears any leftover entries from the site recycle bins. Finally, it removes the app package from the tenant app catalog and empties the app catalog recycle bin as well — ensuring no traces of the solution remain across the tenant.

# [PnP PowerShell](#tab/pnpps)

```powershell
# Set the SharePoint Tenant name
$tenantName = "contoso"
# Set App catalog Url
$appCatalogUrl = "appcatalog"
# Set App name (SPFx solution)
$appName = "my-spfx-solution"

# Connect to the SharePoint admin center to retrieve tenant-wide app and site data
Connect-PnPOnline -Url "https://$($tenantName)-admin.sharepoint.com" -Interactive

# Resolve the app ID from the tenant app catalog by matching the title
$app = Get-PnPApp | Where-Object { $_.Title -eq $appName }

# Get all site collections in the tenant
$sites = Get-PnPTenantSite

foreach ($site in $sites) {
    try {
        Connect-PnPOnline -Url $site.Url -Interactive

        # Check if this site has the app listed (not necessarily installed)
        $installedApp = Get-PnPApp | Where-Object { $_.Id -eq $app.Id }

        # InstalledVersion is only set when the app is actively deployed on the site
        if ($installedApp -and $installedApp.InstalledVersion) {
            Write-Host "Removing app from $($site.Url)"

            Uninstall-PnPApp -Identity $installedApp.Id
        }

        # After uninstall, the app package moves to the recycle bin — clear it to fully remove it
        $recycleItems = Get-PnPRecycleBinItem | Where-Object {
            $_.Title -like $appName
        }

        foreach ($item in $recycleItems) {
            Clear-PnPRecycleBinItem -Identity $item.Id -Force
        }

    } catch {
        Write-Host "Error on $($site.Url): $_"
    }
}

# Connect to the tenant app catalog site to remove the app package itself
Connect-PnPOnline -Url "https://$($tenantName).sharepoint.com/sites/$($appCatalogUrl)" -Interactive

# Remove the app package from the app catalog
Remove-PnPApp -Identity $appName -Force

# Clear the app catalog recycle bin to ensure the package is fully gone
$recycleItems = Get-PnPRecycleBinItem | Where-Object {
    $_.Title -like $appName
}

foreach ($item in $recycleItems) {
    Clear-PnPRecycleBinItem -Identity $item.Id -Force
}
```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***

## Contributors

| Author(s) |
|-----------|
| [Fabian Hutzli](https://github.com/fabianhutzli)|


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-cleanup-spfx-solution" aria-hidden="true" />
