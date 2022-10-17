---
plugin: add-to-gallery
---

# Delete all (non-group connected) modern SharePoint sites

## Summary

When you delete Microsoft 365 groups, the modern group-connected team sites get deleted with them. The script below handles the remaining modern sites: communication sites and groupless team sites.
 
[!INCLUDE [Delete Warning](../../docfx/includes/DELETE-WARN.md)]

# [CLI for Microsoft 365 using PowerShell](#tab/cli-m365-ps)
```powershell
$sparksjoy = "Cat Lovers United", "Extranet", "Hub"
$sites = m365 spo site classic list -o json |ConvertFrom-Json
$sites = $sites | where {  $_.template -eq "SITEPAGEPUBLISHING#0" -or $_.template -eq "STS#3" -and -not ($sparksjoy -contains $_.Title)}
if ($sites.Count -eq 0) { break }
$sites | Format-Table Title, Url, Template
Read-Host -Prompt "Press Enter to start deleting (CTRL + C to exit)"
$progress = 0
$total = $sites.Count
foreach ($site in $sites)
{
    $progress++
    write-host $progress / $total":" $site.Title
    write-host $site.Url
    m365 spo site classic remove --url $site.Url
}
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

# [CLI for Microsoft 365 using Bash](#tab/cli-m365-bash)

```bash
#!/bin/bash

# requires jq: https://stedolan.github.io/jq/

sparksjoy=("Communication site" "Comm Site" "Hub")
sitestoremove=()
while read site; do
 siteTitle=$(echo ${site} | jq -r '.Title')
 echo $siteTitle
  exists=true
  for keep in "${sparksjoy[@]}"; do
    echo $keep
    if [ "$keep" == "$siteTitle" ] ; then
    echo "matched"
      exists=false
      break
    fi
  done
  if [ "$exists" = true ]; then
    sitestoremove+=("$site")
  fi

done < <(m365 spo site classic list -o json | jq -c '.[] | select(.Template == "SITEPAGEPUBLISHING#0" or .Template == "STS#3")')

if [ ${#sitestoremove[@]} = 0 ]; then
  exit 1
fi

printf '%s\n' "${sitestoremove[@]}"
echo "Press Enter to start deleting (CTRL + C to exit)"
read foo

for site in "${sitestoremove[@]}"; do
   siteUrl=$(echo ${site} | jq -r '.Url')
  echo "Deleting site..."
  echo $siteUrl
   m365 spo site classic remove --url $siteUrl
done

```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

***

## Source Credit

Sample first appeared on [Delete all (non-group connected) modern SharePoint sites | CLI for Microsoft 365](https://pnp.github.io/cli-microsoft365/sample-scripts/spo/delete-non-group-connected-modern-sites/)

## Contributors

| Author(s) |
|-----------|
| Laura Kokkarinen |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-delete-non-group-connected-modern-sites" aria-hidden="true" />
