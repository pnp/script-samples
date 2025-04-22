

# Remove Title Area from SharePoint Page

## Summary

This sample script shows how to remove the title area at the top of the page from SharePoint online site page using PnP PowerShell and CLI for Microsoft 365.

Scenario inspired from this blog post: [SharePoint Online: Create a blank page without header & title](https://ganeshsanapblogs.wordpress.com/2021/03/26/sharepoint-online-create-a-blank-page-without-header-and-title/)

![Outupt Screenshot](assets/output.png)

# [PnP PowerShell](#tab/pnpps)

```powershell

# SharePoint online site url
$siteUrl = "https://contoso.sharepoint.com/sites/SPConnect"	

# Name of the site page
$pageName = "MyPage"

# Connect to SharePoint Online site
Connect-PnPOnline -Url $siteUrl -Interactive

# Set site page layout to remove title area
Set-PnPPage -Identity $pageName -LayoutType Home

# Use below command to bring back the page title area
# Set-PnPPage -Identity "MyPage" -LayoutType Article

```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365](#tab/cli-m365-ps)

```powershell

# SharePoint online site URL
$siteUrl = "https://contoso.sharepoint.com/sites/wlive"

# Name of the site page
$pageName = "MyPage.aspx"

# Get Credentials to connect
$m365Status = m365 status
if ($m365Status -match "Logged Out") {
   m365 login
}

# Set site page layout to remove title area
m365 spo page set --name $pageName --webUrl $siteUrl --layoutType Home

# Use below command to bring back the page title area
# m365 spo page set --name $pageName --webUrl $siteUrl --layoutType Article

```

[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

***

## Contributors

| Author(s) |
|-----------|
| [Ganesh Sanap](https://ganeshsanapblogs.wordpress.com/about) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-remove-page-title-area" aria-hidden="true" />
