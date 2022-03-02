---
plugin: add-to-gallery
---

# Export all PowerApps details and its Role assignments from Tenant in CSV format

## Summary

This powershell script will export all the powerapps in a particular tenant and all its environment and its role assignments in csv format.


Script will export AppID, AppDisplay Name, User Display name, User Email, Role Type(Owner/CanView/CanEdit), Environment, App Created Time, App Modified Time

![Example Screenshot](assets/SampleOutPut.png)


## Implementation

- Open Windows PowerShell ISE
- Create a new file
- Save the file and run it
- Make sure you are PowerApps admin to so that you have access to all the apps
 
# [Power Apps PowerShell](#tab/powerapps-ps)
```powershell


#Modules for PowerApps Powershell Commands
Install-Module -Name Microsoft.PowerApps.Administration.PowerShell
Install-Module -Name Microsoft.PowerApps.PowerShell -AllowClobber

#PowerApps Connection
Add-PowerAppsAccount

$currentTime=$(get-date).ToString("yyyyMMddHHmmss");    
$outputFilePath="D:\SP\repos\PowerAppsInventory-"+$currentTime+".csv"    
$resultColl=@()   

write-host -ForegroundColor Magenta "Getting all the PowerApp Details..."  
   
# Get all the PowerApps  
$apps=Get-AdminPowerApp 
foreach($app in $apps)  
{  
   
   foreach($user in Get-PowerAppRoleAssignment -Appname $app.Appname)
   { 
    $result = New-Object PSObject
    $result | Add-Member -MemberType NoteProperty -name "AppName" -value $app.AppName -Force
    $result | Add-Member -MemberType NoteProperty -name "DisplayName" -value $app.DisplayName  -Force
    $result | Add-Member -MemberType NoteProperty -name "PrincipalDisplayName" -value $user.PrincipalDisplayName-Force
    $result | Add-Member -MemberType NoteProperty -name "PrincipalEmail" -value $user.PrincipalEmail-Force
    $result | Add-Member -MemberType NoteProperty -name "RoleType" -value $user.RoleType-Force
    $result | Add-Member -MemberType NoteProperty -name "Environment" -value $app.EnvironmentName -Force
    $result | Add-Member -MemberType NoteProperty -Name "CreatedTime" -value $app.CreatedTime  -Force
    $result | Add-Member -MemberType NoteProperty -Name "LastModifiedTime" -value $app.LastModifiedTime  -Force
    $resultColl += $result 
   }

}  

#Export the result Array to CSV file  
$resultColl | Export-Csv $outputFilePath -NoTypeInformation 

write-host -ForegroundColor Magenta "Successful!!"  

```
[!INCLUDE [More about Power Apps PowerShell](../../docfx/includes/MORE-POWERAPPS.md)]
***

## Contributors

| Author(s) |
|-----------|
| Siddharth Vaghasia |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/powerapps-get-app-users-list-csv" aria-hidden="true" />

