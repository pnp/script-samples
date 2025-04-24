

# Replace specific users in the People web part

## Summary

When people leave the company or assigned new responsibilities, you might want to replace them in the People web part with another user. This script will help you do that.

![Example Screenshot](assets/example.png)


# [PnP PowerShell](#tab/pnpps)

```powershell

#define which site collections you wish to iterate
$tenentUrl = "https://contoso.sharepoint.com"
if(-not $conn)
{
    $conn = Connect-PnPOnline -Url $tenentUrl -Interactive -ReturnConnection
}

$relevantsitecollections = Get-PnPTenantSite -Connection $conn | Where-Object {$_.Url -eq "https://contoso.sharepoint.com/sites/HubsiteA"}

$SPAdminUrl = "https://contoso-admin.sharepoint.com/"
if(-not $SPAdminUrl)
{
    $spAdminConn = Connect-PnPOnline -Url $SPAdminUrl -Interactive -ReturnConnection
}


#replacementlist is a hashtable where the key is the old user and the value is the new user
$replacementlist = @{"i:0#.f|membership|pattif@tcwlv.onmicrosoft.com" = "i:0#.f|membership|adelev@tcwlv.onmicrosoft.com"}
    
$Output = @()

function UpdateWebPartIfRequired ($theWebpart, $page, $pageUrl)
{
    $props =  $thewebpart.PropertiesJson | ConvertFrom-Json
    $anyUpdates= $false
    foreach($person in $props.persons)
    {
        $personId = $person.Id
        if($replacementlist.ContainsKey($personId))
        {
            $anyUpdates = $true
            $newPersonId = $replacementlist[$personId]
            $person.Id = $newPersonId

            $myObject = [PSCustomObject]@{
            URL     = $tenentUrl+$page["FileRef"]
            errorcode = "User $personId has been replaced with $newPersonId"
            }        
            $Output+=($myObject)
            
        }
    }
    if($anyUpdates)
    {
        $thewebpart.PropertiesJson = $props | ConvertTo-Json
        $null = $page.Save()        
        $null = $page.Publish()
    }
    
}
foreach($site in  $relevantsitecollections)
{
    $sitecollectionUrl = $site.Url
    Write-Host "Url =  $sitecollectionUrl" -ForegroundColor Yellow
    
    $localConn = Connect-PnPOnline -Url $sitecollectionUrl -Interactive -ReturnConnection
    $pages = Get-PnPListItem -List "sitePages" -Connection $localConn

    foreach($page in $pages)
    {
        try 
        {
            $fullUrl = $tenentUrl+$page["FileRef"]
            Write-Host " Page = $fullUrl" -ForegroundColor Green
            $webpartpage = Get-PnPClientSidePage -Identity $page["FileLeafRef"] -ErrorAction Stop -Connection $localConn
            $webparts = $webpartpage.controls | Where-Object {$_.PropertiesJson -like "*persons*"}
            foreach($webpart in $webparts)
            {
                UpdateWebPartIfRequired -theWebpart $webpart -page $webpartpage -pageUrl $fullUrl
            }
        }
        catch 
        {
            $myObject = [PSCustomObject]@{
                URL     = $tenentUrl+$page["FileRef"]
                personid = ""
                personupn = ""
                errorcode = $_.Exception.Message

            }        
            $Output+=($myObject)
        }
    }
}
$Output | Export-Csv  -Path c:\temp\PeopleWebPartHasBeenUpdated.csv -Encoding utf8NoBOM -Force  -Delimiter "|"
  

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***


## Contributors

| Author(s) |
|-----------|
| Kasper Larsen |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-replace-people-in-people-web-part" aria-hidden="true" />
