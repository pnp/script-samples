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
 
## Disconnect the context  
Disconnect-PnPOnline  
 
## Stop Transcript  
Stop-Transcript  
  

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365 with PowerShell](#tab/cli-m365-ps)
```powershell
Write-host 'ensure logged in'
$m365Status = m365 status
if ($m365Status -match "Logged Out") {
  m365 login --authType browser
}


#Destination site collection url
$url="https://<tenant>.sharepoint.com/sites/<sitename>"
#Path to CSV file
$csvFilePath = "ListsAndLibraries.csv"


## Import CSV file
$data = Import-Csv -Path $csvFilePath -Delimiter ";"

## Create list or library
$data | Foreach-Object{
   m365 spo list add --title $_.Title --baseTemplate $_.Template --webUrl $url --output 'json'
   
} 
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

# [CSV file](#tab/csv)
```csv
Title;Template;Url
PnP Library;DocumentLibrary;PnPLibrary
Announcements;Announcements;lists/Announcements
Custom Simple List;GenericList;lists/CustomSimpleList

```
***

## Contributors

| Author(s) |
|-----------|
| Valeras Narbutas |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-export-sharepoint-list-items-to-csv" aria-hidden="true" />
