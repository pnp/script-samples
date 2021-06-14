---
plugin: add-to-gallery
---

# Delete custom SharePoint site designs

## Summary

Site designs and especially site scripts can be something that ends up just hanging around in your tenant for a long time even though you no longer need them for anything. Use the scripts below to get rid of them. You might also find some site scripts that are not linked to any site design and hence never get executed!
 
[!INCLUDE [Delete Warning](../../docfx/includes/DELETE-WARN.md)]

# [CLI for Microsoft 365 with PowerShell](#tab/cli-m365-ps)
```powershell
$sparksjoy = "Cat Lovers United", "Multicolored theme"
$sitedesigns = m365 spo sitedesign list -o json | ConvertFrom-Json
$sitedesigns = $sitedesigns | where {-not ($sparksjoy -contains $_.Title)}
$sitedesigns | Format-Table Title, SiteScriptIds, Description
if ($sitedesigns.Count -eq 0) { break }
Read-Host -Prompt "Press Enter to start deleting (CTRL + C to exit)"
$progress = 0
$total = $sitedesigns.Count
foreach ($sitedesign in $sitedesigns)
{
  $progress++
  write-host $progress / $total":" $sitedesign.Title
  m365 spo sitedesign remove --id "$($sitedesign.Id)" --confirm
}
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
 
# [Microsoft 365 CLI with Bash](#tab/m365cli-bash)
```bash
#!/bin/bash

# requires jq: https://stedolan.github.io/jq/

sparksjoy=("Cat Lovers United" "Multicolored theme")
sitedesignstoremove=()
while read sitedesign; do
  exists=false
  designinfo=(${sitedesign//;/ })
  for keep in "${sparksjoy[@]}"; do
    if [ "$keep" == "${designinfo[0]}" ] ; then
      exists=true
      break
    fi
  done
  if [ "$exists" = false ]; then
    sitedesignstoremove+=("$sitedesign")
  fi
done < <(m365 spo sitedesign list -o json | jq -r '.[].Title + ";" + .[].Id')

if [ ${#sitedesignstoremove[@]} = 0 ]; then
  exit 1
fi

printf '%s\n' "${sitedesignstoremove[@]}"
echo "Press Enter to start deleting (CTRL + C to exit)"
read foo

for sitedesign in "${sitedesignstoremove[@]}"; do
  designinfo=(${sitedesign//;/ })
  echo "Deleting ${designinfo[0]}..."
  m365 spo sitedesign remove --id "${designinfo[1]}" --confirm
done
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

# [SPO Management Shell](#tab/spoms-ps)
```powershell
Connect-SPOService "https://contoso-admin.sharepoint.com"

$keepThese = "Register the new site", "Corporate Basic Site", "Corporate Internal Site"
$siteDesigns = Get-SPOSiteDesign
$siteDesigns = $siteDesigns | Where-Object { -not ($keepThese -contains $_.Title)}

if ($siteDesigns.Count -eq 0) { break }

$siteDesigns | Format-Table Title, SiteScriptIds, Description
Read-Host -Prompt "Press Enter to start deleting (CTRL + C to exit)"
$progress = 0
$total = $siteDesigns.Count

foreach ($siteScript in $siteDesigns)
{
  $progress++
  Write-Host $progress / $total":" $siteScript.Title
  Remove-SPOSiteDesign $siteScript.Id
}
```
[!INCLUDE [More about SPO Management Shell](../../docfx/includes/MORE-SPOMS.md)]

***

## Source Credit

Sample first appeared on [Delete custom SharePoint site designs | CLI for Microsoft 365](https://pnp.github.io/cli-microsoft365/sample-scripts/spo/remove-site-designs/)

## Contributors

| Author(s) |
|-----------|
| Laura Kokkarinen |
| Paul Bullock |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/spo-remove-site-designs" aria-hidden="true" />