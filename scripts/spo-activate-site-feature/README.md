---
plugin: add-to-gallery
---

# Activate a site feature in SharePoint online

## Summary

This sample script shows how to Activate a site feature in SharePoint online site.

Scenario inspired from this blog post: [Activate a site feature in SharePoint Online using PnP PowerShell](https://ganeshsanapblogs.wordpress.com/2020/12/03/activate-a-site-feature-in-sharepoint-online-using-pnp-powershell/)

![Outupt Screenshot](assets/output.png)

# [PnP PowerShell](#tab/pnpps)

```powershell

# SharePoint online site url
$siteUrl = "https://<tenant>.sharepoint.com/contoso"

# Scope of feature: Web or Site
$featureScope = "Web"

# SharePoint Feature ID: E.g. Spaces feature ID
$featureId = "2ac9c540-6db4-4155-892c-3273957f1926"	

# Connect to SharePoint Online site  
Connect-PnPOnline -Url $siteUrl -Interactive

# Get Feature from SharePoint site
$spacesFeature = Get-PnPFeature -Scope $featureScope -Identity $featureId

# Check if feature found or not
if($spacesFeature.DefinitionId -eq $null) {  
    Write-host "Activating Feature ($featureId)..." 
	
    # Activate the site feature eature
    Enable-PnPFeature -Scope $featureScope -Identity $FeatureId -Force
 
    Write-host -f Green "Feature ($featureId) has been activated Successfully!"
}
else {
    Write-host "Feature ($featureId) is already active on this site!"
}

```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***

## Contributors

| Author(s) |
|-----------|
| [Ganesh Sanap](https://ganeshsanapblogs.wordpress.com/about) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-activate-site-feature" aria-hidden="true" />
