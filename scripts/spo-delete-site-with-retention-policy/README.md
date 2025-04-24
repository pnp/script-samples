

# Delete SharePoint Online sites that have retention policies

## Summary

This sample script deletes specified SharePoint Online sites that have a retention policy applied by excluding them from the retention policy, deleting the site and then cleaning up the retention policy exclusions.

Trying to delete a site connected to a M365 group with this script will show the message "This site belongs to a Microsoft 365 group. To delete the site, you must delete the group.". Deletion of M365 group is not handled by this script.

[Exchange Online PowerShell module](https://learn.microsoft.com/en-us/powershell/exchange/exchange-online-powershell-v2) is used for the retention policy exclusion, available on [PowerShell Gallery](https://www.powershellgallery.com/packages/ExchangeOnlineManagement)

![Example Screenshot](assets/example.png)

# [PnP PowerShell](#tab/pnpps)

```powershell
$spoAdminUrl = "<spo admin center url>"
$retentionPolicyName = "<name of the retention policy applied to the sites>"

[string[]]$sitesUrls = @(
    "<spo site to delete url 1>"
    "<spo site to delete url 2>"
    "<spo site to delete url 3>"
)

$ErrorActionPreference = "Stop"

# Connect to Security & Compliance
Connect-IPPSSession

# Connect to SPO Admin Center using PnP PowerShell
Connect-PnPOnline $spoAdminUrl -Interactive

# Exclude the SPO sites from the retention policy.
# This might take a few minutes to take effect. Use Get-RetentionCompliancePolicy -DistributionDetail "Test 2 years" | Select-Object Distribution* to check the distribution status
Write-Host "Excluding sites from retention policy"
Set-RetentionCompliancePolicy -Identity $retentionPolicyName -AddSharePointLocationException $sitesUrls

foreach ($siteUrl in $sitesUrls)
{
    try
    {
        Write-Host "Deleting site $siteUrl"
        Remove-PnPTenantSite -Url $siteUrl -Force
    }
    catch
    {
        Write-Host $_
    }
}

# Clean up the retention policy exclusions by removing the sites just deleted
Write-Host "Cleaning up retention policy exclusions"
Set-RetentionCompliancePolicy -Identity $retentionPolicyName -RemoveSharePointLocationException $sitesUrls
```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Contributors

| Author(s) |
|-----------|
| Giacomo Pozzoni |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-delete-site-with-retention-policy" aria-hidden="true" />