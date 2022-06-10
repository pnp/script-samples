---
plugin: add-to-gallery
---

# Export SharePoint List Data to CSV with attachments

## Summary

Script will export all SharePoint list data to CSV file, also takes items attachments and stores it to PC.

## Implementation

- Open Windows PowerShell ISE
- Edit Script and add details like listname and SharePoint Site
- Press run
- CSV file and attachments will be saved at same directory where script was started from

# [PnP PowerShell](#tab/pnpps)
```powershell

###### Declare and Initialize Variables ######  

#site collection url
$url="Site collection url"

#list to be exported  
$listName="Requests"

#include or exclude hidden and readonly fields
$includeHiddenField = $False
$includeReadonlyField = $False


# data will be saved in same directory script was started from
$saveDir = (Resolve-path ".\")  
$currentTime= $(get-date).ToString("yyyyMMddHHmmss")  
$logFilePath=".\log-"+$currentTime+".log"  
 
## Start the Transcript  
Start-Transcript -Path $logFilePath   
 
## Export List to CSV ##  
function ExportList  
{  

# Fields that has to be retrieved  - currently taking all the fields 
$listFields = Get-PnPField -List $listName |? { $_.Hidden -eq $includeHiddenField -AND $_.ReadOnlyField -eq $includeReadonlyField} | Select -ExpandProperty internalname

$count = 0
    try  
    {  
    md .\$listName -Force
    md ".\$($listName)\Attachments" -Force

        $listItems=(Get-PnPListItem -List $listName -Fields $listFields -PageSize 1000).FieldValues  
        $outputFilePath=".\$($listName)_list_results-"+$currentTime+".csv"  
            
        $hashTable=@()  
        
        # Loop through the list items  
        foreach($listItem in $listItems)  
        {   $count = $count+1
            Write-Progress -Activity "Exporting" -Status "$($count/$listItems.Count*100)% Complete:" -PercentComplete $($count/$listItems.Count*100)
            $obj=New-Object PSObject              
            $listItem.GetEnumerator() | Where-Object { $_.Key -in $listFields }| ForEach-Object{ 
                    
                    
                    if($_.Value.LookupValue){$obj | Add-Member Noteproperty $_.Key $_.Value.LookupValue}
                    else{$obj | Add-Member Noteproperty $_.Key $_.Value}
                    
                    if($_.Key -eq "Attachments" -And $_.Value -eq "TRUE"){
                        md ".\$($listName)\Attachments\$($listItem.ID)" -Force
                        $item = Get-PnPListItem -List $listName -Id $($listItem.ID)
                        
                        $attachments = ForEach-Object{Get-PnPProperty -ClientObject $item -Property "AttachmentFiles"}
                        $fileUrls = ""
                        $attachments | ForEach-Object {
                            
                            #save file to disk
                            Get-PnPFile -Url $_.ServerRelativeUrl -FileName $_.FileName -Path ".\$($listName)\Attachments\$($listItem.ID)"  -AsFile -Force
                            $fileUrl +=  "Attachments\$($listItem.ID)\$($_.FileName);"
 
                        } 
                        $obj | Add-Member Noteproperty "AttachmentUrl" "$fileUrl"
                       
                    }
                    
                   
                }
                 
            #write-host $count
            
            $hashTable+=$obj;  
            $obj=$null;  
        }  
  
        $hashtable | export-csv $outputFilePath -NoTypeInformation  
     }  
     catch [Exception]  
     {  
        $ErrorMessage = $_.Exception.Message         
        Write-Host "Error: $ErrorMessage" -ForegroundColor Red          
     }  
}  
 
## Connect to SharePoint Online site  
Connect-PnPOnline -Url $Url -Interactive
 
## Call the Function  
ExportList  
 
## Disconnect the context  
Disconnect-PnPOnline  
 
## Stop Transcript  
Stop-Transcript    

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365](#tab/cli-m365-ps)
```powershell
# Usage example:
# .\Exoprt-SPListItems.ps1 -WebUrl "https://contoso.sharepoint.com/sites/Intranet" -ListName "Demo List"

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, HelpMessage = "Please enter Site URL, e.g. https://contoso.sharepoint.com/sites/Intranet")]
    [string]$WebUrl,
    [Parameter(Mandatory = $true, HelpMessage = "Please enter list title")]
    [string]$ListName,
    [Parameter(Mandatory = $false, HelpMessage = "Include or exclude hidden fields")]
    [bool]$IncludeHiddenFields = $false,
    [Parameter(Mandatory = $false, HelpMessage = "Include or exclude readonly fields")]
    [bool]$IncludeReadOnlyFields = $false
)
begin {
    #Log in to Microsoft 365
    Write-Host "Connecting to Tenant" -f Yellow

    $m365Status = m365 status
    if ($m365Status -match "Logged Out") {
        m365 login
    }

    Write-Host "Connection Successful!" -f Green 
}
process {
    function EnsureFolder {
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory = $true)]
            [string]$FolderPath
        )
        begin {
            Write-Host "Ensuring folder at $($FolderPath)"
        }
        process {
            if (!(Test-Path $FolderPath)) {
                New-Item -ItemType Directory -Path $FolderPath -Force
            }
        }
        end {
            Write-Host "Ensured folder at $($FolderPath)"
        }
    }

    $dateTime = "{0:MM_dd_yy}_{0:HH_mm_ss}" -f (Get-Date)
    $csvPath = "$($ListName -replace '\s','_')-items-" + $dateTime + ".csv"

    # Compose a query path
    $hiddenFieldsPath = If ($IncludeHiddenFields) { "" } else { "!" }
    $readonlyFieldsPath = If ($IncludeReadOnlyFields) { "" } else { "!" }
    $queryPath = "[?" + $hiddenFieldsPath + "Hidden && " + $readonlyFieldsPath + "ReadOnlyField]"

    # Retrieve columns for the specified list
    $listFields = m365 spo field list --webUrl $WebUrl --listTitle $ListName --query $queryPath | ConvertFrom-Json
    $listFieldsWithInternalName = $listFields | Select-Object -ExpandProperty InternalName
    $listFieldsString = $listFieldsWithInternalName -join ','

    if (-not ($listFieldsWithInternalName -ccontains "id")) {
        $listFieldsString = "ID," + $listFieldsString;
    }
    
    try {
        EnsureFolder -FolderPath .\$ListName        

        # Get list of items from the specified list
        $listItems = m365 spo listitem list --webUrl $WebUrl --title $ListName --fields $listFieldsString | ConvertFrom-Json
        
        # Loop through the list items 
        foreach ($listItem in $listItems) {
            if ($listItem.Attachments) {
                # Get the list item attachments
                $attachments = m365 spo listitem attachment list --webUrl $WebUrl --listTitle $ListName --itemId $listItem.ID | ConvertFrom-Json
                
                $fileUrls = ""
                foreach ($attachment in $attachments) {
                    # Save file to disk
                    EnsureFolder -FolderPath ".\$($ListName)\Attachments\$($listItem.ID)"

                    Write-Host "Downloading attachment at: Attachments\$($listItem.ID)\$($attachment.FileName)"
                    m365 spo file get --webUrl $WebUrl --url $attachment.ServerRelativeUrl --asFile --path ".\$($ListName)\Attachments\$($listItem.ID)\$($attachment.FileName)"

                    $fileUrls +=  "Attachments\$($listItem.ID)\$($attachment.FileName);"
                }

                # Add custom property "AttachmentUrl" to the list item
                $listItem | Add-Member -MemberType NoteProperty -Name "AttachmentUrl" -Value $fileUrls
            }
        }

        # Export list items
        $listItems | Export-Csv ".\$($ListName)\$($csvPath)" -NoTypeInformation
    }  
    catch [Exception] {         
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red          
    }
}
end { 
    Write-Host "Finished"
}
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
***

## Contributors

| Author(s) |
|-----------|
| Valeras Narbutas |
| [Nanddeep Nachan](https://github.com/nanddeepn) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-export-sharepoint-list-items-to-csv" aria-hidden="true" />
