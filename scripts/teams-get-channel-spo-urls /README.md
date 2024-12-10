---
plugin: add-to-gallery
---

# Retrieving SharePoint Site URL for Teams Channels

## Summary

You may want to retrieve the SharePoint sites of private and shared channels for different reasons like to add to eDiscovery when running against "Specific Locations" or just for reporting purposes. A teams can have up to 30 Private Channels and unlimited shared channels up to the maximum of 1000 channels. This script can help to identify the SharePoint Urls associated to private and shared channels.

# [PnP PowerShell](#tab/pnpps)

```powershell

param (
    [Parameter(Mandatory = $true)]
    [string] $domain ,
    [Parameter(Mandatory = $true)]
    [string] $teamName 
)

$adminSiteURL = "https://$domain-Admin.SharePoint.com"
Connect-PnPOnline -Url $adminSiteURL

$team = Get-PnPTeamsTeam -Identity  $teamName

$m365GroupId = $team.GroupId

Get-PnPTenantSite | Where-Object { $_.Template -eq 'TEAMCHANNEL#1' -and $_.RelatedGroupId -eq $m365GroupId  } | select Url,Template, Title

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***

## Source Credit

Sample first appeared on [Retrieving SharePoint Site URL for Teams Channels](https://reshmeeauckloo.com/posts/powershell-get-teams-channel-sharepoint-site/)

## Contributors

| Author(s) |
|-----------|
| [Reshmee Auckloo](https://github.com/reshmee011) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/teams-get-channel-spo-urls" aria-hidden="true" />