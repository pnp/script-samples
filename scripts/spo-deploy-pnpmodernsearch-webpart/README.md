---
plugin: add-to-gallery
---

# Sample showing how to use extract the configuration of a PnP Modern Search results web part and apply it to the same web part on another site collection

## Summary

Often the same configuration for a PnP Modern Search results web part is deployed to numeral site using some provisioning engine. Updating the config afterwards can be a pain, but this script will make it a lots easier.

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

# extracts the PropertiesJSON from a PnP Modern Search Results web part and injects it into the target site
function Extract-JSON ($sourceSiteUrl, $sourcePage, $webPartName)
{
    Connect-PnPOnline -Url $sourceSiteUrl -UseWebLogin
    $page = Get-PnPClientSidePage -Identity $sourcePage 
    
    $webpart = $page.controls | Where-Object {$_.Title -eq $webPartName}
    $webpart.PropertiesJSON
    
}

function Inject-JSON ($targetSiteUrl, $targetPage, $webPartName, $newJSON)
{
    Connect-PnPOnline -Url $targetSiteUrl -UseWebLogin
    $page = Get-PnPClientSidePage -Identity $targetPage 
    
    $webpart = $page.controls | Where-Object {$_.Title -eq $webPartName}
    
    Set-PnPPageWebPart -Page $targetPage -Identity $webpart.InstanceId -PropertiesJson $newJSON
    Set-PnPPage -Identity $targetPage -Publish   
}

$json = Extract-JSON -sourceSiteUrl "https://[yourtenant].sharepoint.com/sites/[sitecollection]" -sourcePage "Home.aspx" -webPartName "PnP - Search Results"

#here you can insert a query that will provide your with a list of the site collections that need to be updated
Inject-JSON -targetSiteUrl "https://[yourtenant].sharepoint.com/sites/[sitecollection]" -targetPage "Home.aspx" -webPartName "PnP - Search Results" -newJSON $json



```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Contributors

| Author(s) |
|-----------|
| Kasper Larsen, Fellowmind|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-deploy-pnpmodernsearch-webpart" aria-hidden="true" />
