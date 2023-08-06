---
plugin: add-to-gallery
---

# Archive inactive Teams

## Summary

This function, Archive-PnPInactiveTeams, gets a list of all the inactive Teams, based on the given number of days and archives them one by one.

![Example Screenshot](assets/example.png)

## Implementation
Save this script to a PSM1 module file, like `archive-inactiveTeams.psm1`. Then import the module file with Import-Module:
```powershell

Import-Module archive-inactiveTeams.psm1 -Verbose

```
The -Verbose switch lists the functions that are imported.

Once the module is imported the function `Archive-PnPInactiveTeams` will be loaded and ready to use.

# [PnP PowerShell](#tab/pnpps)

```powershell

<# Script to archive inactive Teams
Author: Nico De Cleyre - @nicodecleyre
Blog: https://www.nicodecleyre.com
v1.0 - 8/6/2023

#>
Function Archive-PnPInactiveTeams {
<#
.SYNOPSIS
Script to archive the inactive Teams

.Description
By inputting a designated timeframe for inactivity, the script automatically identifies Teams that have remained dormant beyond the specified period. These Teams are then archived

This solution requires an Azure App registration with the following permissions:
- Reports.Read.All
- TeamSettings.ReadWrite.All

.Parameter tenandId
The ID of your tenant

.PARAMETER clientId
The ID of your Azure app registration

.PARAMETER clientSecret
The secret of your Azure app registration

.PARAMETER inactiveDays
The minimum number of days that a Team must be active in order to be archived otherwise. Possible values: 7, 30, 90 or 180

.Example 
Archive-PnPInactiveTeams -tenandId "e2d68954-d30b-4e35-af8c-3a42bd5ce587" -clientId "ccfd26aa-96b4-4f24-b896-274f62b0f4d9" -clientSecret "TiQ8Q~13OtsXZ9KId01-CB1xlX1n_nknmIzpWam-" -inactiveDays 30

.Example 
Archive-PnPInactiveTeams -tenandId "e2d68954-d30b-4e35-af8c-3a42bd5ce587" -clientId "ccfd26aa-96b4-4f24-b896-274f62b0f4d9" -clientSecret "TiQ8Q~13OtsXZ9KId01-CB1xlX1n_nknmIzpWam-" -inactiveDays 180

#>    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $tenantId,
        [Parameter(Mandatory = $true)]
        $clientId,
        [Parameter(Mandatory = $true)]
        $clientSecret,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateSet("7","30","90","180")]
        $inactiveDays
    )
    
    begin {
        #Log in to Microsoft Graph
        Write-Host "Connecting to Microsoft Graph" -f Yellow

        $uri = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"

        $body = @{
            client_id = $clientId
            client_secret = $clientSecret
            grant_type = "client_credentials"
            scope = "https://graph.microsoft.com/.default"
        }

        $response = invoke-restMethod -Uri $uri -method Post -body $body
        $accessToken = $response.access_token
    }
    
    process {
        $today = Get-Date
        # Get the Teams Team activity detail
        $inactiveTeamsUri = "https://graph.microsoft.com/v1.0/reports/getTeamsTeamActivityDetail(period='D$inactiveDays')"

        $inactiveTeamsHeader = @{
            Authorization = "Bearer $accessToken"
        }

        $inactiveTeamsResponse = invoke-restMethod -Uri $inactiveTeamsUri -method Get -Headers $inactiveTeamsHeader

        $teams = $inactiveTeamsResponse | ConvertFrom-Csv | where {$_.'Last Activity Date' -ne ""}

        foreach($team in $teams){
            $lastActivityDate = $team.'Last Activity Date'
            $timeSpan = New-TimeSpan -Start $lastActivityDate -End $today
            if($timeSpan.Days -gt $inactiveDays){
                $teamId = $team.'Team Id'
                $teamName = $team.'Team Name'
                Write-Host "Team $teamName ($teamId) is inactive since $($timeSpan.Days) days" -f DarkYellow
                
                $archiveTeamUri = "https://graph.microsoft.com/v1.0/teams/$teamId/archive"
                invoke-restMethod -Uri $archiveTeamUri -method Post -Headers $inactiveTeamsHeader
                Write-Host "Team $teamName ($teamId) is archived" -f Green
            }
        }
    }
    
    end {
        
    }
}

```

## Contributors

| Author(s) |
|-----------|
| [Nico De Cleyre](https://www.nicodecleyre.com)|


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-request-pnp-reindex-user-profile" aria-hidden="true" />
