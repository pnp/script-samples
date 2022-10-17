---
plugin: add-to-gallery
---

# Copy a library view across multiple libraries in destination site 

## Summary
I had a requirement to create a flat view "checked out files by me" across all libraries to enable users to easily spot checked out files by them within folders. I created the view in one library using the SharePoint Online UI and I used the script to copy the view to all libraries in another site. The url of the view needed to be without spaces so I created the view with a name without spaces and amended the title of the view using the script.

The sample script using PnP PowerShell to copy a library view from the source site and create it in libraries present in destination site.

Please refactor according to requirements as in the sample given only fields, views, query, item limit and certain settings are copied across.

# [CLI for Microsoft 365 with PowerShell](#tab/cli-m365-ps)

```powershell

$SourceSite = Read-Host "Enter the source site url from which to copy the view from" #e.g.https://contose.sharepoint.com/sites/test
$SourceList = Read-Host "Enter the source Library from which to copy the view from" #Documents
$SourceViewName = Read-Host "Enter the view name to be copied from" #Checked Out FlatView

$destSiteUrl = Read-Host "Enter the destination site url to which to copy the view to" #e.g.https://contose.sharepoint.com/sites/testClone2

$dateTime = (Get-Date).toString("dd-MM-yyyy")
$invocation = (Get-Variable MyInvocation).Value
$directorypath = Split-Path $invocation.MyCommand.Path
$fileName = "CheckedOutViewCreationReport-" + $dateTime + ".csv"
$OutPutView = $directorypath + $fileName

#Arry to Skip System Lists and Libraries
$SystemLists = @("Converted Forms", "Master Page Gallery", "Customized Reports", "Form Templates", "List Template Gallery", "Theme Gallery",
                            "Reporting Templates", "Solution Gallery", "Style Library", "Web Part Gallery","Site Assets", "wfpub", "Site Pages", "Images", "MicroFeed","Pages")

#remove any spaces from view 
$SourceInternalName = $SourceViewName -replace '\s',''

$m365Status = m365 status

if ($m365Status -eq "Logged Out") {
    # Connection to Microsoft 365
    m365 login
}


$CheckedOutView = m365 spo list view get --webUrl $SourceSite --listTitle $SourceList --viewTitle $SourceViewName |ConvertFrom-Json
[xml] $listViewXML = $CheckedOutView.ListViewXml

#Array to Hold Result - PSObjects

$ViewCollection = @()

$fieldsArr = @();

$listViewXML.View.ViewFields.FieldRef |  ForEach-Object {
 $fieldsArr +=$_.Name;
}

$viewScope=1 #enum recursive = 1 , RecursiveAll = 2, FilesOnly = 3

#retrieving only document libraries from destination libraries
 $lists= m365 spo list list --webUrl $destSiteUrl | ConvertFrom-Json  
  foreach ($list in ($lists | Where-Object {$_.BaseTemplate -eq 101 -and $_.Hidden -eq $false -and $SystemLists -notcontains $_.Title})) {
   $viewInL =  m365 spo list view get --webUrl $destSiteUrl --listTitle $list.Title --viewTitle $SourceViewName
   #create view only if not present
   if(!$viewInl)
   {

     $ExportVw = New-Object PSObject
     $ExportVw | Add-Member -MemberType NoteProperty -name "Site URL" -value $destSiteUrl
     $ExportVw | Add-Member -MemberType NoteProperty -name "Library Name" -value $list.Title
     $ExportVw | Add-Member -MemberType NoteProperty -name "View Name" -value $SourceViewName

    #create view
     m365 spo list view add --webUrl $destSiteUrl --listTitle $list.Title --title $SourceInternalName  --fields ($fieldsArr -join ",") --rowLimit $CheckedOutView.RowLimit
     $viewInL = m365 spo list view get --webUrl $destSiteUrl --listTitle $list.Title --viewTitle $SourceInternalName  
    

     if($viewInL)
     {
       # Update the list view name to the display name and change the scope to recursive so that all files are displayed without any folders.
      m365 spo list view set --webUrl $destSiteUrl --listTitle $list.Title  --viewTitle $SourceInternalName --Title $SourceViewName --ViewQuery $CheckedOutView.ViewQuery.Replace('"','\"') --Scope $viewScope
      
      #m365 spo list view set --webUrl https://reshmeeauckloo.sharepoint.com/sites/TestClone2 --listTitle "Documents" --viewTitle "FlatView" --Title "FlatView1"
      #Set-PnPView -List $list.Title -Identity $SourceInternalName -Values @{Scope=$viewScope;Title=$SourceViewName}   
     }
      $ViewCollection += $ExportVw
    }
   }

#Export the result Array to CSV file
$ViewCollection | Export-CSV $OutPutView -Force -NoTypeInformation

m365 logout
```

