---
plugin: add-to-gallery
---

# Get Content type usage within a site across lists, list items and item version

## Summary

This sample script returns content type usage within a site across lists, list items and item version. The error message "content type in use" appears while trying to delete a content type within a site, the script can help identify where the content type is referenced to help with deletion of content type.

## Implementation

- Open Windows PowerShell ISE
- Create a new file
- Write a script as below,
- Update the  
# [PnP PowerShell](#tab/pnpps)
```powershell

$username = "chandani@domain.onmicrosoft.com"
$password = "*******"
$secureStringPwd = $password | ConvertTo-SecureString -AsPlainText -Force 
$Creds = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secureStringPwd
$global:listFields = @()
$BasePath = "E:\Contribution\PnP-Scripts\ListFields\"
$DateTime = "{0:MM_dd_yy}_{0:HH_mm_ss}" -f (Get-Date)
$CSVPath = $BasePath + "\listfields" + $DateTime + ".csv"

Function ConnectToSPSite() {
    try {
        $SiteUrl = Read-Host "Please enter Site URL"
        if ($SiteUrl) {
            Write-Host "Connecting to Site :'$($SiteUrl)'..." -ForegroundColor Yellow  
            Connect-PnPOnline -Url $SiteUrl -Credentials $Creds
            Write-Host "Connection Successfull to site: '$($SiteUrl)'" -ForegroundColor Green              
            GetListFields
        }
        else {
            Write-Host "Source Site URL is empty." -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Error in connecting to Site:'$($SiteUrl)'" $_.Exception.Message -ForegroundColor Red               
    } 
}

Function GetListFields() {
    try {
        $ListName =  Read-Host "Please enter list name"
        if ($ListName) {
            Write-Host "Getting fields from :'$($ListName)'..." -ForegroundColor Yellow  
            $ListFields = Get-PnPField -List $ListName
            Write-Host "Getting fields from :'$($ListName)' Successfully!" -ForegroundColor Green  
            foreach ($ListField in $ListFields) {  
                $global:listFields += New-Object PSObject -Property ([ordered]@{
                        "Title"            = $ListField.Title                           
                        "Type"             = $ListField.TypeAsString                         
                        "Internal Name"    = $ListField.InternalName  
                        "Static Name"      = $ListField.StaticName  
                        "Scope"            = $ListField.Scope  
                        "Type DisplayName" = $ListField.TypeDisplayName                          
                        "Is read only?"    = $ListField.ReadOnlyField  
                        "Unique?"          = $ListField.EnforceUniqueValues  
                        "IsRequired"       = $ListField.Required
                        "IsSortable"       = $ListField.Sortable
                        "Schema XML"       = $ListField.SchemaXml
                        "Description"      = $ListField.Description 
                        "Group Name"       = $ListField.Group   
                    })
            }  
        }
        else {
            Write-Host "List name is empty." -ForegroundColor Red
        }
        BindingtoCSV($global:listFields)
        $global:listFields = @()
    }
    catch {
        Write-Host "Error in getting list fields from :'$($ListName)'" $_.Exception.Message -ForegroundColor Red               
    } 
    Write-Host "Export to CSV Successfully!" -ForegroundColor Green
}

Function BindingtoCSV {
    [cmdletbinding()]
    param([parameter(Mandatory = $true, ValueFromPipeline = $true)] $Global)       
    $global:listFields | Export-Csv $CSVPath -NoTypeInformation -Append            
}

ConnectToSPSite

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]


# [CLI for Microsoft 365](#tab/cli-m365-ps)
```powershell
Function Login {
    Write-Host "Connecting to Tenant Site" -f Yellow   
    $m365Status = m365 status

    if ($m365Status -match "Logged Out") {
      m365 login
    }
}

Function ExportListFields {
    $webUrl = Read-Host "Please enter Site URL"
    $listTitle = Read-Host "Please enter list name"

    try {
        $listFields = m365 spo field list --webUrl $webUrl --listTitle $listTitle --output json | ConvertFrom-Json

        $listFieldsReports = @()

        foreach ($listField in $listFields) {
            Write-Host "Processing field: $($listField.Title) - $($listField.Id)"
            $field = m365 spo field get --webUrl $webUrl --listTitle $listTitle --id $listField.Id --output json | ConvertFrom-Json
            $listFieldsReports += $field
        }
    
        $dateTime = "_{0:MM_dd_yy}_{0:HH_mm_ss}" -f (Get-Date)
        $csvPath = ".\ListFields" + $dateTime + ".csv"
        $listFieldsReports | ConvertTo-Csv -NoTypeInformation | Out-File -FilePath "SearchResults.csv"
    }
    catch {
        Write-Host "Error in getting list fields: " $_.Exception.Message -ForegroundColor Red                 
    }
}

Login
ExportListFields
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
***

## Contributors

| Author(s) |
|-----------|
| Chandani Prajapati |
| Nanddeep Nachan |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-get-and-export-list-fields" aria-hidden="true" />
