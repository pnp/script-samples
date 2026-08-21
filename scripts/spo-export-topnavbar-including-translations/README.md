# Export TopNavBar Structure and Translations.

## Summary

This sample script exports the Top Navigation Bar structure from a SharePoint Online site, including all translations for each navigation node. It connects to a SharePoint site using PnP PowerShell, recursively traverses the navigation tree (including nested children), retrieves multilingual title resources (e.g. German, French, Italian), and exports the full structure — with IDs, URLs, external link flags, and translations — as a JSON file (`TopNavigation.json`).

# [PnP PowerShell](#tab/pnpps)

```powershell
$cn = Connect-PnPOnline -Url "https://tenant-admin.sharepoint.com/sites/site-with-topnavbar" -Interactive -ReturnConnection

$ctx = Get-PnPContext -Connection $cn

function Get-NavigationNodeRecursive {
   param(
       [Microsoft.SharePoint.Client.NavigationNode]$Node
   )

   # Load children and title resource
   $ctx.Load($Node.Children)
   $ctx.Load($Node.TitleResource)
   $ctx.ExecuteQuery()

   # Get translations
   $resourceEntries = $Node.TitleResource.GetResourceEntries()
   $ctx.ExecuteQuery()

   $translations = @{}

   foreach($entry in $resourceEntries)
   {
       if($null -ne $entry.LCID)
       {
           $translations["$($entry.LCID)"] = $entry.Value
       }
   }

   [PSCustomObject]@{
       Id          = $Node.Id
       ParentId    = $Node.ParentId
       Title       = $Node.Title
       Url         = $Node.Url
       IsExternal  = $Node.IsExternal

       # Use Title_* for direct access to a specific language by LCID, or TitleResource for the full translation map — remove whichever you don't need
       Title_1031  = $translations["1031"]
       Title_1036  = $translations["1036"]
       Title_1040  = $translations["1040"]

       TitleResource = $translations

       Children = @(
           foreach($child in $Node.Children)
           {
               Get-NavigationNodeRecursive -Node $child
           }
       )
   }
}

$topNodes = Get-PnPNavigationNode -Location TopNavigationBar -Connection $cn

$navigationTree = foreach($node in $topNodes)
{
   Get-NavigationNodeRecursive -Node $node
}

# Export JSON
$navigationTree |
   ConvertTo-Json -Depth 100 |
   Set-Content ".\TopNavigation.json" -Encoding UTF8
```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***

## Contributors

| Author(s) |
|-----------|
| Fabian Hutzli |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-export-topnavbar-including-translations" aria-hidden="true" />
