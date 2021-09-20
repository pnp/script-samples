---
plugin: add-to-gallery
---

# Cancel all running flow runs for a flow in an environment

## Summary

Do you want to automate the cancellation of running Power Automate flow runs?

This script will cancel all running flow runs of a Power Automate flow created in an environment. Pass the Flow environment id and the flow guid as parameter while running the script.

# [CLI for Microsoft 365 with PowerShell](#tab/cli-m365-ps)
```powershell

$flowEnvironment = $args[0]
$flowGUID = $args[1]
$flowRuns = m365 flow run list --environment $flowEnvironment --flow $flowGUID --output json | ConvertFrom-Json
foreach ($run in $flowRuns) {
  if ($run.status -eq "Running") {
    Write-Output "Run details: " $run
    # Cancel all the running flow runs
    m365 flow run cancel --environment $flowEnvironment --flow $flowGUID --name $run.name --confirm
    Write-Output "Run Cancelled successfully"
  }
}

```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
***

## Source Credit

Sample first appeared on [Cancel all running flow runs for a flow in an environment | CLI for Microsoft 365](https://pnp.github.io/cli-microsoft365/sample-scripts/flow/cancel-all-running-flow-runs/)

## Contributors

| Author(s) |
|-----------|
| Mohamed Ashiq Faleel |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/flow-cancel-all-running-flow-runs" aria-hidden="true" />