---
plugin: add-to-gallery
---

# List app usage in Microsoft Teams

## Summary

A sample script which iterates through all the teams in your tenant and lists all apps in each team. This script will be handy if you want to generate a report of available apps in Teams across your tenant.
 
# [CLI for Microsoft 365 with PowerShell](#tab/cli-m365-ps)
```powershell
$availableTeams = m365 teams team list -o json | ConvertFrom-Json

if ($availableTeams.count -gt 15) {
    $duration =  [math]::Round(($availableTeams.count/60),1);
    Write-Host "There are total of $($availableTeams.count) teams. This probably will take around $duration minutes to finish."
} else {
    Write-Host "There are total of $($availableTeams.count) teams."
}

foreach ($team in $availableTeams) {
    $apps = m365 teams app list -i $team.Id -a    
    Write-Output "All apps in team are given below: $($team.displayName) $($team.id)"
    Write-Output $apps
}
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
 
# [Microsoft 365 CLI with Bash](#tab/m365cli-bash)
```bash
#!/bin/bash

# requires jq: https://stedolan.github.io/jq/
defaultIFS=$IFS
IFS=$'\n'

availableTeams=$(m365 teams team list -o json)

if [[ $(echo $availableTeams | jq length) -gt 15 ]]; 
then
  duration=$(((($(echo $availableTeams | jq length)) + 59) / 60))
  echo "There are total of" $(echo $availableTeams | jq length) "teams. This probably will take around" $duration" minutes to finish."
else
  echo "There are total of" $(echo $availableTeams | jq length) "teams available"
fi

for team in $(echo $availableTeams | jq -c '.[]'); do
    apps=$(o365 teams app list -i $(echo $team | jq ''.id) -a)
    echo "All apps in team are given below: " $(echo $team | jq ''.displayName) " " $(echo $team | jq ''.id)
    echo $apps
done
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]


## Source Credit

Sample first appeared on [List app usage in Microsoft Teams | CLI for Microsoft 365](https://pnp.github.io/cli-microsoft365/sample-scripts/teams/list-teams-app-usage/)

## Contributors

| Author(s) |
|-----------|



[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/teams-list-teams-app-usage" aria-hidden="true" />