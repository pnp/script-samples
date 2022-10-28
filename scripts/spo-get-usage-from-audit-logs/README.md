---
plugin: add-to-gallery
---

# Gets usage from a particular user(s) or site(s) from the Unified Audit Log

## Summary

Say we have a user who has written a lot of flows and PowerBI reports and is complaining that she is getting throttled in SharePoint quite often.

We need to see all the calls being made by that user and/or to particular sites to attempt to narrow down the issues.

This script will scan the ULS Logs for the last week looking for all access by a user an or to a site and create an excel file summarizing the activity.

# [PnP PowerShell](#tab/pnpps)

```powershell
Connect-PnPOnline -Url "HTTPS://tenant-ADMIN.sharepoint.COM" -Interactive
$intervalminutes = 15 
$now = Get-Date
$outputArray = @()
for ($i = 60; $i -le 11000 ; $i = $i + $intervalminutes) {
    # 1 hour ago to a day ago
    $starttime = $now.AddMinutes(-$i - $intervalminutes)
    $endtime = $now.AddMinutes(-$i)
    $results = Get-PnPUnifiedAuditLog -ContentType "SharePoint" -StartTime $starttime -EndTime $endtime
    $OperationalExcellenceHub = $results | Where { $_.SiteUrl -eq "https://tenant.sharepoint.com/sites/OperationalExcellenceHub/" }
    $OperationalExcellence = $results | Where { $_.SiteUrl -eq "https://tenant.sharepoint.com/sites/OperationalExcellence/" }
    $user= $results | Where { $_.UserId -eq "some.user@domain.com" }
    Write-Host  "$i FROM $starttime TO $endtime  OperationalExcellenceHub:$($OperationalExcellenceHub.Count) OperationalExcellence:$($OperationalExcellence.Count) RobS:$($Sarracini.Count) TOTAL:$($results.Count)"
    $outputObject = [PSCustomObject]@{
        Count                    = $i
        StartTime                = $starttime
        EndTime                  = $endtime
        OperationalExcellenceHub = $OperationalExcellenceHub.Count
        OperationalExcellence    = $OperationalExcellence.Count
        Sarracini                = $Sarracini.Count
        Total                    = $results.Count
    }
    $outputArray += $outputObject
    
}

$outputArray | Export-Csv "c:\Temp\IOCounts.csv" -NoTypeInformation

    # End

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Contributors

| Author(s) |
|-----------|
| Russell Gove |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-get-usage-from-audit-logs" aria-hidden="true" />

