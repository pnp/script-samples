---
plugin: add-to-gallery
---

# Create a multi-hub set of communication sites

## Summary

Want to see how the hub site association works but don't have an large intranet to play with, or looking to build a large multi-departmental intranet. 
This sample builds 9 SharePoint communication sites, creates three hub sites and associates them to a main hub site; these are empty sites with no content,
however you can build on this script or the approach to populate all the sites with example content.

> [!div class="full-image-size"]
>![Example Screenshot](assets/example.png)


# [PnP PowerShell](#tab/pnpps)

```powershell

[CmdletBinding()]
param (
    [string]$TenantOrg = "contoso",
    [int]$TimeZoneId = 2,
    [string]$OwnerEmail = "paul.bullock@contoso.onmicrosoft.com", # <email address>
    [string]$SiteListJsonFile = "large-intranet-example.json", #use the sample from the JSON tab
    $SiteType = "CommunicationSite" # <TeamSite|TeamSiteWithoutMicrosoft365Group|CommunicationSite>
)
begin {
   
    Start-Transcript -OutputDirectory .

    # Part 
    $adminUrl = "https://$($TenantOrg)-admin.sharepoint.com"

    # Requires SharePoint Admin Role on your account
    Connect-PnPOnline -Url $adminUrl -Interactive

    $jsonFilePath = "$($SiteListJsonFile)"
    $sites = Get-Content $jsonFilePath -Raw | ConvertFrom-Json

    $baseUrl = "https://$($TenantOrg).sharepoint.com/sites/"

}
process {

    function GetTenantSite($siteUrl) {
        try{
            $existingSite = Get-PnPTenantSite $siteUrl -ErrorAction SilentlyContinue
        }
        catch {
            Write-Host "  - Site does not exist" -ForegroundColor Yellow
        }
        return $existingSite
    }

    Write-Host "Phase 1 - Create the SharePoint Sites" -ForegroundColor Cyan
    $sites | Foreach-Object {

        $siteUrl = "$($baseUrl)$($_.SiteUrl)"
        $siteTitle = $_.SiteTitle

        # Check for existing site
        $existingSite = GetTenantSite $siteUrl

        if ($existingSite -eq $null) {

            Write-Host "  - Creating new site...."
            New-PnPSite -Type $SiteType -Title $siteTitle -Url $siteUrl -Lcid $_.LocaleId -Owner $OwnerEmail -TimeZone $TimeZoneId -Wait
            Write-Host "  - Created new site"
        }
        else {
            # Site already exists
            Write-Host "  - Site already exists $($siteUrl)" -ForegroundColor Yellow
        }
    }

    # Phase 2 - Create the Hub Sites
    Write-Host "Phase 2 - Create the Hub Sites" -ForegroundColor Cyan
    $sites | Foreach-Object {

        $siteUrl = "$($baseUrl)$($_.SiteUrl)"
        
        # Check for existing site - for those with the hub association only
        $existingSite = GetTenantSite $siteUrl

        if ($existingSite ) {

            if ($_.CreateHubWithName) {

                Write-Host "  - Registering site as Hub site " $siteUrl
                try{
                    Register-PnPHubSite -Site $siteUrl

                    # Update the Hub Title - this can be expanded to include the other options as well
                    Write-Host "  - Updating Hub Title " $siteUrl
                    Set-PnPHubSite -Identity $siteUrl -Title $_.CreateHubWithName

                }catch{
                    Write-Host "  - Site already registered as Hub site" -ForegroundColor Yellow
                }
            }           
        }
        else {
            # Site already exists
            Write-Host "  - Site does not exist" -ForegroundColor Yellow
        }
    }

    Write-Host "Phase 3 - Associate the sites to the Hub Sites" -ForegroundColor Cyan
    $sites | Foreach-Object {

        $siteUrl = "$($baseUrl)$($_.SiteUrl)"
        
        if ($_.JoinHubUrl) {

            # Check for existing site - for those with the hub association only
            $existingSite = GetTenantSite $siteUrl

            if ($existingSite) {

                $joinHubSite = "$($baseUrl)$($_.JoinHubUrl)"
                $hubSite = Get-PnPHubSite -Identity $joinHubSite

                if ($hubsite) {

                    Write-Host "  - Joining site to Hub site " $siteUrl " to " $joinHubSite
                    Add-PnPHubSiteAssociation -Site $siteUrl -HubSite $joinHubSite

                }
                else {
                    # Hubsite not found
                    Write-Host "  - Hub site not found" -ForegroundColor Yellow
                }         
            }
            else {
                # Site already exists
                Write-Host "  - Site does not exist" -ForegroundColor Yellow
            }
        }
    }

    Write-Host "Phase 4 - Associate the sites to the Hub Sites and setup Hub to Hub associations" -ForegroundColor Cyan
    $sites | Foreach-Object {

        $siteUrl = "$($baseUrl)$($_.SiteUrl)"
        
        if ($_.CreateHubWithName -and $_.AssociateHubToHub) {

            # Check for existing site - for those with the hub association only
            $existingSite = GetTenantSite $siteUrl
            
            if ($existingSite) {

                $hubSiteUrl = "$($baseUrl)$($_.AssociateHubToHub)"
                $hubSite = Get-PnPHubSite -Identity $hubSiteUrl

                if ($hubsite) {
            
                    Write-Host "  - Joining site to Hub site to Hub Site" $siteUrl " to " $hubSiteUrl
                    Add-PnPHubToHubAssociation -SourceUrl $siteUrl -TargetUrl $hubSiteUrl

                }
                else {
                    # Hubsite not found
                    Write-Host "  - Hub site not found" -ForegroundColor Yellow
                }
            }
            else {
                # Site already exists
                Write-Host "  - Site does not exist" -ForegroundColor Yellow
            }
        }
    }


    Write-Host "Script Complete! :)" -ForegroundColor Green
}
end {
    #Disconnect-PnPOnline
    Stop-Transcript
}

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]


# [JSON](#tab/json)
```json

