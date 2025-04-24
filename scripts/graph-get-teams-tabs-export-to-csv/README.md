

# Get teams tabs and export to CSV

## Summary

Locate all Teams having a Wiki and export the list to CSV

# [Microsoft Graph PowerShell](#tab/graphps)

```powershell


Connect-MgGraph -Scopes "Team.ReadBasic.All", "TeamSettings.Read.All", "TeamSettings.ReadWrite.All", "User.Read.All", "Directory.Read.All", "User.ReadWrite.All", "Directory.ReadWrite.All", "Channel.ReadBasic.All", "TeamsTab.Read.All"
$accessToken = m365 util accesstoken get --resource https://graph.microsoft.com --new
$accessToken.Trim('"');


$header = @{
    'Authorization' = "Bearer $($accessToken.Trim('"'))"
   'Content-type'  = "application/json"
}

$teams = (Invoke-MgGraphRequest -Method GET https://graph.microsoft.com/v1.0/me/joinedTeams -Headers $header).value

$teamsWithWiki = @()
foreach($team in $teams)
{
    
    $channels = (Invoke-MgGraphRequest -Method GET https://graph.microsoft.com/v1.0/teams/$($team.id)/channels -Headers $header).value
    foreach($channel in $channels){
        
        $tabs = (Invoke-MgGraphRequest -Method GET https://graph.microsoft.com/v1.0/teams/$($team.id)/channels/$($channel.id)/tabs -Headers $header).value
        # $tabs = (Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/teams/$($team.id)/channels/$($channel)/tabs" -Headers $header).value
        if ($tabs.displayName -match "Wiki")
        {
            $teamsWithWiki += $team
        }
    }
}

# Export results to CSV file
$teamsWithWiki.GetEnumerator() | select description, id, displayName, tenatId  | Export-Csv -Path "teams_with_wiki.csv" -NoTypeInformation

```
[!INCLUDE [More about Microsoft Graph PowerShell SDK](../../docfx/includes/MORE-GRAPHSDK.md)]
***

## Contributors

| Author(s) |
|-----------|
| Valeras Narbutas|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]

<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/graph-get-teams-tabs-export-to-csv" aria-hidden="true" />
