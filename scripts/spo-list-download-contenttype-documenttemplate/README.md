

# Download all the content type document templates files associated with a library

## Summary

The script will download all the document templates assigned to all content types in a library. I created this script as I needed to download the document templates assocaited to a library's content types and could not find as easy way to do it through the UI or did not want to download SharePoint Designer etc.

## Implementation

- Open Windows PowerShell ISE or VS Code
- Copy script below to your clipboard
- Paste script into your preferred editor
- Change config variables to reflect the site, library name & download location required


# [PnP PowerShell](#tab/pnpps)

```powershell

# SharePoint online site URL
$siteUrl = "https://contoso.sharepoint.com/sites/clientfacing"

# Display name of SharePoint document library
$libraryName = "Documents"

# Local path where document templates will be downloaded
$LocalPathForDownload = "c:\temp\"

# Connect to SharePoint online site
Connect-PnPOnline -Url $siteUrl -Interactive

# Get SharePoint list with content types
$list = Get-PnPList -Identity $libraryName -Includes ContentTypes

foreach ($CT in $list.ContentTypes | Where-Object {$_.ReadOnly -eq $false})
{
    if ($CT.DocumentTemplateUrl) {
        Write-Host "Downloading Document Template: $($CT.DocumentTemplate) for Content Type: $($CT.Name) to $LocalPathForDownload$($CT.DocumentTemplate)"

        # Download content type document template
        Get-PnPFile -Url $CT.DocumentTemplateUrl -Path $LocalPathForDownload -Filename $($CT.DocumentTemplate) -AsFile
    }
}

# Disconnect SharePoint online connection
Disconnect-PnPOnline

```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365](#tab/cli-m365-ps)

```powershell

# SharePoint online site URL
$siteUrl = "https://contoso.sharepoint.com/sites/clientfacing"

# Display name of SharePoint document library
$libraryName = "Documents"

# Local path where document templates will be downloaded
$LocalPathForDownload = "c:\temp\"

# Get Credentials to connect
$m365Status = m365 status
if ($m365Status -match "Logged Out") {
   m365 login
}

# Get SharePoint list content types
$contentTypes = m365 spo list contenttype list --webUrl $siteUrl --listTitle $libraryName | ConvertFrom-Json

foreach ($CT in $contentTypes | Where-Object {$_.ReadOnly -eq $false})
{
	if($CT.DocumentTemplateUrl) {
		Write-Host "Downloading Document Template: $($CT.DocumentTemplate) for Content Type: $($CT.Name) to $LocalPathForDownload$($CT.DocumentTemplate)"
		
		# Download content type document template
		m365 spo file get --webUrl $siteUrl --url $CT.DocumentTemplateUrl --asFile --path "$($LocalPathForDownload)\$($CT.DocumentTemplate)"
	}
}

# Disconnect SharePoint online connection
m365 logout

```

[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

***

## Contributors

| Author(s) |
|-----------|
| [Leon Armston](https://github.com/LeonArmston) |
| [Ganesh Sanap](https://ganeshsanapblogs.wordpress.com/about) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-list-download-contenttype-documenttemplate" aria-hidden="true" />