[
    {
        "SiteTitle":"Ketchup Inc",
        "SiteUrl":"ketchupinc-intranet",
        "CreateHubWithName": "Ketchup Inc Intranet",
        "JoinHubUrl": "",
        "AssociateHubToHub": "",
        "LocaleId":1033
    },
    {
        "SiteTitle":"Ketchup Inc - News",
        "SiteUrl":"ketchupinc-news",
        "CreateHubWithName": "",
        "JoinHubUrl": "ketchupinc-intranet",
        "AssociateHubToHub": "",
        "LocaleId":1033
    },


    {
        "SiteTitle":"Ketchup Inc - HR Hub",
        "SiteUrl":"ketchupinc-hr",
        "CreateHubWithName": "Ketchup Inc HR Hub",
        "JoinHubUrl": "",
        "AssociateHubToHub": "ketchupinc-intranet",
        "LocaleId":1033
    },
    {
        "SiteTitle":"Ketchup Inc - HR Support",
        "SiteUrl":"ketchupinc-hr-support",
        "CreateHubWithName": "",
        "JoinHubUrl": "ketchupinc-hr",
        "AssociateHubToHub": "",
        "LocaleId":1033
    },
    {
        "SiteTitle":"Ketchup Inc - HR Management",
        "SiteUrl":"ketchupinc-hr-management",
        "CreateHubWithName": "",
        "JoinHubUrl": "ketchupinc-hr",
        "AssociateHubToHub": "",
        "LocaleId":1033
    },


    {
        "SiteTitle":"Ketchup Inc - IT Hub",
        "SiteUrl":"ketchupinc-it",
        "CreateHubWithName": "Ketchup Inc IT Hub",
        "JoinHubUrl": "",
        "AssociateHubToHub": "ketchupinc-intranet",
        "LocaleId":1033
    },
    {
        "SiteTitle":"Ketchup Inc - IT Services",
        "SiteUrl":"ketchupinc-it-services",
        "CreateHubWithName": "",
        "JoinHubUrl": "ketchupinc-it",
        "AssociateHubToHub": "",
        "LocaleId":1033
    },
    {
        "SiteTitle":"Ketchup Inc - IT Support",
        "SiteUrl":"ketchupinc-it-support",
        "CreateHubWithName": "",
        "JoinHubUrl": "ketchupinc-it",
        "AssociateHubToHub": "",
        "LocaleId":1033
    },
    {
        "SiteTitle":"Ketchup Inc - IT Training",
        "SiteUrl":"ketchupinc-it-training",
        "CreateHubWithName": "",
        "JoinHubUrl": "ketchupinc-it",
        "AssociateHubToHub": "",
        "LocaleId":1033
    }
]

```
***


## Contributors

| Author(s) |
|-----------|
| Paul Bullock |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-create-multi-hub-sites" aria-hidden="true" />