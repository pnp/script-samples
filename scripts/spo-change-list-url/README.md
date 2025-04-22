

# Change SharePoint Online List URL

## Summary

This sample script shows how to change SharePoint online list URL and rename the list after list creation using PnP PowerShell.

Scenario inspired from this blog post: [Change SharePoint Online List URL using PnP PowerShell](https://ganeshsanapblogs.wordpress.com/2023/03/22/change-sharepoint-online-list-url-using-pnp-powershell/)

![Outupt Screenshot](assets/output.png)

# [PnP PowerShell](#tab/pnpps)

```powershell

# SharePoint online site URL
$siteUrl = "https://contoso.sharepoint.com/sites/SPConnect"

# Current display name of SharePoint list
$oldListName = "Images List"

# New list URL
$newListUrl = "Lists/LogoUniverse"

# New display name for SharePoint list
$newListName = "Logo Universe"

# Connect to SharePoint online site
Connect-PnPOnline -Url $siteUrl -Interactive

# Get the SharePoint list
$list = Get-PnPList -Identity $oldListName

# Move SharePoint list to the new URL
$list.Rootfolder.MoveTo($newListUrl)
Invoke-PnPQuery

# Rename List
Set-PnPList -Identity $oldListName -Title $newListName

```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***

## Contributors

| Author(s) |
|-----------|
| [Ganesh Sanap](https://ganeshsanapblogs.wordpress.com/about) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-change-list-url" aria-hidden="true" />
