---
plugin: add-to-gallery
---

# Export CSV To SharePoint List Data

## Summary

Many times we have requirements like having to add a CSV file to the SharePoint list so if there are many records then manually this work becomes difficult.

## Implementation

- Open Windows PowerShell ISE
- Create a new file
- Write a script as below,
- First, we will connect the site URL with the user's credentials.
    - To connect the SharePoint site with PnP refer to this article.
    - Then we will create a list and fields. so field types will be as a below,
    - FirstName,LastName,JobTitle,Location - Single line of text
    - BirthDate, HireDate - Date and time

We will import the CSV using the Import-Csv method.

# [PnP PowerShell](#tab/pnpps)
```powershell

$Login = #userid    
$password = #password  
$secureStringPwd = $password | ConvertTo-SecureString -AsPlainText -Force     
$Creds = New-Object -Typename System.Management.Automation.PSCredential -ArgumentList $Login, $secureStringPwd   
$siteUrl = #siteUrl  
 
#connect to site  
Write-Host "Connection to the site..." -ForegroundColor Yellow  
Connect-PnpOnline -Url $SiteUrl -Credentials $Creds       
Write-Host "Connection successfully..." -ForegroundColor Yellow  
 
#create a list  
Write-Host "Creating list..." -ForegroundColor Yellow  
New-PnPList -Title "Employees" -Url "lists/Employees"   
Write-Host "List created..." -ForegroundColor Yellow  
 
#create fields  
Write-Host "Creating fields..." -ForegroundColor Yellow  
Add-PnPField -List "Employees" -DisplayName "First Name" -InternalName "FirstName" -Type Text -AddToDefaultView  
Add-PnPField -List "Employees" -DisplayName "Last Name" -InternalName "LastName" -Type Text -AddToDefaultView  
Add-PnPField -List "Employees" -DisplayName "Location" -InternalName "Location" -Type Text -AddToDefaultView  
Add-PnPField -List "Employees" -DisplayName "Job Title" -InternalName "JobTitle" -Type Text -AddToDefaultView   
Add-PnPField -List "Employees" -DisplayName "Hire Date" -InternalName "HireDate" -Type DateTime -AddToDefaultView  
Add-PnPField -List "Employees" -DisplayName "Birth Date" -InternalName "BirthDate" -Type DateTime -AddToDefaultView  
Write-Host "Fields created..." -ForegroundColor Yellow  
  
$filePath = "F:\Intranet Employee Report.csv"  
 
#Import CSV  
$CSVRecords = Import-Csv $FilePath  
Write-host -f Yellow "$($CSVRecords.count) Rows Found!"  
 
#create list items  
Write-Host "Creating list items..." -ForegroundColor Yellow  
foreach ($Record in $CSVRecords) {  
    $items = Add-PnPListItem -List "Employees" -Values @{  
        "Title"     = $Record.'FirstName' + " " + $Record.'LastName';  
        "FirstName" = $Record.'FirstName';  
        "LastName"  = $Record.'LastName';  
        "Location"  = $Record.'Location';  
        "JobTitle"  = $Record.'JobTitle';        
        "BirthDate" = $Record.'BirthDate';  
        "HireDate"  = $Record.'HireDate';  
    }  
}  
  
Write-Host "list items created..." -ForegroundColor Yellow  

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365 with PowerShell](#tab/cli-m365-ps)
```powershell

$siteUrl = #siteUrl
$listName = "Employees"

$m365Status = m365 status
if ($m365Status -match "Logged Out") {
    m365 login
}
 
#create a list  
Write-Host "Creating list..." -ForegroundColor Yellow  

m365 spo list add --title $listName --baseTemplate "GenericList" --webUrl $siteUrl
Write-Host "List created..." -ForegroundColor Yellow  
 
#create fields  
Write-Host "Creating fields..." -ForegroundColor Yellow  

$firstNameXml = "<Field Type='Text' DisplayName='FirstName' Required='FALSE' EnforceUniqueValues='FALSE' Indexed='FALSE' ID='{6085e32a-339b-4da7-ab6d-c1e013e5ab27}' SourceID='{4f118c69-66e0-497c-96ff-d7855ce0713d}' StaticName='FirstName' Name='FirstName'></Field>"
m365 spo field add --webUrl $siteUrl --listTitle $listName --xml $firstNameXml
m365 spo list view field add --webUrl $siteUrl --listTitle $listName --viewTitle 'All Items' --fieldTitle 'FirstName'

