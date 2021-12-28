---
plugin: add-to-gallery
---

# List guests within Teams in a tenant

## Summary
List all guests in Microsoft Teams teams in the tenant and exports the results in a CSV.
 
![Example Screenshot](assets/example.png)

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

## Contributors

| Author(s) |
|-----------|
| [Jiten Parmar](https://github.com/jitenparmar) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/teams-list-guestusers" aria-hidden="true" />