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

#Parameters
$SiteURL="https://contoso.sharepoint.com/teams/TEAM-Test"
$ReportOutput ="C:\Temp\ContentTypeUsage.csv"
$ContentTypeName="Admin"

cd $PSScriptRoot

#Delete the Output Report, if exists
If (Test-Path $ReportOutput) { Remove-Item $ReportOutput }

Try{
    #Connect to the Site       
    Connect-PnPOnline -Url $SiteURL -Interactive

    #Get All Lists
    $Lists = Get-PnPList -Includes RootFolder | Where-Object {$_.Hidden -eq $False}

    #Get content types of each list from the web
    $ContentTypeUsages=@()
     $ctx = (Get-PnPConnection).Context
    ForEach($List in $Lists)
    {
        Write-host -f Yellow "Scanning List:" $List.Title
        $ListURL =  $List.RootFolder.ServerRelativeUrl

        #get all content types from the list
        $ContentType = Get-PnPContentType -List $List | Where {$_.Name -eq $ContentTypeName}

        #Collect list details
        If($ContentType)
        {
            $ContentTypeUsage = New-Object PSObject
            $ContentTypeUsage | Add-Member NoteProperty SiteURL($SiteURL)
            $ContentTypeUsage | Add-Member NoteProperty ListName($List.Title)
            $ContentTypeUsage | Add-Member NoteProperty ListURL($ListURL)
            $ContentTypeUsage | Add-Member NoteProperty ContentTypeName($ContentType.Name)
            $ContentTypeUsage | Add-Member NoteProperty Type('list/library')
            $ContentTypeUsage | Add-Member NoteProperty ListItemID('')
            $ContentTypeUsage | Add-Member NoteProperty VersionNumber('')
            Write-host -f Green "`tFound the Content Type in Use!"
            $ContentTypeUsages+= $ContentTypeUsage
            #find content type referenced within list items
            $ListItems = Get-PnPListItem -List $List  -PageSize 500 -IncludeContentType
            ForEach($item in $ListItems)
            {
               if($item.ContentType.Id.StringValue -eq $contentType.Id.StringValue)
               {
               Write-host -f Green "`t`tFound the Content Type in Use for item id " + $item.id
                 $ContentTypeUsage = New-Object PSObject
                 $ContentTypeUsage | Add-Member NoteProperty SiteURL($SiteURL)
                 $ContentTypeUsage | Add-Member NoteProperty ListName($List.Title)
                 $ContentTypeUsage | Add-Member NoteProperty ListURL($ListURL)
                 $ContentTypeUsage | Add-Member NoteProperty ContentTypeName($ContentType.Name)
                 $ContentTypeUsage | Add-Member NoteProperty Type('Item/FileItem')
                 $ContentTypeUsage | Add-Member NoteProperty ListItemID($item.Id)
                 $ContentTypeUsages+= $ContentTypeUsage
                 #adding sleep of 2 secs to prevent too many requests being sent which might cause the script to fail
                 Start-Sleep -Seconds 2
               }
            $versions = Get-PnPProperty -ClientObject $item -Property Versions              
               #find content type referenced within list versions
               ForEach($version in  $versions )
               {
               if($contentType.Id.StringValue -eq  $version.FieldValues.ContentTypeId.StringValue)
                {
                  Write-host -f Green "`t`t`tFound the Content Type in Use for version " + $version.VersionLabel + "pertaining to item id " + $item.id
                 $ContentTypeUsage = New-Object PSObject
                 $ContentTypeUsage | Add-Member NoteProperty SiteURL($SiteURL)
                 $ContentTypeUsage | Add-Member NoteProperty ListName($List.Title)
                 $ContentTypeUsage | Add-Member NoteProperty ListURL($ListURL)
                 $ContentTypeUsage | Add-Member NoteProperty ContentTypeName($ContentType.Name)
                 $ContentTypeUsage | Add-Member NoteProperty Type('ItemVersion/FileVersion')
                 $ContentTypeUsage | Add-Member NoteProperty ListItemID($item.Id)
                 $ContentTypeUsage | Add-Member NoteProperty VersionNumber($version.VersionLabel)
                 $ContentTypeUsages+= $ContentTypeUsage

                 $version.FieldValues.ContentTypeId = $item.ContentType.Id
                 $ctx.ExecuteQuery()
                 #adding sleep of 2 secs to prevent too many requests being sent which might cause the script to fail
                 Start-Sleep -Seconds 2
                }
               }
                #check list version
            }
            #Export the result to CSV file
            $ContentTypeUsages | Export-CSV $ReportOutput -NoTypeInformation -Append
        }
    }
}
Catch {
    write-host -f Red "Error Generating Content Type Usage Report!" $_.Exception.Message
}
```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Contributors

| Author(s) |
|-----------|
| [Reshmee Auckloo](https://github.com/reshmee011)|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-get-contenttype-usage-listitem-listversion" aria-hidden="true" />
