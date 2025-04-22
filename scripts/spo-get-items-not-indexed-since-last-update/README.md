

# Pinpoint the items/docs that hasn't been indexed yet after an update

## Summary

This script will enable you to pinpoint the items/docs that hasn't been indexed yet. This can be a useful tool if it looks like Search is kinda slow, and your results seems wrong.

## Implementation

<!-- - Open your editor of choice aka VS Code -->
- Open VS Code
- Create a new file
- Copy a script  below

# [PnP PowerShell](#tab/pnpps)
```powershell

#purpose  Visit each document and listitem in a Site Collection and verify when this object was crawled
#Autor Kasper Larsen Fellowmind DK


$SiteCollectionUrl = "https://[Tenant].sharepoint.com/sites/[SiteCollection]"
$tenantUrl ="https://[Tenant].sharepoint.com"

Connect-PnPOnline -Url $SiteCollectionUrl -Interactive 
#if there are any subsites you will have to extend the script to handle that

$lists = Get-PnPList 
try
{
    foreach($list in $lists)
    {
        Write-Host $list.Title -ForegroundColor Blue
        $listItems = Get-PnPListItem -List $list -PageSize 500 
        foreach($item in $listItems)
        {
            if($list.BaseType -eq "GenericList")
            {
                $localurl = $tenantUrl + $item.FieldValues["FileDirRef"]+"/DispForm.aspx?ID=" + $item.id
            }
            elseif ($list.BaseType -eq "DocumentLibrary") 
            {
                
                $localurl = $tenantUrl+  $item.FieldValues["FileRef"] 
            
            }    
            $results = Get-PnPSearchCrawlLog -Filter $localurl 
            
            if($results)
            {
                Write-Debug $localurl 
                $lastcrawled = Get-Date -AsUTC
                $lastcrawled = $lastcrawled.AddDays(-100)
                foreach($result in $results)  #not sure if the last in the array always is the most resent, hence the iteration
                {
                    if($result.crawltime -gt $lastcrawled)
                    {
                        $lastcrawled = $result.crawltime
                    }
                }
                $lastModified = $item.FieldValues["Modified"]
                if($lastcrawled -lt $lastModified)
                {
                    #the item has been modified and the crawler hasn't picked it up yet
                    Write-Host "Last crawled $lastcrawled , last updated $lastModified" -ForegroundColor Red
                }
            }
        }
    }
}
catch
{
    write-host $_.Exception.Message 
}

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Contributors

| Author(s) |
|-----------|
| [Kasper Larsen](https://github.com/kasperbolarsen)|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-get-items-not-indexed-since-last-update" aria-hidden="true" />

