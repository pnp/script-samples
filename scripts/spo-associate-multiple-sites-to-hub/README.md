---
plugin: add-to-gallery
---

# Associate Multiple Site Collections to Hub Site

## Summary

This PowerShell script can be used to associate mutilple site collections to Hub site. You can provide list of site collection URLs in an array.

## Implementation

- Open Windows PowerShell ISE
- Create a new file
- Update the parameters with site collection URLs and hub site URL
- Save the file and run it
 
# [PnP PowerShell](#tab/pnpps)

```powershell

# Parameters

# Provide SharePoint online Hub site URL
$HubSiteURL = "https://******.sharepoint.com/sites/**********"

# Array of site collections to associate with hub site
$arrSCs = @("https://******.sharepoint.com/sites/**********", "https://******.sharepoint.com/sites/**********", "https://******.sharepoint.com/sites/**********")

# Get admin user credentials
$creds = (Get-Credential)

function AssociateHubSite {
	try {
		foreach ($SC in $arrSCs) { 
			Write-Host "Connecting site collection: " $SC 
			Connect-PnPOnline -Url $SC -Credentials $creds
			Add-PnPHubSiteAssociation -Site $SC -HubSite $HubSiteURL -ErrorAction Stop
			Write-Host "Hub site associated with site collection: " $SC -ForegroundColor Green            
		}
	}
	catch {
		Write-Host "Error in associating hub site $($SC): " $_.Exception.Message -ForegroundColor Red
	}   
	
	# Disconnect SharePoint online connection
	Disconnect-PnPOnline
}

AssociateHubSite

```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [SPO Management Shell](#tab/spoms-ps)

```powershell

# SharePoint tenant admin site collection URL
$adminSiteUrl = "https://contoso-admin.sharepoint.com"

# SharePoint online Hub site URL
$hubSiteURL = "https://contoso.sharepoint.com/sites/communicationhubsite"

# Array of site collections to associate with hub site
$arrayOfSites = @("https://contoso.sharepoint.com/sites/siteA", "https://contoso.sharepoint.com/sites/siteB", "https://contoso.sharepoint.com/sites/siteC")

# Connect to SharePoint Online admin site  
Connect-SPOService -Url $adminSiteUrl

function AssociateHubSite {
	try {
		foreach ($site in $arrayOfSites) { 
			Write-Host "Associating site collection: " $site 
			
			# Associating site collection with hub site
			Add-SPOHubSiteAssociation -Site $site -HubSite $hubSiteURL -ErrorAction Stop
			
			Write-Host "Hub site associated with site collection: " $site -ForegroundColor Green            
		}
	}
	catch {
		Write-Host "Error in associating hub site $($site): " $_.Exception.Message -ForegroundColor Red
	}   
	
	# Disconnect SharePoint online connection
	Disconnect-SPOService
}

AssociateHubSite

```

[!INCLUDE [More about SPO Management Shell](../../docfx/includes/MORE-SPOMS.md)]

# [CLI for Microsoft 365](#tab/cli-m365-ps)

```powershell

# SharePoint online Hub site URL
$hubSiteURL = "https://contoso.sharepoint.com/sites/communicationhubsite"

# Array of site collections to associate site with hub site
$arrayOfSites = @("https://contoso.sharepoint.com/sites/siteA", "https://contoso.sharepoint.com/sites/siteB", "https://contoso.sharepoint.com/sites/siteC")

# Get Credentials to connect
$m365Status = m365 status
if ($m365Status -match "Logged Out") {
   m365 login
}

# Get information about the specified hub site
$hubSiteDetails = m365 spo hubsite get --url $hubSiteURL | ConvertFrom-Json

function AssociateHubSite {
	try {
		foreach ($site in $arrayOfSites) { 
			Write-Host "Associating site collection: " $site 
			
			# Associating site collection with hub site
			m365 spo site hubsite connect --siteUrl $site --id $hubSiteDetails.ID
			
			Write-Host "Hub site associated with site collection: " $site -ForegroundColor Green            
		}
	}
	catch {
		Write-Host "Error in associating hub site $($site): " $_.Exception.Message -ForegroundColor Red
	}   
	
	# Disconnect SharePoint online connection
	m365 logout
}

AssociateHubSite

```

[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

***

## Contributors

| Author(s) |
|-----------|
| [Siddharth Vaghasia](https://github.com/siddharth-vaghasia) |
| [Ganesh Sanap](https://ganeshsanapblogs.wordpress.com/about) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]

<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-associate-multiple-sites-to-hub" aria-hidden="true" />