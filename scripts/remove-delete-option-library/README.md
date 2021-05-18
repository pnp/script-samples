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
***

## Source Credit

Sample first appeared on [Prevent document library deletion | CaPa Creative Ltd](https://capacreative.co.uk/2018/09/17/prevent-document-library-deletion/)

## Contributors

| Author(s) |
|-----------|
| Paul Bullock |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/remove-delete-option-library" aria-hidden="true" />