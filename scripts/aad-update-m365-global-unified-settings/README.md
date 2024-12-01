---
plugin: add-to-gallery
---

# Update Global Microsoft 365 Group Settings

## Summary

Managing Microsoft 365 Group settings is crucial for maintaining a compliant and secure environment.PowerShell and Microsoft Graph can be used to configure various group settings, including naming policies, guest access, and more.

As a regular user of PnP PowerShell, I wanted to replicate the [Microsoft Entra cmdlets for configuring group settings](https://learn.microsoft.com/en-us/entra/identity/users/groups-settings-cmdlets?wt.mc_id=MVP_308367) using PnP PowerShell.

### Prerequisites

- PnP PowerShell https://pnp.github.io/powershell/
- The user account that runs the script must have Global Admin administrator access or Entra ID Admin role.

# [PnP PowerShell](#tab/pnpps)

```powershell
param (
    [Parameter(Mandatory = $true)]
    [string] $domain
)
Clear-Host

$adminSiteURL = "https://$domain-Admin.SharePoint.com"
Connect-PnPOnline -Url $adminSiteURL

$BlockedWords = @("law","pension","finance","sea","ocean","river","lake","stream","creek","pond","pool","reservoir","dam","canal","ditch","drain","gutter","sewer","pipe","tube","hose","conduit","channel","aqua")

$unifiedSet = Get-PnPMicrosoft365GroupSettings -GroupSetting "Group.Unified"

$url = "/groupSettings/$($unifiedSet.Id)"
  
$Payload = @"
{
    "values": [
        {
            "name": "CustomBlockedWordsList",
            "value": "$($BlockedWords -join ',')"
        },
        {
            "name": "PrefixSuffixNamingRequirement",
            "value": "Test_[Department][GroupName][Office]"
        }
        ,
        {
            "name": "AllowToAddGuests",
            "value": "True"
        },
        {
            "name": "AllowGuestsToBeGroupOwner",
            "value": "False"
        },
        {
            "name": "AllowGuestsToAccessGroups",
            "value": "True"
        },
        {
            "name": "AllowToAddGuests",
            "value": "True"
        },
        {
            "name": "EnableGroupCreation",
            "value": "True"
        },
        {
            "name": "NewUnifiedGroupWritebackDefault",
            "value": "True"
        },
        {
            "name": "EnableMIPLabels",
            "value": "True"
        },
        {
            "name": "EnableMSStandardBlockedWords",
            "value": "False"
        }
     ]
}
"@


Invoke-PnPGraphMethod -Url $url -Method Patch -Content $Payload
(Get-PnPMicrosoft365GroupSettings -GroupSetting "Group.Unified").Values 
```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***

## Source Credit

Sample first appeared on [Managing Microsoft 365 Group Settings with PnP PowerShell and Microsoft Graph](https://reshmeeauckloo.com/posts/powershell-m365-groupsetting-graph/)

## Contributors

| Author(s) |
|-----------|
| [Reshmee Auckloo](https://github.com/reshmee011) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/aad-update-m365-global-unified-settings" aria-hidden="true" />
