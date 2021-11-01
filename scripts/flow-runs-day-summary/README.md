---
plugin: add-to-gallery
---

# Flow run day summary

## Summary

Powershell script that could run once a day and sends summary (for example adaptive card in teams) with list of all flows runs with total runs count for current day, number of times the flow succeeded and number of times the flow failed

result in console

![run in console](assets/example2.png)

result as adaptive card in teams

![adaptive card in teams](assets/example.png)
 
# [CLI for Microsoft 365 with PowerShell](#tab/cli-m365-ps)
```powershell

$m365Status = m365 status
if ($m365Status -eq "Logged Out") {
    m365 login
}

$environment = 'Default-2942bb31-1d49-4da6-8d3d-d0f9e1141234'
$adaptiveCard = '{\"type\":\"AdaptiveCard\",\"body\":[{\"type\":\"TextBlock\",\"size\":\"Medium\",\"weight\":\"Bolder\",\"text\":\"${title}\"},{\"type\":\"TextBlock\",\"text\":\"${description}\",\"wrap\":true}],\"$schema\":\"http://adaptivecards.io/schemas/adaptive-card.json\",\"version\":\"1.3\"}'
$webhook = 'https://contoso.webhook.office.com/webhookb2/1204eba2-061c-4442-9696-2a725cb2d094@2942bb31-1d49-4da6-8d3d-d0f9e1141486/IncomingWebhook/6e54c3958bde444e96fec9ecad356993/be11f523-2a4d-4eae-9d42-277410893c41'

$flows = m365 flow list --environment $environment --output json
$flows = $flows | ConvertFrom-Json
$currentDayDate = Get-Date
$previousDayDate = (Get-Date).AddDays(-1)

$adaptiveCardDescription = ""
foreach ($flow in $flows) 
{
    $flowRuns = m365 flow run list --environment $environment --flow $flow.name --output json
    $flowRuns = $flowRuns | ConvertFrom-Json

    $displayName = $flow.displayName
    $id = $flow.name

    $todayRuns = $flowRuns.Where({[DateTime]$_.properties.endTime -le $currentDayDate -and [DateTime]$_.properties.endTime -gt $previousDayDate})
    
    $todayRunsCount = 0
    $todaySuccessRunsCount = 0
    $todayFailedRunsCount = 0
    if($todayRuns.Count -gt 0)
    {
        $todaySuccessRuns = $todayRuns.Where({$_.status -eq 'Succeeded'})
        $todaySuccessRunsCount = $todaySuccessRuns.Count

        $todayFailedRuns = $todayRuns.Where({$_.status -eq 'Failed'})
        $todayFailedRunsCount = $todayFailedRuns.Count

        $todayRunsCount = $todayRuns.Count
    }

    Write-Host "$displayName -> Runs: $todayRunsCount , Succeeded: $todaySuccessRunsCount , Failed: $todayFailedRunsCount"
    $adaptiveCardDescription = $adaptiveCardDescription + "\r- [$displayName](https://us.flow.microsoft.com/manage/environments/$environment/flows/$id/details) -> Runs: $todayRunsCount , Succeeded: $todaySuccessRunsCount , Failed: $todayFailedRunsCount"
}

$today = Get-Date -Format "MM/dd/yyyy"
$cardData = '{\"title\": \"Flows summary - ' + $today + '\" ,\"description\":\"' + $adaptiveCardDescription + '\"}'

m365 adaptivecard send --url $webhook --card $adaptiveCard --cardData $cardData

```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

## Contributors

| Author(s) |
|-----------|
| [Adam Wójcik](https://github.com/Adam-it)|


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/flow-search-flows-for-connection" aria-hidden="true" />