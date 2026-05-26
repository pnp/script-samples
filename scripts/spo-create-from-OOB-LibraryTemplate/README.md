# Create a library from Out-of-the-Box (OOB) library template

## Summary

This post demonstrates how to create a SharePoint library using an out-of-the-box (OOB) list template via the Site Script ApplyListDesign REST API and how to call it from PnP PowerShell.

While `Invoke-PnPListDesign` is useful for deploying custom list templates (see [Custom document library template using PnP PowerShell](https://reshmeeauckloo.com/posts/powershell-invoke-spolistdesign-to-create-instances-of-lists-libraires/)), creating a library from an OOB list design requires calling the `ApplyListDesign()` REST endpoint.

---

## The Solution: REST API Hack

By using SharePoint's REST API hack through PnP PowerShell as a hack, we can programmatically apply these site designs to existing sites. Here's how to do it:

# [PnP PowerShell](#tab/pnpps)

```powershell
$SiteUrl     = "https://yourtenant.sharepoint.com/sites/YourSite"
$ClientId    = "<your-client-id>"   # Entra app client id or omit for interactive login
$Method      = "POST"
$Endpoint    = "_api/Microsoft.Sharepoint.Utilities.WebTemplateExtensions.SiteScriptUtility.ApplyListDesign()"

# The list design ID for the Media Library template (example)
$listDesignId = "7fdc8cba-3e07-4851-a7ac-b747040ff1ce"

# The runtime parameter name used by the template to set the list name
$listName_FieldValue = "MediaLibrary_listName"
$listName = "Media Lib"

# Build the body object. runtimeParameters must be a JSON string.
$BodyObject = @{
    listDesignId      = $listDesignId
    store             = 1
    runtimeParameters = "{`"$listName_FieldValue`":`"$listName`"}"
}

# Connect using PnP
Connect-PnPOnline -Url $SiteUrl -ClientId $ClientId -Interactive

$Uri = "$SiteUrl/$Endpoint"

# Call the REST endpoint using PnP helper
$Response = Invoke-PnPSPRestMethod -Method $Method -Url $Uri -Content $BodyObject

# Output the response for debugging
$Response | ConvertTo-Json -Depth 10
```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***

## Source Credit

Sample first appeared on [Create a library from Out-of-the-Box (OOB) library template with PnP PowerShell](https://reshmeeauckloo.com/posts/powershell-pnp-create-oob-library/)

## Contributors

| Author(s) |
|-----------|
| [Reshmee Auckloo](https://github.com/reshmee011) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-create-from-OOB-LibraryTemplate" aria-hidden="true" />
