---
plugin: add-to-gallery
---

      
# Clone a Microsoft Team
![Outputs](assets/header.png)
## Summary

This script allow us to clone an existing team into a new one with changed properties.  

On the new to be "cloned" team we can define name, description, visibility and "parts to clone" ("Apps","Tabs","Settings","Channels",  "Members")  

The script is a subset of the SPO powershell packages with content (PnPCandy) concept already been used across many projects.  
  
Excelsior, hum? :P  

# [PnP PowerShell](#tab/pnpps)

```powershell

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$Tenant,
    [Parameter(Mandatory = $true)]
    [string]$Url,
    [Parameter(Mandatory = $true)]
    [string]$Team ,
    [Parameter(Mandatory = $True)]
    [string]$NewTeamName,
    [Parameter(Mandatory = $false)]
    [string]$NewTeamDescription ,
    [Parameter(Mandatory = $false)]
    [string]$NewMailNickname,
    [Parameter(Mandatory = $true)]
    [ValidateSet("Private", "Public")]
    [string]$NewTeamVisibility,
    [Parameter(Mandatory = $false)]
    [ValidateSet("Apps", "Tabs", "Settings", "Channels", "Members")]
    [string[]]$PartsToClone = ("Apps", "Tabs", "Settings", "Channels", "Members")
)
begin {
    $ErrorActionPreference = "Stop"
    Import-Module PnP.PowerShell

    $msg = "`n`r

    █▀█ █▄░█ █▀█ █▀▀ ▄▀█ █▄░█ █▀▄ █▄█
    █▀▀ █░▀█ █▀▀ █▄▄ █▀█ █░▀█ █▄▀ ░█░  `n    MSTeam Builder  `n`n    ...aka ... [team-clone-team]
    `n"
    $msg += ('#' * 70) + "`n"

    Write-Output  $msg
    
    #Validate if PartsToClone has duplicate values 
    $tmp = $PartsToClone | Group-Object | Where-Object -Property Count -gt 1
    if ($null -ne $tmp) {
        throw "PartsToClone : The following values are duplicated: $($tmp.Name -join ', ')"
    }
    Write-Output "Connecting to $Url"
    Connect-PnPOnline -Url $Url -Interactive -Tenant $Tenant
 
    $accesstoken = Get-PnPGraphAccessToken
}
process {
   
    Write-Output " Get Team by name or Id [$team]"
    $existingTeam = Get-PnPMicrosoft365Group  -IncludeSiteUrl | Where-object { $_.HasTeam -and (($_.id -eq $Team) -or ($_.Displayname -eq $Team)) } | Select-Object Id, DisplayName
   
    $URL = "https://graph.microsoft.com/v1.0/teams/$($existingTeam.Id)/clone"  
    
   
    $NewTeamDescription = $NewTeamDescription.Trim()
    if ($NewTeamDescription.Trim().Length -eq 0) { 
        Write-Output (" Fill in description if empty")
        $NewTeamDescription = $NewTeamName
    }
    Write-Output (" Cleanup MailNickname (remove spaces)")
    $NewMailNickname = $NewMailNickname.Trim().Replace(" ", "")
    if ($NewMailNickname.Trim().Length -eq 0) {
        $NewMailNickname = $NewTeamName.ToLower()
    }
    $tmp = ($PartsToClone -join ",").ToLower()
    if ($tmp.Trim().Length -eq 0) {
        Write-Output (" Parts To Clone if empty")
        $PartsToClone = ("Apps", "Tabs", "Settings", "Channels", "Members")
        $PartsToClone = ($PartsToClone -join ",").ToLower()
    }
  
    $newTeam = '{ 
        "displayName": "'+ $NewTeamName + '",
        "description": "'+ $NewTeamDescription + '",
        "mailNickname": "'+ $NewMailNickname + '",
        "partsToClone": "apps,tabs,settings,channels,members",
        "visibility": "'+ $NewTeamVisibility + '"
        }'
    Write-Output (" Clone new Team:$NewTeamName")
    Invoke-RestMethod -Headers @{Authorization = "Bearer $accesstoken"; "Content-Type" = "application/json" } `
        -Uri $URL -Body $newTeam -Method POST 
    Write-Output (" Team [$NewTeamName] was cloned from [$($existingTeam.DisplayName)]")
    Disconnect-PnPOnline
}

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Contributors

| Author(s) |
|-----------|
| Rodrigo Pinto |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/teams-clone-team" aria-hidden="true" />
