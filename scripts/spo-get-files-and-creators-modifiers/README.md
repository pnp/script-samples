---
plugin: add-to-gallery
---

# Get all files in a Document Library along with Created By and Modified By

## Summary

A customer recently wanted to find out who the most active users were in each site. They were planning for a migration and they wanted an idea who was creating and modifying the most files so they could bring them into the migration planning and testing. When connected to a site with Connect-PnPOnline this script will walk through the site's document libraries, list each file, when it was created and by whom, and when it was last modified by whom. It exports this to a CSV file. The customer can bring this CSV file into Excel and slice the data to the their heart's content. 

![Example Screenshot](assets/example.png)

For this customer they looped through a list of sites gotten from Get-PnPTenantSite and ran this code in a ForEach block. The Export-CSV command uses -Append, so all of the results were stored in one large file.

This was hastily written as a one-liner. It should probably be rewritten as a cleaner function in a module.


# [PnP PowerShell](#tab/pnpps)

```powershell

# Connect to the site we want the inventory from
Connect-PnPOnline -Url https://contoso.sharepoint.com -Interactive

# Get all of the Libraries we want
$LibraryList = Get-PnPList -Includes IsSystemList,RootFolder | Where-Object {($_.BaseType -eq "DocumentLibrary" -and $_.IsSystemList -eq $False) -or ($_.Title -eq "Site Pages")}

# All the files in all the document libraries
$LibraryList | ForEach-Object{Get-PnPListItem -List $_.RootFolder.Name | Where-Object{$_.FieldValues.FSObjType -ne 1} | Select-Object @{n="FileRef";e={$_.FieldValues.FileRef}},@{n="Created_x0020_By";e={$($_.FieldValues.Created_x0020_By).split("|")[2]}},@{n="Created";e={$_.FieldValues.Created}},@{n="Modified_x0020_By";e={$($_.FieldValues.Modified_x0020_By).split("|")[2]}},@{n="Modified";e={$_.FieldValues.Modified}}} | Export-Csv -Path .\FilesAndOwners.csv -Append

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Contributors

| Author(s) |
|-----------|
| [Todd Klindt](https://www.toddklindt.com)|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-get-files-and-creators-modifiers" aria-hidden="true" />