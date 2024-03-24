---
plugin: add-to-gallery
---

# List all Microsoft Teams team's Owners and Members

## Summary

This script allows you to list all Teams team's owners and members and export them into a CSV file. This script is inspired by [Robin Clarke](https://dailysysadmin.com/KB/Article/3607/microsoft-teams-powershell-commands-to-list-all-members-and-owners/)
 
# [PnP PowerShell](#tab/pnpps)

```powershell

$AdminCenterURL="https://contoso-admin.sharepoint.com/"

# Connect to SharePoint Online admin center
Connect-PnPOnline -Url $AdminCenterURL -Interactive

$dateTime = (Get-Date).toString("dd-MM-yyyy")
$invocation = (Get-Variable MyInvocation).Value
$directorypath = Split-Path $invocation.MyCommand.Path
$fileName = "m365GroupUsersReport-" + $dateTime + ".csv"
$OutPutView = $directorypath + "\Logs\"+ $fileName

# Array to Hold Result - PSObjects
$m365GroupCollection = @()

# Retrieve all M365 groups associated with Microsoft teams
$m365Groups = Get-PnPMicrosoft365Group | where-object {$_.HasTeam -eq $true}

$m365Groups | ForEach-Object {
    $ExportVw = New-Object PSObject
    $ExportVw | Add-Member -MemberType NoteProperty -name "Group Name" -value $_.DisplayName
    $m365GroupOwnersName="";
    $m365GroupMembersName="";
    
    # For auditing purpose
    $m365GroupOwnersName = (Get-PnPMicrosoft365GroupOwner -Identity $_.GroupId | select -ExpandProperty DisplayName) -join ";";
    $m365GroupMembersName = (Get-PnPMicrosoft365GroupMember -Identity $_.GroupId | select -ExpandProperty DisplayName) -join ";";

    $ExportVw | Add-Member -MemberType NoteProperty -name "Group Owners" -value $m365GroupOwnersName
    $ExportVw | Add-Member -MemberType NoteProperty -name "Group Members" -value $m365GroupMembersName
    $m365GroupCollection += $ExportVw
}

# Export the result array to CSV file
$m365GroupCollection | sort "Group Name" |Export-CSV $OutPutView -Force -NoTypeInformation

# Disconnect SharePoint online connection
Disconnect-PnPOnline

```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365](#tab/cli-m365-ps)

```powershell

$dateTime = (Get-Date).toString("dd-MM-yyyy")
$directorypath = "D:\dtemp"
$fileName = "MSTeamsUsersReport-" + $dateTime + ".csv"
$OutPutView = $directorypath + "\"+ $fileName

# Array to hold results - PSObjects
$msTeamsUsersCollection = @()

# Get Credentials to connect
$m365Status = m365 status
if ($m365Status -match "Logged Out") {
    m365 login
}

# Retrieve all teams in Microsoft Teams
$msTeams = m365 teams team list | ConvertFrom-Json

$msTeams | ForEach-Object {
	$ExportVw = New-Object PSObject
	$ExportVw | Add-Member -MemberType NoteProperty -name "Team Name" -value $_.displayName
	$teamOwnerNames = "";
	$teamMemberNames = "";
	$teamGuestNames = "";
	
	$teamOwnerNames = (m365 teams user list --teamId $_.id --role Owner | ConvertFrom-Json | select -ExpandProperty displayName) -join ";"
	$teamMemberNames = (m365 teams user list --teamId $_.id --role Member | ConvertFrom-Json | select -ExpandProperty displayName) -join ";"
	$teamGuestNames = (m365 teams user list --teamId $_.id --role Guest | ConvertFrom-Json | select -ExpandProperty displayName) -join ";"
	
	$ExportVw | Add-Member -MemberType NoteProperty -name "Team Owners" -value $teamOwnerNames
	$ExportVw | Add-Member -MemberType NoteProperty -name "Team Members" -value $teamMemberNames
	$ExportVw | Add-Member -MemberType NoteProperty -name "Team Guests" -value $teamGuestNames
	$msTeamsUsersCollection += $ExportVw
}

# Export the results to CSV file
$msTeamsUsersCollection | sort "Team Name" |Export-CSV $OutPutView -Force -NoTypeInformation

# Disconnect M365 connection
m365 logout

```

[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

***

## Contributors

| Author(s) |
|-----------|
| Reshmee Auckloo |
| [Ganesh Sanap](https://ganeshsanapblogs.wordpress.com/about) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/teams-list-teams-owners-and-members" aria-hidden="true" />
