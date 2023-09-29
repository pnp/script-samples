---
plugin: add-to-gallery-preparation
---

# Add an alternate language to SharePoint Online Site

## Summary

This script adds a new language to the SharePoint Online site with the help of language LCID decimal.


# [PnP PowerShell](#tab/pnpps)

```powershell

### Variables for Processing
$SiteURL="https://<tenant name>.sharepoint.com/sites/<site>"
$LanguageID = 1025 #Arabic LCID

#Connect to PNP Online
Connect-PnPOnline -Url $SiteURL -Interactive

#Get the Web
$Web = Get-PnPWeb -Includes RegionalSettings.InstalledLanguages

#Add Alternate Language
$Web.IsMultilingual = $True
$Web.AddSupportedUILanguage($LanguageID)
$Web.Update()

Invoke-PnPQuery

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]


***


## Source Credit

Sample first appeared on [SharePoint Diary](https://www.sharepointdiary.com/2019/11/sharepoint-online-change-site-language-using-powershell.html)

## Contributors

| Author(s) |
|-----------|
| [Kshitiz Kalra](https://www.linkedin.com/in/kshitiz-kalra-b3107b164/) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/template-script-submission" aria-hidden="true" />