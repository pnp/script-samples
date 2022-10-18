---
plugin: add-to-gallery
---

# Delete orphaned temporary site pages

## Summary

Locate, take ownership of, and delete temporary orphaned pages from /SitePages library.

[!INCLUDE [Delete Warning](../../docfx/includes/DELETE-WARN.md)]

# [PnP PowerShell](#tab/pnpps)
```powershell

$SiteURL = "https://{tenant}.sharepoint.com/sites/{site}"
$ListName = "Site Pages"

Disconnect-PnPOnline
#use a login with Site Collection Administrator or Owner permissions
Connect-PnPOnline -Url $SiteURL -Interactive
$context = Get-PnPContext

$list = Get-PnPList -Identity $ListName

$context.Load($list)
Invoke-PnPQuery

$checkedOutFiles = $list.GetCheckedOutFiles()
$context.Load($checkedOutFiles)
Invoke-PnPQuery

$filesProcessed = @()

foreach($checkedOutFile in $CheckedOutFiles) {
    $fileServerRelativeUrl = [string]::Concat($list.ParentWebUrl, $checkedOutFile.ServerRelativePath.DecodedUrl.Replace($list.ParentWebUrl, ""))

    #8 random characters seem to be used for temporary page names.  Be careful - if a valid page was created with valid 8 character name, that page would be deleted as well.  TODO: figure out a way to avoid valid pages?
    $tempPageSampleUrlForThisSite = $list.RootFolder.ServerRelativeUrl + "/zz5yfe8u.aspx"

    if ($fileServerRelativeUrl.Length -ne $tempPageSampleUrlForThisSite.Length) {
        Write-Host "Skipping $fileServerRelativeUrl" -ForegroundColor Green
    } else {
        $checkedOutFile.TakeOverCheckOut()
        Invoke-PnPQuery

        $file = $checkedOutFile.Context.Web.GetFileByServerRelativeUrl($fileServerRelativeUrl)

        $context.Load($file)
        Invoke-PnPQuery

        $filesProcessed += [PSCustomObject]@{
            ServerRelativeUrl = $fileServerRelativeUrl
            Exists = $file.Exists
            UIVersionLabel = $file.UIVersionLabel
        }

        $file.DeleteObject()
        $context.ExecuteQuery()
        Write-host "." -NoNewline
    }
}


$nowString = [System.DateTime]::Now.ToString("yyyyMMdd_hhmm")
$path = "$env:USERPROFILE\Desktop\PS1\Get-FilesWithNoCheckin_$nowString.csv"
$filesProcessed | select ServerRelativeUrl, Exists, UIVersionLabel | Export-Csv $path -NoTypeInformation
```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365 using PowerShell](#tab/cli-m365-ps)
```powershell

$SiteURL = "https://{tenant}.sharepoint.com/sites/{site}"
$listName = "Site Pages"

$m365Status = m365 status
if ($m365Status -match "Logged Out") {
  Write-Host "Logging in the User!"
  m365 login --authType browser
}

$filesProcessed = @()

$pages = m365 spo page list -u $SiteURL | ForEach-Object { $_.replace("Id", "_Id") } | ConvertFrom-Json
$list =  m365 spo list get -u $SiteURL -t $listName | ConvertFrom-Json
$checkedOutPages = $pages | ? CheckOutType -eq 0

foreach ($page in $checkedOutPages){
 $fileServerRelativeUrl = [string]::Concat($list.ParentWebUrl, $page.ServerRelativePath.DecodedUrl.Replace($list.ParentWebUrl, ""))

    #8 random characters seem to be used for temporary page names.  Be careful - if a valid page was created with valid 8 character name, that page would be deleted as well.  TODO: figure out a way to avoid valid pages?
    $tempPageSampleUrlForThisSite = $list.RootFolder.ServerRelativeUrl  + "/zz5yfe8u.aspx"

    if ($fileServerRelativeUrl.Length -ne $tempPageSampleUrlForThisSite.Length) {
        Write-Host "Skipping $fileServerRelativeUrl" -ForegroundColor Green
    } else {
        if(!$page.IsPageCheckedOutToCurrentUser){
        #take over check out
            m365 spo file checkin  --webUrl $SiteUrl --fileUrl $page.ServerRelativeUrl
            m365 spo file checkout  --webUrl $SiteUrl --fileUrl $page.ServerRelativeUrl
       }

 $filesProcessed += [PSCustomObject]@{
            ServerRelativeUrl = $page.ServerRelativeUrl
            Exists = $page.Exists
            UIVersionLabel = $page.UIVersionLabel
        }
  m365 spo page remove -u $SiteURL -n $page.Name --confirm
 }
}

$nowString = [System.DateTime]::Now.ToString("yyyyMMdd_hhmm")
$path = "$env:USERPROFILE\Desktop\PS1\Get-FilesWithNoCheckin_$nowString.csv"
$filesProcessed | select ServerRelativeUrl, Exists, UIVersionLabel | Export-Csv $path -NoTypeInformation

## Disconnect the context  
m365 logout  
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
***

## Contributors

| Author(s) |
|-----------|
| [Brian P. McCullough](https://github.com/brianpmccullough) |
| [Reshmee Auckloo](https://github.com/reshmee011)|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-delete-orphaned-temporary-sitepages" aria-hidden="true" />

