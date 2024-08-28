---
plugin: add-to-gallery
---

# Find every page that contains a Modern Script Editor web part

> [!Note]
> This is a submission helper template please find the [contributor guidance](/docfx/contribute.md) to help you write this scenario.

## Summary

Since the Modern Script Editor web part is impacted by the automatic disabling af Custom Scripting every 24 hours, it is a good idea to find all pages that contain this web part. This script will search through all pages in a site collection and return the pages that contain the Modern Script Editor web part.

![Example Screenshot](assets/example.png)


# [PnP PowerShell](#tab/pnpps)

```powershell

#locate all page containing a Script Editor Web part

$url = "https://contoso.sharepoint.com/sites/somesite"
#login in a way that allows you to search all sites. I usually use -ManagedIdentity in Azure Automation/Function
$conn = Connect-PnPOnline -Url $url -Interactive  -ReturnConnection -WarningAction Ignore

$IdForScriptEditorWebPart = "3a328f0a-99c4-4b28-95ab-fe0847f657a3"
$query = 'SPFxExtensionJson:"'+$IdForScriptEditorWebPart+'"'
$result = Invoke-PnPSearchQuery -Query $query -Connection $conn -All -SelectProperties "Path", "FileName"
$result.ResultRows.Count
#export to csv
$data = @()
foreach($row in $result.ResultRows)
{
    $item = New-Object PSObject
    $item | Add-Member -MemberType NoteProperty -Name "Path" -Value $row.Path
    $item | Add-Member -MemberType NoteProperty -Name "FileName" -Value $row.FileName
    $data += $item
}
$data | Export-Csv -Path "C:\temp\searchresult.csv" -NoTypeInformation 


```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***


## Contributors

| Author(s) |
|-----------|
| Kasper Larsen |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-find-script-editor-webpart-using-search" aria-hidden="true" />
