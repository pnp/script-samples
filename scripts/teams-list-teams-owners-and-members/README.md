---
plugin: add-to-gallery
---

# List all Microsoft Teams team's Owners and Members

## Summary

This script allows you to list all Teams team's owners and members and export them into a CSV file. This script is inspired by [Robin Clarke](https://dailysysadmin.com/KB/Article/3607/microsoft-teams-powershell-commands-to-list-all-members-and-owners/)
 
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


## Contributors

| Author(s) |
|-----------|
| Reshmee Auckloo |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/teams-list-teams-owners-and-members" aria-hidden="true" />
