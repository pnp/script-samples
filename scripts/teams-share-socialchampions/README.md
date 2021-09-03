---
plugin: add-to-gallery
---

# Share social champions to Teams

## Summary

Retrieves activities for SharePoint Online, Teams and Yammer and shares the top 3 contributors for each category as an adaptive card to the specified webhook url.
 
## [CLI for Microsoft 365 with PowerShell](#tab/cli-m365-ps)
```powershell
$m365Status = m365 status

if ($m365Status -eq "Logged Out") {
  # Connection to Microsoft 365
  m365 login
}

$webhookUrl = "<PUTYOURURLHERE>"

# Send top 3 for SharePoint based on file actions.
$activityUsers = m365 spo report activityuserdetail --period D7 --output json --query 'reverse(sort_by(@, &\"Viewed Or Edited File Count\")) | [0:3].\"User Principal Name\"' | ConvertFrom-Json
$title = "SharePoint Weekly Social Champions"
$card = '{ \"type\": \"AdaptiveCard\", \"$schema\": \"http://adaptivecards.io/schemas/adaptive-card.json\", \"version\": \"1.2\", \"body\": [  {  \"type\": \"TextBlock\",  \"text\": \"'+$($title)+'\",  \"wrap\": true,  \"size\": \"Medium\",  \"weight\": \"Bolder\",  \"color\": \"Attention\"  },  {  \"type\": \"TextBlock\",  \"wrap\": true,  \"text\": \"Week '+$(get-date -UFormat %V)+'\",  \"fontType\": \"Default\",  \"size\": \"Small\",  \"weight\": \"Lighter\",  \"isSubtle\": true  },  {  \"type\": \"FactSet\",  \"facts\": [   {   \"title\": \"First place\",   \"value\": \"'+$($activityUsers[0])+'\"   },   {   \"title\": \"Second place\",   \"value\": \"'+$($activityUsers[1])+'\"   },   {   \"title\": \"Third place\",   \"value\": \"'+$($activityUsers[2])+'\"   }  ]  } ] }'
m365 adaptivecard send --url $webhookUrl --card $card

# Send top 3 for Teams based on chat messages
$activityUsers = m365 teams report useractivityuserdetail --period D7 --output json --query 'reverse(sort_by(@, &\"Team Chat Message Count\")) | [0:3].\"User Principal Name\"' | ConvertFrom-Json
$title = "Teams Weekly Social Champions"
$card = '{ \"type\": \"AdaptiveCard\", \"$schema\": \"http://adaptivecards.io/schemas/adaptive-card.json\", \"version\": \"1.2\", \"body\": [  {  \"type\": \"TextBlock\",  \"text\": \"'+$($title)+'\",  \"wrap\": true,  \"size\": \"Medium\",  \"weight\": \"Bolder\",  \"color\": \"Attention\"  },  {  \"type\": \"TextBlock\",  \"wrap\": true,  \"text\": \"Week '+$(get-date -UFormat %V)+'\",  \"fontType\": \"Default\",  \"size\": \"Small\",  \"weight\": \"Lighter\",  \"isSubtle\": true  },  {  \"type\": \"FactSet\",  \"facts\": [   {   \"title\": \"First place\",   \"value\": \"'+$($activityUsers[0])+'\"   },   {   \"title\": \"Second place\",   \"value\": \"'+$($activityUsers[1])+'\"   },   {   \"title\": \"Third place\",   \"value\": \"'+$($activityUsers[2])+'\"   }  ]  } ] }'
m365 adaptivecard send --url $webhookUrl --card $card

# Send top 3 for Yammer based on posts
$activityUsers = m365 yammer report activityuserdetail --period D7 --output json --query 'reverse(sort_by(@, &\"Posted Count\")) | [0:3].\"User Principal Name\"' | ConvertFrom-Json
$title = "Yammer Weekly Social Champions"
$card = '{ \"type\": \"AdaptiveCard\", \"$schema\": \"http://adaptivecards.io/schemas/adaptive-card.json\", \"version\": \"1.2\", \"body\": [  {  \"type\": \"TextBlock\",  \"text\": \"'+$($title)+'\",  \"wrap\": true,  \"size\": \"Medium\",  \"weight\": \"Bolder\",  \"color\": \"Attention\"  },  {  \"type\": \"TextBlock\",  \"wrap\": true,  \"text\": \"Week '+$(get-date -UFormat %V)+'\",  \"fontType\": \"Default\",  \"size\": \"Small\",  \"weight\": \"Lighter\",  \"isSubtle\": true  },  {  \"type\": \"FactSet\",  \"facts\": [   {   \"title\": \"First place\",   \"value\": \"'+$($activityUsers[0])+'\"   },   {   \"title\": \"Second place\",   \"value\": \"'+$($activityUsers[1])+'\"   },   {   \"title\": \"Third place\",   \"value\": \"'+$($activityUsers[2])+'\"   }  ]  } ] }'
m365 adaptivecard send --url $webhookUrl --card $card
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]


## Source Credit

Sample first appeared on [Share social champions to Teams | CLI for Microsoft 365](https://pnp.github.io/cli-microsoft365/sample-scripts/teams/share-socialchampions/)

## Contributors

| Author(s) |
|-----------|
| Albert-Jan Schot |
| Emily Mancini |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/teams-share-socialchampions" aria-hidden="true" />