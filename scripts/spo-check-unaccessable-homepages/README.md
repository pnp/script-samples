---
plugin: add-to-gallery
---

# Scan for potential inaccessible site collection homepages

## Summary

Sample looks for site collections where the default page has custom permissions and outputs to a CSV file

![Example Screenshot](assets/example.png)


# [PnP PowerShell](#tab/pnpps)

```powershell

$SPOAdminUrl = "The URL of your tenant SharePoint admin center"


if(-not $adminConn)
{
    $adminConn = Connect-PnPOnline -Url $SPOAdminUrl -Interactive -ReturnConnection
}

$allRelevantSites = Get-PnPTenantSite -Connection $adminConn | Where-Object { $_.Template -like "STS#3" } #or similar filter as per your requirement
$allRelevantSites.Count

#output to an arraylist
$output = New-Object System.Collections.ArrayList
foreach($site in $allRelevantSites)
{
    try 
    {
        $localconn = Connect-PnPOnline -Url $site.Url -Interactive  -WarningAction SilentlyContinue -ErrorAction Stop -ReturnConnection
        Write-Host "Processing $($site.Url)" -ForegroundColor Green
        $sitepagesList = Get-PnPList -Identity "SitePages" -Connection $localconn
        $defaultpageUrl  = Get-PnPHomePage -Connection $localconn
        $defaultpageUrl = $defaultpageUrl.Substring($defaultpageUrl.IndexOf("/")+1)
        $defaultpageItem = Get-PnPListItem -List $sitepagesList  -Connection $localconn | Where-Object { $_.FieldValues.FileLeafRef -eq $defaultpageUrl }   
        
        
        #check if the page has custom permissions as this can cause issues 
        $permissions = Get-PnPListItemPermission -List $sitepagesList -Identity $defaultpageItem -Connection $localconn
        
        $output.Add([PSCustomObject]@{
            SiteUrl = $site.Url
            DefaultPage = $defaultpageUrl
            PagePermissions = $defaultpageItem.HasUniqueRoleAssignments
            ErrorMsg = ""
        }) | Out-Null


    }
    catch 
    {
    
        $output.Add([PSCustomObject]@{
            SiteUrl = $site.Url
            DefaultPage = $defaultpage
            PagePermissions = $defaultpageItem.HasUniqueRoleAssignments
            ErrorMsg = $_.Exception.Message
        }) | Out-Null
        
    }
    
    
}

$output | Export-Csv -Path "C:\temp\DefaultHomePageAccessablityRisk.csv" -NoTypeInformation -Force -Encoding utf8BOM -Delimiter "|"


```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***


## Contributors

| Author(s) |
|-----------|
| Kasper Larsen |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-check-unaccessable-homepages" aria-hidden="true" />
