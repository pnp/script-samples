

# Open Office documents in the Client

## Summary

One of the most common requests from customers is that any office document in SharePoint site should open in the desktop client application so here goes:

## Implementation

- Open VS Code
- Create a new file
- Write a script as below
- Change the variables to target to your environment
- Run the script

## Screenshot of Output

![Example Screenshot](assets/example.png)

# [PnP PowerShell](#tab/pnpps)

```powershell

# SharePoint online site url
$siteUrl = "https://contoso.sharepoint.com/sites/SPConnect"

# Scope of feature: Web or Site
$featureScope = "Site"

# SharePoint Feature ID: in this case "Open Documents in Client Applications by Default (OpenInClient)"
$featureId = "8a4b8de2-6fd8-41e9-923c-c7c3c00f8295"	

# Another common scenario is Activating Document ID feature (Feature ID: b50e3104-6812-424f-a011-cc90e6327318)

# Connect to SharePoint Online site
Connect-PnPOnline -Url $siteUrl -Interactive

# Get Feature from SharePoint site
$spFeature = Get-PnPFeature -Scope $featureScope -Identity $featureId

# Check if feature found or not
if ($spFeature.DefinitionId -eq $null) {  
    Write-host "Activating Feature ($featureId)..." 
	
    # Activate the site feature
	Enable-PnPFeature -Scope $featureScope -Identity $FeatureId -Force
 
    Write-host -f Green "Feature ($featureId) has been activated Successfully!"
}
else {
    Write-host "Feature ($featureId) is already active on this site!"
}   
   
```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365](#tab/cli-m365-ps)

```powershell

# SharePoint online site url
$siteUrl = "https://contoso.sharepoint.com/sites/SPConnect"

# Scope of feature: Web or Site
$featureScope = "Site"

# SharePoint Feature ID: in this case "Open Documents in Client Applications by Default (OpenInClient)"
$featureId = "8a4b8de2-6fd8-41e9-923c-c7c3c00f8295"	

# Another common scenario is Activating Document ID feature (Feature ID: b50e3104-6812-424f-a011-cc90e6327318)

# Get Credentials to connect
$m365Status = m365 status
if ($m365Status -match "Logged Out") {
   m365 login
}

# Get all enabled features from SharePoint site
$allEnabledFeatures = m365 spo feature list --webUrl $siteUrl --scope $featureScope | ConvertFrom-Json

# Get feature from enabled features
$spfeature = $allEnabledFeatures | Where-Object { $_.DefinitionId -eq $featureId }

# Check if feature found or not
if($spfeature.DefinitionId -eq $null) {  
    Write-host "Activating Feature ($featureId)..." 
	
    # Activate the site feature
	m365 spo feature enable --webUrl $siteUrl --id $featureId --scope $featureScope
 
    Write-host -f Green "Feature ($featureId) has been activated Successfully!"
}
else {
    Write-host "Feature ($featureId) is already active on this site!"
}

```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

***

## Contributors

| Author(s) |
|-----------|
| Kasper Larsen, Fellowmind|
| [Ganesh Sanap](https://ganeshsanapblogs.wordpress.com/about) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-open-doc-in-client" aria-hidden="true" />
