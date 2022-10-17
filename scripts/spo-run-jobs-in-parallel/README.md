---
plugin: add-to-gallery
---

# Sample on how to use ForEach-Object -Parallel to iterate SharePoint site collections in parallel, something some of us do a LOT

## Summary

Often we will have to iterate a lot of site collections in order to query if this or that property has been changed, or to update something.

There are a number of ways to speed up the process (divide&conquer using multiple scripts or fan in / fan out in Azure Functions) but I have had the ForEach-Object -parallel on my to do list since I saw it here: https://devblogs.microsoft.com/powershell/powershell-foreach-object-parallel-feature/


## Implementation

- Open Windows PowerShell ISE
- Create a new file
- Write a script as below,
- Change the variables to target to your environment, site, document library, document path, max count
- Run the script.
 
## Screenshot of Output 

![Example Screenshot](assets/preview.png)

# [PnP PowerShell](#tab/pnpps)
```powershell


if(-not $cred)
{
    $cred = Get-Credential
}
$SPAdminSiteUlr = "https://[YourTenant]-admin.sharepoint.com"
$conn = Connect-PnPOnline -Url $SPAdminSiteUlr -Credentials $cred -ErrorAction Stop

#substitute this section with your selection of site collections
#in this case I just get the first 40 sitecollections from the tenant
try
{
    $SiteCollections = Get-PnPTenantSite -Connection $conn | select-object -first 40
}
catch
{
    Write-Host $_.Exception
    throw $_.Exception
}
$urls = @()
foreach($sitecollection in $SiteCollections)
{
    $urls+=$sitecollection.Url    
}

function DoSomethingInASiteCollection ($sitecollectionUrl, $cred )
{
    $success = $false
    $reruncount = 0
    $filecounter = 0
    $errors = @()
    while($success -eq $false -and $reruncount -lt 9)
    {
        try
        {
            $localconn = Connect-PnPOnline -Url $sitecollectionUrl -Credentials $cred -ReturnConnection -ErrorAction Stop
            $lists= Get-PnPList -Connection $localconn -ErrorAction Stop| Where-Object {$_.BaseTemplate -eq 101 -and $_.Hidden -eq $false} 
            foreach($list in $lists)
            {
                if( $list.Title -eq "Form Templates" -or $list.Title -eq "Style Library" -or $list.Title -eq "Site Assets")
                {
                    #not sure if I need to count those
                }
                else
                {
                    $listItems = Get-PnPListItem -Connection $localconn -List $list  -ErrorAction Stop
                    $filecounter+= $listItems.Count
                }
                
            }
            $outputobj = new-object PSObject -property @{"SiteUrl" = $sitecollectionUrl; "FileCount" = $filecounter; "Reruncount" = $reruncount ; "errors"  = $errors}
            $success = $true
            return $outputobj
            
        }
        catch
        {
            #this error handling is pretty rudimentary, please replace it with your own :-)
            if($_.Exception.Message -like "*429*")
            {
                Write-Warning -Message ("Received throttling error ")
                [int]$waittime = $_.Exception.Response.Headers.GetValues("Retry-after")[0]
                Start-Sleep -Seconds $waittime
            }
            #write-host -f Red "`tError:" $_.Exception.Message $_.Exception
            $reruncount++
            $errors+= $_.Exception.Message
        }
    }
    if($reruncount -gt 9)
    {
        $outputobj = new-object PSObject -property @{"SiteUrl" = $sitecollectionUrl; "FileCount" = $filecounter; "Reruncount" = $reruncount ; "errors" = $errors}
        return $outputobj
    
    }
}


#just included in order to show the diff between running it in sequence and parallel
#it also serves as a test bed for the logic in the function as you can debug using this
if($true)
{
    Write-Host "Starting sequential run" -ForegroundColor Green
    $start = (Get-Date)
    foreach($url in $urls)
    {
        $test = DoSomethingInASiteCollection -sitecollectionUrl $url -cred $cred
        write-host "URL $($test.SiteUrl), FileCount   $($test.FileCount)  , Reruns $($test.Reruncount), errros  $($test.errors)" -ForegroundColor Yellow
    }
    $end = (Get-Date)
    $sequentialtimespan = $end - $start
    Write-Host "Running sequentially total time:$sequentialtimespan " -ForegroundColor Green
}


Write-Host "Starting parallel run" -ForegroundColor Blue
$throttleLimit = 10
$funcDef = $function:DoSomethingInASiteCollection.ToString()
$threadSafeDictionary = [System.Collections.Concurrent.ConcurrentDictionary[string,object]]::new()

$start = Get-Date
$urls| ForEach-Object -Parallel -ThrottleLimit $throttleLimit   {
    $function:DoSomethingInASiteCollection = $using:funcDef
    $res = DoSomethingInASiteCollection -sitecollectionUrl $_  -cred $using:cred 
    $dict = $using:threadSafeDictionary
    $outObject = new-object PSObject -property @{"FileCount" = $res.filecount; "Reruncount" = $res.reruncount; errors = $res.errors }
    $dict.TryAdd($res.SiteUrl, $outObject) | Out-Null

} 
$end = Get-Date
$timespan = $end - $start

$threadSafeDictionary.Count
foreach($key in $threadSafeDictionary.Keys)
{
    $returnObject = $threadSafeDictionary[$key]
    if($returnObject.errors -and $returnObject.errors.Count -gt 0)
    {
        Write-Host " Url : $key failed with codes $($returnObject.errors)" -ForegroundColor Red
    }
    else
    {
        Write-Host " Url : $key contains $($returnObject.FileCount) items, reruns = $($returnObject.Reruncount)"
    }
}
Write-Host "Running sequentially total time:$sequentialtimespan " -ForegroundColor Green
Write-Host "Running parallel total time:$timespan " -ForegroundColor Blue


```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Contributors

| Author(s) |
|-----------|
| Kasper Larsen, Fellowmind|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/run-jobs-in-parallel" aria-hidden="true" />
