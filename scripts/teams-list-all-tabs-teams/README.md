---
plugin: add-to-gallery
---

# List all tabs in Microsoft Teams teams in the tenant

## Summary

List all tabs in Microsoft Teams teams in the tenant and exports the results in a CSV.
 
![Example Screenshot](assets/example.png)
 
# [CLI for Microsoft 365 with PowerShell](#tab/cli-m365-ps)
```powershell
$fileExportPath = "<PUTYOURPATHHERE.csv>"
$m365Status = m365 status
if ($m365Status -eq "Logged Out") {
  # Connection to Microsoft 365
  m365 login
}
$results = @()
$allTeams = m365 teams team list -o json | ConvertFrom-Json
$teamCount = $allTeams.Count
Write-Host "Processing $teamCount teams..."
#Loop through each Team
$counter = 0
foreach ($team in $allTeams) {
  $counter++
  Write-Host "Processing $($team.displayName)... ($counter/$teamCount)"
  $allChannels = m365 teams channel list --teamId $team.id -o json | ConvertFrom-Json
    
  #Loop through each Channel
  foreach ($channel in $allChannels) {
    $allTabs = m365 teams tab list --teamId $team.id --channelId $channel.id -o json | ConvertFrom-Json
        
    #Loop through each Tab + get the info!
    foreach ($tab in $allTabs) {
      $results += [pscustomobject][ordered]@{
        TeamId                = $team.id
        TeamDisplayName       = $team.displayName
        TeamIsArchived        = $team.isArchived
        TeamVisibility        = $team.visibility
        ChannelId             = $channel.id
        ChannelDisplayName    = $channel.DisplayName
        ChannelMemberShipType = $channel.membershipType
        TabId                 = $tab.id
        TabNameDisplayName    = $tab.DisplayName
        TeamsAppTabId         = $tab.teamsAppTabId
      }
    }
  }
}
Write-Host "Exporting file to $fileExportPath.."
$results | Export-Csv -Path $fileExportPath -NoTypeInformation
Write-Host "Completed."
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
***

## Source Credit

Sample first appeared on [List all tabs in Microsoft Teams teams in the tenant | CLI for Microsoft 365](https://pnp.github.io/cli-microsoft365/sample-scripts/teams/list-all-tabs-teams/)

## Contributors

| Author(s) |
|-----------|
| Veronique Lengelle |
| Patrick Lamber |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/teams-list-all-tabs-teams" aria-hidden="true" />