---
plugin: add-to-gallery
---

# Get Content type usage within a site across lists, list items and item version

## Summary

This sample script returns content type usage within a site across lists, list items and item version. The error message "content type in use" appears while trying to delete a content type within a site, the script can help identify where the content type is referenced to help with deletion of content type.

## Implementation

- Open Windows PowerShell ISE
- Create a new file
- Write a script as below,
- Update the $SiteURL, $ReportOutput and $ContentTypeName

# [PnP PowerShell](#tab/pnpps)
```powershell
# Connect to SharePoint site

$siteUrl = "https://contoso.sharepoint.com/teams/d-app-ar"
Connect-PnPOnline -Url $siteUrl -Interactive

$dateTime = (Get-Date).toString("dd-MM-yyyy")
$invocation = (Get-Variable MyInvocation).Value
$directorypath = Split-Path $invocation.MyCommand.Path
$fileFieldsName = "FieldsReports-" + $dateTime + ".csv"

$OutPutFieldsFile = $directorypath + "\Logs\"+ $fileFieldsName

#Arry to Skip Views for custom fields
$SystemFlds = @("Compliance Asset Id","Body","Expires","ID","Content Type","Modified","Created","Created By","Modified By","Version","Attachments","Edit","Type","Item Child Count","Folder", "Child Count","App Created By","App Modified By",
"Name","Classification","Source","Status","Document Type","From","In-Reply-To","OriginalSubject","References","Reply-To","Subject","To","Date","Cc","Comments","Checked Out To","Check In Comment","File Size","Source Version (Converted Document)","Source Name (Converted Document)",
,"Location","Start Time","End Time","Description","All Day Event","Recurrence","Attendees","Category","Resources","Free/Busy","Check Double Booking","Enterprise Keywords",
"Last Updated","Parent Item Editor","Parent Item ID","Last Reply By","Question","Best Response","Best Response Id", "Is Featured Discussion","E-Mail Sender","Replies","Folder Child Count","Discussion Subject","Reply","Post","Threading","Posted By",
"Due Date","Assigned To","File Received","Number Of Setups","Notes/Comments","Task_Status","Is Approval Required","Approver","Approver Comments","Approval Date","Documents",
"Order","Role","Person or Group","Location",
"Predecessors","Priority","Task Status","% Complete","Start Date","Completed","Related Items",
"Background Image Location","Link Location","Launch Behavior","Background Image Cluster Horizontal Start","Background Image Cluster Vertical Start",
"First Name","Full Name","Email Address","Company","Job Title","Business Phone","Home Phone","Mobile Number","Fax Number","Address","City","State/Province","ZIP/Postal Code","Country/Region","Web Page","Notes","Name","Order","Role", "Color Tag", "Label setting", "Retention label", "Retention Label Applied", "Label applied by", "Item is a Record" 
)
#Arry to Skip System Lists and Libraries
$SystemLists = @("Converted Forms", "Master Page Gallery", "Customized Reports", "Form Templates", "List Template Gallery", "Theme Gallery",
                            "Reporting Templates", "Solution Gallery", "Style Library", "Web Part Gallery","Site Assets", "wfpub", "Site Pages", "Images", "MicroFeed","Pages")

                             $listsToReport = @("UPM","Recoveries","Remittances","Payments")
# Specify the list name

# Get all items from the list
$FieldsCollection = @()
$lists = Get-PnPList  | Where {$_.Hidden -eq $false -and $listsToReport -contains $_.Title } | ForEach-Object {
$list = $_.Title
   Get-PnPField -List $list  | Where {$_.Hidden -eq $false -and $SystemFlds -notcontains $_.Title } | ForEach-Object {
   $ExportField = New-Object PSObject
   $ExportField | Add-Member -MemberType NoteProperty -name "List" -value $list
   $ExportField | Add-Member -MemberType NoteProperty -name "FieldName" -value $_.Title
   $FieldsCollection += $ExportField
   }
}

 
$FieldsCollection | Export-Csv -Path $OutPutFieldsFile -NoTypeInformation
 
# Disconnect from SharePoint site

#Disconnect-PnPOnline
```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Contributors

| Author(s) |
|-----------|
| [Reshmee Auckloo](https://github.com/reshmee011)|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-get-contenttype-usage-listitem-listversion" aria-hidden="true" />
