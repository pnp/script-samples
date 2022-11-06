---
plugin: add-to-gallery
---

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

#Config Variables
$url = 'https://contoso.sharepoint.com/sites/clientfacing'
$libraryName = 'Documents'
$LocalPathForDownload = "c:\temp\"

Connect-PnPOnline -Url $url -Interactive

$list = Get-PnPList -Identity $libraryName -Includes ContentTypes

foreach($CT in $list.ContentTypes | Where-Object{$_.ReadOnly -ne $false})
{
    Write-Host "Downloading Document Template: $($CT.DocumentTemplate) for Content Type: $($CT.Name) to $LocalPathForDownload$($CT.DocumentTemplate)"
    Get-PnPFile -Url $CT.DocumentTemplateUrl -Path $LocalPathForDownload -Filename $($CT.DocumentTemplate) -AsFile
}
```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***

## Contributors

| Author(s) |
|-----------|
| [Leon Armston](https://github.com/LeonArmston) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-list-download-contenttype-documenttemplate" aria-hidden="true" />
