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
***

## Source Credit

Sample first appeared on [https://www.c-sharpcorner.com/article/export-csv-to-sharepoint-list-data-using-pnp-powershell/](https://www.c-sharpcorner.com/article/export-csv-to-sharepoint-list-data-using-pnp-powershell/)

## Contributors

| Author(s) |
|-----------|
| Chandani Prajapati |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/spo-export-data-to-sharepoint-lists" aria-hidden="true" />