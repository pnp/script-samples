---
plugin: add-to-gallery
---

# Export and import library folder structure

## Summary

Sometimes you just need to copy a folder structure from one library to another. This script will export the folder structure from one library and import it to another library using a JSON file to store the folder structure. The can be used as is or be an invidual function in a site provisioning script.


![Example Screenshot](assets/example.png)


# [PnP PowerShell](#tab/pnpps)

```powershell
#----------------------------------------------------------[Local variables to update]----------------------------------------------------------
$labelsToRemove =  "Entity Document (POC)","Entity Record (POC)"
$siteURL = "https://contoso.sharepoint.com/sites/EntitySite"
$libraries = "Documents","Reports" # Enter Document Library Names Here
#---------------------------------------------------------[Initialisation]--------------------------------------------------------
Clear-Host
$ExecutionContext.SessionState.LanguageMode = 'FullLanguage'
#-----------------------------------------------------------[Execution]-----------------------------------------------------------


function Split-Collection {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object[]] $InputObject,

        [Parameter(Position = 0)]
        [ValidateRange(1, [int]::MaxValue)]
        [int] $ChunkSize = 5
    )

    begin {
        $list = [System.Collections.Generic.List[object]]::new()
    }
    process {
        foreach($item in $InputObject) {
            $list.Add($item)
            if($list.Count -eq $ChunkSize) {
                $PSCmdlet.WriteObject($list.ToArray())
                $list.Clear()
            }
        }
    }
    end {
        if($list.Count) {
            $PSCmdlet.WriteObject($list.ToArray())
        }
    }
}

Write-Host "Connecting to site: $($siteURL)" -foregroundcolor Green

try
{
    Connect-PnPOnline -url $siteURL -Interactive
    $ctx = Get-PnPContext
}
catch
{
    write-host  "You don't have permission to site - $($siteURL)" -foregroundcolor Red
    write-host  "Error: $($_.Exception.Message)" -foregroundcolor Red
    exit
}


foreach($label in $labelsToRemove)
{
    foreach($lib in $libraries)
    {
        try
        {
            Write-Host "Processing $lib library in $siteURL"
            $DocumentsLib = Get-PnPList -Identity $lib

            #Gettings All Items with Label - workaround if more than 5000 items as CAML can then not be used.
            if($DocumentsLib.ItemCount -gt 4999)
            {
                $items = Get-PnPListItem -List $DocumentsLib -PageSize 5000 | Where-Object { $_.FieldValues._ComplianceTag -eq $label} | Select-Object Id
            }
            else 
            {
                $CAML = "<View><Query><Where><Eq><FieldRef Name='_ComplianceTag' /><Value Type='Text'>$label</Value></Eq></Where></Query></View>"
                $items = Get-PnPListItem -List $DocumentsLib -PageSize 5000 -Query $caml | Select-Object Id
            }

            if($items.Count -gt 0)
            {
                Write-Host "   $($items.Count) items with $label label found for $($lib.Title)" -ForegroundColor Magenta
                
                $items.Id | Split-Collection 200 | ForEach-Object {

                $JSON ="{
                    ""blockDelete"": false,
                    ""blockEdit"": false,
                    ""complianceTagValue"": """",
                    ""itemIds"": [
                        $($_ -join "","")
                    ],
                    ""listUrl"": ""$($DocumentsLib.RootFolder.ServerRelativeUrl)""
                }"

                Write-Host "     Created JSON Payload to Remove Label: $label from $($_.Count) files" -ForegroundColor Yellow

                Invoke-PnPSPRestMethod -Method Post -Url "$($ctx.Url)/_api/SP.CompliancePolicy.SPPolicyStoreProxy.ApplyLabelOnBulkItems()"  -ContentType "application/json;odata=verbose" -Content $JSON
                }
            }
            else
            {
                Write-Host "   No items with $label label found for $($lib.Title)" -ForegroundColor Green
            }
        }
        catch
        {
            Write-Host  "Error: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}


```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***


## Contributors

| Author(s) |
|-----------|
| Leon Armston |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-bulk-remove-retention-labels" aria-hidden="true" />
