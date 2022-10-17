---
plugin: add-to-gallery
---

# Import CSV values to an existing SharePoint List

## Summary

Main idea here is import content from a csv to a existing list.  

Usually for that to happen,  we need to explicit enumerate each column of the list and in the csv file.    

With this sample you dont need to do it anymore as long you follow the bellow rule :  
>  
> CSV columns must have the same name as the list columns name.  
  
Excelsior, hum? :P  

# [PnP PowerShell](#tab/pnpps)

```powershell

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$Url,
    [Parameter(Mandatory = $true)]
    [string]$ListName,
    [Parameter(Mandatory = $true)]
    [string]$CsvFile
)
begin {
    Import-Module PnP.PowerShell
    Write-Output "Connecting to $Url"
    Connect-PnPOnline -Url $Url -Interactive
}
process {
    
    
    ## Powershell filter , it converts an array in a hashtable
    filter ArrayToHash {
        begin {
            $hash = @{} 
        }
        process { 
            $obj = $_ | Get-Member | Where-Object { $_.MemberType -eq 'NoteProperty' } | Select-object name
            foreach ($o in $obj) {
                $name = $o.Name
                $hash[$name] = $_."$name"
            }
     
        }
        end { return $hash }
    }
    Write-Output " Collect CSV data from $CsvFile"
    $rows = Import-Csv $CsvFile
    $totalRows = $rows.Length
    Write-Output " $CsvFile has $totalRows rows"
 
    Write-Output " Items will be added using batch mode"
    Write-Output " Initiate batch" 
    $batch = New-PnPBatch
    $ct=0
    $rows.ForEach({
            # convert hast
            $values = $_ | ArrayToHash
            Add-PnPListItem -List $ListName -Values $values -Batch  $batch
            Write-Output "  Item added ($ct/$totalRows)"  
            $ct++
        })
    Write-Output " Invoke batch" 
    Invoke-PnPBatch -Batch $batch
    Write-Output " Batch invoked"
}
end{
    Write-Output " Disconnecting"
    Disconnect-PnPOnline
    Write-Output "Disconnected from $Url"
    Write-Output "All done!"
}
```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Contributors

| Author(s) |
|-----------|
| Rodrigo Pinto |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-import-csv-data-to-existing-sharepoint-list" aria-hidden="true" />

