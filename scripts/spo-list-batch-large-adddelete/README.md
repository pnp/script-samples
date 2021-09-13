---
plugin: add-to-gallery
---

# Using PnP Batch to add and delete 300k items from a list in SharePoint Online

## Summary
In a test environment the data loaded into a SharePoint List reached more than 300k over time and I was tasked to come with a script to delete all the items. 

The sample using PnP Batch to add and delete 300k items in a list

# [PnP PowerShell](#tab/pnpps)
```powershell
$action = Read-Host "Enter the action you want to perform, e.g. Add or Delete"
$siteUrl = "https://contoso.sharepoint.com/sites/Team1"
$listName = "TestDemo" 
$ErrorActionPreference="Stop"
Connect-PnPOnline –Url $siteUrl -interactive
$Stoploop = $false
[int]$Retrycount = "0"

write-host $("Start time " + (Get-Date))
do {
try {

if($action -eq "Add")
{   $lst = Get-PnPList -Identity $listName
    
    if($lst.ItemCount -lt 300000)
    {
       $startInc = $lst.ItemCount
       while($lst.ItemCount -lt 300000)
       {
      
       $batch = New-PnPBatch
        #perform in increment of 1000 until 300k is reached 
       if($startInc+1000 -gt 300000)
        {
         $endNu = 300000
        } 
        else
        {
        $endNu = $startInc+1000
        }
        for($i=$startInc;$i -lt ($endNu);$i++)
        {
            Add-PnPListItem -List $listName -Values @{"Title"="Test $i"} -Batch $batch
        }
        Invoke-PnPBatch -Batch $batch
         $lst = Get-PnPList -Identity $listName
       }
    }
}
if($action -eq "Delete")
{
 $listItems= Get-PnPListItem -List $listName -Fields "ID" -PageSize 1000  
 $itemIds = $lisItems | Foreach {$_.Id}

$itemCount = $listItems.Count
while($itemCount -gt 0)
{
    $batch = New-PnPBatch
    #delete in batches of 1000, if itemcount is less than 1000 , all will be deleted 

    if($itemCount -lt 1000)
    {
     $noDeletions = 0
    }
    else
    {
     $noDeletions = $itemCount -1000
    }

    for($i=$itemCount-1;$i -ge $noDeletions;$i--)
    {
        Remove-PnPListItem -List $listName -Identity $listItems[$i].Id -Batch $batch 
    }
    Invoke-PnPBatch -Batch $batch
    $itemCount = $itemCount-1000
 }
}
 Write-Host "Job completed"
 $Stoploop = $true
}
catch {
if ($Retrycount -gt 3){
 Write-Host "Could not send Information after 3 retrys." 
 $Stoploop = $true
}

else {
  Write-Host "Could not send Information retrying in 30 seconds..."
  Start-Sleep -Seconds 30
  Connect-PnPOnline –Url $siteUrl -interactive
  $Retrycount = $Retrycount + 1
  }
 }
}
While ($Stoploop -eq $false)
write-host $("End time " + (Get-Date))
```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***
## Source Credit

Sample first appeared on [PnP Batch add delete 300k items from a list in SharePoint Online](https://reshmeeauckloo.wordpress.com/2021/09/12/pnp-batch-add-delete-300k-items-from-a-sharepoint-online-list/)

## Contributors

| Author(s) |
|-----------|
| Reshmee Auckloo |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]

<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/spo-list-batch-large-adddelete" aria-hidden="true" />