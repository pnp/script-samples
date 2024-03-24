---
plugin: add-to-gallery
---

# Scan for potential inaccessible site collection homepages

## Summary

This script sample looks for the site collections where site home page has custom permissions and outputs to a CSV file.

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

# Disconnect SharePoint online connection
Disconnect-PnPOnline
```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365](#tab/cli-m365-ps)

```powershell
#Get Credentials to connect
$m365Status = m365 status
if ($m365Status -match "Logged Out") {
    m365 login
}

$allRelevantSites = m365 spo site list | ConvertFrom-Json | Where-Object { $_.Template -like "STS#3" } #or similar filter as per your requirement
$allRelevantSites.Count

#output to an arraylist
$output = New-Object System.Collections.ArrayList

foreach($site in $allRelevantSites)
{
    try
    {
        Write-Host "Processing $($site.Url)" -ForegroundColor Green
        $webDetails = m365 spo web get --url $site.Url | ConvertFrom-Json
		$defaultpageUrl = $webDetails.WelcomePage
        $defaultpageUrl = $defaultpageUrl.Substring($defaultpageUrl.IndexOf("/")+1)
		$defaultpageItem = m365 spo listitem list --listTitle "Site Pages" --webUrl $site.Url --fields "ID,HasUniqueRoleAssignments,FileLeafRef" --filter "FileLeafRef eq '$($defaultpageUrl)'" | ConvertFrom-Json
		
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

$output | Export-Csv -Path "D:\dtemp\DefaultHomePageAccessablityRisk-CLI.csv" -NoTypeInformation -Force -Encoding utf8BOM -Delimiter "|"

#Disconnect SharePoint online connection
m365 logout
```

[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

***

## Contributors

| Author(s) |
|-----------|
| Kasper Larsen |
| [Ganesh Sanap](https://ganeshsanapblogs.wordpress.com/) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-check-unaccessable-homepages" aria-hidden="true" />
