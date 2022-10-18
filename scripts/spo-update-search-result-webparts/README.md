---
plugin: add-to-gallery
---

# Sample on how to locate the classic Search Result Web part and check the Remove Duplicates setting

## Summary

Locate all the pages where a classic Search Result Web Part is used, and if the Remove Duplicates setting is True (which is the default) log the location in the csv file. The duplicate algoritm is basically broken and will often trim records that are NOT duplicates

## Implementation

- Open VS Code
- Create a new file
- Write a script as below,
- Change the variables to target to your environment
- Run the script.
 
## Screenshot of Output 

![Example Screenshot](assets/preview.png)

# [PnP PowerShell](#tab/pnpps)
```powershell


#Purpose: locate all pages that contains a OOTB search result web part ( for checking number of returned items + duplicat check)

function Handle-Pages ($pages, $url) 
{
    foreach($page in $pages)
    {
         $wps = Get-PnPWebPart -ServerRelativePageUrl  $page["FileRef"]
         foreach($wp in $wps)
         {
             try {
                 if($wp.WebPart.Properties.FieldValues.ContainsKey("ResultsPerPage"))
                 {
                     $dataProviderJSON = $wp.WebPart.Properties.FieldValues["DataProviderJSON"]
                     $vals = ConvertFrom-Json $dataProviderJSON
 
                     Write-Host $page["FileRef"] ", TrimDuplicates = " $vals.TrimDuplicates ", ResultsPerPage" $wp.WebPart.Properties.FieldValues["ResultsPerPage"]    
                    if($true -eq $vals.TrimDuplicates )
                    {
                        #add to output
                        $myobj = [PSCustomObject]@{
                            url = $url
                            page = $page["FileRef"]
                            
                        }
                        $hits.Add($myobj)
            
                    }
                 }
                 
             }
             catch 
             {
                write-host "Exception in Web Part data extraction: $($_.Exception)"    
             }
             
         }
                 
    }    
    
}


$hits = New-Object -TypeName "System.Collections.ArrayList"
#$cred = Get-Credential
$tenantUrl =  "https://[tenant]-admin.sharepoint.com"  
$tenantConn = Connect-PnPOnline -Url $tenantUrl -UseWebLogin -ReturnConnection

# get all classic site collections
$classicSiteCollections = Get-PnPTenantSite -Template "STS#0" -Connection $tenantConn
Disconnect-PnPOnline -Connection $tenantConn

$classicSiteCollections.Count
foreach($classicSiteCollection in $classicSiteCollections)
{
    $classicSiteCollection.Url
    Connect-PnPOnline -Url $classicSiteCollection.Url -UseWebLogin
    $pages = Get-PnPListItem -List "Site Pages" 
    Handle-Pages -pages $pages -url $classicSiteCollection.Url

    $webs = Get-PnPSubWebs -Recurse 
    foreach($web in $webs)
    {
         try
         {    
             $pages = Get-PnPListItem -List "Site Pages" -Web $web -ErrorAction Stop
             Handle-Pages -pages $pages $web.Url
             
        }
        catch
        {
             write-host $web.Url -ForegroundColor Red
        }
     }
}
$hits | Export-Csv -Path C:\temp\searchwebpartswithtrimming.csv -Encoding UTF8 -Delimiter "|" -Force -NoTypeInformation
   
   

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Contributors

| Author(s) |
|-----------|
| Kasper Larsen, Fellowmind|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-update-search-result-webparts" aria-hidden="true" />
