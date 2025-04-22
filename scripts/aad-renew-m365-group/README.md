

# Automate Renewal of Expiring M365 Groups or or Microsoft Teams teams

## Summary

It is a good practice to set lifecycle expiration policy to control sprawl. However that means that the group will get automatically deleted after they expire. The Teams/M365 groups owners will get email notifications to renew within a certain timeframe , however if the owners missed the renewal notifications for different reasons, it may lead to accidental data loss. The script can help identify M365 groups nearing expiration to renew them.

![Example Screenshot](assets/example.png)

# [PnP PowerShell](#tab/pnpps)

```powershell
param (
    [Parameter(Mandatory = $true)]
    [string] $domain
)

$adminSiteURL = "https://$domain-Admin.SharePoint.com"
$dateTime = "_{0:MM_dd_yy}_{0:HH_mm_ss}" -f (Get-Date)
$invocation = (Get-Variable MyInvocation).Value
$directorypath = Split-Path $invocation.MyCommand.Path
$fileName = "m365_group_expire_reset" + $dateTime + ".csv"
$outputPath = $directorypath + "\"+ $fileName

if (-not (Test-Path $outputPath)) {
    New-Item -ItemType File -Path $outputPath
}
Connect-PnPOnline -Url $adminSiteURL -Interactive -WarningAction SilentlyContinue


Get-PnPMicrosoft365ExpiringGroup  | ForEach-Object {
    $group = $_
    Reset-PnPMicrosoft365GroupExpiration -Identity $group.Id
    $group = Get-PnPMicrosoft365Group -Identity $group.Id
    $group | Select-Object id, RenewedDateTime,DisplayName|Export-Csv -Path $outputPath -NoTypeInformation -Append

}

Disconnect-PnPOnline
```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***

## Source Credit

Sample first appeared on [Automate Renewal of Expiring M365 Groups Using PowerShell](https://reshmeeauckloo.com/posts/powershell-renew-expiring-m365-group/)


## Contributors

| Author(s) |
|-----------|
| [Reshmee Auckloo](https://github.com/reshmee011) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/aad-renew-m365-group" aria-hidden="true" />

