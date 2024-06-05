---
plugin: add-to-gallery
---

# Reindex Search index for lists where a specific term is used (when you have renamed the term)

> [!Note]
> This is a submission helper template please find the [contributor guidance](/docfx/contribute.md) to help you write this scenario.

## Summary

Once in a while you might need to rename a term in the term store. This script will help you reindex all lists where the term is used.

![Example Screenshot](assets/example.png)


# [PnP PowerShell](#tab/pnpps)

```powershell

#this is just a sample. In a real world scenario you would probably want to run this using an App registration with the necessary permissions
# in order to be able to search all content in the tenant

#connect to the term store
$spAdminUrl = "https://[your tenant]-admin.sharepoint.com"
if(-not $SPAdminConn)
{
    $SPAdminConn = Connect-PnPOnline -Url $spAdminUrl -Interactive -ReturnConnection
}
$Output = @()
#get all hits on the term guid
$termId = "the guid of the term you want to search for"
$query = $termId
# find the unique LISTS where the term is used and reindex them
$hits = Invoke-PnPSearchQuery -Connection $SPOAdminConn -Query $termId -All -CollapseSpecification "ListId:1"

foreach($hit in $hits.ResultRows)
{
    try 
    {
        Write-Host "Term $($termId) is used in $($hit["SPWebUrl"]) - $($hit["Title"])"
        $siteUrl = $hit["SPWebUrl"]
        $listId = $hit["IdentityListId"]
        $siteConn = Connect-PnPOnline -Url $siteUrl -Interactive -ReturnConnection
        $list = Get-PnPList -Connection $siteConn -Identity $listId
        Write-Host "Reindexing $($list.Title) in $($siteUrl)"
        $myObject = [PSCustomObject]@{
            URL     = $siteUrl
            ListName = $list.Title
            Status = "Reindexed"
    
        }        
        $Output+=($myObject)
        Request-PnPReIndexList -Identity $list -Connection $siteConn
    }
    catch 
    {
        $myObject = [PSCustomObject]@{
            URL     = $siteUrl
            ListName = $list.Title
            Status = "Failed $($_.Exception.Message)"    
        }        
        $Output+=($myObject)
    }
}

$Output | Export-Csv -Path "C:\temp\ReindexResults.csv" -Encoding UTF8 -Delimiter "|" -Force

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***


## Contributors

| Author(s) |
|-----------|
| Kasper Larsen |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-reindex-list-where-term-is-used" aria-hidden="true" />
