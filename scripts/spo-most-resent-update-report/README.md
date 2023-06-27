---
plugin: add-to-gallery
---

# Generate a csv report for a selection of site collections showing the time of the most resent update by any user

> [!Note]
> This is a submission helper template please find the [contributor guidance](/docfx/contribute.md) to help you write this scenario.

## Summary


![Example Screenshot](assets/example.png)


# [PnP PowerShell](#tab/pnpps)

```powershell

$ClientId = "xxxxxxxxx"
$TenantName = "contoso.onmicrosoft.com"
$thumbprint = "1234567890"
$SharePointAdminSiteURL = "https://contoso-admin.sharepoint.com"
$conn = Connect-PnPOnline -Url $adminSiteURL -ClientId $ClientId -Tenant $TenantName -Thumbprint $thumbprint -ReturnConnection
$UsageDays = 180

$accessToken = Get-PnPAccessToken -Connection $conn
$header = @{
    "Content-Type" = "application/json"
    Authorization = "Bearer $accessToken"
    }

#call graph getSharePointSiteUsageDetail
$GraphUrl = "https://graph.microsoft.com/v1.0/reports/getSharePointSiteUsageDetail(period='D$($UsageDays)')"
$UsageData = Invoke-RestMethod -Uri $GraphUrl -Method Get -Headers $header
$UsageDataAsObject = $UsageData | ConvertFrom-Csv

function GetUsageDatoForSiteCollection ($url)
{
    foreach($item in $UsageDataAsObject)
    {
        if($item."Site Url" -eq $url)
        {
            return $item
        }
    }
    return $null
}


$arrayList = New-Object System.Collections.ArrayList
$allsitecollections = Get-PnPTenantSite -Connection $conn
foreach($site in $allsitecollections)
{
    #get last item user modified date
    $localconn = Connect-PnPOnline -Url $site.Url -ClientId $ClientId -Tenant $TenantName -Thumbprint $thumbprint -ReturnConnection
    $token = Get-PnPAccessToken -Connection $localconn
    try {
        $web = Get-PnPWeb -Connection $localconn  -ErrorAction Stop
        $lastmod = Get-PnPProperty -ClientObject $web -Property LastItemUserModifiedDate -Connection $localconn   
        
        $object = New-Object PSObject
        $object | Add-Member -MemberType NoteProperty -Name "SiteUrl" -Value $site.Url
        $object | Add-Member -MemberType NoteProperty -Name "LastItemUserModifiedDate" -Value $lastmod.Date
        
        
        $UsageDataForSiteCollection = getUsageDatoForSiteCollection $site.Url
        If($UsageDataForSiteCollection -eq $null -or $UsageDataForSiteCollection.'Last Activity Date' -eq "")
        {
            Write-Host "No usage data for site collection $($site.Url) for the last $UsageDays days"
            $object | Add-Member -MemberType NoteProperty -Name "Last Activity Date (Graph)" -Value "No usage data for the last $UsageDays days" 
        }
        else 
        {
            $object | Add-Member -MemberType NoteProperty -Name "Last Activity Date (Graph)" -Value $UsageDataForSiteCollection.'Last Activity Date'
        }
        $arrayList.add( $object) | Out-Null
    }
    catch 
    {
        Write-Host $_.Exception.Message
    }
}
$arrayList | Export-Csv -Path "C:\temp\LastActivity.csv"  -Force -Delimiter "|" -Encoding utf8


```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***


## Contributors

| Author(s) |
|-----------|
| Kasper Larsen |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-most-resent-update-report" aria-hidden="true" />
