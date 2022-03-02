---
plugin: add-to-gallery
---

# Bulk add members to Microsoft Teams team from CSV file

## Summary

This script will add users in existing Teams contained in your .csv file.
 
# [CLI for Microsoft 365 with PowerShell](#tab/cli-m365-ps)
```powershell
<#
.SYNOPSIS
    Add users to a Microsoft 365 group linked to Teams.
.DESCRIPTION
    This script will add users in existing Teams contained in your .csv file.
.EXAMPLE
    PS C:\> .\add-users-teams.ps1
    This script will add users in existing Microsoft Teams teams from your .csv file
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    Your .csv file must contain headers called UPN, teamName, teamId, and role. If you change those headers then make sure to amend the script.
#>

#Check if connected to M365
$m365Status = m365 status
if ($m365Status -eq "Logged Out") {
  m365 login
}
    
#Import csv
$usersCsvFile = Import-Csv -Path "<YOUR_CSVFile_PATH_HERE.csv>"

#Add users to the Team
foreach ($row in $usersCsvFile) {
  Write-Host "Adding $($row.UPN) to the $($row.teamName) Team" -ForegroundColor Magenta
  m365 aad o365group user add --groupId $row.teamId --userName $($row.UPN) --role $($row.role)
}
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
***

## Source Credit

Sample first appeared on [Bulk add members to Microsoft Teams team from CSV file | CLI for Microsoft 365](https://pnp.github.io/cli-microsoft365/sample-scripts/teams/add-bulk-users-teams/)

## Contributors

| Author(s) |
|-----------|
| Inspired by Rakesh Pandey |
| Veronique Lengelle |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/teams-add-bulk-users-teams" aria-hidden="true" />
