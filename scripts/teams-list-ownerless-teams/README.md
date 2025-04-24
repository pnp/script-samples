

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

## Contributors

| Author(s) |
|-----------|
| [Dan Toft](https://Dan-Toft.dk) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/teams-list-ownerless-teams" aria-hidden="true" />