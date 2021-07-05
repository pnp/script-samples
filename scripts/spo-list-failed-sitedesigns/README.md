---
plugin: add-to-gallery
---

# List all failed site design for all sites

## Summary

The following script iterates through all site collections and lists all site design runs with errors. By filtering on ``` OutcomeCode == '1' ``` it will return all sites and runs with explicit errors. By filtering on ``` OutcomeCode != '0' ```  you can also return any result that is not marked as successful.
 
![Example Screenshot](assets/example.png)
 
# [CLI for Microsoft 365 with PowerShell](#tab/cli-m365-ps)
```powershell
$allSPOSites = m365 spo site classic list -o json | ConvertFrom-Json
$siteCount = $allSPOSites.Count
Write-Output "Processing $siteCount sites..."
foreach ($site in $allSPOSites) {
    $siteCounter++
    Write-Output "Processing $($site.Url)... ($siteCounter/$siteCount)"
    $runs = m365 spo sitedesign run list --webUrl $site.Url --output json | ConvertFrom-Json
    foreach ($run in $runs) {
        $runData = m365 spo sitedesign run status get --webUrl $site.Url --runId $run.ID --query '[?OutcomeCode == `1`]' --output json | ConvertFrom-Json
        if ($runData) {
            Write-Output "$($run.SiteDesignTitle) failed at $($site.Url) with id $($run.ID)"
        }
    }
}
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
***

## Source Credit

Sample first appeared on [List all failed site design for all sites | CLI for Microsoft 365](https://pnp.github.io/cli-microsoft365/sample-scripts/spo/list-failed-sitedesigns/)

## Contributors

| Author(s) |
|-----------|
| Albert-Jan Schot |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/spo-list-failed-sitedesigns" aria-hidden="true" />