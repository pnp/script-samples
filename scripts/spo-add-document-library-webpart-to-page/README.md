---
plugin: add-to-gallery
---

# Add a document library web part to a page (and only show a specific folder)

## Summary

A customer had the requirement to create a page for each of their 86 folders in a document library so they could add more information on those topics. That meant creating 86 pages, each with a document library web part on it that showed a specific folder.

![Example Screenshot](assets/example.png)

The sample creating the page, adding the web parts and includes repeating this for all 86 folders. There is probably a really nice way to, in code, get all folders from the document library and loop through them. So I exported the document library to Excel and copied the folder names. I added some quotes and a comma (in an Excel formula using =CHAR(34) &  A2 & CHAR(34) &”,”) and added an array to store these.

# [PnP PowerShell](#tab/pnpps)
```powershell
Connect-PnPOnline -Url https://yourtenant.sharepoint.com/sites/Yoursite/ -UseWebLogin
$ray = "folder1",
       "folder2",
       "folder3"

foreach ($name in $ray) {

    #create page
    Add-PnPClientSidePage -Name $name -LayoutType Article -HeaderLayoutType NoImage -CommentsEnabled:$false
    
    #add sections
    Add-PnPClientSidePageSection -Page $name -SectionTemplate TwoColumn -Order 1
    
    #add text webpart
    Add-PnPClientSideText -Page $name -Section 1 -Column 1 -Text " "
    
    #add doclib
    Add-PnPClientSideWebPart -Page $name -DefaultWebPartType List -Section 1 -Column 2 -WebPartProperties @{isDocumentLibrary="true";selectedListId="1fa1fb45-e53b-4ea1-9325-ddca7afe986e";selectedFolderPath="/$name";hideCommandBar="false"}
    $page = Get-PnPClientSidePage -Identity $name
    $page.Publish()
}

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Source Credit

Sample first appeared on [Use PnP Powershell to add a document library webpart to a page (and only show a specific folder) | Tech Community](https://techcommunity.microsoft.com/t5/microsoft-365-pnp-blog/use-pnp-powershell-to-add-a-document-library-webpart-to-a-page/ba-p/2428310)

## Contributors

| Author(s) |
|-----------|
| Marijn Somers |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/template-script-submission" aria-hidden="true" />