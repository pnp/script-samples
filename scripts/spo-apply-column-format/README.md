---
plugin: add-to-gallery
---

# Apply column format to SharePoint column

## Summary

This sample script shows how to apply column format using:

* Existing column format
* Format added in script
* Getting format sample from GitHub sample page

Scenario inspired by Paul Bullock [Blog post about column formatting](https://www.pkbullock.com/blog/2018/using-pnp-powershell-to-apply-modern-column-formatting/)

![Example Screenshot](assets/example.png)

# [PnP PowerShell](#tab/pnpps)

```powershell
#site collection url
$url="https://<tenant>.sharepoint.com"

#list to be exported  
$listName="ListTitle"

## Connect to SharePoint Online site  
Connect-PnPOnline -Url $Url -Interactive

#----method 1 Apply formatting from existing column sample in sharepoint-------#
# field title with existing format - ChoiceFld
$field = Get-PnPField -Identity "ChoiceFld" -List $listName

#copy field format
$fieldFormat = $field.CustomFormatter

#apply field format to other column
# field title with no format - ChoiceFldFormattedViaPowershell
Set-PnPField -List $listName -Identity "ChoiceFldFormattedViaPowershell" -Values @{CustomFormatter=$fieldFormat}


#---method 2 Apply formatting directly from script
Set-PnPField -List $listName -Identity "ChoiceFldFormattedViaPowershell" -Values @{CustomFormatter=@'
{
  "$schema": "https://developer.microsoft.com/json-schemas/sp/column-formatting.schema.json",
  "elmType": "div",
  "style": {
    "position": "relative"
  },
  "children": [
    {
      "elmType": "div",
      "attributes": {
        "class": "=if([$DueDate] <= @now, 'sp-field-severity--severeWarning', if(1 - Number([$DueDate] - @now) / Number([$DueDate] - [$StartDate]) >= 0.7, 'sp-field-severity--war
ning', 'sp-field-severity--good'))"
      },
      "style": {
        "min-height": "inherit",
        "width": "=if([$DueDate] <= @now, '100%', (1 - Number([$DueDate] - @now) / Number([$DueDate] - [$StartDate])) * 100 + '%')"
      }
    },
    {
      "elmType": "span",
      "txtContent": "@currentField",
      "style": {
        "position": "absolute",
        "left": "8px"
      },
      "attributes": {
        "class": "ms-fontColor-neutralSecondary"
      }
    }
  ]
}
'@
}

#----method 3 Apply formattin using sample from github-------#
$webContent = Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/pnp/List-Formatting/master/column-samples/date-range-rag/date-range-rag.json' 
$fieldFormatFromGit = $webContent.Content 

$fieldToFormat = Get-PnPField -Identity "GitHubFormatted" -List $listName
$fieldToFormat.CustomFormatter = $fieldFormatFromGit
$fieldToFormat.UpdateAndPushChanges($true)

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

> [!Note]
> In 3rd method i use **$fieldToFormat.UpdateAndPushChanges($true)** but it is perfectly fine to use **Set-PnPField** command as in method 1 and 2

# [JSON](#tab/json)

```

{
  "$schema": "https://developer.microsoft.com/json-schemas/sp/column-formatting.schema.json",
  "elmType": "div",
  "style": {
    "position": "relative"
  },
  "children": [
    {
      "elmType": "div",
      "attributes": {
        "class": "=if([$DueDate] <= @now, 'sp-field-severity--severeWarning', if(1 - Number([$DueDate] - @now) / Number([$DueDate] - [$StartDate]) >= 0.7, 'sp-field-severity--warning', 'sp-field-severity--good'))"
      },
      "style": {
        "min-height": "inherit",
        "width": "=if([$DueDate] <= @now, '100%', (1 - Number([$DueDate] - @now) / Number([$DueDate] - [$StartDate])) * 100 + '%')"
      }
    },
    {
      "elmType": "span",
      "txtContent": "@currentField",
      "style": {
        "position": "absolute",
        "left": "8px"
      },
      "attributes": {
        "class": "ms-fontColor-neutralSecondary"
      }
    }
  ]
}

```

> [!Note]
> This is JSON used in examples

***

## Contributors

| Author(s) |
|-----------|
| Valeras Narbutas |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/spo-apply-column-format" aria-hidden="true" />