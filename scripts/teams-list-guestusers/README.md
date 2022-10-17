---
plugin: add-to-gallery
---

# List guests within Teams in a tenant

## Summary

List all guests in Microsoft Teams teams in the tenant and exports the results in a CSV.

PnP PowerShell script uses Microsoft Graph behind the scenes to get all teams and guest users. it requires an application/user that has been granted the Microsoft Graph API permission : Group.Read.All or Group.ReadWrite.All

# [MicrosoftTeams PowerShell](#tab/teamsps)
```powershell
Install-Module MicrosoftTeams
Connect-MicrosoftTeams
$teams = @()
$externalteams = @()
$teams = get-team
foreach ($team in $teams){
  $groupid = ($team.groupid)
  $users = (Get-TeamUser -GroupId $team.groupid | Where-Object {$_.Role -eq "Guest"})
  $extcount = ($users.count)
  foreach ($extuser in $users){
    $id = $team.groupid
    $teamext = ((Get-Team | Where-Object {$_.groupid -eq "$id"}).DisplayName).ToString()
    $ext = $extuser.User
    $externalteams += [pscustomobject]@{
      ExtUser   = $ext
      GroupID   = $id
      TeamName  = $teamext
	} 
  }
}
 if ($externalteams.Count -gt 0){
    Write-Host "Exporting the guest members in teams results.."
    $externalteams | Export-Csv -Path "GuestUsersFromTeams.csv" -NoTypeInformation
    Write-Host "Completed."
 }
 else{
    Write-host "there are no external user added to any team in your organization" -ForegroundColor yellow
 }
```
[!INCLUDE [More about Microsoft Teams PowerShell](../../docfx/includes/MORE-TEAMSPS.md)]

# [PnP PowerShell](#tab/pnpps)
```powershell
#Connect as an application/user that has been granted Microsoft Graph API permissions : Group.Read.All or Group.ReadWrite.All
$siteUrl = "https://contoso-admin.sharepoint.com"
Connect-PnPOnline -Url $siteUrl -Interactive

$teams = @()
$externalteams = @()
$teams = Get-PnPTeamsTeam
foreach ($team in $teams)
{
  $groupid = $team.groupid
  $users = Get-PnPTeamsUser -Team $groupid -Role Guest
  $extcount = $users.count
  if($extcount -gt 0)
  {
    foreach ($extuser in $users)
    {
        $externalteams += [pscustomobject]@{
        ExtUser   = $extuser.UserPrincipalName
        GroupID   = $groupid
        TeamName  = $team.DisplayName
        } 
    }
  }
}
 if ($externalteams.Count -gt 0)
 {
    Write-Host "Exporting the guest members in teams results.."
    $externalteams | Export-Csv -Path "GuestUsersFromTeams.csv" -NoTypeInformation
    Write-Host "Completed."
 }
 else
 {
    Write-host "there are no external user added to any team in your organization" -ForegroundColor yellow
 }

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365](#tab/cli-m365-ps)
```powershell
$m365Status = m365 status
if ($m365Status -match "Logged Out") {
  m365 login
}

$teams = @()
$externalteams = @()
$teams = m365 teams team list | ConvertFrom-Json

foreach ($team in $teams)
{
	$id = $team.id
	$users = m365 teams user list --teamId $id --role Guest | ConvertFrom-Json
	$extcount = $users.count

  if($extcount -gt 0)
  {
    foreach ($extuser in $users)
    {
      $externalteams += [pscustomobject]@{
        ExtUser   = $extuser.userPrincipalName
        GroupID   = $id
        TeamName  = $team.displayName
      } 
    }    
  }
}

if ($externalteams.Count -gt 0)
{
	Write-Host "Exporting the guest members in teams results.."
	$externalteams | Export-Csv -Path "GuestUsersFromTeams.csv" -NoTypeInformation
	Write-Host "Completed."
}
else
{
	Write-host "there are no external user added to any team in your organization" -ForegroundColor yellow
}
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
***

## Contributors

| Author(s) |
|-----------|
| [Jiten Parmar](https://github.com/jitenparmar) |
| [Leon Armston](https://github.com/LeonArmston) |
| [Jasey Waegebaert](https://github.com/Jwaegebaert) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/teams-list-guestusers" aria-hidden="true" />

