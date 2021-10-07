---
plugin: add-to-gallery
---

# Create list and libraries from CSV file

## Summary

This script sample will bulk create lists or libraries using CSV file

## Implementation

- Open Windows PowerShell ISE
- Edit Script and add required parameters for Site URL and path to CSV file
- Press run

# [PnP PowerShell](#tab/pnpps)
```powershell

###### Declare and Initialize Variables ######  

#Destination site collection url
$url="https://<tenant>.sharepoint.com/sites/yoursite"

#Path to CSV file
$csvFilePath = "ListsAndLibraries.csv"


# log file will be saved in same directory script was started from
$saveDir = (Resolve-path ".\")  
$currentTime= $(get-date).ToString("yyyyMMddHHmmss")  
$logFilePath=".\log-"+$currentTime+".log"  

## Start the Transcript  
Start-Transcript -Path $logFilePath 



## Connect to SharePoint Online site  
Connect-PnPOnline -Url $Url -Interactive

## Import CSV file
$data = Import-Csv -Path $csvFilePath -Delimiter ";"

## Create list or library
$data | Foreach-Object{
   
   New-PnPList -Title $_.Title -Url $_.Url -Template $_.Template -OnQuickLaunch -EnableContentTypes 
   
}   

```
# [CSV file](#tab/csv)
```csv
Title;Template;Url
PnP Library;DocumentLibrary;PnPLibrary
Announcements;Announcements;lists/Announcements
Custom Simple List;GenericList;lists/CustomSimpleList

```


[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Contributors

| Author(s) |
|-----------|
| Valeras Narbutas |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/spo-export-sharepoint-list-items-to-csv" aria-hidden="true" />