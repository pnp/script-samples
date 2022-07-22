---
plugin: add-to-gallery
---

# Bulk Publish Syntex Models To Libraries

## Summary

This script sample will publish Syntex Document Understanding Models to many libraries using the batching functionality of PnP PowerShell. *Currently only document understanding models can be templated and rolled out to many sites

## Implementation

- Create CSV file using the format supplied below and modify to reflect the values of your sites/libraries that you wish to deploy Syntex models to.
- Open Windows PowerShell ISE
- Edit Script and add required parameters for Syntex Content Centre URL and path to CSV file
- Press run

# [PnP PowerShell](#tab/pnpps)
```powershell

###### Declare and Initialize Variables ######  

#Change To Reflect Your Syntex Content Center
$syntexContentCentre = "https://contoso.sharepoint.com/sites/HRContentCenter" 

#Path to CSV file
$csvFilePath = "Libraries.csv"

###### DO NOT EDIT BELOW THIS LINE #####

## log file will be saved in same directory script was started from
$saveDir = (Resolve-Path ".\")  
$currentTime= $(Get-Date).ToString("yyyyddMMHHmmss")  
$logFilePath=".\log-"+$currentTime+".log"  

## Start the Transcript  
Start-Transcript -Path $logFilePath 

## Connect to your Syntex Content Centre
Connect-PnPOnline -Url $syntexContentCentre -Interactive

## Import CSV file
$libraries = Import-Csv -Path $csvFilePath -Delimiter ";"

## Create a new batch
$batch = New-PnPBatch

foreach($lib in $libraries) 
{ 

    $splatCmds = @{
        Model = $lib.Model
        TargetSiteUrl = $lib.TargetSiteUrl
        TargetWebServerRelativeUrl = $lib.TargetWebServerRelativeUrl
        TargetLibraryServerRelativeUrl = $lib.TargetLibraryServerRelativeUrl
        Batch = $batch
    }

    Publish-PnPSyntexModel @splatCmds

}

## Execute Batch - Add Syntex Model To Libraries
Invoke-PnPBatch -Batch $batch
 
## Disconnect the context  
Disconnect-PnPOnline  
 
## Stop Transcript  
Stop-Transcript  

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CSV file](#tab/csv)
```csv
Model;TargetSiteUrl;TargetWebServerRelativeUrl;TargetLibraryServerRelativeUrl
Aviation Incident Report;https://contoso.sharepoint.com/sites/Retail;/sites/Retail;/sites/Retail/shared%20documents
Refinement Rules Example;https://contoso.sharepoint.com/sites/SalesAndMarketing;/sites/SalesAndMarketing;/sites/SalesAndMarketing/shared%20documents


```
***

## Contributors

| Author(s) |
|-----------|
| [Leon Armston](https://github.com/LeonArmston) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-bulk-publish-syntex-model" aria-hidden="true" />
