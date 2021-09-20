---
plugin: add-to-gallery
---

# Add custom client-side web part to modern page

## Summary

You've built an amazing new web part and now you want to programmatically add it to a modern page. This sample helps you add your web part to the page with your custom properties that might be dynamic according to your script.
 
# [CLI for Microsoft 365 using PowerShell](#tab/cli-m365-ps)
```powershell
$site = "https://contoso.sharepoint.com/sites/site1"
$pageName = "AModernPage.aspx"
$webPartId = "af660fc1-c09b-4c15-b093-2b74b047286b"

$choice1 = "Choice 1"
$choice2 = "Choice 2"

# Put all the web part properties in a PowerShell hashtable
$webPartProps = @{
    myChoices              = @($choice1, $choice2);
    description            = 'My "Awesome" web part';
};

# Build JSON string from PowerShell hashtable object
$webPartPropsJson = $webPartProps | ConvertTo-Json -Compress
# Make sure to add the backticks, double the JSON double-quotes and escape double quotes in properties'values
$webPartPropsJson = '`"{0}"`' -f $webPartPropsJson.Replace('\','\\').Replace('"', '""')

m365 spo page clientsidewebpart add -u $site -n $pageName --webPartId $webPartId --webPartProperties $webPartPropsJson
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

# [CLI for Microsoft 365 using Bash](#tab/cli-m365-bash)
```bash
#!/bin/bash
site=https://contoso.sharepoint.com/sites/site1
pageName=AModernPage.aspx
webPartId=af660fc1-c09b-4c15-b093-2b74b047286b

choice1='Choice X'
choice2='Choice Z'
description='My "Super Awesome" web part';
# Build the JSON including your dynamic values with printf
# For each argument that might be dynamic, we escape the double quotes " with \"
# Make sure not to ommit the surrounding back ticks and surrounding double quotes for each arguments
printf -v webPartPropsJson '`{"myChoices":["%s","%s"], "description":"%s"}`' "${choice1//\"/\\\"}" "${choice2//\"/\\\"}" "${description//\"/\\\"}"

m365 spo page clientsidewebpart add -u $site -n $pageName --webPartId $webPartId --webPartProperties $webPartPropsJson
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
***


## Source Credit

Sample first appeared on [Add custom client-side web part to modern page | CLI for Microsoft 365](https://pnp.github.io/cli-microsoft365/sample-scripts/spo/add-custom-clientside-webpart-to-modern-page/)

## Contributors

| Author(s) |
|-----------|
| Yannick Plenevaux |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/spo-add-custom-clientside-webpart-to-modern-page" aria-hidden="true" />