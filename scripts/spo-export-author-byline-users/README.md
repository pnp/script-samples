

# Sample showing how to Extract the employees shown on modern pages (Author byline) in a selection of Site Collections to CSV

## Summary

One of my customs requested that we removed a specific employee from the modern pages in their Intranet ASAP as that employee had left rather abruptly. They had no idea where that employee was displayed hence this script

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
# Purpose : locate any Author byline and report the people displayed


$tenentUrl = "https://[Tenant].sharepoint.com"

Connect-PnPOnline -Url $tenentUrl -Interactive

#define which site collections you wish to iterate
#$relevantsitecollections = Get-PnPTenantSite | Where-Object {$_.template -eq "STS#3"}
$relevantsitecollections = Get-PnPTenantSite 

$Output = @()

foreach($site in  $relevantsitecollections)
{
    $sitecollectionUrl = $site.Url
    Write-Host "Url =  $sitecollectionUrl" -ForegroundColor Yellow
    Connect-PnPOnline -Url $sitecollectionUrl -Interactive
    $pages = Get-PnPListItem -List "sitePages" -ErrorAction SilentlyContinue
    
    foreach($page in $pages)
    {
        try 
        {
            $authorbyline = $page["_AuthorByline"]
            if($authorbyline)
            {
                $myObject = [PSCustomObject]@{
                    URL     = $tenentUrl+$page["FileRef"]
                    Email = $authorbyline.Email
                    Name = $authorbyline.LookupValue
                    errorcode = ""

                }        
                $Output+=($myObject)
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
$Output | Export-Csv  -Path c:\temp\AuthorbylineUsers.csv -Encoding utf8BOM -Force  -Delimiter "|"

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Contributors

| Author(s) |
|-----------|
| Kasper Larsen, Fellowmind|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-export-author-byline-users" aria-hidden="true" />
