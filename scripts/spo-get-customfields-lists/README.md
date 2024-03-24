---
plugin: add-to-gallery
---

# List custom fields from SharePoint Lists or libraries

## Summary

This sample script may help to identify any custom columns/fields created in SharePoint lists or libraries.

## Implementation

- Open Windows PowerShell ISE
- Create a new file
- Write a script as given below
- Update the `$siteUrl`, `$ReportOutput` and optionally update `$SystemFlds` & `$SystemLists` to remove any values you would like to include in the report

# [PnP PowerShell](#tab/pnpps)

```powershell
# Connect to SharePoint site
$siteUrl = "https://contoso.sharepoint.com/teams/d-app"
Connect-PnPOnline -Url $siteUrl -Interactive

$dateTime = (Get-Date).toString("dd-MM-yyyy")
$invocation = (Get-Variable MyInvocation).Value
$directorypath = Split-Path $invocation.MyCommand.Path
$ReportOutput = "FieldsReports-" + $dateTime + ".csv"

$OutPutFieldsFile = $directorypath + "\Logs\"+ $ReportOutput

#Arry to Skip OOB Fields
$SystemFlds = @(
    "Compliance Asset Id","Body","Expires","ID","Content Type","Modified","Created","Created By","Modified By","Version","Attachments","Edit","Type","Item Child Count","Folder", "Child Count","App Created By","App Modified By", "Name","Checked Out To","Check In Comment","File Size","Source Version (Converted Document)","Source Name (Converted Document)","Location","Start Time","End Time","Description","All Day Event","Recurrence","Attendees","Category","Resources","Free/Busy","Check Double Booking","Enterprise Keywords", "Last Updated","Parent Item Editor","Parent Item ID","Last Reply By","Question","Best Response","Best Response Id", "Is Featured Discussion","E-Mail Sender","Replies","Folder Child Count","Discussion Subject","Reply","Post","Threading","Posted By", "Due Date","Assigned To","File Received","Number Of Setups","Notes/Comments","Task_Status","Is Approval Required","Approver","Approver Comments","Approval Date","Documents", "Order","Role","Person or Group","Location", "Predecessors","Priority","Task Status","% Complete","Start Date","Completed","Related Items", "Background Image Location","Link Location","Launch Behavior","Background Image Cluster Horizontal Start","Background Image Cluster Vertical Start", "First Name","Full Name","Email Address","Company","Job Title","Business Phone","Home Phone","Mobile Number","Fax Number","Address","City","State/Province","ZIP/Postal Code","Country/Region","Web Page","Notes","Name","Order","Role", "Color Tag", "Label setting", "Retention label", "Retention Label Applied", "Label applied by", "Item is a Record" ,"Comment Count","Like Count","Sensitivity", "Copy Source","Title"
)

#Arry to Skip System Lists and Libraries
$SystemLists = @(
    "Converted Forms", "Master Page Gallery", "Customized Reports", "Form Templates", "List Template Gallery", "Theme Gallery", "Apps for SharePoint", "Reporting Templates", "Solution Gallery", "Style Library", "Web Part Gallery", "Site Assets", "wfpub", "Site Pages", "Images", "MicroFeed", "Pages"
)

#Get all lists from the site
$FieldsCollection = @()
$lists = Get-PnPList | Where {$_.Hidden -eq $false -and $SystemLists -notcontains $_.Title } | ForEach-Object {
    $list = $_.Title
    Get-PnPField -List $list | Where {$_.Hidden -eq $false -and $SystemFlds -notcontains $_.Title } | ForEach-Object {
        $ExportField = New-Object PSObject
        $ExportField | Add-Member -MemberType NoteProperty -name "List" -value $list
        $ExportField | Add-Member -MemberType NoteProperty -name "FieldName" -value $_.Title
        $FieldsCollection += $ExportField
    }
}

#Export to CSV
$FieldsCollection | Export-Csv -Path $OutPutFieldsFile -NoTypeInformation 

#Disconnect from SharePoint site
Disconnect-PnPOnline
```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365](#tab/cli-m365-ps)

```powershell
# SharePoint Online site URL
$siteUrl = "https://contoso.sharepoint.com/sites/spconnect"

#Get Credentials to connect
$m365Status = m365 status
if ($m365Status -match "Logged Out") {
    m365 login
}

#Path for output CSV file
$dateTime = (Get-Date).toString("dd-MM-yyyy")
$invocation = (Get-Variable MyInvocation).Value
$directorypath = Split-Path $invocation.MyCommand.Path
$ReportOutput = "FieldsReportsCLI-" + $dateTime + ".csv"

$OutPutFieldsFile = $directorypath + "\Logs\"+ $ReportOutput

#Arry to Skip OOB Fields
$SystemFlds = @(
    "Compliance Asset Id","Body","Expires","ID","Content Type","Modified","Created","Created By","Modified By","Version","Attachments","Edit","Type","Item Child Count","Folder", "Child Count","App Created By","App Modified By", "Name","Checked Out To","Check In Comment","File Size","Source Version (Converted Document)","Source Name (Converted Document)","Location","Start Time","End Time","Description","All Day Event","Recurrence","Attendees","Category","Resources","Free/Busy","Check Double Booking","Enterprise Keywords", "Last Updated","Parent Item Editor","Parent Item ID","Last Reply By","Question","Best Response","Best Response Id", "Is Featured Discussion","E-Mail Sender","Replies","Folder Child Count","Discussion Subject","Reply","Post","Threading","Posted By", "Due Date","Assigned To","File Received","Number Of Setups","Notes/Comments","Task_Status","Is Approval Required","Approver","Approver Comments","Approval Date","Documents", "Order","Role","Person or Group","Location", "Predecessors","Priority","Task Status","% Complete","Start Date","Completed","Related Items", "Background Image Location","Link Location","Launch Behavior","Background Image Cluster Horizontal Start","Background Image Cluster Vertical Start", "First Name","Full Name","Email Address","Company","Job Title","Business Phone","Home Phone","Mobile Number","Fax Number","Address","City","State/Province","ZIP/Postal Code","Country/Region","Web Page","Notes","Name","Order","Role", "Color Tag", "Label setting", "Retention label", "Retention Label Applied", "Label applied by", "Item is a Record" ,"Comment Count","Like Count","Sensitivity", "Copy Source","Title"
)

#Arry to Skip System Lists and Libraries
$SystemLists = @(
    "Converted Forms", "Master Page Gallery", "Customized Reports", "Form Templates", "List Template Gallery", "Theme Gallery", "Apps for SharePoint", "Reporting Templates", "Solution Gallery", "Style Library", "Web Part Gallery", "Site Assets", "wfpub", "Site Pages", "Images", "MicroFeed", "Pages"
)

#Get all lists from the site
$FieldsCollection = @()
$lists = m365 spo list list --webUrl $siteUrl | ConvertFrom-Json | Where {$_.Hidden -eq $false -and $SystemLists -notcontains $_.Title } | ForEach-Object {
	$list = $_.Title
	
	#Get custom fields from the list
	Write-Host "Fetching custom fields from: $($list)"
	m365 spo field list --webUrl $siteUrl --listTitle $list | ConvertFrom-Json | Where {$_.Hidden -eq $false -and $SystemFlds -notcontains $_.Title } | ForEach-Object {
		$ExportField = New-Object PSObject
		$ExportField | Add-Member -MemberType NoteProperty -name "List" -value $list
		$ExportField | Add-Member -MemberType NoteProperty -name "FieldName" -value $_.Title
		$FieldsCollection += $ExportField
	}
}

#Export to CSV file
$FieldsCollection | Export-Csv -Path $OutPutFieldsFile -NoTypeInformation 

#Disconnect SharePoint online connection
m365 logout
```

[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

***

## Contributors

| Author(s) |
|-----------|
| [Reshmee Auckloo](https://github.com/reshmee011)|
| [Ganesh Sanap](https://ganeshsanapblogs.wordpress.com/) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-get-customfields-lists" aria-hidden="true" />
