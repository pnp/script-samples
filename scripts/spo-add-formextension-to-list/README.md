---
plugin: add-to-gallery
---

# Associate Form Customizer Extension with List or Libraries Form

## Summary

This script allows you to associate Form Customizer Extension to List/Library via Content Type properties.
With SPFx version 1.15.1, we can now create new type of Extension as Form customizer which allows us to associate custom forms to SharePoint List. To associate a Form Customizer with list, we would have to update below new Content type properties which will associate the component id of the Form customizer extension to List.


**Properties**:

- NewFormClientSideComponentId - For New Form
- EditFormClientSideComponentId - For Edit Form
- DisplayFormClientSideComponentId - For Display Form

If you want to remove association you can pass empty string to update the properties and it would remove existing association.

**Note**: You need to find component id of your SPFx Form Customizer from manifest of the component (refer screenshot below). Go to your SPFx solution and open the manifest JSON file of the targeted Form Customizer Extension.

![Get Component ID](assets/howtogetcomponentid.png)

## Implementation

- Open Windows PowerShell ISE
- Create a new file
- Write a script as below
- Run the script
- Provide inputs requested by script

# [PnP PowerShell](#tab/pnpps)

```powershell

# Importing PnP module for PowerShell
Import-Module PnP.PowerShell

# SharePoint online site URL
$siteUrl = Read-Host -Prompt "Enter your SharePoint site URL (e.g https://<tenant>.sharepoint.com/sites/contoso)"

# Connect to SharePoint Online site
Write-Host "Connecting to " $siteUrl -ForegroundColor Yellow 
Connect-PnPOnline -Url $siteUrl -Interactive

# Enter SharePoint display list name and content type name
$listName = Read-Host 'Enter your SharePoint list name'
$contentTypeName = Read-Host 'Enter your list content type name'

# Enter new form component Id
$newFormComponentId = Read-Host 'Enter New form component Id'

# Enter edit form component Id
$editFormComponentId = Read-Host 'Enter Edit form component Id'

# Enter display form component Id
$displayFormComponentId = Read-Host 'Enter Display form component Id'

# Associate form customizer extension with SharePoint list forms
Set-PnPContentType -Identity $contentTypeName -List $listName -NewFormClientSideComponentId $newFormComponentId -EditFormClientSideComponentId $editFormComponentId -DisplayFormClientSideComponentId $displayFormComponentId

# Disconnect SharePoint online connection
Disconnect-PnPOnline
	
```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365](#tab/cli-m365-ps)

```powershell

# Get Credentials to connect
$m365Status = m365 status
if ($m365Status -match "Logged Out") {
    m365 login
}

# SharePoint online site URL
$siteUrl = Read-Host -Prompt "Enter your SharePoint site URL (e.g https://<tenant>.sharepoint.com/sites/contoso)"

# Enter SharePoint display list name and content type name
$listName = Read-Host 'Enter your SharePoint list name'
$contentTypeName = Read-Host 'Enter your list content type name'

# Enter new form component Id
$newFormComponentId = Read-Host 'Enter New form component Id'

# Enter edit form component Id
$editFormComponentId = Read-Host 'Enter Edit form component Id'

# Enter display form component Id 
$displayFormComponentId = Read-Host 'Enter Display form component Id'

# Associate form customizer extension with SharePoint list forms
m365 spo contenttype set --name $contentTypeName --listTitle $listName --webUrl $siteUrl --NewFormClientSideComponentId $newFormComponentId --EditFormClientSideComponentId $editFormComponentId --DisplayFormClientSideComponentId $displayFormComponentId

# Disconnect SharePoint online connection
m365 logout

```

[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

***

## Contributors

| Author(s) |
|-----------|
| [Siddharth Vaghasia](https://www.linkedin.com/in/siddharthvaghasia/) |
| [Ganesh Sanap](https://ganeshsanapblogs.wordpress.com/about) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-add-formextension-to-list" aria-hidden="true" />
