---
plugin: add-to-gallery
---

# Add dummy folders and files to a SharePoint library

## Summary

This sample shows how to efficiently update a large SharePoint list of 60,000 or more items using PnP-Batch, significantly reducing update time. It addresses throttling challenges, emphasizing exception handling and retry mechanisms to ensure smooth updates.
 
# [PnP PowerShell](#tab/pnpps)

```PowerShell
$siteUrl = "https://contoso.sharepoint.com/teams/app-test"
##azure function #Sharepoint App
Connect-PnPOnline –Url $siteUrl -interactive
function UpdateType($TypeColumn,$list){
do {
try {
$StopLoop = $false
$batch = New-PnPBatch
$index = 1; 
$itemId = 0; 
$listItems = Get-PnPListItem -List $list  -PageSize 500 | Where {$_.FieldValues.$TypeColumn -ne $null }
$totalCount =  $listItems.Count

$listItems| ForEach-Object {
    $itemId = $_.Id
   Set-PnPListItem -List $list -Identity $_.Id -Values @{$TypeColumn = $null;} -UpdateType SystemUpdate -Batch $batch

if($index % 100 -eq 0 -or $index -eq $listItems.Count){
  write-host "Updating batch starting $index out of $totalCount on library $list"
  Invoke-PnPBatch $batch
  $batch = New-PnPBatch
}
  $index+=1;
}

Write-Host "Job completed"
$Stoploop = $true
}
catch {
if ($Retrycount -gt 3){
Write-Host "Could not send Information after 3 retrys.$itemId after number of item  processed $index"
$Stoploop = $true
}
else {
  Write-Host "Could not send Information retrying in 30 seconds...{$itemId} after number of item  processed {$index}"
  Start-Sleep -Seconds 30
  Connect-PnPOnline –Url $siteUrl -interactive
  $Retrycount = $Retrycount + 1
  }
}
}
While ($Stoploop -eq $false)

write-host $("End time " + (Get-Date) + " Updating column: " +  $TypeColumn + "from list " + $listName )
}

UpdateType "Type" "List1" 
```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

## Source Credit

Sample first appeared on [Optimising Large List Updates with PnP Batch: Handling Throttling and Enhancing Efficiency](https://reshmeeauckloo.com/posts/pnpbatch-update-biglist-sharepoint/)

## Contributors

| Author(s) |
|-----------|
| [Reshmee Auckloo](https://github.com/reshmee011)|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]

<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-update-largelist-pnpbatch-with-retry" aria-hidden="true" />
