---
plugin: add-to-gallery
---

# Export Content Type Details To CSV

## Summary
This example illustrates how to export all content types present on websites, capturing essential details like Name, ID, Scope, Schema, Fields, and additional information, then organizing them into a CSV format.

![Example Screenshot](assets/example.png)

# [PnP PowerShell](#tab/pnpps)

```powershell

$siteUrl = Read-Host "Enter site URL"
$username = "username@domain.onmicrosoft.com"
$password = "********"
$secureStringPwd = $password | ConvertTo-SecureString -AsPlainText -Force 
$creds = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secureStringPwd
$dateTime = "{0:MM_dd_yy}{0:HH_mm_ss}" -f (Get-Date)
$basePath = "D:\Contributions\Scripts\Logs\"
$csvPath = $basePath + "\ContentTypeData" + $dateTime + ".csv"
$global:ctData = @()

Function Login() {
    [cmdletbinding()]
    param([parameter(Mandatory = $true, ValueFromPipeline = $true)] $creds)     
    Write-Host "Connecting to Site '$($siteUrl)'" -ForegroundColor Yellow   
    Connect-PnPOnline -Url $siteUrl -Credentials $creds
    Write-Host "Connection Successful!" -ForegroundColor Green     
}

Function ContentTypeDetails() {
    try {
        Write-Host "Getting content type details..." -ForegroundColor Yellow
        $allContentTypes = Get-PnPContentType
        Foreach ($contentType in $allContentTypes)
        {
            #Collect Content Type Data
            $ctName = $contentType.Name
            $ctId = $contentType.Id
            $ctGroup = $contentType.Group  
            $ctDescription = $contentType.Description  
            $ctPath = $contentType.Path  
            $ctScope = $contentType.Scope  
            $ctStringId = $contentType.StringId  
            $ctSchemaXml = $contentType.SchemaXml  
            $contentTypeFields = Get-PnPProperty -ClientObject $contentType -Property Fields
            $contentTypeFieldsCount = $contentTypeFields.Count
            $contentTypeFieldsSchema = $contentTypeFields.SchemaXml
            $contentTypeTitle = ($contentTypeFields | select-object -property Title | foreach-object { $_.Title }) -join ','
            
            $global:ctData += [PSCustomObject] @{
                Name               = $ctName
                ID                 = $ctId
                Group              = $ctGroup
                Description        = $ctDescription
                Path               = $ctPath
                Scope              = $ctScope
                StringId           = $ctStringId
                SchemaXml          = $ctSchemaXml
                Fields             = $contentTypeTitle
                FieldCount         = $contentTypeFieldsCount
                FieldSchemaXMl     = $contentTypeFields.SchemaXml
            }
        }    
        Write-Host "Getting content type details successfully!..." -ForegroundColor Green  
    }
    catch {
        Write-Host "Error in getting content type information:" $_.Exception.Message -ForegroundColor Red                 
    }    
    Write-Host "Exporting to CSV..."  -ForegroundColor Yellow 
    $global:ctData | Export-Csv $csvPath -NoTypeInformation -Append
    Write-Host "Exported to CSV successfully!..."  -ForegroundColor Gree
}

Function StartProcessing {
    Login($creds);  
    ContentTypeDetails 
}

StartProcessing
```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***
## Contributors

| Author(s) |
|-----------|
| Chandani Prajapati (https://github.com/chandaniprajapati) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/export-content-type-details-to-csv" aria-hidden="true" />