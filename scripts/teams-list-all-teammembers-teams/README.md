---
plugin: add-to-gallery
---

# List all team members in Microsoft Teams teams in the tenant

List all team members in Microsoft Teams teams in the tenant and exports the results in a CSV.
 
![Example Screenshot](assets/example.png)
 
# [CLI for Microsoft 365 with PowerShell](#tab/cli-m365-ps)
```powershell
function Get-TeamMembers(
    [Parameter(Mandatory = $false)][string] $teamID
) {
    if (!$teamID) {
        Write-Error "'Team ID' is required!"
        return
    }
    Write-Host "Retrieving the users.."
    $results = @()
    $users = m365 teams user list --teamId $teamID -o 'json' | ConvertFrom-Json
    if ($users.length -gt 0) {
        foreach ($user in $users) {
            $results += [pscustomobject][ordered]@{
                ID             = $user.id
                "Display Name" = $user.displayName
                UPN            = $user.userPrincipalName
                Role           = $user.userType
            }
        }
    }
    else {
        Write-Output "No team members!"
    }
    Write-Host "Exporting the results.."
    $results | Export-Csv -Path "TeamMembers.csv" -NoTypeInformation
    Write-Host "Completed."
}

Write-Host "Ensure logged in"
$m365Status = m365 status
if ($m365Status -eq "Logged Out") {
    Write-Host "Logging in the User!"
    m365 login --authType browser
}
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]


## Source Credit

Sample first appeared on [List all team members in Microsoft Teams teams in the tenant | CLI for Microsoft 365](https://pnp.github.io/cli-microsoft365/sample-scripts/teams/list-all-teammembers-teams/)

## Contributors

| Author(s) |
|-----------|
| Sudharsan Kesavanarayanan |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/teams-list-all-teammembers-teams" aria-hidden="true" />