---
plugin: add-to-gallery
---

# Identifying Duplicate Microsoft 365 Group Names

## Summary

It is possible to create M365 Groups and Teams with the same name, and there is currently no built-in way to prevent this. Having duplicate names can cause confusion and increase security, governance and compliance risks.

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
$dateTime = (Get-Date).toString("dd-MM-yyyy-hh-ss")
$invocation = (Get-Variable MyInvocation).Value
$directorypath = (Split-Path $invocation.MyCommand.Path) + "\"
$exportFilePath = Join-Path -Path $directorypath -ChildPath $([string]::Concat($domain,"-duplicateM365_",$dateTime,".csv"));

$adminSiteURL = "https://$domain-Admin.SharePoint.com"
Connect-PnPOnline -Url $adminSiteURL

# Retrieve all M365 groups
$groups = get-PnPMicrosoft365Group

# Find duplicate group names
$duplicateGroups = $groups | Group-Object DisplayName | Where-Object { $_.Count -gt 1 }

# Create a report
$report = @()
foreach ($group in $duplicateGroups) {
    foreach ($item in $group.Group) {
        $report += [PSCustomObject]@{
            DisplayName = $item.DisplayName
            GroupId     = $item.Id
            Mail        = $item.Mail
        }
    }
}

# Export the report to a CSV file
$report | Export-Csv -Path $exportFilePath -NoTypeInformation
Disconnect-PnPOnline
```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***

## Source Credit

Sample first appeared on [Identifying Duplicate Microsoft 365 Group Names](https://reshmeeauckloo.com/posts/powershell-duplicate-m365group-teams/)

## Contributors

| Author(s) |
|-----------|
| [Reshmee Auckloo](https://github.com/reshmee011) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/aad-get-duplicate-m365group" aria-hidden="true" />
