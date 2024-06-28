---
plugin: add-to-gallery
---

# Remove site access requests

## Summary

Sometimes, as a site owner you cannot manage all site access requests for your site. Especially when users request access for specific content on the site (Site page, list etc.) you might prefer to grant access to the entire site.
Use this script to remove site access requests depending on their status.
 
![Example Screenshot](assets/example.png)


# [PnP PowerShell](#tab/pnpps)

```powershell

$siteUrl = "https://contoso.sharepoint.com/sites/DemoSite"

# Request status: 0 - Pending, 1 - Accepted, 3 - Declined
$requestStatus = 0

Connect-PnPOnline -Url $siteUrl -Interactive

$batch = New-PnPBatch
$accessRequestsList = Get-PnPList | Where-Object {$_.Title -eq "Access Requests"}
$itemsToRemove = Get-PnPListItem -List $accessRequestsList -Query "<View><Query><Where><And><Eq><FieldRef Name='Status'/><Value Type='Number'>$requestStatus</Value></Eq><Eq><FieldRef Name='IsInvitation'/><Value Type='Boolean'>0</Value></Eq></And></Where></Query></View>
"
$itemsToRemove | ForEach-Object { 
    Remove-PnPListItem -List $accessRequestsList -Identity $_.Id -Batch $batch
}
Invoke-PnPBatch -Batch $batch

Disconnect-PnPOnline

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]


***

## Contributors

| Author(s) |
|-----------|
| [Aimery Thomas](https://github.com/a1mery)|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-remove-access-requests" aria-hidden="true" />
