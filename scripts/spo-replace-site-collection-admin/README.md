---
plugin: add-to-gallery
---

# Replace site collection admin with another user

## Summary

The script removes a user from a site collection and adds a new one as site collection admin.
 
[!INCLUDE [Delete Warning](../../docfx/includes/DELETE-WARN.md)]

# [CLI for Microsoft 365 with PowerShell](#tab/cli-m365-ps)
```powershell
$userToAdd = "<upnOfUserToAdd>"
$userToRemove = "<upnOfUserToRemove>"
$webUrl = "<spoUrl>"

$m365Status = m365 status
Write-Host $m365Status
if ($m365Status -eq "Logged Out") {
  # Connection to Microsoft 365
  m365 login
  $m365Status = m365 status
}

m365 spo user remove --webUrl $webUrl --loginName "i:0#.f|membership|$userToRemove" --confirm
m365 spo site classic set --url $webUrl --owners $userToAdd
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

***

## Source Credit

Sample first appeared on [Replace site collection admin with another user | CLI for Microsoft 365](https://pnp.github.io/cli-microsoft365/sample-scripts/spo/replace-site-collection-admin/)

## Contributors

| Author(s) |
|-----------|
| Patrick Lamber |
| Inspired By Salaudeen Rajack |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/spo-replace-site-collection-admin" aria-hidden="true" />