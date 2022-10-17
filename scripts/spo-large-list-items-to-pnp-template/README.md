---
plugin: add-to-gallery
---

# Add Large List items to PnP Template

## Summary

Add Large list items to PnP Template using PnP command [Add-PnPDataRowsToSiteTemplate](https://docs.microsoft.com/en-us/powershell/module/sharepoint-pnp/add-pnpdatarowstositetemplate?view=sharepoint-ps).


## Implementation

- Open Windows PowerShell ISE
- Create a new file
- Copy a script  below,

# [PnP PowerShell](#tab/pnpps)
```powershell

$url = "https://yourtenantname.sharepoint.com/sites/SiteCollection"
$listname = "YourLargeList"
$xmlFilePath="template.xml"
$BatchSize=2000
Connect-PnPOnline -Url $Url -Interactive
Try
{
  
  $clientContext = Get-PnPContext
  $targetWeb = Get-PnPWeb
  $targetList = $targetWeb.Lists.GetByTitle($listname)
  $clientContext.Load($targetList)
  $clientContext.ExecuteQuery()
  if ($targetList.ItemCount -gt 0){
  if ($targetList.ItemCount -le 5000){
      Add-PnPDataRowsToSiteTemplate -Path $xmlFilePath -List $targetList -Query '<View></View>'
  }
  else
  {
  $loopCount =[math]::ceiling($targetList.ItemCount/$BatchSize)
  $startCount = 0
  $initialStartCount = 1
  $endCount = $BatchSize
      for ($count = 0;$count -lt $loopCount;$count++)
      {If($count -eq $loopCount-1){
              $templatequery = '<Query><Where><And><Gt><FieldRef Name=""ID""></FieldRef><Value Type=""Number"">' +$startCount + '</Value></Gt><Lt><FieldRef Name=""ID""></FieldRef><Value Type=""Number"">' +$endCount + '</Value></Lt></And></Where></Query>'
                  Add-PnPDataRowsToSiteTemplate -Path $xmlFilePath -List $targetList -Query $templatequery
          }
          else{
              $camlQuery = ""<View><Query><Where><And><Gt><FieldRef Name='ID'></FieldRef><Value Type='Number'>$startCount</Value></Gt><Lt><FieldRef Name='ID'></FieldRef><Value Type='Number'>$endCount</Value></Lt></And></Where><View><OrderBy><FieldRef Name='ID' Ascending='True' /></OrderBy></View></Query></View>""
              $Items = Get-PnPListItem -List $targetList -Query $camlQuery | select -Last 1
              $templatequery = '<Query><Where><And><Gt><FieldRef Name=""ID""></FieldRef><Value Type=""Number"">' +$startCount + '</Value></Gt><Lt><FieldRef Name=""ID""></FieldRef><Value Type=""Number"">' +$endCount + '</Value></Lt></And></Where></Query>'
              Add-PnPDataRowsToSiteTemplate -Path $xmlFilePath -List $targetList -Query $templatequery
              $startCount = $initialStartCount + $Items.Id
              $endCount = $endCount + $BatchSize
              }
          }
      }
  }
}
Catch {}
Disconnect-PnPOnline
```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Contributors

| Author(s) |
|-----------|
|[Jiten Parmar](https://github.com/jitenparmar)|


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-large-list-items-to-pnp-template" aria-hidden="true" />
