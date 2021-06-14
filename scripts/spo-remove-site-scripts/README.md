---
plugin: add-to-gallery
---

# Delete custom SharePoint site scripts

## Summary

Site designs and especially site scripts can be something that ends up just hanging around in your tenant for a long time even though you no longer need them for anything. Use the scripts below to get rid of them. You might also find some site scripts that are not linked to any site design and hence never get executed!
 
[!INCLUDE [Delete Warning](../../docfx/includes/DELETE-WARN.md)]

# [CLI for Microsoft 365 with PowerShell](#tab/cli-m365-ps)
```powershell
$sparksjoy = "Project Site", "Issues List"
$siteScripts = m365 spo sitescript list -o json | ConvertFrom-Json
$siteScripts = $siteScripts | where {  -not ($sparksjoy -contains $_.Title)}
if ($siteScripts.Count -eq 0) { break }
$siteScripts | Format-Table Title, SiteScriptIds, Description
Read-Host -Prompt "Press Enter to start deleting (CTRL + C to exit)"
$progress = 0
$total = $siteScripts.Count
foreach ($siteScript in $siteScripts)
{
  $progress++
  Write-Host $progress / $total":" $siteScript.Title
  m365 spo sitescript remove -i $siteScript.Id --confirm
}
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
 
# [Microsoft 365 CLI with Bash](#tab/m365cli-bash)
```bash
#!/bin/bash

# requires jq: https://stedolan.github.io/jq/

sparksjoy=("Project Site"  "Issues List")
sitesscriptstoremove=()
while read script; do
 scriptTitle=$(echo ${script} | jq -r '.Title')
  exists=true
  for keep in "${sparksjoy[@]}"; do
    if [ "$keep" == "$scriptTitle" ] ; then
      exists=false
      break
    fi
  done
  if [ "$exists" = true ]; then
    echo $scriptTitle
    sitesscriptstoremove+=("$script")
  fi

done < <(m365 spo sitescript list -o json | jq -c '.[]')

if [ ${#sitesscriptstoremove[@]} = 0 ]; then
  exit 1
fi

echo "Press Enter to start deleting (CTRL + C to exit)"
read foo

for script in "${sitesscriptstoremove[@]}"; do
  scriptTitle=$(echo ${script} | jq -r '.Title')
  scriptId=$(echo ${script} | jq -r '.Id')
  echo "Deleting Site script..."  $scriptTitle
  m365 spo sitescript remove --id $scriptId --confirm
done
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

# [SPO Management Shell](#tab/spoms-ps)

```powershell
Connect-SPOService "https://contoso-admin.sharepoint.com"

$keepThese = "Base Site Settings", "English Region", "Standard Site Columns", "Standard Libraries"
$siteScripts = Get-SPOSiteScript
$siteScripts = $siteScripts | Where-Object { -not ($keepThese -contains $_.Title)}

if ($siteScripts.Count -eq 0) { break }

$siteScripts | Format-Table Title, SiteScriptIds, Description
Read-Host -Prompt "Press Enter to start deleting (CTRL + C to exit)"
$progress = 0
$total = $siteScripts.Count

foreach ($siteScript in $siteScripts)
{
  $progress++
  Write-Host $progress / $total":" $siteScript.Title
  Remove-SPOSiteScript $siteScript.Id
}
```
[!INCLUDE [More about SPO Management Shell](../../docfx/includes/MORE-SPOMS.md)]

***

## Source Credit

Sample first appeared on [Delete custom SharePoint site scripts | CLI for Microsoft 365](https://pnp.github.io/cli-microsoft365/sample-scripts/spo/remove-site-scripts/)

## Contributors

| Author(s) |
|-----------|
| Laura Kokkarinen |
| Paul Bullock |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/spo-remove-site-scripts" aria-hidden="true" />