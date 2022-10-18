---
plugin: add-to-gallery
---

# Export all site pages details from Site Pages library

## Summary

This sample will export the required site pages information to CSV.

## Implementation

- Open Windows PowerShell ISE
- Create a new file
- Write a script as below,
- First, we will connect to the site from which site we want to get Site Pages library details.
    - Then we will get Site Pages details and export it to CSV.

# [PnP PowerShell](#tab/pnpps)
```powershell
$siteURL = "https://domain.sharepoint.com/"
$username = "username@domain.onmicrosoft.com"
$password = "********"
$secureStringPwd = $password | ConvertTo-SecureString -AsPlainText -Force 
$creds = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secureStringPwd
$dateTime = "_{0:MM_dd_yy}_{0:HH_mm_ss}" -f (Get-Date)
$basePath = "E:\Contribution\PnP-Scripts\Logs\"
$csvPath = $basePath + "\SitePages" + $dateTime + ".csv"
$global:sitePagesCollection = @()

Function Login() {
    [cmdletbinding()]
    param([parameter(Mandatory = $true, ValueFromPipeline = $true)] $creds)     
    Write-Host "Connecting to Site '$($siteURL)'" -f Yellow   
    Connect-PnPOnline -Url $siteURL -Credential $creds
    Write-Host "Connection Successful" -f Green 
}

Function GetSitePagesDetails {    
    try {
        Write-Host "Getting site pages information..."  -ForegroundColor Yellow 
        $sitePages = Get-PnPListItem -List "Site Pages"     
        ForEach ($Page in $sitePages) {
            $sitePagesInfo = New-Object PSObject -Property ([Ordered] @{
                    'ID'               = $Page.ID
                    'Title'            = $Page.FieldValues.Title
                    'Description'      = $Page.FieldValues.Description
                    'Page Layout Type' = $Page.FieldValues.PageLayoutType
                    'FileRef'          = $Page.FieldValues.FileRef  
                    'FileLeafRef'      = $Page.FieldValues.FileLeafRef      
                    'Created'          = Get-Date -Date $Page.FieldValues.Created_x0020_Date -Format "dddd MM/dd/yyyy HH:mm"
                    'Modified'         = Get-Date -Date $Page.FieldValues.Last_x0020_Modified -Format "dddd MM/dd/yyyy HH:mm"
                    'Modified By'      = $Page.FieldValues.Modified_x0020_By
                    'Created By'       = $Page.FieldValues.Created_x0020_By
                    'Author'           = $Page.FieldValues.Author.Email
                    'Editor'           = $Page.FieldValues.Editor.Email
                    'BannerImage Url'  = $Page.FieldValues.BannerImageUrl.Url   
                    'File_x0020_Type'  = $Page.FieldValues.File_x0020_Type   
                })
            $global:sitePagesCollection += $sitePagesInfo
        }
    }
    catch {
        Write-Host "Error in getting site pages:" $_.Exception.Message -ForegroundColor Red                 
    }
    Write-Host "Exporting to CSV..."  -ForegroundColor Yellow 
    $global:SitePagesCollection | Export-Csv $csvPath -NoTypeInformation -Append
    Write-Host "Exported to CSV successfully!"  -ForegroundColor Green	

}

Function StartProcessing {
    Login($creds);
    GetSitePagesDetails
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
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-export-all-site-pages-details" aria-hidden="true" />
