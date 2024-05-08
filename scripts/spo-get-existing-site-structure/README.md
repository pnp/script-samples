---
plugin: add-to-gallery
---

# Get (or export) an existing site structure in a SharePoint Online tenant

## Summary
  The `Get-SiteStructure` function is a PowerShell function that could be part of a larger script or module. 
  Its purpose is to provide a function that retrieves an existing structure of a SharePoint Online (SPO) tenant
  and its content for further processing.

  The function takes in several parameters:
  * `$RootSiteUrl`: The URL of the root site to start with.
  * `$WithSiteContent`: A switch parameter that determines whether the site content (libraries) should be included.
  * `$AsObject`: A switch parameter that determines whether the result will be returned as an object to be processed later.

  The main function consists of several sub-functions define the analysis or export process:
  1. initialize some variables,
  1. analyze whether to start with a home site or hub site,
  1. get informations about the selected root site,
  1. get all assigned sites (and hubs),
  1. and optionally retrieve also site content (document libraries and lists). 
  
  Finally, `Get-SiteStructure` returns the site structure, optionally as an object that can be processed later:
  * `Tenant`: The tenant's name
  * `Version`: Timestamp of the execution
  * `SharePoint`: High-level inforamtion about the tenant (for now, only the `TenantId`)
  * `Structure`: The retrieved structure, consisting of sites and site content (optional)

> [!NOTE]
> The function needs an exisiting connection to the SPO admin center; at least SharePoint administrator rights are needed.

## Usage
First of all, connect to the SPO admin center:

```powershell
$adminUrl = "your SPO tenant admin url"
Connect-PnPOnline -Url $adminUrl -Interactive
```  

Then, use the function `Get-SiteStructure`:

```powershell
Get-SiteStructure -RootSiteUrl "https://<yourtenant>.sharepoint.com/sites/<your(hub)site>" -WithSiteContent

# store the output as a structured object in a variable
$result = Get-SiteStructure -RootSiteUrl "https://<yourtenant>.sharepoint.com/sites/<your(hub)site>" -WithSiteContent -AsObject
```

Further processing can be done on the `$result` object along your needs, e.g.:
```powershell
$result | ConvertTo-Json -Depth 4 > hub-structure.json
```


# [PnP PowerShell](#tab/pnpps)

