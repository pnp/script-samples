---
plugin: add-to-gallery
---

# Set SharePoint regional settings

## Summary

Script will set custom regional settings in your sharepoint site

## Implementation

- Open Windows PowerShell ISE
- Edit Script and add details of your prefered regional settings
- Press run


# [PnP PowerShell](#tab/pnpps)
```powershell

###### Declare and Initialize Variables ######  

#Destination site collection url
$url="https://<tenant>.sharepoint.com/sites/<yoursitecollection>"

# data will be saved in same directory script was started from
$saveDir = (Resolve-path ".\")  
$currentTime= $(get-date).ToString("yyyyMMddHHmmss")  
$logFilePath=".\log-"+$currentTime+".log"  

## Start the Transcript  
Start-Transcript -Path $logFilePath 

## Connect to SharePoint Online site  
Connect-PnPOnline -Url $Url -Interactive


### Set Sharepoint site time zone with Pnp Powershell 
$localeId = 2057 # UK
$timeZoneId = 2 # London

$web = Get-PnPWeb -Includes RegionalSettings,RegionalSettings.TimeZones
$timeZone = $web.RegionalSettings.TimeZones | Where-Object {$_.Id -eq $timeZoneId}
$web.RegionalSettings.LocaleId = $localeId
$web.RegionalSettings.TimeZone = $timeZone
$web.Update()
Invoke-PnPQuery


### Set Regional Settings using PnP PowerShell
$web = Get-PnPWeb -Includes RegionalSettings

## Define your regional settings in an object
$myRegionalSettings = @{
    LocaleId              = 1063
    WorkDayStartHour      = 9
    WorkDayEndHour        = 6
    FirstDayOfWeek        = 0
    Time24                = $False
    CalendarType          = 1
    AlternateCalendarType = 0
    WorkDays              = 124
}

$properties = $myRegionalSettings.GetEnumerator()

foreach($property in $myRegionalSettings.GetEnumerator()){
    $web.RegionalSettings.$($property.Name)= $property.Value 
}
$web.Update()
Invoke-PnPQuery


## Disconnect the context  
Disconnect-PnPOnline  
 
## Stop Transcript  
Stop-Transcript  
 

```

>[!Note]
> Site regional settings can be changed in multiple ways via code. One of the examples of changing reginal setting via site design can be found in this sample [Create and add site design to SharePoint site with site columns, content type](https://pnp.github.io/script-samples/spo-add-site-design-with-custom-list/README.html?tabs=pnpps)

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Source Credit

Sample first appeared on [The many ways to set UK Locale in SharePoint](https://www.pkbullock.com/blog/2020/the-many-ways-to-set-uk-locale-in-sharepoint/)

## Contributors

| Author(s) |
|-----------|
| Inspired by Paul Bullock |
| Valeras Narbutas |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-set-sharepoint-regional-settings" aria-hidden="true" />
