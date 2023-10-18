---
plugin: add-to-gallery
---

# Creation of SharePoint Online sites from CSV

## Summary

This script helps you in creation of SharePoint Communication and Team sites in bulk. It takes an input from CSV.
CSV structure should look like:

| RootSiteUrl                          | SiteTitle             | Alias                 | SiteUrl           | Type              |
|--------------------------------------|-----------------------|-----------------------|-------------------|-------------------|
| https://<tenant_name>.sharepoint.com | My Communication Site | My Communication Site | /sites/mycommsite | CommunicationSite |
| https://<tenant_name>.sharepoint.com | My Team Site          | My Team Site          | /teams/myteamsite | TeamSite          |


# [PnP PowerShell](#tab/pnpps)

```powershell
$AdminCenterUrl = <url-of-sharepoint-admin-center>
$inputFilePath = <path-to-your-csv-file>
$input = import-csv $inputFile

Write-Host "Invoked CSV file"

Connect-PnPOnline -Url $AdminCenterUrl

foreach($row in $input)
{ 
    #Connect to Admin Center 
    Write-Host "Getting Configuration Details"

    $RootSiteUrl = $row.RootSiteUrl
    $SiteTitle = $row.SiteTitle
    $SiteUrl = $row.SiteUrl
    $Type = $row.Type
    $Alias = $row.Alias
    $commSiteUrl = $RootSiteUrl + $SiteURL 
    $site = $null

    try
    {
        $site = Get-PnPTenantSite -Identity $commSiteUrl 
    }
    catch
    {
        Write-Host "Exception: $($_.Exception.Message)"
    }

    If ($null -eq $Site)
    {
        if($Type -eq "TeamSite")
        {
            #sharepoint online pnp powershell create site collection
            $ProvisionedSiteUrl = New-PnPSite -Type $Type -Title $SiteTitle -Alias $SiteTitle -IsPublic   
            write-host "Site Collection $($ProvisionedSiteUrl) Created Successfully!" -foregroundcolor Green
        }
        else
        {
            #sharepoint online pnp powershell create site collection
            $ProvisionedSiteUrl = New-PnPSite -Type $Type -Title $SiteTitle -Url $commSiteUrl  
            write-host "Site Collection $($ProvisionedSiteUrl) Created Successfully!" -foregroundcolor Green
        }
    }
    else
    {
        write-host "Site $($SiteURL) exists already!" -foregroundcolor Yellow
        $ProvisionedSiteUrl = $SiteURL;
    }

    Write-Log "$Home Site Url  configured" 
}
```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]


## Contributors

| Author(s) |
|-----------|
| [Kshitiz Kalra](https://www.linkedin.com/in/kshitiz-kalra-b3107b164/) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-bulk-creation-sharepoint-sites-csv" aria-hidden="true" />
