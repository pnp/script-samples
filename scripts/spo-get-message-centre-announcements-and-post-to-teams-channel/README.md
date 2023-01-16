---
plugin: add-to-gallery
---

# Retrieve Message Centre announcements and post to Teams channel

## Summary

This script allows you to connect to your SharePoint Online tenant and retrieve Message Centre announcements. It then connects to Microsoft Teams and loops through the announcements, posting them to a specific Teams channel.

# [PnP PowerShell](#tab/pnpps)

```powershell
# Connect to SharePoint Online
Connect-PnPOnline -Url https://yourTenantName.sharepoint.com/ -Interactive 

# Get Message Centre announcements
$announcements = Get-PnPMessageCenterAnnouncement | Where-Object { $_.Category -eq "PlanForChange" } | Select-Object Title, Description

# Connect to teams
Connect-MicrosoftTeams 

# Loop through the announcements and post to Teams channel
foreach ($announcement in $announcements) {
    $message = "$($announcement.Title): $($announcement.Description)"
    Submit-PnPTeamsChannelMessage -Team "TeamID"  -Channel "General"  -Message $message
}

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Contributors

| Author(s) |
|-----------|
| Valeras Narbutas |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-get-message-centre-announcements-and-post-to-teams-channel" aria-hidden="true" />
