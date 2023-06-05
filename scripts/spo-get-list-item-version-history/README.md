---
plugin: add-to-gallery
---

# SharePoint List Item Version History Retrieval

## Summary

This script retrieves the version history of a specified list item, including all field values or only selected fields. The field values can be filtered by providing a comma-separated list of field names.

# [PnP PowerShell](#tab/pnpps)

```powershell

param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$SiteUrl,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ListName,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [int]$ItemId,

    [string]$FieldNames = ""
)

Connect-PnPOnline -Url $SiteUrl -Interactive

$item = Get-PnPListItem -List $ListName -Id $ItemId
$file = Get-PnPProperty -ClientObject $item -Property File
$versions = Get-PnPProperty -ClientObject $item -Property Versions
$fileVersions = Get-PnPProperty -ClientObject $file -Property Versions


$listItemVersionHistory = @()
foreach ($version in $versions) {   

    $checkInComment = $fileVersions | Where-Object { $_.VersionLabel -eq $version.VersionLabel } | Select-Object -ExpandProperty CheckInComment
    $fieldValues = $version.FieldValues

    $fieldValuesFormatted = New-Object -TypeName PSObject
    foreach ($field in $fieldValues.GetEnumerator()) {
        $fieldName = $field.Key
        $fieldValue = $field.Value
        if ([string]::IsNullOrEmpty($FieldNames) -or ($FieldNames.Split(',') -contains $fieldName)) {
            $fieldValuesFormatted | Add-Member -MemberType NoteProperty -Name $fieldName -Value $fieldValue
        }
    }    
    
    $listItemVersionHistory += [PSCustomObject]@{
        VersionLabel = $version.VersionLabel
        VersionId = $version.VersionId
        IsCurrentVersion = $version.IsCurrentVersion
        Created = $version.Created
        CreatedBy = Get-PnPProperty -ClientObject $version.CreatedBy -Property Title
        FieldValues = $fieldValuesFormatted | ConvertTo-Json -Compress
        CheckInComment = $checkInComment
    }
}

Write-Output $listItemVersionHistory
```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

## Contributors

| Author(s) |
|-----------|
| [Michał Romiszewski](https://github.com/mromiszewski) |
| Kasper Larsen |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-get-list-item-version-history" aria-hidden="true" />