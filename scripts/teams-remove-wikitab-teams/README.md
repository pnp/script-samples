---
plugin: add-to-gallery
---

# Remove Wiki tab in a Microsoft Teams channel

## Summary

Removes the wiki tab of a Microsoft Teams Team's channel.


[!INCLUDE [Delete Warning](../../docfx/includes/DELETE-WARN.md)]
 
![Example Screenshot](assets/example.png)
 
# [CLI for Microsoft 365 with PowerShell](#tab/cli-m365-ps)
```powershell
$groupMailNickname = "Architecture"
$channelName = "General"

$groups = m365 aad o365group list --query "[?mailNickname=='$groupMailNickname']" -o json | ConvertFrom-Json
if ($null -eq $groups) { Write-Error "A team with the mailNickname $groupMailNickname was not found" }
else {
  $channels = m365 teams channel list --teamId $groups[0].id --query "[?displayName=='$channelName']" -o json | ConvertFrom-Json
  if ($null -eq $channels) { Write-Error "A channel with the name $channelName was not found in the team" }
  else {
    $tabs = m365 teams tab list --teamId $groups[0].id --channelId $channels[0].id --query "[?teamsApp.id=='com.microsoft.teamspace.tab.wiki']" -o json | ConvertFrom-Json
    if ($null -eq $tabs) { Write-Error "A Wiki tab was not found in the channel" }
    else {
      write-host "Removing wiki tab for the channel.." -ForegroundColor Green 
      m365 teams tab remove --teamId $groups[0].id --channelId $channels[0].id --tabId $tabs[0].id --confirm
      write-host " ...Done" -ForegroundColor Green 
    }
  }
}
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
 
# [Microsoft 365 CLI with Bash](#tab/m365cli-bash)
```bash
#!/bin/bash

# requires jq: https://stedolan.github.io/jq/

groupMailNickname="Architecture"
channelName="Channel"
wikiTabId="com.microsoft.teamspace.tab.wiki"

groups=$(m365 aad o365group list -o json | jq '.[] | select(.mailNickname == "'"$groupMailNickname"'")')
if [ -z "$groups" ]; then
  echo "A team with the mailNickname $groupMailNickname was not found"
else
  teamId=$(echo $groups | jq '.id')
  channels=$(m365 teams channel list --teamId $teamId -o json | jq '.[] | select(.displayName == "'"$channelName"'")')
  
  if [ -z "$channels" ]; then
    echo "A channel with the name $channelName was not found in the team"
  else
    channelId=$(echo $channels | jq '.id')
    tabs=$(m365 teams tab list --teamId $teamId --channelId $channelId -o json | jq '.[] | select(.teamsApp.id == "'"$wikiTabId"'")')

    if [ -z "$tabs" ]; then
      echo "A Wiki tab was not found in the channel"
    else
      tabId=$(echo $tabs | jq '.id')
      echo "Removing wiki tab for the channel.."
      m365 teams tab remove --teamId $teamId --channelId $channelId --tabId $tabId --confirm
      echo "...Done"
    fi
  fi
fi
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
***

## Source Credit

Sample first appeared on [Remove Wiki tab in a Microsoft Teams channel | CLI for Microsoft 365](https://pnp.github.io/cli-microsoft365/sample-scripts/teams/remove-wikitab-teams/)

## Contributors

| Author(s) |
|-----------|
| Garry Trinder |
| Laura Kokkarinen |
| Rabia Williams |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/teams-remove-wikitab-teams" aria-hidden="true" />