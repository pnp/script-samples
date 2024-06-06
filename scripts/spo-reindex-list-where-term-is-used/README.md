---
plugin: add-to-gallery
---

# Reindex Search index for lists where a specific term is used (when you have renamed the term)

## Summary

Once in a while you might need to rename a term in the term store. This script will help you reindex all lists where the term is used.

![Example Screenshot](assets/example.png)


# [PnP PowerShell](#tab/pnpps)

```powershell

#this is just a sample. In a real world scenario you would probably want to run this using an App registration with the necessary permissions
# in order to be able to search all content in the tenant

#connect to the term store
$spAdminUrl = "https://contoso-admin.sharepoint.com"
if(-not $SPAdminConn)
{
    $SPAdminConn = Connect-PnPOnline -Url $spAdminUrl -Interactive -ReturnConnection
}
$Output = @()
#get all hits on the term guid
$query = "the guid of the term you want to search for"
$hits = Invoke-PnPSearchQuery -Connection $SPAdminConn -Query $query -All 
$hash = @{}
#in order to avoid reindexing the same list multiple times, we will store the list id in a hash table
foreach($hit in $hits.ResultRows)
{
    try 
    {
        $hash.Add($hit["SPWebUrl"], $hit["IdentityListId"])    
    }
    catch 
    {
        <#Do this if a terminating exception happens#>
    }
    
    
}

foreach($siteUrl in $hash.Keys)
{
    try 
    {
        $siteconn = Connect-PnPOnline -Url $siteUrl -Interactive -ReturnConnection
        $list = Get-PnPList -Connection $siteconn -Identity $hash[$siteUrl]
        #reindex the list
        Write-Host "Reindexing $($list.Title) in $($siteUrl)"
        $myObject = [PSCustomObject]@{
            URL     = $siteUrl
            ListName = $list.Title
            Status = "Reindexed"
    
        }        
        $Output+=($myObject)
        Request-PnPReIndexList -Identity $list -Connection $siteconn
            
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
