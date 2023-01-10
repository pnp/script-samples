---
plugin: add-to-gallery
---

# Create Documentset with PnP PowerShell 

## Summary

The script below is a sample for when you need to work with documentsets in SharePoint. 
You need to have a SharePoint site with a document library, the documentset and related metadata in place.


## Implementation

- Open Visual Studio Code
- Create a new file
- Write a script as below,
- Change the variables to target to your environment, site, document library, metadata
- Run the script.
 
## Screenshot of Output 

Below is the output after I have ran the script a couple of times, you can use a .csv or any other source for metadata input.
 
Documentset folders are have a white icon.

![Example Screenshot](assets/docset06.png)

# [PnP PowerShell](#tab/pnpps)
```powershell

#Connect to SharePoint online site
$spcon = Connect-PnPOnline -Url "https://tenant.sharepoint.com/sites/site" -Interactive -ReturnConnection

#new docset metadata
$doclibrary = "Shared Documents"
$docsetName = "Documentset 1002"
$docsetContenttype = "My Documentset"
$Year = "1002"
$ResponsiblePerson = "UPN" #UPN of the user
$ResponsibleUnit = "Marketing"

#check if the Documentset exist or not
$docsetexist = Get-PnPFolder -Url "https://tenant.sharepoint.com/sites/sites/$doclibrary/$docsetName" -Connection $spcon -ErrorAction SilentlyContinue
if($docsetexist)
{
      #write-host
      Write-Host "Documentset exist in library: " $docsetName 
            
}
else 
{
      #Add-PnP Documentset, then update documentset metadata
      Write-Host "Creating Documentset: " $docsetName -BackgroundColor Green

      $docset = Add-PnPDocumentSet -List $doclibrary -ContentType $docsetContenttype -Name $docsetName -Connection $spcon
      $docsetprop = Get-PnPFolder -Url $docset -Connection $spcon
      $docsetprop.Context.Load($docsetprop.ListItemAllFields)
      $docsetprop.Context.ExecuteQuery()

      #Set docset metadata
      Set-PnPListItem -List $doclibrary -Identity $docsetprop.ListItemAllFields.Id -Values @{Year="$Year"; Responsible_x0020_Person="$ResponsiblePerson"; Responsible_x0020_Unit="$ResponsibleUnit"} -Connection $spcon
}

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***


## Contributors

| Author(s) |
|-----------|
| Jimmy Hang|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/create-dummy-docs-in-library" aria-hidden="true" />
