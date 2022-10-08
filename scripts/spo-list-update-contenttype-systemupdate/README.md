---
plugin: add-to-gallery
---

# Update content type of files in folder with system update

## Summary

Update content type with system update option for all files in a folder within a library to a custom content type to avoid updating modified and modified by properties.

## Implementation

- Open Windows PowerShell ISE
- Create a new file
- Copy a script  below


# [PnP PowerShell](#tab/pnpps)
```powershell

#Config Variables
$SiteURL = "https://tenant.sharepoint.com/sites/Estimator"
$ListName = "Documents" 
$FolderServerRelativePath= "/sites/Estimator/Shared Documents/LineManagement"
$NewContentType = "Legal"

Connect-PnPOnline -url $SiteURL  -Interactive
 
Try {

  #Get all files from folder
   Get-PnPListItem -List $ListName -PageSize 2000 | Where {$_.FieldValues.FileRef -like "$FolderServerRelativePath*" -and $_.FileSystemObjectType -eq "File"  } | ForEach-Object {
    Write-host $_.FieldValues.FileRef
   Set-PnPListItem -UpdateType SystemUpdate -List  $ListName -ContentType $NewContentType -Identity $_
  }
}
catch {
    write-host "Error: $($_.Exception.Message)" -foregroundcolor Red
}
```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***

## Contributors

| Author(s) |
|-----------|
| [Reshmee Auckloo](https://github.com/reshme011) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-list-update-contenttype-systemupdate" aria-hidden="true" />
