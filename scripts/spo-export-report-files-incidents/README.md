

# Report of SharePoint Files Incidents

## Summary
The script identifies the following events:

- Renaming a file
- Restoring a file from the recycle bin
- Sharing a file with someone
- Reducing a file's size by more than 50%
- Moving a file within the library
- Checking out a file

Additionally, it tracks the list of people who edit each file and exports the complete list of editors in the library. This allows us to identify users who shouldn't have editing rights or those who edited files only occasionally and then stopped. By keeping an eye on these factors, the script helps maintain a more secure and efficient collaborative environment.

The script produces two CSV files as its output. The first file contains information about incidents, while the second file contains details about editors.

![Example Screenshot](assets/example.png)


# [PnP PowerShell](#tab/pnpps)

```powershell

# Use your variables
$targetSiteUrl = "https://contoso.sharepoint.com/sites/siteExample"
$libraryName = "Documents"

$editors = New-Object PSObject

function Get-DocumentLibrary {
    param (
        [string]$SiteUrl,
        [string]$LibraryName
    )

    $documentLibrary = Get-PnPList -Identity $LibraryName
    if ($documentLibrary.BaseTemplate -ne [Microsoft.SharePoint.Client.ListTemplateType]::DocumentLibrary) {
        Write-Host "The list is not a document library"
        return $null
    }

    return $documentLibrary
}

function Get-IsFolder {
    param (
        [Microsoft.SharePoint.Client.ListItem]$document
    )

    $fsObjType = $document.FieldValues["FSObjType"]

    return $fsObjType -eq 1
}

function Get-IncidentObject {
    param (
        [Microsoft.SharePoint.Client.ListItem]$document
    )

    $fileName = $document.FieldValues["FileLeafRef"]
    $fileId = $document.FieldValues["ID"]
    $fileType = $document.FieldValues["File_x0020_Type"]
    $fileSize = $document.FieldValues["File_x0020_Size"]
    $createdBy = $document.FieldValues["Created_x0020_By"]
    $createdDate = $document.FieldValues["Created_x0020_Date"]
    $modifiedBy = $document.FieldValues["Modified_x0020_By"]
    $modifiedDate = $document.FieldValues["Last_x0020_Modified"]

    $documentMetadata = [PSCustomObject]@{
        FileName     = $fileName
        FileId       = $fileId
        FileType     = $fileType
        FileSize     = $fileSize
        CreatedBy    = $createdBy
        CreatedDate  = $createdDate
        ModifiedBy   = $modifiedBy
        ModifiedDate = $modifiedDate
    }

    return $documentMetadata
}

function Get-ClonedPSCustomObject {
    param (
        [Parameter(Mandatory)]
        [PSCustomObject]$object
    )
    $newObject = New-Object PSObject
    $object.PSObject.Properties | ForEach-Object {
        $newObject | Add-Member -MemberType $_.MemberType -Name $_.Name -Value $_.Value
    }
    return $newObject
}

function Get-FileActivitiesIncidents {
    param (
        [string]$SiteUrl,
        [string]$documentLibraryId,
        [string]$fileId,
        [PSCustomObject]$incidentObj
    )

    # Get just itemUrl in SharePoint api 2.0 format from the sharing information of the file
    $requestUrl = "$SiteUrl/_api/web/Lists('$documentLibraryId')/GetItemById('$fileId')/GetSharingInformation?%24select=itemUrl"
    $sharingInformation = Invoke-PnPSPRestMethod -Url $requestUrl -Method Post -Accept "application/json" -Content "{}"

    # Get the file activities from the SharePoint api 2.0
    $itemUrl = $sharingInformation.itemUrl
    $activities = Invoke-PnPSPRestMethod -Url "$itemUrl/activities" -Accept "application/json"

    $incidents = @()

    $activities.value | ForEach-Object {
        $activity = $_
        $isRename = $activity.action."rename"
        $isShare = $activity.action."share"
        $isMoved = $activity.action."move"
        $isRestored = $activity.action."restore"

        $incidentToAdd = Get-ClonedPSCustomObject -object $incidentObj

        $editor = $activity.actor.user.userPrincipalName
        IncrementEditor -key $editor

        $incidentToAdd | Add-Member -MemberType NoteProperty -Name "Who" -Value $editor
        $incidentToAdd | Add-Member -MemberType NoteProperty -Name "When" -Value $activity.times.recordedTime

        if ($isRename) {
            $incidentToAdd | Add-Member -MemberType NoteProperty -Name "Incident" -Value "Filename has been changed"
            $incidentToAdd | Add-Member -MemberType NoteProperty -Name "ValueBefore" -Value $isRename.oldName
            $incidentToAdd | Add-Member -MemberType NoteProperty -Name "ValueAfter" -Value ""
            $incidents += $incidentToAdd
        }

        if ($isMoved) {
            $incidentToAdd | Add-Member -MemberType NoteProperty -Name "Incident" -Value "File has been moved"
            $incidentToAdd | Add-Member -MemberType NoteProperty -Name "ValueBefore" -Value $isMoved.From
            $incidentToAdd | Add-Member -MemberType NoteProperty -Name "ValueAfter" -Value ""
            $incidents += $incidentToAdd
        }

        if ($isShare) {
            $formattedRecipients = $isShare.recipients | ForEach-Object {
                $_.user.userPrincipalName
            }

            $incidentToAdd | Add-Member -MemberType NoteProperty -Name "Incident" -Value "File has been shared"
            $incidentToAdd | Add-Member -MemberType NoteProperty -Name "ValueBefore" -Value ""
            $incidentToAdd | Add-Member -MemberType NoteProperty -Name "ValueAfter" -Value $formattedRecipients
            $incidents += $incidentToAdd
        }

        if ($isRestored) {
            $incidentToAdd | Add-Member -MemberType NoteProperty -Name "Incident" -Value "File has been restored"
            $incidentToAdd | Add-Member -MemberType NoteProperty -Name "ValueBefore" -Value ""
            $incidentToAdd | Add-Member -MemberType NoteProperty -Name "ValueAfter" -Value ""
            $incidents += $incidentToAdd
        }
    }

    return $incidents
}

function IncrementEditor {
    param (
        [Parameter(Mandatory)]
        [string]$key
    )

    if ($editors.PSObject.Properties[$key]) {
        $editors.$key += 1
    }
    else {
        $editors | Add-Member -MemberType NoteProperty -Name $key -Value 1
    }
}
function Get-FileIsCheckedOut {
    param (
        [Parameter(Mandatory)]
        [Microsoft.SharePoint.Client.ListItem]$item,

        [Parameter(Mandatory)]
        [PSCustomObject]$incidentObj
    )

    $fileIsCheckedOut = $item.FieldValues["CheckoutUser"]
    if ($fileIsCheckedOut) {
        $incidentObj | Add-Member -MemberType NoteProperty -Name "Incident" -Value "File is checked out"
        $incidentObj | Add-Member -MemberType NoteProperty -Name "ValueBefore" -Value ""
        $incidentObj | Add-Member -MemberType NoteProperty -Name "ValueAfter" -Value $fileIsCheckedOut.Email
        return $incidentObj
    }
}

function Get-FileSizeHasDecreasedByMoreThan50Percent {
    param (
        [Parameter(Mandatory)]
        [Microsoft.SharePoint.Client.ClientObject]$version1,

        [Parameter(Mandatory)]
        [Microsoft.SharePoint.Client.ClientObject]$version2,

        [Parameter(Mandatory)]
        [string]$modifiedBy,

        [Parameter(Mandatory)]
        [string]$actionModifiedDate,

        [Parameter(Mandatory)]
        [PSCustomObject]$incidentObj
    )
    $fileSize1 = $version1.Length
    $fileSize2 = $version2.Length

    if ($fileSize1 -gt $fileSize2) {
        $fileSizeDecrease = $fileSize1 - $fileSize2
        $fileSizeDecreasePercentage = $fileSizeDecrease / $fileSize1

        if ($fileSizeDecreasePercentage -gt 0.5) {

            $incidentObj | Add-Member -MemberType NoteProperty -Name "Incident" -Value "File size has decreased by more than 50%"
            $incidentObj | Add-Member -MemberType NoteProperty -Name "ValueBefore" -Value $fileSize2
            $incidentObj | Add-Member -MemberType NoteProperty -Name "ValueAfter" -Value $fileSize1
    
            return $incidentObj      
        }
    }
}

function Get-EditorIncident {
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$editorsIncident,

        [Parameter(Mandatory = $true)]
        [string]$fileEditors
    )

    $editorsIncident | Add-Member -MemberType NoteProperty -Name "Who" -Value $fileEditors
    $editorsIncident | Add-Member -MemberType NoteProperty -Name "When" -Value ""
    $editorsIncident | Add-Member -MemberType NoteProperty -Name "Incident" -Value "File Editors"
    $editorsIncident | Add-Member -MemberType NoteProperty -Name "ValueBefore" -Value ""
    $editorsIncident | Add-Member -MemberType NoteProperty -Name "ValueAfter" -Value ""
    return $editorsIncident
}


function Get-DocumentVersionsIncidents {
    param (
        [System.Collections.Generic.List[Microsoft.SharePoint.Client.ListItemVersion]]$documentVersions,
        [Microsoft.SharePoint.Client.ListItem]$document,
        [Microsoft.SharePoint.Client.File]$documentFile,
        [PSCustomObject]$incidentObj
    )

    $previousVersion = $null
    $previousFileVersion = $null
    $incidents = @()
    
    #List of ediors for the file, creator is a first editor
    $creator = $document.FieldValues["Created_x0020_By"].Replace("i:0#.f|membership|", "") 
    $fileEditors = $creator + ";"
    IncrementEditor -key $creator

    for ($versionIndex = 0; $versionIndex -lt $documentVersions.Count; $versionIndex++) {
        $version = $documentVersions[$versionIndex]
        $incidentToAdd = Get-ClonedPSCustomObject -object $incidentObj

        #For some reason the first version does not have the FileVersion property so we take it from the documentFile
        if ($versionIndex -eq 0) {
            $fileVersion = $documentFile
        }
        else {
            $fileVersion = Get-PnPProperty -ClientObject $version -Property FileVersion
        }

        # in next steps we compare two versions of the file so we need to skip the first version
        if ($null -eq $previousVersion) {
            $previousVersion = $version
            $previousFileVersion = $fileVersion
            continue
        }

        $editor = $version.FieldValues["Modified_x0020_By"].Replace("i:0#.f|membership|", "")
        $fileEditors += $editor + ";"
        IncrementEditor -key $editor
        
        $incidentToAdd | Add-Member -MemberType NoteProperty -Name "Who" -Value $editor
        $incidentToAdd | Add-Member -MemberType NoteProperty -Name "When" -Value $version.FieldValues["Last_x0020_Modified"] 

        $fileIsCheckoutIncident = Get-ClonedPSCustomObject -object $incidentToAdd
        $fileIsCheckedOut = Get-FileIsCheckedOut -item $document -incidentObj $fileIsCheckoutIncident
        if ($fileIsCheckedOut) {
            $incidents += $fileIsCheckedOut
        }

        $fileSizeHasDecreasedIncident = Get-ClonedPSCustomObject -object $incidentToAdd
        $fileSizeHasDecreased = Get-FileSizeHasDecreasedByMoreThan50Percent -version1 $fileVersion -version2 $previousFileVersion -modifiedBy $version.FieldValues["Modified_x0020_By"] -actionModifiedDate $version.FieldValues["Last_x0020_Modified"] -incidentObj  $fileSizeHasDecreasedIncident

        if ($fileSizeHasDecreased) {
            $incidents += $fileSizeHasDecreased
        }

        $previousVersion = $version
        $previousFileVersion = $fileVersion
    }

    # For every file add an incident with all editors
    $editorsIncident = Get-ClonedPSCustomObject -object $incidentObj
    $incidents += Get-EditorIncident -editorsIncident $editorsIncident -fileEditors $fileEditors

    return $incidents
}

function Get-CSVDataFromEditorsObject {
    $csvData = @()
    $keys = $editors.PSObject.Properties | ForEach-Object { $_.Name }

    # Add key-value pairs to the CSV data
    foreach ($key in $keys) {
        $csvData += [PSCustomObject]@{
            Name       = $key
            Activities = $editors.$key
        }
    }

    return $csvData
}

function CheckFiles {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$SiteUrl,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$LibraryName,

        [Parameter]
        [string]$Date
    )

    try {
        Connect-PnPOnline -Url $SiteUrl -Interactive

        # Get the document library
        $documentLibrary = Get-DocumentLibrary -SiteUrl $SiteUrl -LibraryName $LibraryName
    
        # If the list is not a document library, return
        if (-not $documentLibrary) { return }
    
        $documents = Get-PnPListItem -List $LibraryName -Fields "FileLeafRef", "ID", "File_x0020_Type", "File_x0020_Size", "Created_x0020_By", "Created_x0020_Date", "Modified_x0020_By", "Last_x0020_Modified", "CheckoutUser", "Versions", "File"
        $incidents = @()

        # Loop through all documents in the library
        foreach ($document in $documents) {

            # If the item is a folder, skip it
            if (Get-IsFolder -document $document) { continue; }

            $documentVersions = Get-PnPProperty -ClientObject $document -Property Versions
            $documentFile = Get-PnPProperty -ClientObject $document -Property File
    
            # Get an empty incident object
            $incidentObj = Get-IncidentObject -document $document

            # Get the incidents for the file activities - SharePoint api 2.0
            $incidents += Get-FileActivitiesIncidents -SiteUrl $SiteUrl -documentLibraryId $documentLibrary.Id -fileId $document.Id -incidentObj $incidentObj 

            # Get the incidents for the file versions
            $incidents += Get-DocumentVersionsIncidents -document $document -documentVersions $documentVersions -documentFile $documentFile -incidentObj $incidentObj
        }

        # Export the incidents to a CSV file
        $incidents | Export-Csv -Path "$PSScriptRoot/report.csv" -NoTypeInformation
        
        # Export the editors to a CSV file
        $csvEditorsData = Get-CSVDataFromEditorsObject
        $csvEditorsData | Export-Csv -Path "$PSScriptRoot/editors.csv" -NoTypeInformation

        Disconnect-PnPOnline
    }
    catch {
        Write-Host $_.Exception.Message
    }
}

CheckFiles -SiteUrl $targetSiteUrl -LibraryName $libraryName


```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***


## Source Credit

Sample first appeared on [https://michalkornet.com/2023/09/19/Report-of-SharePoint-Files-Incidents.html](https://michalkornet.com/2023/09/19/Report-of-SharePoint-Files-Incidents.html)

## Contributors

| Author(s)                                 |
| ----------------------------------------- |
| [Michał Kornet](https://github.com/mkm17) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-export-report-files-incidents" aria-hidden="true" />