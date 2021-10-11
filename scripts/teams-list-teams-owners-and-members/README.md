---
plugin: add-to-gallery
---

# List all Microsoft Teams team's Owners and Members

## Summary

This script allows you to list all Teams team's owners and members and export them into a CSV file. This script is inspired by [Robin Clarke](https://dailysysadmin.com/KB/Article/3607/microsoft-teams-powershell-commands-to-list-all-members-and-owners/)
 
# [CLI for Microsoft 365 with PowerShell](#tab/cli-m365-ps)
```powershell
$fileExportPath = "<PUTYOURPATHHERE.csv>"
# process teams that you have joined only
$joined = $false

$m365Status = m365 status

if ($m365Status -eq "Logged Out") {
  # Connection to Microsoft 365
  m365 login
}

# configure the CLI to output JSON on each execution
m365 cli config set --key output --value json

$exportData = @()
$teams = m365 teams team list --joined $joined | ConvertFrom-Json
# you can use the next line if you already know the GroupId/TeamId
#$teams = @(m365 teams team get --id $teamId | ConvertFrom-Json)

$i = 0
$teams | ForEach-Object {
  $team = $_
  $i++
  Write-Host "Processing Team '$($team.displayName)' - ($i/$($teams.length))"
  $owners = $null
  $owners = m365 teams user list --teamId $team.id --role Owner --query "[].userPrincipalName" | ConvertFrom-Json
  $members = $null
  $members = m365 teams user list --teamId $team.id --role Member --query "[].userPrincipalName" | ConvertFrom-Json
  $exportData += [PSCustomObject]@{ Id = $team.id; DisplayName = $team.displayName; Owners = $owners -join ', '; Members = $members -join ', '}
}

Write-Host "Exporting file to $fileExportPath..."
$exportData | Export-Csv -Path $fileExportPath -NoTypeInformation
Write-Host "Completed."
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
# [PnP PowerShell](#tab/pnpps)
```powershell
$AdminCenterURL="https://contoso-admin.sharepoint.com/"
#Connect to SharePoint Online admin centre
Connect-PnPOnline -Url $AdminCenterURL -Interactive

$dateTime = (Get-Date).toString("dd-MM-yyyy")
$invocation = (Get-Variable MyInvocation).Value
$directorypath = Split-Path $invocation.MyCommand.Path
$fileName = "m365GroupUsersReport-" + $dateTime + ".csv"
$OutPutView = $directorypath + "\Logs\"+ $fileName

#Array to Hold Result - PSObjects

$m365GroupCollection = @()
#retrieve any m 365 group associated with Microsoft teams
$m365Groups = Get-PnPMicrosoft365Group | where-object {$_.HasTeam -eq $true}
$m365Groups | ForEach-Object{
$ExportVw = New-Object PSObject
$ExportVw | Add-Member -MemberType NoteProperty -name "Group Name" -value $_.DisplayName
$m365GroupOwnersName="";
$m365GroupMembersName="";
 
 #for auditing purpo
 $m365GroupOwnersName = (Get-PnPMicrosoft365GroupOwners  -Identity $_.GroupId | select -ExpandProperty DisplayName) -join ";";
 $m365GroupMembersName = (Get-PnPMicrosoft365GroupMembers  -Identity $_.GroupId | select -ExpandProperty DisplayName) -join ";";

 $ExportVw | Add-Member -MemberType NoteProperty -name " Group Owners" -value $m365GroupOwnersName
  $ExportVw | Add-Member -MemberType NoteProperty -name " Group Members" -value $m365GroupMembersName
 $m365GroupCollection += $ExportVw
}

#Export the result Array to CSV file
$m365GroupCollection | sort "Group Name" |Export-CSV $OutPutView -Force -NoTypeInformation
Disconnect-PnPOnline
```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Source Credit

Sample first appeared on [List all Microsoft Teams team's Owners and Members | CLI for Microsoft 365](https://pnp.github.io/cli-microsoft365/sample-scripts/teams/list-teams-owners-and-members/)

## Contributors

| Author(s) |
|-----------|
| Patrick Lamber |
| Inspired by Robin Clarke |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/teams-list-teams-owners-and-members" aria-hidden="true" />