---
plugin: add-to-gallery-preparation
---

# Add an alternate language to SharePoint Online Site

## Summary

This script adds a new language to the SharePoint Online site with the help of language LCID decimal. 
The following table shows the LCID for each language.

| LCID | Language                 |
|------|-------------------------|
| 1025 | Arabic                  |
| 1046 | Brazilian               |
| 1026 | Bulgarian               |
| 1027 | Catalan                 |
| 2052 | Chinese - Simplified    |
| 1028 | Chinese - Traditional   |
| 1050 | Croatian                |
| 1029 | Czech                   |
| 1030 | Danish                  |
| 1043 | Dutch                   |
| 1033 | English                 |
| 1061 | Estonian                |
| 1035 | Finnish                 |
| 1036 | French                  |
| 1031 | German                  |
| 1032 | Greek                   |
| 1037 | Hebrew                  |
| 1081 | Hindi                   |
| 1038 | Hungarian               |
| 1040 | Italian                 |
| 1041 | Japanese                |
| 1087 | Kazakh                  |
| 1042 | Korean                  |
| 1062 | Latvian                 |
| 1063 | Lithuanian              |
| 1044 | Norwegian               |
| 1045 | Polish                  |
| 2070 | Portuguese              |
| 1048 | Romanian                |
| 1049 | Russian                 |
| 2074 | Serbian                 |
| 1051 | Slovak                  |
| 1060 | Slovenian               |
| 1034 | Spanish                 |
| 1053 | Swedish                 |
| 1054 | Thai                    |
| 1055 | Turkish                 |
| 1058 | Ukrainian               |


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
