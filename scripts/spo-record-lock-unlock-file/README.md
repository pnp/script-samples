

# Lock and Unlock a file leveraging Microsoft Graph API through PnP PowerShell

## Summary

This script shows how to lock and unlock a file which is a record in SharePoint Online using the Microsoft Graph API through PnP PowerShell. The script retrieves the drive id and drive item id before calling the endpoint to lock or unlock a file.

# [PnP PowerShell](#tab/pnpps)

```powershell
$siteUrl = Read-Host -Prompt "Enter site collection URL";
$list = Read-Host -Prompt "Enter library name";
$itemid = Read-Host -Prompt "Enter file id"; 
$setLock = Read-Host -Prompt "Enter Yes or No for lock or unlock the file"; 


function Get-UrlComponents {
    param (
        [Parameter(Mandatory = $true)]
        [string] $fullPath
    )
    # Regular expression to match the site, library, and document path
    #In summary, this regex matches a string that starts with a /, followed by three segments separated by /, and then captures the rest of the path. Each segment is captured into a separate group for further processing.
    $regex = "^/([^/]+)/([^/]+)/([^/]+)/(.+)$"

    if ($fullPath -match $regex) {
        $base = $matches[1]
        $siteUrl = "/$base/$($matches[2])"
        $library = $matches[3]
        $documentPath = $matches[4]
        
        return @{
            SiteUrl = $siteUrl
            Library = $library
            DocumentPath = $documentPath
        }
    } else {
        throw "Invalid path format. Expected format: /<base>/<site>/<library>/<document path>"
    }
}

Connect-PnPOnline -url $siteUrl -Interactive
#get site id
# Extract the domain and site name
$uri = New-Object System.Uri($siteurl)
$domain = $uri.Host
$siteName = $uri.AbsolutePath
$RestMethodUrl = "v1.0/sites/$($domain):$($siteName)?$select=id"
$site = (Invoke-PnPGraphMethod -Url $RestMethodUrl -Method Get -ConsistencyLevelEventual)
$siteId = $site.id
#get drive id
 $url = 'v1.0/drives/'+$driveId+'/root:/'+$($relativeUrl)+'?$select=id'
$drives = (Invoke-PnPGraphMethod -Url "v1.0/sites/${siteId}/drives?$select=webUrl,id" -Method Get).Value


#filter $drives by weburl matches $_listUrl
$driveId = $drives | Where-Object { $_.name -eq $list} | Select-Object -ExpandProperty id      
$item = Get-PnPListItem -List $list -Id $itemid 
#get drive item id
$path = $item.FieldValues["FileRef"]
$result = Get-UrlComponents -fullPath $path
$url = 'v1.0/drives/' +$driveId+'/root:/'+ $($result.DocumentPath) +'?$select=id'
$driveItemId =(Invoke-PnPGraphMethod -Url $url -Method Get).Id

write-host $driveItemId

$url = 'v1.0/drives/' +$driveId+'/items/'+$driveItemId+'/retentionLabel'
$bSetLock = $SetLock -eq "Yes" ? "true" : "false"

$Payload = @"
{
    "retentionSettings": {
        "isRecordLocked": $bSetLock
    }
}
"@

#unlock the item
Invoke-PnPGraphMethod -Url $url -Method Patch -Content $Payload
```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***

## Source Credit

The script first appeared  ["Get Drive ID and Drive Item ID for File for Further Microsoft Graph Operations using PnP PowerShell"](https://reshmeeauckloo.com/posts/powershell-pnp-graph-getdrive-driveid-for-file//).

## Contributors

| Author(s) |
|-----------|
| [Reshmee Auckloo](https://github.com/reshmee011) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-record-lock-unlock-file" aria-hidden="true" />