[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

# [PnP PowerShell](#tab/pnpps)
```powershell
  $SourceSite = Read-Host "Enter the source site url from which to copy the view from" #e.g.https://contoso.sharepoint.com/sites/Team1
$SourceList = Read-Host "Enter the source Library from which to copy the view from" #Demo Library
$SourceViewName = Read-Host "Enter the view name to be copied from" #Checked Out Files

$destSiteUrl = Read-Host "Enter the destination site url to which to copy the view to" #e.g.https://contoso.sharepoint.com/sites/testDemo

$dateTime = (Get-Date).toString("dd-MM-yyyy")
$invocation = (Get-Variable MyInvocation).Value
$directorypath = Split-Path $invocation.MyCommand.Path
$fileName = "CheckedOutViewCreationReport-" + $dateTime + ".csv"
$OutPutView = $directorypath + $fileName

#Arry to Skip System Lists and Libraries
$SystemLists = @("Converted Forms", "Master Page Gallery", "Customized Reports", "Form Templates", "List Template Gallery", "Theme Gallery",
                            "Reporting Templates", "Solution Gallery", "Style Library", "Web Part Gallery","Site Assets", "wfpub", "Site Pages", "Images", "MicroFeed","Pages")

#remove any spaces from view name
$SourceInternalName = $SourceViewName -replace '\s',''

Connect-PnPOnline -Url $SourceSite -Interactive

$CheckedOutView = Get-PnPView -List $SourceList -Identity $SourceViewName -Includes RowLimit, ViewQuery, ViewFields

#Array to Hold Result - PSObjects

$ViewCollection = @()

$fieldsArr = @();

$CheckedOutView.ViewFields |  ForEach-Object {
$fieldsArr +=$_;
}

#Flat view parameter
$viewScope=[Microsoft.SharePoint.Client.ViewScope]::Recursive 

Connect-PnPOnline -Url $destSiteUrl -UseWebLogin

#retrieving only document libraries from destination libraries
  foreach ($list in (Get-PnPList | ? {$_.BaseTemplate -eq 101 -and $_.Hidden -eq $false -and $SystemLists -notcontains $_.Title})) {
   $viewInL =  Get-PnPView -List $list.Title -Identity $SourceViewName -ErrorAction SilentlyContinue
   #create view only if not present
   if(!$viewInl)
   {

     $ExportVw = New-Object PSObject
     $ExportVw | Add-Member -MemberType NoteProperty -name "Site URL" -value $destSiteUrl
     $ExportVw | Add-Member -MemberType NoteProperty -name "Library Name" -value $list.Title
     $ExportVw | Add-Member -MemberType NoteProperty -name "View Name" -value $SourceViewName

    #create view with name without spaces and settings from source view 
     Add-PnPView -List $list.Title -Title $SourceInternalName -Query $CheckedOutView.ViewQuery -Fields $fieldsArr -RowLimit $CheckedOutView.RowLimit
     $viewInL =  Get-PnPView -List $list.Title -Identity $SourceInternalName -ErrorAction SilentlyContinue

     if($viewInL)
     {
       # Update the list view name to the display name and change the scope to recursive so that all files are displayed without any folders.
      Set-PnPView -List $list.Title -Identity $SourceInternalName -Values @{Scope=$viewScope;Title=$SourceViewName}   
     }
      $ViewCollection += $ExportVw
    }
   }

#Export the result Array to CSV file
$ViewCollection | Export-CSV $OutPutView -Force -NoTypeInformation

Disconnect-PnPOnline
 
```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Contributors

| Author(s) |
|-----------|
| [Reshmee Auckloo](https://github.com/reshmee011)|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-copy-library-view" aria-hidden="true" />
