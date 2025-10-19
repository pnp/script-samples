# Find all Remote Event Receivers in a SharePoint Online site

## Summary

Remote Event Receivers (RERs) are a way to extend the functionality of SharePoint Online by allowing developers to execute custom code in response to specific events that occur within a SharePoint site. However, starting April 2. 2026, Microsoft is deprecating RERs in favor of more modern approaches like Power Automate and webhooks. This script helps administrators identify and manage existing RERs before the deprecation date.

This script will enumerate all Remote Event Receivers in all SharePoint Online site collections and display their properties, such as the event type, the endpoint URL, and the status.


# [PnP PowerShell](#tab/pnpps)

```powershell

$TenantUrl = "https://<tenant>.sharepoint.com/";

# I recommend using app-only authentication for this script
Connect-PnPOnline -Url $TenantUrl -ClientId "<client-id>" -Tenant "<tenant>.onmicrosoft.com" -CertificatePath "<path-to-certificate>" -CertificatePassword (ConvertTo-SecureString "<certificate-password>" -AsPlainText -Force);

$Sites = Get-PnPTenantSite;

$ReceiverInfo = @();


foreach ($Site in $Sites) {
    Connect-PnPOnline -Url $Site.Url;
    Write-Host "Processing site: $($Site.Url)" -ForegroundColor Cyan;
    $Lists = Get-PnPList;
    foreach ($List in $Lists) {
        Write-Host "`t>Processing list: $($List.Title)" -ForegroundColor Yellow;
        $EventReceivers = Get-PnPEventReceiver -List $List;

        foreach ($Receiver in $EventReceivers) {
            if ($null -ne $Receiver.ReceiverUrl) {
                $UrlObject = [System.Uri]::new($Receiver.ReceiverUrl);
                if (-not $UrlObject.IsBaseOf("svc.ms")) {
                    Write-Host "`t`t>Found remote event receiver: $($Receiver.ReceiverName) at $($Receiver.ReceiverUrl)" -ForegroundColor Green;
                    $ReceiverInfo += [PSCustomObject]@{
                        SiteUrl      = $Site.Url;
                        ListTitle    = $List.Title;
                        ReceiverName = $Receiver.ReceiverName;
                        ReceiverUrl  = $Receiver.ReceiverUrl;
                    };
                }
            }
        }
    }
}

$ReceiverInfo | Export-Csv -Path "RemoteEventReceivers.csv" -NoTypeInformation; 

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Contributors

| Author(s) |
|-----------|
| Dan Toft |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-remote-event-receivers" aria-hidden="true" />