```powershell
# Initial parameters to start (connect to SPO admin center)
$adminUrl = "your SPO tenant admin url"
Connect-PnPOnline -Url $adminUrl -Interactive


Function Get-SiteStructure {
  param (
    [Parameter(HelpMessage = "The root site url to start with", Mandatory = $true)]
    [string] $RootSiteUrl,
    [Parameter(HelpMessage = "defines whether the site content (libraries) should be included", Mandatory = $false)]
    [switch] $WithSiteContent,
    [Parameter(HelpMessage = "defines whether the result will be returned as an object to be processed later", Mandatory = $false)]
    [switch] $AsObject
  )

  Function Initialize-Routine {
    $Script:RootSiteUrl = $RootSiteUrl
    $Script:Structure = @()
    $Script:TenantInfo = Get-PnPTenantInfo
    $Script:RetrieveSiteContent = $WithSiteContent
    
    Clear-Host
  }

  Function Get-SiteInfo([string] $SiteUrl) {
    $siteInfo = Get-PnPTenantSite -Identity $SiteUrl
    return @{
      Id        = $siteInfo.IsHubSite ? $siteInfo.HubSiteId : $siteInfo.Id
      Title     = $siteInfo.Title
      Url       = $siteInfo.Url
      Type      = $siteInfo.Template -eq "SITEPAGEPUBLISHING#0" ? "Communication" 
      : $siteInfo.Template -eq "GROUP#0" ? "Team" 
      : $siteInfo.Template -eq "STS#3" ? "SPOTeam" 
      : "Other"
      IsHubSite = $siteInfo.IsHubSite
    }
  }
  
  Function Get-StartSite {
    Function Get-HomeSite() {
      try {
        Write-Host "Trying to get the home site in your tenant and check whether it matches the root site"
        $homeSite = Get-PnPHomeSite -Detailed
        if (!$homeSite) { throw "Home Site not found or not set" }
        if ($homeSite.Url -ne $RootSiteUrl) { throw "Home Site does not match root site" }
        $siteInfo = Get-SiteInfo -SiteUrl $hubSite.SiteUrl
        $siteObject = ([Ordered]@{Hub = $siteInfo.Title; Url = $siteInfo.Url; Type = $siteInfo.Type })
        
        if ($Script:RetrieveSiteContent) { 
          $content = Get-SiteContent -RootSite $siteInfo 
          if ($content) { $siteObject.Content = $content }
        }

        $Script:Structure += $siteObject
        return $siteInfo
      }
      catch {
        throw $_
      }
    }
    
    Function Get-HubSite([string] $SiteUrl) {
      try {
        Write-Host "Trying to get the according hub site: " -NoNewline
        $hubSite = Get-PnPHubSite -Identity $RootSiteUrl
        if (!$hubSite) { throw "Hub Site not found or not set" }
        
        Write-Host -ForegroundColor DarkGreen "✔︎ Starting with $($hubSite.SiteUrl)"
        $siteInfo = Get-SiteInfo -SiteUrl $hubSite.SiteUrl
        $siteObject = ([Ordered]@{Hub = $siteInfo.Title; Url = $siteInfo.Url; Type = $siteInfo.Type })
        
        if ($Script:RetrieveSiteContent) { 
          $content = Get-SiteContent -RootSite $siteInfo 
          if ($content) { $siteObject.Content = $content }
        }

        $Script:Structure += $siteObject
        return $siteInfo
      }
      catch {
        throw $_
      }
    }
    
    # Run the start site routine
    try {
      return Get-HomeSite
    }
    catch {
      Write-Host -ForegroundColor DarkYellow $_
      return Get-HubSite -SiteUrl $RootSiteUrl
    }
  }

  Function Get-AssignedSites {
    param (
      [Parameter(HelpMessage = "the site from where the assigned sites will be retrieved", Mandatory = $true)]
      [object] $RootSite
    )
    
    # Get all hubs that are assigned to this site site;
    # either directly connected sites (first test) or connected hubs (second test)
    $children = (Get-PnPHubSiteChild -Identity $RootSite.Url) ?? (Get-PnPHubSite | ? { $_.ParentHubSiteId -eq $RootSite.Id })
    foreach ($site in $children) {
      $siteInfo = switch ($site.GetType().FullName) {
        "Microsoft.Online.SharePoint.TenantAdministration.SiteProperties" { Get-SiteInfo -SiteUrl $site.SiteUrl }
        "System.String" { Get-SiteInfo -SiteUrl $site }
        "Default" { Get-SiteInfo -SiteUrl $site }
      }

      Write-Host "👉 $($siteInfo.Url)"
      
      # Get all assigned sites in case of current site is a hub site
      if ($siteInfo.IsHubSite) {
        $siteObject = ([Ordered]@{Hub = $siteInfo.Title; Url = $siteInfo.Url; Type = $siteInfo.Type; ConnectedHubsite = $RootSite.Url })
        if ($Script:RetrieveSiteContent) { 
          $content = Get-SiteContent -RootSite $siteInfo 
          if ($content) { $siteObject.Content = $content }
        }
        
        $Script:Structure += $siteObject
        Get-AssignedSites -RootSite $siteInfo
      }
      else {
        $siteObject = ([Ordered]@{Site = $siteInfo.Title; Url = $siteInfo.Url; Type = $siteInfo.Type; ConnectedHubsite = $RootSite.Url })
        if ($Script:RetrieveSiteContent) { 
          $content = Get-SiteContent -RootSite $siteInfo 
          if ($content) { $siteObject.Content = $content }
        }
        
        $Script:Structure += $siteObject
      }
    }
  }

  Function Get-SiteContent {
    param (
      [Parameter(HelpMessage = "the site from where the content will be retrieved", Mandatory = $true)]
      [object] $RootSite
    )
    $output = @()
    $connSite = Connect-PnPOnline -Url $RootSite.Url -Interactive -ReturnConnection
    
    # Get the document libraries & lists
    $objects = Get-PnPList -Connection $connSite | `
      Where-Object { $_.BaseType -in @("DocumentLibrary", "GenericList", "Events") -and $_.Hidden -eq $false -and $_.EntityTypeName -notin @("Style_x0020_Library", "FormServerTemplates", "SiteAssets", "SitePages") }
    if ($objects) {
      foreach ($object in $objects) {
        $output += switch ($object.BaseType) {
          "DocumentLibrary" { [Ordered]@{ DocumentLibrary = $object.Title; Url = "/" + $object.RootFolder.ServerRelativeUrl.Split("/")[-1]; } }
          "GenericList" { [Ordered]@{ List = $object.Title; Url = "/" + $object.RootFolder.ServerRelativeUrl.Split("/")[-1]; } }
          "Default" { [Ordered]@{ List = $object.Title; Url = "/" + $object.RootFolder.ServerRelativeUrl.Split("/")[-1]; } }
        }
      }
    }
    $connSite = $null;
    return $output
  }
  
  #######################################
  # START Main Routine
  try {
    Initialize-Routine
    $startSite = Get-StartSite
    Get-AssignedSites -RootSite $startSite
    
    $result = [Ordered]@{
      Tenant     = $Script:TenantInfo.DisplayName
      Version    = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
      SharePoint = @{TenantId = $Script:TenantInfo.TenantId.ToString() }
      Structure  = $Script:Structure
    }

    if ($AsObject.IsPresent) {
      return $result
    }
    else {
      $result.Structure
    }
  }
  catch {
    Write-Error $_
  }
}

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Source Credit

Sample taken from [https://github.com/tmaestrini/easyProvisioning/](https://github.com/tmaestrini/easyProvisioning)

## Contributors

| Author(s) |
|-----------|
| [Tobias Maestrini](https://github.com/tmaestrini)|


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-copy-hubsite-navigation" aria-hidden="true" />