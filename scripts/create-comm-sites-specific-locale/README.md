---
plugin: add-to-gallery
---

# Create Communication Sites with a specific primary language

## Summary

Do you want to create a Communication Site in another language? This script will show you how by creating a modern site with the primary language set to a language other than English.

![Example Screenshot](assets/example.png)

> [!Note]
> Once you create a site in the primary language you cannot change it, however you can add support for other languages.

# [PnP PowerShell](#tab/pnpps)

```powershell

$adminUrl = "https://<tenant>-admin.sharepoint.com"
$newSiteUrl = "https://<tenant>.sharepoint.com/sites/Pensaerniaeth" 
$ownerEmail = "<your.name@your.email.com>"

$siteTitle = "Pensaerniaeth"                # Translates to "Architecture" - Bing Translator
$siteTemplate = "SITEPAGEPUBLISHING#0"      # Communication Site Template
$lcid = 1106                                # Welsh
$timeZone = 2                               # London (https://capa.ltd/sp-timezones)

Connect-PnPOnline -Url $adminUrl -NoTelemetry
New-PnPTenantSite -Template $siteTemplate -Title $siteTitle -Url $newSiteUrl `
        -Lcid $lcid -Owner $ownerEmail -TimeZone $timeZone

Write-Host "Script Complete! :)" -ForegroundColor Green

```

***

To see a list of LCIDs, check out the sample [Generate Markdown Report of LCIDs](../generate-markdown-lcids/README.md) to see the full list

## Source Credit

Article first appeared on [https://capacreative.co.uk/2018/11/19/create-communication-sites-with-a-specific-primary-language-using-pnp-powershell/](https://capacreative.co.uk/2018/11/19/create-communication-sites-with-a-specific-primary-language-using-pnp-powershell/)

## Contributors

| Author(s) |
|-----------|
| Paul Bullock |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]

<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/create-comm-sites-specific-locale" aria-hidden="true" />