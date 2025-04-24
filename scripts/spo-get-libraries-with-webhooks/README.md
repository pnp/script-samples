

# Scan libraries for webhook and export to csv

## Summary

As part of the the pre migration assessment, it is important to identify all libraries that have webhooks configured. This script will scan all libraries in a site collection and export the libraries that have webhooks configured to a csv file.

![Example Screenshot](assets/example.png)


# [PnP PowerShell](#tab/pnpps)

```powershell


#use this function to get the sites you want to check
function GetSitesToCheck 
{
    #$allsites = Get-PnPTenantSite -Connection $adminConn -Filter "Url -like 'https://contoso.sharepoint.com/'"  -ErrorAction Stop
    $allsites = Get-PnPTenantSite -Connection $adminConn -ErrorAction Stop
    return $allsites
}


$adminUrl = "https://contoso-admin.sharepoint.com"
$PnPClientId = "Your PnP Client ID"
$adminConn = Connect-PnPOnline -Url $adminUrl -Interactive -ClientId $PnPClientId
$outputPath = "C:\temp\" 
$sites = GetSitesToCheck
$output = @()
foreach ($site in $sites) 
{
    $siteUrl = $site.Url
    $siteConn = Connect-PnPOnline -Url $siteUrl -Interactive -ClientId $PnPClientId
    $libraries = Get-PnPList  | Where-Object {$_.BaseType -eq "DocumentLibrary"}
    foreach ($library in $libraries) 
    {
        $webhooks = Get-PnPWebhookSubscription -List $library.Title
        foreach ($webhook in $webhooks)
        {
            Write-Host "Library $($library.Title) in site $($site.Title) has $($webhooks.Count) webhooks"
            $output += [PSCustomObject]@{
                SiteUrl = $siteUrl
                SiteTitle = $site.Title
                LibraryTitle = $library.Title
                WebhookId = $webhook.Id
                WebhookExpirationDateTime = $webhook.ExpirationDateTime
                WebhookNotificationUrl = $webhook.NotificationUrl
                WebhookResource = $webhook.Resource
                WebhookClientState = $webhook.ClientState
            }
        }
    }
}

$output | Export-Csv -Path "$outputPath\Webhooks.csv" -Encoding utf8BOM -Delimiter "|" -Force;


```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***


## Contributors

| Author(s) |
|-----------|
| Kasper Larsen |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-get-libraries-with-webhooks" aria-hidden="true" />
