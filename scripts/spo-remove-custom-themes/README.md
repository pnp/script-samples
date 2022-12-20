---
plugin: add-to-gallery
---

# Delete custom color themes from SharePoint

## Summary

Have you been creating a lot of beautiful themes lately and testing them in your dev tenant, but don’t want to keep them anymore? If yes, then this PowerShell script is for you.
 
 
# [PnP PowerShell](#tab/pnpps)

```powershell

$SPOAdmminSite = 'https://contoso-admin.sharepoint.com'
$themesToKeep = "Contoso Explorers", "Multicolored theme"

Connect-PnPOnline -Url $SPOAdmminSite -Interactive
$themes = Get-PnPTenantTheme
$themes = $themes | where {-not ($themesToKeep -contains $_.name)}
$themes | Format-Table name
if ($themes.Count -eq 0) { break }
Read-Host -Prompt "Press Enter to start deleting $($themes.Count) themes (CTRL + C to exit)"
$progress = 0
$total = $themes.Count
foreach ($theme in $themes)
{
  $progress++
  write-host $progress / $total":" $theme.name
  Remove-PnPTenantTheme -Identity "$($theme.name)"
}

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Contributors

| Author(s) |
|-----------|
| [Leon Armston](https://github.com/LeonArmston)|


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-remove-custom-themes" aria-hidden="true" />
