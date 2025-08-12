# Add a SharePoint Document Library as a Tab in Microsoft Teams

## Summary

Adding a SharePoint document library as a tab in Microsoft Teams is a common requirement for collaboration scenarios. While Teams provides an out-of-the-box (OOTB) experience for this, automating the process via PowerShell or Microsoft Graph can be tricky due to limitations.

Thanks to [Tiago Duarte](https://github.com/tiagoduarte) through the discussion within the [[BUG] Add-PnPTeamsTab with DocumentLibrary type creates a hidden tab(https://github.com/pnp/powershell/issues/4948) he raised , he found out a solution for it using Ms Graph PowerShell and I attempted to achieve same using PnP PowerShell. 
 
# [PnP PowerShell](#tab/pnpps)

```powershell

# Connect to SharePoint Online admin center
Connect-PnPOnline -Url $AdminCenterURL -Interactive

$siteUrl = "https://contoso.sharepoint.com/sites/Retail"
$lib = "test"  # Specify the library name
$team = "Retail"
$channel = "General"
$displayName = "test"

$ContentUrl = ($siteUrl + '/_layouts/15/filebrowser.aspx?app=teamsfile&scenario=teamsPage&auth=none&fileBrowser=' + [System.Web.HttpUtility]::UrlEncode('{"sdk":"1.0","entry":{"sharePoint":{"byPath":{"folder":"' + $siteUrl + '/' + $lib + '"}}}}') + '&theme={theme}')
Add-PnPTeamsTab -Team $team -Channel $channel -DisplayName $displayName -Type Custom -ContentUrl $ContentUrl -TeamsAppId "2a527703-1f6f-4559-a332-d8a7d288cd88"
# Disconnect SharePoint online connection
Disconnect-PnPOnline
```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365](#tab/cli-m365-ps)

```powershell

$siteUrl = "https://contoso.sharepoint.com/sites/Retail"
$lib = "test"  # Specify the library name
$team = "Retail"
$channel = "General"
$displayName = "test"

# Login to Microsoft 365 CLI with service principal
m365 login --appId "xxx" --tenant "xxx" 

# Get teamId using CLI
$teamId = m365 teams team get --name $team --output json | ConvertFrom-Json | Select-Object -ExpandProperty id
# Get channelId using CLI
$channelId = m365 teams channel get --teamId $teamId --name $channel --output json | ConvertFrom-Json | Select-Object -ExpandProperty id

$ContentUrl = ($siteUrl + '/_layouts/15/filebrowser.aspx?app=teamsfile&scenario=teamsPage&auth=none&fileBrowser=' + [System.Web.HttpUtility]::UrlEncode('{"sdk":"1.0","entry":{"sharePoint":{"byPath":{"folder":"' + $siteUrl + '/' + $lib + '"}}}}') + '&theme={theme}')

m365 teams tab add --teamId $teamId --channelId $channelId --appId "2a527703-1f6f-4559-a332-d8a7d288cd88" --appName $displayName --contentUrl $ContentUrl

# Disconnect M365 connection
m365 logout
```

[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

***

## Source Credit

Sample first appeared on [How to Add a SharePoint Document Library as a Tab in Microsoft Teams with PowerShell](https://reshmeeauckloo.com/posts/powershell-teams-add-documentlibrary-as-tab//)

## Contributors

| Author(s) |
|-----------|
| [Reshmee Auckloo](https://github.com/reshmee011) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/teams-add-sharepointlibrary-as-tab" aria-hidden="true" />
