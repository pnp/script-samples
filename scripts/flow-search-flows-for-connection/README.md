---
plugin: add-to-gallery
---

# Search flows for connections

## Summary

Search all flows as, an administrator, for a specific search string and report results. This sample allows you to get a report of all flows that are connected to a specific site or list. The 
``` $searchString ``` can be any value but results are the best when using a GUID or site collection URL.
 
# [CLI for Microsoft 365 with PowerShell](#tab/cli-m365-ps)
```powershell
Write-Output "Retrieving all environments"

$environments = m365 flow environment list -o json | ConvertFrom-Json
$searchString = "15f5b014-9508-4941-b564-b4ab1b863a7a" #listGuid
$path = "exportedflow.json";

ForEach ($env in $environments) {
    Write-Output "Processing $($env.displayName)..."

    $flows = m365 flow list --environment $env.name --asAdmin -o json | ConvertFrom-Json

    ForEach ($flow in $flows) {

        m365 flow export --id $flow.name --environment $env.name --format json --path $path

        $flowData = Get-Content -Path $path

        if ($flowData.Contains($searchString)) {
            Write-Output $($flow.displayName + "contains your search string" + $searchString)
            Write-Output $flow.id
        }

        Remove-Item $path -Confirm:$false
    }
}
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

## Source Credit

Sample first appeared on [Search flows for connections | CLI for Microsoft 365](https://pnp.github.io/cli-microsoft365/sample-scripts/flow/search-flows-for-connection/)

## Contributors

| Author(s) |
|-----------|
| Albert-Jan Schot |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/flow-search-flows-for-connection" aria-hidden="true" />