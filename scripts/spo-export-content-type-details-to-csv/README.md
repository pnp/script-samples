---
plugin: add-to-gallery
---

# Export Content Type Details To CSV

## Summary

This example illustrates how to export all content types present on a SharePoint site, capturing essential details like Name, ID, Scope, Schema, Fields, and additional information, then organizing them into a CSV format.

# [PnP PowerShell](#tab/pnpps)

```powershell
$siteUrl = Read-Host "Enter site URL"
$username = "username@domain.onmicrosoft.com"
$password = "********"
$secureStringPwd = $password | ConvertTo-SecureString -AsPlainText -Force
$creds = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secureStringPwd
$dateTime = "{0:MM_dd_yy}_{0:HH_mm_ss}" -f (Get-Date)
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
                Name                = $ctName
                ID                  = $ctId
                Group               = $ctGroup
                Description         = $ctDescription
                Path                = $ctPath
                Scope               = $ctScope
                StringId            = $ctStringId
                SchemaXml           = $ctSchemaXml
                Fields              = $contentTypeTitle
                FieldCount          = $contentTypeFieldsCount
                FieldSchemaXMl      = $contentTypeFields.SchemaXml
            }
        }
        Write-Host "Getting content type details successfully!..." -ForegroundColor Green
    }
    catch {
        Write-Host "Error in getting content type information:" $_.Exception.Message -ForegroundColor Red
    }
    Write-Host "Exporting to CSV..."  -ForegroundColor Yellow
    $global:ctData | Export-Csv $csvPath -NoTypeInformation -Append
    Write-Host "Exported to CSV successfully!..."  -ForegroundColor Green

    # Disconnect SharePoint online connection
    Disconnect-PnPOnline
}

Function StartProcessing {
    Login($creds);
    ContentTypeDetails
}

StartProcessing
```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365](#tab/cli-m365-ps)

```powershell
$siteUrl = Read-Host -Prompt "Enter your SharePoint online site URL (e.g https://contoso.sharepoint.com/sites/work)"
$dateTime = "{0:MM_dd_yy}_{0:HH_mm_ss}" -f (Get-Date)
$basePath = "D:\dtemp\"
$csvPath = $basePath + "\ContentTypesData" + $dateTime + ".csv"
$global:ctData = @()

Function Login() {     
    Write-Host "Connecting to SharePoint" -ForegroundColor Yellow
	
	#Get Credentials to connect
	$m365Status = m365 status
	if ($m365Status -match "Logged Out") {
		m365 login
	}
    
	Write-Host "Connection Successful!" -ForegroundColor Green
}

Function ContentTypeDetails() {
    try {
        Write-Host "Getting content type details..." -ForegroundColor Yellow
		$allContentTypes = m365 spo contenttype list --webUrl $siteUrl | ConvertFrom-Json

        Foreach ($contentType in $allContentTypes)
        {
            #Collect Content Type Data
            $ctName = $contentType.Name
            $ctId = $contentType.Id
            $ctGroup = $contentType.Group
			$ctDescription = $contentType.Description
            $ctScope = $contentType.Scope
            $ctStringId = $contentType.StringId
            $ctSchemaXml = $contentType.SchemaXml
            
            $global:ctData += [PSCustomObject] @{
                Name            = $ctName
                ID              = $ctId.StringValue
                Group			= $ctGroup
                Description		= $ctDescription
                Scope			= $ctScope
                StringId		= $ctStringId
                SchemaXml		= $ctSchemaXml
            }
        }
        Write-Host "Getting content type details successfully!..." -ForegroundColor Green
    }
    catch {
        Write-Host "Error in getting content type information:" $_.Exception.Message -ForegroundColor Red
    }
    Write-Host "Exporting to CSV..."  -ForegroundColor Yellow
    $global:ctData | Export-Csv $csvPath -NoTypeInformation -Append
    Write-Host "Exported to CSV successfully!..."  -ForegroundColor Green
	
	# Disconnect SharePoint online connection
	m365 logout
}

Function StartProcessing {
	Login
    ContentTypeDetails
}

StartProcessing
```

[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

***

## Contributors

| Author(s) |
|-----------|
| Chandani Prajapati (https://github.com/chandaniprajapati) |
| [Ganesh Sanap](https://ganeshsanapblogs.wordpress.com/) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-export-content-type-details-to-csv" aria-hidden="true" />
