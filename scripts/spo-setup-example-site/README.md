---
plugin: add-to-gallery
---

# Setup example site

## Summary

This script is a good starting point for a setup script to create site with some assets like columns, content types, lists, navigation etc. The given example:
 - creates a site,
 - adds a site column and a content type,
 - adds list and modifies it's settings (add a content type to it and makes it hidden),
 - adds a document library with a custom column and some folder,
 - modifies the all items view of the document library,
 - modifies the site navigation links
 

# [PnP PowerShell](#tab/pnpps)
```powershell
###### Declare and Initialize Variables ######  

Write-host 'setup script example'
## Connect to SharePoint Online site  
Connect-PnPOnline -Url $Url -Interactive


Write-host 'create setup site'
$siteRelativeUrl = 'sites/setupTestSitePNP'
$tenantUrl = 'https://<tenant>.sharepoint.com'
$siteUrl = "$tenantUrl/$siteRelativeUrl"
$siteTitle = 'setup test site PNP'
$siteType = 'CommunicationSite'

$site = Get-PnPTenantSite -Identity  $siteUrl

if ($null -eq $site) {
  Write-host 'setup site does not exist, I will create it'
  New-PnPSite -Type $siteType -Title $siteTitle -Url $siteUrl
}
else {
  Write-host 'setup site already exists'
}

## Disconnect the context  
Disconnect-PnPOnline  
## Connect to SharePoint Online site  
Connect-PnPOnline -Url $siteUrl -Interactive

Write-host 'add site column'
$fieldName = 'Sample Text Column PNP'
$field = Get-PnPField -Identity $fieldName
if ($null -eq $field) {
  Write-host 'sample site column does not exist, I will create it'
  $fieldXml = "<Field ID='{13AFECC0-2454-41F3-85E6-E194458C861C}' Type='Text' Name='SampleTextColumnPNP' DisplayName='Sample Text Column PNP' Indexed='FALSE' Group='Sample Columns PNP' Required='FALSE' SourceID='{4f118c69-66e0-497c-96ff-d7855ce0713d}' StaticName='SampleTextColumnPNP' FromBaseType='TRUE' ></Field>"
  $field = Add-PnPFieldFromXml -FieldXml $fieldXml 
}
else {
  Write-host 'sample site column already exists'
}

Write-host 'add site content type'
$contentTypeName = 'sample content type PNP'
$contentTypeGroup = 'sample content type group PNP'
$parentId = '0x01007926A45D687BA842B947286090B8F67D' # list item content type
$contentType = Get-PnPContentType -Identity $contentTypeName

if ($null -eq $contentType) {
  Write-host 'sample site content type does not exist, I will create it'
  $ct = Get-PnPContentType -Identity Item
  $contentType = Add-PnPContentType -Name $contentTypeName  -Group $contentTypeGroup -ParentContentType $ct 
  $contentType = Get-PnPContentType -Identity $contentTypeName

}
else {
  Write-host 'sample site content type already exists'
}


Write-host 'add field to content type'
$fieldId = $field.Id
$contentTypeId = $contentType.StringId
Add-PnPFieldToContentType -Field $fieldId -ContentType $contentTypeId

Write-host 'create generic list'
$listName = 'setup test list PNP'
$list = Get-PnPList -Identity $listName
if ($null -eq $list) {
  Write-host 'sample generic list does not exist, I will create it'
  $list = New-PnPList -Title $listName -Template GenericList
}
else {
  Write-host 'sample generic list already exists'
}

Write-host 'modify list settings to allow content types'
Set-PnPList -Identity $list -EnableContentTypes $true


Write-host 'add content type to list'
$contentTypeAddedToList = Add-PnPContentTypeToList -List $list -ContentType $contentTypeId -DefaultContentType


Write-host 'make list hidden'
Set-PnPList -Identity $list -Hidden $true

Write-host 'create document lib'
$libName = 'setup test lib PNP'
$lib = Get-PnPList -Identity $libName

if ($null -eq $lib) {
  Write-host 'sample document lib does not exist, I will create it'
  $lib = New-PnPList -Title $libName -Template DocumentLibrary
}
else {
  Write-host 'sample document lib already exists'
}


Write-host 'add sample column'
$columnName = 'Sample Text Column PNP'
$column = Get-PnPField -List $libName -Identity $columnName

if ($null -eq $column) {
  Write-host 'sample column in lib does not exist, I will create it'
  $columnXml = "<Field ID='{AC827B0C-8B45-4B4F-927B-CDDC4FEEE79E}' Type='Text' Name='SampleTextColumnPNP' DisplayName='Sample Text Column PNP' Required='FALSE' SourceID='http://schemas.microsoft.com/sharepoint/v3' StaticName='SampleTextColumnPNP' FromBaseType='TRUE' />"
  $column = Add-PnPFieldFromXml -List $libName -FieldXml $columnXml
  
}
else {
  Write-host 'sample column in lib already exists'
}


Write-host 'add sample folder'
$folderName = 'sample Folder PNP'
$folder = Get-PnPFolder -List $libName 

if ($null -eq $folder) {
  Write-host 'sample folder in lib does not exist, I will create it'
  $folder = Add-PnPFolder -Name $folderName -Folder $libName
  
}
else {
  Write-host 'sample folder in lib already exists'
}

Write-host 'modify list view'
$views = Get-PnPView -List $list

$viewName = $views[0].Title # all items view
Set-PnPView -List $list -Identity $viewName -Fields $columnName

Write-host 'modify site navigation'
$currentNavigation = Get-PnPNavigationNode -Location QuickLaunch

Write-host 'clearing old navigation links'
foreach ($navigationItem in $currentNavigation) {
    Remove-PnPNavigationNode -identity $navigationItem.Id   -Location QuickLaunch -Force 
  
}
Write-host 'adding new navigation'
$nodeAddedResponse = Add-PnPNavigationNode -Title "Sample Document Library PNP" -Url "/$siteRelativeUrl/$libName/Forms/AllItems.aspx" -Location "QuickLaunch"
$nodeAddedResponse = Add-PnPNavigationNode -Title "Hidden Sample List PNP" -Url "/$siteRelativeUrl/Lists/$listName/AllItems.aspx" -Location "QuickLaunch"

 
## Disconnect the context  
Disconnect-PnPOnline  
```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***


## Contributors

| Author(s) |
|-----------|
| Valeras Narbutas |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-setup-example-site" aria-hidden="true" />
