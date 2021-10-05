---
plugin: add-to-gallery
---

# Resubmit all failed flow runs for a flow in an environment

## Summary

Have you ever been forced to resubmit lot of failed Power Automate flow runs manually?

Microsoft 365 CLI cmdlets to the rescue, it will help you resubmit the flow runs automatically.

This script will resubmit all failed flow runs of a Power Automate flow created in an environment. Pass the Flow environment id and the flow guid as parameter while running the script.

# [CLI for Microsoft 365 with PowerShell](#tab/cli-m365-ps)
```powershell
$flowEnvironment = $args[0]
$flowGUID = $args[1]
$flowRuns = m365 flow run list --environment $flowEnvironment --flow $flowGUID --output json | ConvertFrom-Json
foreach ($run in $flowRuns) {
  if ($run.status -eq "Failed") {
    Write-Output "Run details: " $run
    #Resubmit all the failed flows
    m365 flow run resubmit --environment $flowEnvironment --flow $flowGUID --name $run.name --confirm
    Write-Output "Run resubmitted successfully"
  }
}
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

## Source Credit

Sample first appeared on [Resubmit all failed flow runs for a flow in an environment | CLI for Microsoft 365](https://pnp.github.io/cli-microsoft365/sample-scripts/flow/resubmit-all-failed-flow-runs/)

## Contributors

| Author(s) |
|-----------|
| Mohamed Ashiq Faleel |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/flow-resubmit-all-failed-flow-runs" aria-hidden="true" />