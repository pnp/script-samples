---
plugin: add-to-gallery-preparation
---

# Get all PowerApps in your tenant

## Summary

Sample script to create a lists of all apps in your tenant


# [Power Apps PowerShell](#tab/powerapps-ps)
```powershell

#get all apps
$apps = Get-AdminPowerApp

#Array to hold result
$powerApps = @()
#Iterate through each field in the array
Foreach ($app in $apps)
{
    #Send Data to object array
    $powerApps += New-Object PSObject -Property @{
            'AppName' = $app.AppName
            'DisplayName' = $app.DisplayName
            'CreatedTime' = $app.CreatedTime
            'Owner' = $app.Owner.displayName
            'LastModifiedTime' = $app.LastModifiedTime
            'EnvironmentName' = $app.EnvironmentName
            'IsFeaturedApp' = $app.IsFeaturedApp
            'appType' = $app.Internal.appType
            }
}

#exporting the array to csv
$powerApps | Export-Csv "C:\Development\PowerShell\TEMP\powerAppsExport.csv" -NoTypeInformation -Force

```
[!INCLUDE [More about Power Apps PowerShell](../../docfx/includes/MORE-POWERAPPS.md)]


***


## Contributors

| Author(s) |
|-----------|
| Jimmy Hang |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/template-script-submission" aria-hidden="true" />