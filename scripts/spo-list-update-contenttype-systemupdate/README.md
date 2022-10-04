---
plugin: add-to-gallery
---

# Update content type with system update of files in folder .

## Summary

Update content type with system update option to avoid updating modified and modified by properties for all files in a folder within a library to custom content type.

## Implementation

- Open Windows PowerShell ISE
- Create a new file
- Copy a script  below


# [PnP PowerShell](#tab/pnpps)
```powershell

#Config Variables
$SiteURL = "https://yourtenantname.sharepoint.com/sites/{siteName}"
$list = "listA" 
$FolderRelativeURL= "/LineManagement"
$NewContentType = "Content Type A"

Connect-PnPOnline -url $SiteURL  -Interactive
 
Try {

 $CAMLQuery = "<View Scope='RecursiveAll'><Query><Where><Eq><FieldRef Name='FileDirRef'/><Value Type='Text'>$FolderRelativeURL</Value></Eq></Where></Query></View>"

 $items = Get-PnPListItem -List $list -IncludeContentType -Query  $CAMLQuery
  
  forEach($listItem in $items){   
     Set-PnPListItem -UpdateType SystemUpdate -List  $list -ContentType "Content Type A" -Identity $listItem
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

