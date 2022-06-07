---
plugin: add-to-gallery
---

# Remove delete option on a document library

## Summary

This sample script will show you how to remove the delete option on a document library to prevent users from accidentally deleting libraries if the have the "edit" permission.
The script will not prevent deletions rather, just disable the UI option.

![Example Screenshot](assets/example.png)

# [PnP PowerShell](#tab/pnpps)

```powershell

Connect-PnPOnline -Url "https://<tenant>.sharepoint.com" -Interactive

$list = Get-PnPList -Identity "<list or library>"
$list.AllowDeletion = $false
$list.Update()

Invoke-PnPQuery
Write-Host "Done! :-)" -ForegroundColor Green

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365](#tab/cli-m365-ps)
```powershell

$m365Status = m365 status
if ($m365Status -match "Logged Out") {
    m365 login
}

$site = "<site>"
$list = "<list or library>"

$json = m365 spo list get --title $list --webUrl $site
$json = $json | ConvertFrom-Json
m365 spo list set --webUrl $site --id $json.Id --allowDeletion false
Write-Host "Done! :-)" -ForegroundColor Green

```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
***

## Source Credit

Sample first appeared on [Prevent document library deletion | CaPa Creative Ltd](https://capacreative.co.uk/2018/09/17/prevent-document-library-deletion/)

## Contributors

| Author(s) |
|-----------|
| Paul Bullock |
| [Adam Wójcik](https://github.com/Adam-it)|


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/remove-delete-option-library" aria-hidden="true" />
