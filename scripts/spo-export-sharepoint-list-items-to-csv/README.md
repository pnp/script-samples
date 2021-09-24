---
plugin: add-to-gallery
---

# Export SharePoint List Data to CSV with attachments

## Summary

Script will export all SharePoint list data to CSV file, also takes items attachments and stores it to PC.

## Implementation

- Open Windows PowerShell ISE
- Edit Script and add details like listname and SharePoint Site
- Press run
- CSV file and attachments will be saved at same directory where script was started from

# [PnP PowerShell](#tab/pnpps)
```powershell

###### Declare and Initialize Variables ######  

#site collection url
$url="Site collection url"

#list to be exported  
$listName="Requests"

#include or exclude hidden and readonly fields
$includeHiddenField = $False
$includeReadonlyField = $False


# data will be saved in same directory script was started from
$saveDir = (Resolve-path ".\")  
$currentTime= $(get-date).ToString("yyyyMMddHHmmss")  
$logFilePath=".\log-"+$currentTime+".log"  
 
## Start the Transcript  
Start-Transcript -Path $logFilePath   
 
## Export List to CSV ##  
function ExportList  
{  

# Fields that has to be retrieved  - currently taking all the fields 
$listFields = Get-PnPField -List $listName |? { $_.Hidden -eq $includeHiddenField -AND $_.ReadOnlyField -eq $includeReadonlyField} | Select -ExpandProperty internalname

$count = 0
    try  
    {  
    md .\$listName -Force
    md ".\$($listName)\Attachments" -Force

        $listItems=(Get-PnPListItem -List $listName -Fields $listFields -PageSize 1000).FieldValues  
        $outputFilePath=".\$($listName)_list_results-"+$currentTime+".csv"  
            
        $hashTable=@()  
        
        # Loop through the list items  
        foreach($listItem in $listItems)  
        {   $count = $count+1
            Write-Progress -Activity "Exporting" -Status "$($count/$listItems.Count*100)% Complete:" -PercentComplete $($count/$listItems.Count*100)
            $obj=New-Object PSObject              
            $listItem.GetEnumerator() | Where-Object { $_.Key -in $listFields }| ForEach-Object{ 
                    
                    
                    if($_.Value.LookupValue){$obj | Add-Member Noteproperty $_.Key $_.Value.LookupValue}
                    else{$obj | Add-Member Noteproperty $_.Key $_.Value}
                    
                    if($_.Key -eq "Attachments" -And $_.Value -eq "TRUE"){
                        md ".\$($listName)\Attachments\$($listItem.ID)" -Force
                        $item = Get-PnPListItem -List $listName -Id $($listItem.ID)
                        
                        $attachments = ForEach-Object{Get-PnPProperty -ClientObject $item -Property "AttachmentFiles"}
                        $fileUrls = ""
                        $attachments | ForEach-Object {
                            
                            #save file to disk
                            Get-PnPFile -Url $_.ServerRelativeUrl -FileName $_.FileName -Path ".\$($listName)\Attachments\$($listItem.ID)"  -AsFile -Force
                            $fileUrl +=  "Attachments\$($listItem.ID)\$($_.FileName);"
 
                        } 
                        $obj | Add-Member Noteproperty "AttachmentUrl" "$fileUrl"
                       
                    }
                    
                   
                }
                 
            #write-host $count
            
            $hashTable+=$obj;  
            $obj=$null;  
        }  
  
        $hashtable | export-csv $outputFilePath -NoTypeInformation  
     }  
     catch [Exception]  
     {  
        $ErrorMessage = $_.Exception.Message         
        Write-Host "Error: $ErrorMessage" -ForegroundColor Red          
     }  
}  
 
## Connect to SharePoint Online site  
Connect-PnPOnline -Url $Url -Interactive
 
## Call the Function  
ExportList  
 
## Disconnect the context  
Disconnect-PnPOnline  
 
## Stop Transcript  
Stop-Transcript    

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Contributors

| Author(s) |
|-----------|
| Valeras Narbutas |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/spo-export-sharepoint-list-items-to-csv" aria-hidden="true" />