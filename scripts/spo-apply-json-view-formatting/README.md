---
plugin: add-to-gallery
---

# Apply SharePoint JSON View Formatting

## Summary

This sample script shows how to apply SharePoint JSON view formatting using PnP PowerShell and CLI for Microsoft 365.

Scenario inspired from this blog post: [SharePoint Online: Apply JSON View formatting using PnP PowerShell](https://ganeshsanapblogs.wordpress.com/2023/04/01/sharepoint-online-apply-json-view-formatting-using-pnp-powershell/)

![Outupt Screenshot](assets/output.png)

# [PnP PowerShell](#tab/pnpps)

```powershell

# SharePoint online site URL
$siteUrl = "https://contoso.sharepoint.com/sites/SPConnect"

# Display name of SharePoint list
$listName = "Ganesh Sanap Blogs"

# Name of SharePoint list view
$viewName = "All Items"

# JSON to apply to view formatting
$jsonViewFormatting = @'
{
  "$schema": "https://developer.microsoft.com/json-schemas/sp/view-formatting.schema.json",
  "additionalRowClass": "=if([$PublishDate] &lt;= @now &amp;&amp; [$IsPublished] == false, 'sp-field-severity--severeWarning', '')"
}
'@

# Connect to SharePoint online site
Connect-PnPOnline -Url $siteUrl -Interactive

# Apply JSON view formatting
Set-PnPView -List $listName -Identity $viewName -Values @{CustomFormatter = $jsonViewFormatting}

```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365](#tab/cli-m365-ps)

```powershell

# SharePoint online site URL
$siteUrl = "https://contoso.sharepoint.com/sites/SPConnect"

# Display name of SharePoint list
$listName = "Ganesh Sanap Blogs"

# Name of SharePoint list view
$viewName = "All Items"

# JSON to apply to view formatting
$jsonViewFormatting = @'
{
  "$schema": "https://developer.microsoft.com/json-schemas/sp/view-formatting.schema.json",
  "additionalRowClass": "=if([$PublishDate] &lt;= @now &amp;&amp; [$IsPublished] == false, 'sp-field-severity--severeWarning', '')"
}
'@

# Get Credentials to connect
$m365Status = m365 status
if ($m365Status -match "Logged Out") {
   m365 login
}

# Apply JSON view formatting
m365 spo list view set --webUrl $siteUrl --listTitle $listName --title $viewName --CustomFormatter $jsonViewFormatting

```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

***

## Contributors

| Author(s) |
|-----------|
| [Ganesh Sanap](https://ganeshsanapblogs.wordpress.com/about) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-apply-json-view-formatting" aria-hidden="true" />
