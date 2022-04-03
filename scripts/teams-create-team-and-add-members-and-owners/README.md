---
plugin: add-to-gallery
---

# Create a Microsoft Teams team and bulk add members from CSV file

## Summary

 This sample script shows you how to create a Team and add members and owners using a CSV.
 
# [CLI for Microsoft 365 with PowerShell](#tab/cli-m365-ps)
```powershell
# This script provisions a Group with owners and members and Teamifies it
# The owners and members can be specified using a CSV file following this format
## upn,type
## pla@expertsinside.com,owner
## eba@expertsinside.com,member
## szu@expertsinside.com,member
# The CLI will provision the Group adding the current user as owner. You can remove this user from the owners list by using the $removeYourSelfFromOwners parameter

$importFile = "<putyourcsvhere.csv>"

## parameters for the Group
$teamDisplayName = "Cool team"
$teamDescription = "."
$mailNickname = "uniqueNickname18"
$isPrivate = $true  
$removeYourSelfFromOwners = $false
## parameters for the Group end

## Script starts here

# process teams that you have joined only
$membersList = Import-Csv $importFile -Delimiter ","

$m365Status = m365 status

if ($m365Status -eq "Logged Out") {
  # Connection to Microsoft 365
  m365 login
}

$Error.Clear()

# configure the CLI to output JSON on each execution
m365 cli config set --key output --value json

$members = ($membersList | where { $_.type -eq "member" } | Select-Object upn).upn -join ","
$owners = ($membersList | where { $_.type -eq "owner" } | Select-Object upn).upn -join ","

$privateString = $(If ($isPrivate) {"true"} Else {"false"})
Write-Host "Provisioning Group..."
$group = m365 aad o365group add --displayName $teamDisplayName --description $teamDescription --mailNickname $mailNickname --isPrivate $privateString --members $members --owners $owners | ConvertFrom-Json

if ($Error.Count -gt 0) {
    Write-Host "Aborting operation..."
    return
}

$trial = 0
$maxRetry = 3
$waitingTime = 20
do {
    $Error.Clear()
    $trial++
    Write-Host "Waiting $waitingTime seconds before teamifying the group (trial $trial/$maxRetry)..."
    Start-Sleep -Seconds $waitingTime
    m365 aad o365group teamify --groupId $($group.id) 2>$null
} while ($Error.Count -gt 0 -and $trial -lt $maxRetry)

# if it still failed, output the error and stop
if ($Error.Count -gt 0) {
  $Error
  return
}
$Error.Clear()

$whoAmI = m365 status | ConvertFrom-Json
# remove yourself from the owners group
if ($removeYourSelfFromOwners -and $owners.IndexOf($whoAmI.connectedAs) -eq -1) {
    Write-Host "Removing $($whoAmI.connectedAs) from the owners list"
    m365 aad o365group user remove --groupId $group.id --userName $whoAmI.connectedAs --confirm
}

Write-Host "Completed."
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
***

## Source Credit

Sample first appeared on [Create a Microsoft Teams team and bulk add members from CSV file | CLI for Microsoft 365](https://pnp.github.io/cli-microsoft365/sample-scripts/teams/create-team-and-add-members-and-owners/)

## Contributors

| Author(s) |
|-----------|
| Patrick Lamber |
| Inspired by Rakesh Pandey |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/teams-create-team-and-add-members-and-owners" aria-hidden="true" />
