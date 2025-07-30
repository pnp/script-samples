# SharePoint List Content Type Migration with Data Preservation

This sample shows how to update a SharePoint list to use a different content type using PowerShell PnP.

⚠️ **Disclaimer**: This will only work if the columns in the Content Type match those already present in the list.

## Summary

This PowerShell script demonstrates how to update a SharePoint list to use a specific content type. The script connects to a SharePoint site, retrieves the target list, and updates its content types configuration.

## How It Works 🤔

The script follows this process:

1. **Create a Content Type**: First, create your content type in SharePoint
2. **Export as Template**: Use `Get-PnPSiteTemplate` to export the content type as a PnP template XML file
3. **Run the Script**: The script will:
   - Load all list items with their values into memory 🧠
   - Remove the old columns that need to be replaced 🗑️
   - Apply the PnP template containing the new content type
   - Restore all values into the new columns ✅

## Complete Column Migration

When you need to replace existing columns with new ones from a content type:

```powershell
# Required variables for advanced mode
$siteUrl = "https://xxx.sharepoint.com/sites/xxx"
$listName = "YourListName"
$contentTypeName = "YourContentTypeName"
$columnsToMap = @("Column1", "Column2", "Column3")  # Replace with actual column names
$userFields = @("AssignedTo", "CreatedBy")  # Replace with actual user field names if needed
$templatePath = "..\ContentTypeTemplate.xml"

# Connect to SharePoint Online
Connect-PnPOnline -Url $siteUrl -Interactive

# Enable content type management on the list
Set-PnPList -Identity $listName -EnableContentTypes $true
Write-Host "Content types enabled on the list."

# Backup data from old columns
$items = Get-PnPListItem -List $listName -PageSize 5000
$backupData = @{}

foreach ($item in $items) {
    $itemData = @{}
    # Backup old column data
    foreach ($column in $columnsToMap) {
        $itemData[$column] = $item[$column]
    }
    $backupData[$item.Id] = $itemData
}

# Remove old columns
foreach ($column in $columnsToMap) {
    Remove-PnPField -List $listName -Identity $column -Force
    Write-Host "Removed old column:" $column
}

# Apply PnP Provisioning Template
Invoke-PnPSiteTemplate -Path $templatePath
Write-Host "PnP template applied to the site."

# Get the content type
$contentType = Get-PnPContentType -Identity $contentTypeName

# Add the content type to the list
Add-PnPContentTypeToList -List $listName -ContentType $contentType
Write-Host "Content type added to the list."

# Update items to the new content type and restore data to new columns
foreach ($item in $items) {
    $itemId = $item.Id
    $itemData = $backupData[$itemId]
    
    # Handle user fields
    foreach ($userField in $userFields) {
        if ($itemData[$userField]) {
            $UserDto = $itemData[$userField];
            write-host "User: " $UserDto.Email

            $itemData[$userField] = $UserDto.Email
        }
    }

    # Update item content type
    Set-PnPListItem -List $listName -Identity $itemId -Values @{"ContentTypeId" = $contentType.Id }
    
    # Restore data to new columns
    Set-PnPListItem -List $listName -Identity $itemId -Values $itemData
    Write-Host "Updated item ID:" $itemId
}

Write-Host "All items updated to the new content type and old columns removed."

# Disconnect from SharePoint Online
Disconnect-PnPOnline
```

### What the Script Does 🛠️

1. **Enable Content Types**: Enables content type management on the list
2. **Backup Data**: Loads all rows with their values into memory 🧠
3. **Remove Old Columns**: Removes the columns specified in `$columnsToMap` 🗑️
4. **Apply Template**: Invokes the PnP template containing the new content type
5. **Add Content Type**: Adds the new content type to the list
6. **Restore Data**: Reloads all values into the new columns ✅
7. **Handle User Fields**: Properly processes user/people picker fields

### Limitations ⚠️

As mentioned, this script doesn't solve everything:
- Any views created with the old columns will no longer work, even if the new columns have the same name
- Custom forms may need to be updated
- Workflows referencing old columns may break
- There's definitely room for improvement in the script

## Contributors

| Author(s)                       |
| ------------------------------- |
| [Jeppe Spanggaard](https://github.com/jeppesc11) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-list-contenttype-migration" aria-hidden="true" />