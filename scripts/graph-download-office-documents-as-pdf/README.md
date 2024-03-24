---
plugin: add-to-gallery
---

# Download contents of Document library as PDF

## Summary

Say we have lots of Office documents in a Document library. We need to have copies of the document
stored on a local file share in case of network outages. We want the local copies to be in PDF format so people cant modify them.

This script will download the contents of a document library to a local directory , converting Office Documents to PDF in the process.

# [PnP PowerShell](#tab/pnpps)

```powershell
cls
# The client ID if an Azure AD app registration with graph read all sites app-only permission
# TODO: Enter value
$clientid=''

# The client Secret if an Azure AD app registration with graph read all sites app-only permission
# TODO: Enter value
$clientsecret=''

# The SharePoint tentant
# TODO: Enter value
$tenant="<tenant>.sharepoint.com"

# The azure tenant ID
# TODO: Enter value
$tenantid=""

# The Graph Drive ID found at https://tenant.sharepoint.com/sites/sitename/_api/v2.0/drives
# TODO: Enter value
$driveid=""

# The , three-part, Graph Site ID found at from https://tenant.sharepoint.com/sites/sitename/_api/v2.0/sites/root
# TODO: Enter value
$siteid="tenant.sharepoint.com,049287e5-abd9-472d-828b-a0a591ca2421,4d6b2467-70b2-46c6-a8a1-c8aa40f1bc9a" # from https://tenant.sharepoint.com/sites/sitename/_api/v2.0/sites/root

$filestoconvert='xlsx','docx','pptx'
$uri="https://login.microsoft.com/$tenantid/oauth2/v2.0/token"
$header = @{ ContentType = "application/x-www-form-urlencoded" }
$postbody = @{client_id=$clientid;scope='https://graph.microsoft.com/.default';client_secret=$clientsecret;grant_type='client_credentials'}
$authresponse = Invoke-RestMethod -Uri $uri -Headers $header -Body $postbody -Method Post
$token=$authresponse.access_token
$header = @{ Authorization = "Bearer $($token)" }
$uri = "https://graph.microsoft.com/v1.0/sites/$siteid/drives/$driveid/root/children"
do{
$response = Invoke-RestMethod -Uri $uri -Headers $header `
      -Method Get -ContentType "application/json" 
foreach ($item in $response.value){
   Write-Host $item.name
   if ($item.name.Contains('.')){
   $fname=$item.name.Substring(0,$item.name.LastIndexOf("."))
   $fext=$item.name.Substring($item.name.LastIndexOf(".")+1)
   }else{
    $fname=$item.name
    $fext=''
   }

   if($filestoconvert.Contains($fext.ToLower())){
      $uri = "https://graph.microsoft.com/v1.0/sites/$siteid/drives/$driveid/items/"+$item.id+"/content?format=pdf"
     $outfile = "C:\temp\$fname.pdf"
   } else
   {
      $uri = "https://graph.microsoft.com/v1.0/sites/$siteid/drives/$driveid/items/"+$item.id+"/content"
      $outfile = "C:\temp\"+$item.name
   }
    Invoke-RestMethod -Uri $uri -Headers $header `
      -Method Get -ContentType "application/json" -OutFile $outfile 

}
$uri=$response.'@odata.nextLink'
}while ($uri -ne '')


    # End

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365](#tab/cli-m365-ps)
```powershell
# The Graph Drive ID found at https://tenant.sharepoint.com/sites/sitename/_api/v2.0/drives
# TODO: Enter value
$driveid = ""

# The , three-part, Graph Site ID found at from https://tenant.sharepoint.com/sites/sitename/_api/v2.0/sites/root
# TODO: Enter value
$siteid = "" # from https://tenant.sharepoint.com/sites/sitename/_api/v2.0/sites/root

$m365Status = m365 status
if ($m365Status -match "Logged Out") {
   m365 login
}

$filestoconvert = 'xlsx', 'docx', 'pptx'
$uri = "https://graph.microsoft.com/v1.0/sites/$siteid/drives/$driveid/root/children"
do {
   $response = m365 request --url $uri | ConvertFrom-Json

   foreach ($item in $response.value) {
      Write-Host $item.name
      if ($item.name.Contains('.')) {
         $fname = $item.name.Substring(0, $item.name.LastIndexOf("."))
         $fext = $item.name.Substring($item.name.LastIndexOf(".") + 1)
      }
      else {
         $fname = $item.name
         $fext = ''
      }

      if ($filestoconvert.Contains($fext.ToLower())) {
         $uri = "https://graph.microsoft.com/v1.0/sites/$siteid/drives/$driveid/items/" + $item.id + "/content?format=pdf"
         $outfile = "C:\temp\$fname.pdf"
      }
      else {
         $uri = "https://graph.microsoft.com/v1.0/sites/$siteid/drives/$driveid/items/" + $item.id + "/content"
         $outfile = "C:\temp\" + $item.name
      }
      m365 request --url $uri --filePath $outfile

   }

   $uri = ''
   if ($null -ne $response['@odata.nextLink']){
      $uri = $response['@odata.nextLink']
   }
      
}while ($uri -ne '')
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
***

## Contributors

| Author(s) |
|-----------|
| Russell Gove |
| [Adam Wójcik](https://github.com/Adam-it)|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/graph-download-office-documents-as-pdf" aria-hidden="true" />