$lastNameXml = "<Field Type='Text' DisplayName='LastName' Required='FALSE' EnforceUniqueValues='FALSE' Indexed='FALSE' ID='{1b9be491-0a09-4381-b9e2-7a980a5b8ad9}' SourceID='{4f118c69-66e0-497c-96ff-d7855ce0713d}' StaticName='LastName' Name='LastName'></Field>"
m365 spo field add --webUrl $siteUrl --listTitle $listName --xml $lastNameXml
m365 spo list view field add --webUrl $siteUrl --listTitle $listName --viewTitle 'All Items' --fieldTitle 'LastName'

$locationXml = "<Field Type='Text' DisplayName='Location' Required='FALSE' EnforceUniqueValues='FALSE' Indexed='FALSE' ID='{b801e08f-c9e1-406d-a044-237f576157be}' SourceID='{4f118c69-66e0-497c-96ff-d7855ce0713d}' StaticName='Location' Name='Location'></Field>"
m365 spo field add --webUrl $siteUrl --listTitle $listName --xml $locationXml
m365 spo list view field add --webUrl $siteUrl --listTitle $listName --viewTitle 'All Items' --fieldTitle 'Location'

$jobTitleXml = "<Field Type='Text' DisplayName='JobTitle' Required='FALSE' EnforceUniqueValues='FALSE' Indexed='FALSE' ID='{127da56f-8d7f-4f36-a461-afab9f5c6f34}' SourceID='{4f118c69-66e0-497c-96ff-d7855ce0713d}' StaticName='JobTitle' Name='JobTitle'></Field>"
m365 spo field add --webUrl $siteUrl --listTitle $listName --xml $jobTitleXml
m365 spo list view field add --webUrl $siteUrl --listTitle $listName --viewTitle 'All Items' --fieldTitle 'JobTitle'

$hireDateXml = "<Field Type='DateTime' DisplayName='HireDate' Required='FALSE' EnforceUniqueValues='FALSE' Indexed='FALSE' ID='{41351989-e693-430d-9c40-d4e19c47df08}' SourceID='{4f118c69-66e0-497c-96ff-d7855ce0713d}' StaticName='HireDate' Name='HireDate'></Field>"
m365 spo field add --webUrl $siteUrl --listTitle $listName --xml $hireDateXml
m365 spo list view field add --webUrl $siteUrl --listTitle $listName --viewTitle 'All Items' --fieldTitle 'HireDate'

$birthDateXml = "<Field Type='DateTime' DisplayName='BirthDate' Required='FALSE' EnforceUniqueValues='FALSE' Indexed='FALSE' ID='{b0541eb4-d16f-4b44-a92a-d36a2e3f88ba}' SourceID='{4f118c69-66e0-497c-96ff-d7855ce0713d}' StaticName='BirthDate' Name='BirthDate'></Field>"
m365 spo field add --webUrl $siteUrl --listTitle $listName --xml $birthDateXml
m365 spo list view field add --webUrl $siteUrl --listTitle $listName --viewTitle 'All Items' --fieldTitle 'BirthDate'
 
Write-Host "Fields created..." -ForegroundColor Yellow  
  
$filePath = "C:\workspace\a_Local\cli_sample\Intranet Employee Report.csv"  
 
#Import CSV  
$CSVRecords = Import-Csv $FilePath  
Write-host -f Yellow "$($CSVRecords.count) Rows Found!"  
 
#create list items  
Write-Host "Creating list items..." -ForegroundColor Yellow  
foreach ($Record in $CSVRecords) {  
    $title = $Record.'FirstName' + " " + $Record.'LastName'
    $FirstName = $Record.'FirstName'
    $LastName = $Record.'LastName'
    $Location = $Record.'Location'
    $JobTitle = $Record.'JobTitle'
    $BirthDate = $Record.'BirthDate'
    $HireDate = $Record.'HireDate'
    m365 spo listitem add --listTitle $listName --webUrl $siteUrl --Title $title --FirstName $FirstName --LastName $LastName --Location $Location --JobTitle $JobTitle --BirthDate $BirthDate --HireDate $HireDate
}  
  
Write-Host "list items created..." -ForegroundColor Yellow  


```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
***

## Source Credit

Sample first appeared on [https://www.c-sharpcorner.com/article/export-csv-to-sharepoint-list-data-using-pnp-powershell/](https://www.c-sharpcorner.com/article/export-csv-to-sharepoint-list-data-using-pnp-powershell/)

## Contributors

| Author(s) |
|-----------|
| Chandani Prajapati |
| [Adam Wójcik](https://github.com/Adam-it)|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-export-data-to-sharepoint-lists" aria-hidden="true" />
