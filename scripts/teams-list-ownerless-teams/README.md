

# List Ownerless Teams

## Summary

If your organization has been using Microsoft Teams for more that a few years, you'll no doubt have a number of Teams that have been orphaned, probably because the original owner has moved on. This script will list all Teams that have fewer than a specified number of owners, and export them to a CSV file.

# [PnP PowerShell](#tab/pnpps)

```powershell

Connect-PnPOnline -ClientId "GUID" -Tenant "GUID" -CertificatePath -CertificatePassword "Password" 

$MinimumRequiredOwners = 1;

$Groups = Get-PnPMicrosoft365Group -IncludeOwners | Where-Object {$_.Owners.Count -le $MinimumRequiredOwners -and $_.HasTeam}

$MappedObjects = [System.Collections.ArrayList]@()

foreach ($Group in $Groups) {
    $MappedObject = [PSCustomObject]@{
        GroupId = $Group.GroupId
        DisplayName = $Group.DisplayName
        OwnersCount = $Group.Owners.Count
        Owners = $Group.Owners | Select-Object -Property "Email" | Join-String -Property "Email" -Separator "; "
    }
    $MappedObjects += $MappedObject
}

$fileName = "$(Get-Date -Format ("yyyy-MM-dd"))-GroupsWithFewerThan$($MinimumRequiredOwners)Owners.csv";
$MappedObjects | Select-Object -Property * | Export-Csv -Path ".\$fileName" -Encoding UTF8 -Delimiter ";" -Force;

```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365](#tab/cli-m365-ps)

```powershell

$minimumRequiredOwners = 1

m365 login --ensure

$teams = @(m365 teams team list --output json | ConvertFrom-Json)

$mappedObjects = foreach ($team in $teams) {
    # Only the owners are needed, and the mail address is not returned unless it is asked for
    $ownersJson = m365 entra m365group user list --groupId $team.id --role Owner --properties "mail" --output json
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Could not read the owners of '$($team.displayName)', skipping it."
        continue
    }
    $owners = @($ownersJson | ConvertFrom-Json)

    if ($owners.Count -le $minimumRequiredOwners) {
        [PSCustomObject]@{
            GroupId     = $team.id
            DisplayName = $team.displayName
            OwnersCount = $owners.Count
            Owners      = ($owners.mail | Where-Object { $_ }) -join "; "
        }
    }
}

$fileName = "$(Get-Date -Format "yyyy-MM-dd")-GroupsWithFewerThan$($minimumRequiredOwners)Owners.csv"
$mappedObjects | Export-Csv -Path ".\$fileName" -Encoding UTF8 -Delimiter ";" -Force

```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
***


## Contributors

| Author(s) |
|-----------|
| [Dan Toft](https://Dan-Toft.dk) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/teams-list-ownerless-teams" aria-hidden="true" />