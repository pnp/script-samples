---
plugin: add-to-gallery
---

# Associate Form Customizer Extension with List or Libraries Form

## Summary

This script allows you to associate Form Customizer Extension to List/Library via Content Type properties.
With SPFx version 1.15.1, we can now create new type of Extension as Form customizer which allows use to associate custom forms to SharePoint List. To associate a Form Customizer with list, we would have to update below new Content type properties which provides will associate the component id of the Form customizer extension to List.

Properties Name

- NewFormClientSideComponentId - For New Form
- EditFormClientSideComponentId - For Edit Form
- DisplayFormClientSideComponentId - For Display Form

If you want to remove association you can pass empty string to update the properties and it would remove existing association 

Note - You need to find component id of your SPFx Form Customizer from manifest of the component(refer screenshot below).
Go to your SPFx solution and open the manifest json file of the targeted Form Extension.

![Get Component ID](assets/howtogetcomponentid.png)

## Implementation

- Open Windows PowerShell ISE
- Create a new file
- Write a script as below,
- Run the script.
- Provide input requested by script
 

# [PnP PowerShell](#tab/pnpps)
```powershell

#Importing PnP module for PowerShell
Import-Module PnP.PowerShell

#Enter SharePoint URL
$siteURL= Read-Host 'Enter site URL ' 

#Connect SharePoint site
Write-Host "Connecting to " $siteURL -ForegroundColor Yellow 
Connect-PnPOnline -Url $siteURL -Interactive

#Get SharePoint online CSOM context 
$clientContext = Get-PnPContext

#Enter list name and content type name
$listName= Read-Host 'Enter List name '
$contentTypeName= Read-Host 'Enter Content type name '

#Get specified content type for current context
$contentType = Get-PnPContentType -List $listName -Identity $contentTypeName

#Enter new form component Id
$newFormComponentId= Read-Host 'Enter New form component Id '
$contentType.NewFormClientSideComponentId = $newFormComponentId;

#Enter edit form component Id
$editFormComponentId= Read-Host 'Enter Edit form component Id '
$contentType.EditFormClientSideComponentId = $editFormComponentId;

#Enter display form component Id 
$displayFormComponentId= Read-Host 'Enter Display form component Id '
$contentType.DisplayFormClientSideComponentId = $displayFormComponentId;

#Update changes to SharePoint
$contentType.Update($false)
$clientContext.ExecuteQuery()
Write-Host "Updated content type successfully!"  -ForegroundColor Cyan  


```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***


## Contributors

| Author(s) |
|-----------|
| [Siddharth Vaghasia](https://www.linkedin.com/in/siddharthvaghasia/)|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-add-formextension-to-list" aria-hidden="true" />
