---
plugin: add-to-gallery
---

# Export a single flow to a Logic App

## Summary

Want to upgrade one of your Power Automate flows to a Logic App? Missing the option in the UI? Or just looking at an easy way to do it programmatically?

By combining the CLI for Microsoft 365 and PowerShell we can make this task easy and repeatable.

This script will export the Power Automate flow *Your sample test flow*, make sure to pass the correct name in the script, and your flow will be exported right away.

# [CLI for Microsoft 365 using PowerShell](#tab/cli-m365-ps)

```powershell
Write-Output "Getting environment info..."
$environmentId = $(m365 flow environment list --query "[?displayName == '(default)']" -o json | ConvertFrom-Json).Name
$flowId = $(m365 flow list --environment $environmentId --query "[?displayName == 'Your sample test flow']" -o json | ConvertFrom-Json)[0].Name

Write-Output "Getting Flow info..."
m365 flow export --environment $environmentId --id $flowId -f 'json'

Write-Output "Complete"
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

# [CLI for Microsoft 365 using Bash](#tab/cli-m365-bash)
```bash
#!/bin/bash
ENV_NAME=m365 flow environment list --query '[?contains(displayName,`default`)] .name'
FLOW_NAME=m365 flow list --environment $environmentId --query '[?displayName == `Your sample test flow`] .name'
echo "Exporting your flow"
m365 flow export --environment $ENV_NAME --id $FLOW_NAME -f 'json'
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
***
## Source Credit

Sample first appeared on [Export a single flow to a Logic App | CLI for Microsoft 365](https://pnp.github.io/cli-microsoft365/sample-scripts/flow/export-flow-logicapp/)

## Contributors

| Author(s) |
|-----------|
| Albert-Jan Schot |
| Luise Freese |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/flow-export-flow-logicapp" aria-hidden="true" />