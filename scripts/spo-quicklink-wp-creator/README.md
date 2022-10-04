---
plugin: add-to-gallery
---

# Create a Quick Links web part with items defined in a datasource  

## Summary

This script will enable you to create a Quick Links web part where the items are defined in some kind of data source, in this case a SharePoint list. However it could just as well be a csv or similar.

The script contains both the setup for the data source (SP List) as well as the Quick Links creator.

Please be advised that this script only enables you to specify the title, the URL and the icon for each item/Quick link.

PnP PowerShell

## Implementation

<!-- - Open Windows PowerShell ISE -->
- Open VS Code
- Create a new file
- Copy a script  below

# [PnP PowerShell](#tab/pnpps)
```powershell

function Create-QuickLinkList ($siteUrl , $ListName)
{
    $connection = Connect-PnPOnline -Url $siteUrl -ReturnConnection -Interactive
    try
    {
      $list = Get-PnPList -Identity $ListName
      if(-not $list)
      {
        $list = New-PnPList -Title $ListName -Template  GenericList
        Add-PnPField -List $list -Type Text -InternalName "Url" -DisplayName "Url" -AddToDefaultView -Required
        Add-PnPField -List $list -Type Text -InternalName "Iconname" -DisplayName "Iconname"  -AddToDefaultView -Required
        Add-PnPField -List $list -Type Text -InternalName "TemplateName" -DisplayName "TemplateName"  -AddToDefaultView -Required

        Add-PnPListItem -List $list -Values @{"Title"= "test";"Url"= "https://github.com/pnp/script-samples"; "Iconname"= "internetsharing";"TemplateName"= "Template1"} -Connection $connection
        
      }
    }
    catch
    {
        throw $_Exception
    }
    finally 
    {
      Disconnect-PnPOnline -Connection $connection  
    }
}
$siteUrl = "https://YourTenantName.sharepoint.com/sites/QuickLinksTest"
$ListName = "QuickLinkDefinitions"
Create-QuickLinkList -siteUrl $siteUrl -ListName $ListName

function Create-PropertiesJson ($webparttitle, $QuickLinksitems)
{
  $base = '{"controlType":3,"id":"00000000-0000-0000-0000-000000000000","position":{"zoneIndex":1,"sectionIndex":1,"controlIndex":1,"layoutIndex":1},"webPartId":"00000000-0000-0000-0000-000000000000","webPartData":{"id":"00000000-0000-0000-0000-000000000000","instanceId":"00000000-0000-0000-0000-000000000000","title":"Quick links","description":"Add links to important documents and pages.",'
  $imageSources = '"imageSources":{},'
  $componentDependencies = '"componentDependencies":{"layoutComponentId":"706e33c8-af37-4e7b-9d22-6e5694d92a6f"}},"dataVersion":"2.2",'
  $end = '"hideWebPartWhenEmpty":true,"dataProviderId":"QuickLinks","webId":"00000000-0000-0000-0000-000000000000","siteId":"00000000-0000-0000-0000-000000000000"}},"emphasis":{},"reservedHeight":164,"reservedWidth":744}'
  
  $links = '"links":{"baseUrl":"",'
  $serverProcessedContent = '"serverProcessedContent":{"htmlStrings":{},"searchablePlainTexts":{"title":"' + $webparttitle + '",'
  $properties = '"properties":{"items":['
  $idx = 0
  foreach($QuickLinksitem in $QuickLinksitems)
  {
    $links+= '"items['+$idx+'].sourceItem.url":"'+ $QuickLinksitem["Url"]+'"'
    $serverProcessedContent += '"items['+ $idx +'].title":"'+ $QuickLinksitem["Title"]+ '"'
    $properties += '{"sourceItem":{"itemType":2,"fileExtension":"","progId":""},"thumbnailType":2,"id":1,"fabricReactIcon":{"iconName":"' + $QuickLinksitem["Iconname"]+'"}}'
    if($idx -lt $QuickLinksitems.Count-1)
    {
      $links+=','
      $serverProcessedContent += ','
      $properties +=  ','
    }
    $idx++
  
  }
  $links += '},'
  $serverProcessedContent +=  '},' 
  $properties += '],"isMigrated":true,"layoutId":"Button","shouldShowThumbnail":true,"buttonLayoutOptions":{"showDescription":false,"buttonTreatment":2,"iconPositionType":2,"textAlignmentVertical":2,"textAlignmentHorizontal":2,"linesOfText":2},"listLayoutOptions":{"showDescription":false,"showIcon":true},"waffleLayoutOptions":{"iconSize":1,"onlyShowThumbnail":false},'
  
  $jsonPropsQuickLinks = $base + $serverProcessedContent + $imageSources + $links + $componentDependencies + $properties + $end
  return $jsonPropsQuickLinks  
  
}
#Connect to the site where the refence list is placed
$portalConn = Connect-PnPOnline -Url "https://YourTenantName.sharepoint.com/sites/QuickLinksTest" -Interactive -ReturnConnection
$QuickLinksitems = Get-PnPListItem -List $ListName -Connection $portalConn | Where-Object {$_["TemplateName"] -eq "Template1"} 

$jsonPropsQuickLinks = Create-PropertiesJson -webparttitle "Vejledninger" -QuickLinksitems $QuickLinksitems

#Connect to the site where the Quick Links web part should be "deployed"
$destinationurl = "https://YourTenantName.sharepoint.com/sites/QuickLinksTest"
$destinationconn = Connect-PnPOnline -Url $destinationurl -Interactive -ReturnConnection
$web = Get-PnPWeb -Connection $destinationconn
$targetpage = Get-PnPPage -Web  $web -Identity "home.aspx" -Connection $destinationconn
 

Add-PnPPageWebPart -Page $targetpage -DefaultWebPartType "QuickLinks" -WebPartProperties $jsonPropsQuickLinks -Connection $portalConn

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Contributors

| Author(s) |
|-----------|
| [Kasper Larsen](https://github.com/kasperbolarsen)|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-quicklink-wp-creator" aria-hidden="true" />

