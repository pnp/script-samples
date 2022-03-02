---
plugin: add-to-gallery
---

# Delete custom color themes from SharePoint

## Summary

Have you been creating a lot of beautiful themes lately and testing them in your dev tenant, but don’t want to keep them anymore? If yes, then this PowerShell script is for you.
 
 
# [CLI for Microsoft 365 with PowerShell](#tab/cli-m365-ps)
```powershell
$sparksjoy = "Cat Lovers United", "Multicolored theme"
$themes = m365 spo theme list -o json | ConvertFrom-Json
$themes = $themes | where {-not ($sparksjoy -contains $_.name)}
$themes | Format-Table name
if ($themes.Count -eq 0) { break }
Read-Host -Prompt "Press Enter to start deleting (CTRL + C to exit)"
$progress = 0
$total = $themes.Count
foreach ($theme in $themes)
{
  $progress++
  write-host $progress / $total":" $theme.name
  m365 spo theme remove --name "$($theme.name)" --confirm
}
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
 
# [Microsoft 365 CLI with Bash](#tab/m365cli-bash)
```bash
#!/bin/bash

# requires jq: https://stedolan.github.io/jq/

sparksjoy=("Cat Lovers United" "Multicolored theme")
themestoremove=()
while read theme; do
  exists=false
  for keep in "${sparksjoy[@]}"; do
    if [ "$keep" == "$theme" ] ; then
      exists=true
      break
    fi
  done
  if [ "$exists" = false ]; then
    themestoremove+=("$theme")
  fi
done < <(m365 spo theme list -o json | jq -r '.[].name')

if [ ${#themestoremove[@]} = 0 ]; then
  exit 1
fi

printf '%s\n' "${themestoremove[@]}"
echo "Press Enter to start deleting (CTRL + C to exit)"
read foo

for theme in "${themestoremove[@]}"; do
  echo "Deleting $theme..."
  m365 spo theme remove --name "$theme" --confirm
done
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
***

## Source Credit

Sample first appeared on [Delete custom color themes from SharePoint | CLI for Microsoft 365](https://pnp.github.io/cli-microsoft365/sample-scripts/spo/remove-custom-themes/)

## Contributors

| Author(s) |
|-----------|
| Laura Kokkarinen |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-remove-custom-themes" aria-hidden="true" />
