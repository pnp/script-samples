---
plugin: add-to-gallery
---

# Export Term Store terms to CSV

## Summary

Script will export all or selected term groups' terms to CSV file.

## Implementation

- Open Windows PowerShell ISE
- Edit Script and add details like SharePoint tenant URL, Term groups, and the output directory
- Press run

# [CLI for Microsoft 365 with PowerShell](#tab/cli-m365-ps)

```powershell
###### Declare and Initialize Variables ######  

#term store variables
$groups = @("Group 1","Group 2") # leave empty for exporting all groups

# data will be saved in same directory script was started from
$saveDir = (Resolve-path ".\")  
$currentTime= $(get-date).ToString("yyyyMMddHHmmss")  
$FilePath=".\TermStoreReport-"+$currentTime+".csv"  
Add-Content $FilePath "Term group name, Term group ID, Term set name, Term set ID, Term name, Term ID"

## Export List to CSV ##  
function ExportTerms
{  
    try  
    {  
        if($groups.Length -eq 0){ 
            $groups = @(m365 spo term group list | ConvertFrom-Json | ForEach-Object{ $_.Name })
        }
        # Loop through the term groups
        foreach ($termGroup in $groups) {
            try {
                $termGroupName = $termGroup
                Write-Host "Exporting terms from $termGroup"
                $query = "[?Name == '"+$termGroupName+"']"
                $termGroupObj = m365 spo term group list --query $query | ConvertFrom-Json 
                if($termGroupObj)
                {
                 $termSets = m365 spo term set list --termGroupName $termGroupName | ConvertFrom-Json 
                 foreach ($termSetObj in $termSets) {
                    $terms = m365 spo term list --termGroupName $termGroupName --termSetName $termSetObj.Name | ConvertFrom-Json 
                    foreach ($term in $terms) {
                        Add-Content $FilePath "$($termGroupObj.Name),$($termGroupObj.Id),$($termSetObj.Name),$($termSetObj.Id),$($term.Name),$($term.Id)"
                    }
                 }
               }
            }
            catch {
                Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
            }            
        }
     }  
     catch [Exception]  
     {  
        $ErrorMessage = $_.Exception.Message         
        Write-Host "Error: $ErrorMessage" -ForegroundColor Red          
     }  
}  
 
## Connect to SharePoint Online site  

$m365Status = m365 status
if ($m365Status -match "Logged Out") {
  Write-Host "Logging in the User!"
  m365 login --authType browser
}
 
## Call the Function  
ExportTerms
 
## Disconnect the context  
m365 logout  

```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]


# [PnP PowerShell](#tab/pnpps)
```powershell

###### Declare and Initialize Variables ######  

#site url
$url="Site admin site url"

#term store variables
$groups = @("Group 1","Group 2") # leave empty for exporting all groups

# data will be saved in same directory script was started from
$saveDir = (Resolve-path ".\")  
$currentTime= $(get-date).ToString("yyyyMMddHHmmss")  
$FilePath=".\TermStoreReport-"+$currentTime+".csv"  
Add-Content $FilePath "Term group name, Term group ID, Term set name, Term set ID, Term name, Term ID"
## Export List to CSV ##  
function ExportTerms
{  
    try  
    {  
        if($groups.Length -eq 0){
            $groups = @(Get-PnPTermGroup | ForEach-Object{ $_.Name })
        }
        # Loop through the term groups
        foreach ($termGroup in $groups) {
            try {
                $termGroupName = $termGroup
                Write-Host "Exporting terms from $termGroup"
                $termGroupObj = Get-PnPTermGroup -Identity $termGroupName -Includes TermSets
                foreach ($termSet in $termGroupObj.TermSets) {
                    $termSetObj = Get-PnPTermSet -Identity $termSet.Id -TermGroup $termGroupName -Includes Terms
                    foreach ($term in $termSetObj.terms) {
                        Add-Content $FilePath "$($termGroupObj.Name),$($termGroupObj.Id),$($termSetObj.Name),$($termSetObj.Id),$($term.Name),$($term.Id)"
                    }
                }
            }
            catch {
                Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
            }
            
        }
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
ExportTerms
 
## Disconnect the context  
Disconnect-PnPOnline  
  

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Contributors

| Author(s) |
|-----------|
| [Ramin Ahmadi](https://github.com/ahmadiramin) |
| [Reshmee Auckloo](https://github.com/reshmee011) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-export-termstore-terms-to-csv" aria-hidden="true" />
