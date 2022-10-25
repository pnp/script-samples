---
plugin: add-to-gallery
---

# List all tenant-wide extensions

## Summary

The following script lists all tenant-wide extensions deployed in the tenant. The sample returns the Id, Title, Extension Location and Extension Disabled status of each extension.
 
# [CLI for Microsoft 365 with PowerShell](#tab/cli-m365-ps)
```powershell
$listName = "Tenant Wide Extensions"
$fields = "Id, Title, TenantWideExtensionDisabled, TenantWideExtensionLocation"

$appcatalogurl = m365 spo tenant appcatalogurl get
m365 spo listitem list --title $listName --webUrl $appcatalogurl --fields $fields
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
 
# [CLI for Microsoft 365 with Bash](#tab/m365cli-bash)
```bash
#!/bin/bash

listName="Tenant Wide Extensions"
fields="Id, Title, TenantWideExtensionLocation, TenantWideExtensionDisabled"

appcatalogurl=$(m365 spo tenant appcatalogurl get)
m365 spo listitem list --title "$listName" --webUrl $appcatalogurl --fields  "$fields"
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
 
***

> [!NOTE]
> To view more/different properties of the extensions, adjust the internal names in the ``` fields ``` variable.

| Column | Internal Name | Description |
|--|--|--|
| Title | Title |Title of the extension.|
| Component Id|TenantWideExtensionComponentId|The manifest ID of the component. It has to be in GUID format and the component must exist in the App Catalog.|
| Component Properties|TenantWideExtensionComponentProperties|component properties.|
| Web Template|TenantWideExtensionWebTemplate|It can be used to target extension only to a specific web template.|
| List template|TenantWideExtensionListTemplate|List type as a number.|
| Location|TenantWideExtensionLocation|Location of the extension. There are different support locations for application customizers and ListView Command Sets.|
| Sequence|TenantWideExtensionSequence|The sequence of the extension in rendering.|
| Host Properties|TenantWideExtensionHostProperties|Additional server-side configuration, like pre-allocated height for placeholders.|
| Disabled|TenantWideExtensionDisabled|Is the extension enabled or disabled?|

## Source Credit

Sample first appeared on [List all tenant-wide extensions | CLI for Microsoft 365](https://pnp.github.io/cli-microsoft365/sample-scripts/spo/list-tenant-wide-extensions/)

## Contributors

| Author(s) |
|-----------|
| Shantha Kumar T |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-list-tenant-wide-extensions" aria-hidden="true" />
