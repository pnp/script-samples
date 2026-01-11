

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

try {
    # Get the list object
    $list = Get-PnPList -Identity $oldListName -ErrorAction Stop

    # Check if the target URL already exists
    $existingFolder = Get-PnPFolder -Url $newListUrl -ErrorAction SilentlyContinue
    if ($existingFolder) {
        Write-Host "Error: A list or folder already exists at '$newListUrl'. Aborting." -ForegroundColor Red
        return
    }

    # Move the list's root folder to the new URL
    $list.RootFolder.MoveTo($newListUrl)
    Invoke-PnPQuery
    Write-Host "List URL successfully changed to '$newListUrl'." -ForegroundColor Green

    # Rename the list display name
    Set-PnPList -Identity $list -Title $newListName
    Write-Host "List display name successfully changed to '$newListName'." -ForegroundColor Green

} catch {
    Write-Host "An error occurred: $_" -ForegroundColor Red
}

```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***

## Contributors

| Author(s) |
|-----------|
| [Ganesh Sanap](https://ganeshsanapblogs.wordpress.com/about) |
| [Josiah Opiyo](https://github.com/ojopiyo) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-change-list-url" aria-hidden="true" />
