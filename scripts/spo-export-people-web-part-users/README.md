---
plugin: add-to-gallery
---

# Sample showing how to extract the employees shown in the People Web part on pages in a selection of Site Collections to CSV

## Summary

One of my customs requested that we removed a specific employee from the People Web part in their Intranet ASAP as that employee had left rather abruptly. They had no idea where that employee was displayed hence this script

## Implementation

- Open VS Code
- Create a new file
- Copy the code below,
- Change the variables to target to your environment
- Run the script.
 
## Screenshot of Output 

![Example Screenshot](assets/preview.png)

# [PnP PowerShell](#tab/pnpps)
```powershell

# Author Kasper Larsen Fellowmind.dk
# Purpose : locate any People Web part and report the people displayed


#define which site collections you wish to iterate
$tenentUrl = "https://[tenant].sharepoint.com"
$relevantsitecollections = Get-PnPTenantSite | Where-Object {$_.template -eq "STS#3"}


$Output = @()


foreach($site in  $relevantsitecollections)
{
    $sitecollectionUrl = $site.Url
    
    Write-Host "Url =  $sitecollectionUrl" -ForegroundColor Yellow
    
    Connect-PnPOnline -Url $sitecollectionUrl -Interactive
    $pages = Get-PnPListItem -List "sitePages" 
    
    foreach($page in $pages)
    {
        try 
        {
            $fullUrl = $tenentUrl+$page["FileRef"]
            Write-Host " Page = $fullUrl" -ForegroundColor Green
            $webpartpage = Get-PnPClientSidePage -Identity $page["FileLeafRef"] -ErrorAction Stop
            
            $webparts = $webpartpage.controls | Where-Object {$_.PropertiesJson -like "*persons*"}

            foreach($webpart in $webparts)
            {
                $props =  $webpart.PropertiesJson | ConvertFrom-Json
                write-host "Found $props.persons.count people in the web part" -ForegroundColor Blue
                foreach($person in $props.persons)
                {
                    $personId = $person.Id
                    if($personId.IndexOf("i:0#.f|membership|") -gt -1)
                    {
                        $personId = $personId.substring(18)
                    }

                    $myObject = [PSCustomObject]@{
                        URL     = $tenentUrl+$page["FileRef"]
                        personid = $personId
                        personupn = $person.upn
                        errorcode = ""

                    }        
                    $Output+=($myObject)
                }
            }
        }
        catch 
        {
            $myObject = [PSCustomObject]@{
                URL     = $tenentUrl+$page["FileRef"]
                personid = ""
                personupn = ""
                errorcode = $_.Exception.Message

            }        
            $Output+=($myObject)
        }
        
        
        
        
    }
}
$Output | Export-Csv  -Path c:\temp\PeopleWebPartUsers.csv -Encoding utf8NoBOM -Force  -Delimiter "|"

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Contributors

| Author(s) |
|-----------|
| Kasper Larsen, Fellowmind|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-export-basic-sitecollection-info" aria-hidden="true" />
