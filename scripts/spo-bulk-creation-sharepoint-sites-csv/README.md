

# Creation of SharePoint Online sites from CSV

## Summary

This script helps you in creation of SharePoint Online Communication and Team sites in bulk. It takes an input from CSV.
CSV structure should look like:

| RootSiteUrl                          | SiteTitle             | Alias                 | SiteUrl           | Type              |
|--------------------------------------|-----------------------|-----------------------|-------------------|-------------------|
| https://<tenant_name>.sharepoint.com | My Communication Site |                       | /sites/mycommsite | CommunicationSite |
| https://<tenant_name>.sharepoint.com | My Team Site          | MyTeamSite            | /sites/myteamsite | TeamSite          |

# [PnP PowerShell](#tab/pnpps)

```powershell

$adminCenterUrl = "https://<tenant_name>-admin.sharepoint.com/"
$inputFilePath = "D:\dtemp\sites.csv"
$inputSites = import-csv $inputFilePath

Write-Host "Invoked CSV file"

# Connect to SharePoint Admin Center
Connect-PnPOnline -Url $adminCenterUrl -Interactive

foreach($row in $inputSites)
{ 
    
    Write-Host "Getting configuration details from CSV"
    $RootSiteUrl = $row.RootSiteUrl
    $SiteTitle = $row.SiteTitle
    $SiteUrl = $row.SiteUrl
    $Type = $row.Type
    $Alias = $row.Alias
    $commSiteUrl = $RootSiteUrl + $SiteUrl 
    $site = $null

    try
    {
        $site = Get-PnPTenantSite -Identity $commSiteUrl 
    }
    catch
    {
        Write-Host "Exception: $($_.Exception.Message)"
    }

    If ($null -eq $site)
    {
        if($Type -eq "TeamSite")
        {
            # Creating a SharePoint team site
            $ProvisionedSiteUrl = New-PnPSite -Type $Type -Title $SiteTitle -Alias $Alias -IsPublic   
            Write-Host "Site Collection $($ProvisionedSiteUrl) Created Successfully!" -foregroundcolor Green
        }
        else
        {
            # Creating a SharePoint communication site
            $ProvisionedSiteUrl = New-PnPSite -Type $Type -Title $SiteTitle -Url $commSiteUrl  
            Write-Host "Site Collection $($ProvisionedSiteUrl) Created Successfully!" -foregroundcolor Green
        }
    }
    else
    {
        Write-Host "Site Collection $($SiteUrl) exists already!" -foregroundcolor Yellow
        $ProvisionedSiteUrl = $SiteUrl;
    }
}

# Disconnect SharePoint online connection
Disconnect-PnPOnline

Write-Host "Script execution completed successfully!" -foregroundcolor Green

```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365](#tab/cli-m365-ps)

```powershell

$inputFilePath = "D:\dtemp\sites.csv"
$inputSites = import-csv $inputFilePath

Write-Host "Invoked CSV file"

# Get Credentials to connect
$m365Status = m365 status
if ($m365Status -match "Logged Out")
{
    m365 login
}

Write-Host "Connected to M365"

foreach ($row in $inputSites)
{
    Write-Host "Getting configuration details from CSV"
    $rootSiteUrl = $row.RootSiteUrl
    $siteTitle = $row.SiteTitle
    $siteUrl = $row.SiteUrl
    $siteAlias = $row.Alias
    $siteType = $row.Type
    $completeSiteUrl = $rootSiteUrl + $siteUrl 
    $site = $null

    try
    {
        $site = m365 spo site get --url $completeSiteUrl | ConvertFrom-Json
    }
    catch
    {
        Write-Host "Exception: $($_.Exception.Message)"
    }

    if ($null -eq $site)
    {
        if ($siteType -eq "TeamSite")
        {
            # Creating a SharePoint team site
            m365 spo site add --type $siteType --title $siteTitle --alias $siteAlias --isPublic
            Write-Host "Site collection $($completeSiteUrl) created successfully!" -foregroundcolor Green
        }
        else
        {
            # Creating a SharePoint communication site
            m365 spo site add --type $siteType --title $siteTitle --url $completeSiteUrl
            Write-Host "Site collection $($completeSiteUrl) created successfully!" -foregroundcolor Green
        }
    }
    else
    {
        Write-Host "Site collection $($completeSiteUrl) exists already!" -foregroundcolor Yellow
    }
}

# Disconnect M365 connection
m365 logout

Write-Host "Script execution completed successfully!" -foregroundcolor Green

```

[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

***

## Contributors

| Author(s) |
|-----------|
| [Kshitiz Kalra](https://www.linkedin.com/in/kshitiz-kalra-b3107b164/) |
| [Ganesh Sanap](https://ganeshsanapblogs.wordpress.com/about) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-bulk-creation-sharepoint-sites-csv" aria-hidden="true" />
