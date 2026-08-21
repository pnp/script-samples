# Check and Correct Site Pages Translation Configuration

## Summary

This script inspects every page in the Site Pages library and validates whether the SharePoint multilingual translation metadata is correctly set. It covers three page roles:

- **Standalone** – a page with no translations: all `_SP*` fields must be empty.
- **Master page** – a page that has translations: `_SPTranslatedLanguages` must list exactly the languages of all translation copies; the other translation fields must be empty.
- **Translated page** – a copy linked to a master: `_SPTranslationLanguage`, `_SPTranslationSourceItemId`, and `_SPIsTranslation` must be set; `_SPTranslatedLanguages` must be empty.

Run without `-Fix` to get a full report. Add `-Fix` to automatically clear fields that are incorrectly set on standalone and master pages. Issues on translated pages that require context (missing language code, broken source reference) are flagged for manual review.

> **Important:** The `-Fix` switch can only handle clear-cut cases where the correct value can be derived unambiguously from the existing metadata. It cannot cover every misconfiguration scenario, and automated fixes carry inherent risk. Always run a report first, review the findings carefully, and verify the results in SharePoint after applying any fix.


# [PnP PowerShell](#tab/pnpps)

```powershell
param (
    [Parameter(Mandatory = $true)]
    [string]$SiteUrl,

    [string]$ClientId = "2f1689f1-1859-4b5e-aa23-08442a625125",

    [switch]$Fix
)

$cn = Connect-PnPOnline -Url $SiteUrl -Interactive -ClientId $ClientId -ReturnConnection

$fields = "FileLeafRef", "Title", "_SPTranslatedLanguages", "_SPTranslationLanguage",
          "_SPTranslationSourceItemId", "_SPIsTranslation", "UniqueId", "LinkFilename"

$items = Get-PnPListItem -List "SitePages" -Fields $fields -Connection $cn -PageSize 500
Write-Host "Loaded $($items.Count) pages from Site Pages library."

# Build lookup: UniqueId -> item (used to validate _SPTranslationSourceItemId references)
$itemByUniqueId = @{}
foreach ($item in $items) {
    $uid = $item.FieldValues.UniqueId
    if ($uid) { $itemByUniqueId[$uid.ToString()] = $item }
}

# Group pages by filename – translations share the same FileLeafRef as their master page
# but live in language sub-folders (e.g. /SitePages/de/page.aspx)
$byFileName = $items | Group-Object { $_.FieldValues.FileLeafRef }

$issues = [System.Collections.Generic.List[PSCustomObject]]::new()

foreach ($group in $byFileName) {
    $sameNameCount = $group.Count

    foreach ($item in $group.Group) {
        $fv                      = $item.FieldValues
        $isTranslation           = ($fv._SPIsTranslation -eq $true)
        $translatedLanguages     = $fv._SPTranslatedLanguages
        $translationLanguage     = $fv._SPTranslationLanguage
        $translationSourceItemId = $fv._SPTranslationSourceItemId
        $uniqueId                = $fv.UniqueId.ToString()

        $langArray = if ($translatedLanguages -is [array]) { $translatedLanguages }
                     elseif ($translatedLanguages)         { @($translatedLanguages) }
                     else                                  { @() }

        # Helper: add an issue entry
        $addIssue = {
            param ([string]$Type, [string]$Message, [bool]$Fixable = $false, [string]$ResolvedValue = $null)
            $issues.Add([PSCustomObject]@{
                File          = $fv.FileLeafRef
                UniqueId      = $uniqueId
                ItemId        = $item.Id
                Type          = $Type
                Issue         = $Message
                Fixable       = $Fixable
                ResolvedValue = $ResolvedValue
            })
        }

        if (-not $isTranslation -and $sameNameCount -eq 1) {
            # ── Case 1: Standalone page ──────────────────────────────────────────────
            # No other page shares this filename → all translation fields must be empty
            if ($langArray.Count -gt 0)   { & $addIssue "Standalone" "_SPTranslatedLanguages should be empty"     $true }
            if ($translationLanguage)      { & $addIssue "Standalone" "_SPTranslationLanguage should be empty"     $true }
            if ($translationSourceItemId)  { & $addIssue "Standalone" "_SPTranslationSourceItemId should be empty" $true }

        }
        elseif (-not $isTranslation) {
            # ── Case 2a: Master page ─────────────────────────────────────────────────
            # Multiple pages share this filename; this one is not a translation itself
            $expectedLangCount = $sameNameCount - 1

            if ($langArray.Count -eq 0) {
                & $addIssue "Master" "_SPTranslatedLanguages is empty, expected $expectedLangCount language(s)" $false
            }
            elseif ($langArray.Count -ne $expectedLangCount) {
                & $addIssue "Master" "_SPTranslatedLanguages has $($langArray.Count) entry/entries, expected $expectedLangCount" $false
            }

            if ($translationLanguage)      { & $addIssue "Master" "_SPTranslationLanguage should be empty"     $true }
            if ($translationSourceItemId)  { & $addIssue "Master" "_SPTranslationSourceItemId should be empty" $true }

        }
        else {
            # ── Case 2b: Translated page ─────────────────────────────────────────────
            if ($langArray.Count -gt 0) {
                & $addIssue "Translation" "_SPTranslatedLanguages should be empty on a translated page" $true
            }
            if (-not $translationLanguage) {
                # Try to derive the missing language from the master page:
                # master._SPTranslatedLanguages minus languages already claimed by sibling translations
                $resolvedLang = $null
                if ($translationSourceItemId -and $itemByUniqueId.ContainsKey($translationSourceItemId.ToString())) {
                    $masterFv        = $itemByUniqueId[$translationSourceItemId.ToString()].FieldValues
                    $masterLangs     = $masterFv._SPTranslatedLanguages
                    $masterLangArray = if ($masterLangs -is [array]) { $masterLangs }
                                       elseif ($masterLangs)         { @($masterLangs) }
                                       else                          { @() }

                    $claimedLangs = @($items | Where-Object {
                        $_.FieldValues._SPIsTranslation -eq $true -and
                        $_.FieldValues._SPTranslationSourceItemId -eq $translationSourceItemId -and
                        $_.FieldValues.UniqueId.ToString() -ne $uniqueId -and
                        $_.FieldValues._SPTranslationLanguage
                    } | ForEach-Object { $_.FieldValues._SPTranslationLanguage })

                    $unclaimed = @($masterLangArray | Where-Object { $_ -notin $claimedLangs })
                    if ($unclaimed.Count -eq 1) { $resolvedLang = $unclaimed[0] }
                }
                & $addIssue "Translation" "_SPTranslationLanguage is not set" ($null -ne $resolvedLang) $resolvedLang
            }
            if (-not $translationSourceItemId) {
                # Try to find the master page within the same FileLeafRef group:
                # the one non-translation item is the master
                $resolvedSourceId  = $null
                $potentialMasters  = @($group.Group | Where-Object { $_.FieldValues._SPIsTranslation -ne $true })
                if ($potentialMasters.Count -eq 1) {
                    $resolvedSourceId = $potentialMasters[0].FieldValues.UniqueId.ToString()
                }
                & $addIssue "Translation" "_SPTranslationSourceItemId is not set" ($null -ne $resolvedSourceId) $resolvedSourceId
            }
            elseif (-not $itemByUniqueId.ContainsKey($translationSourceItemId.ToString())) {
                & $addIssue "Translation" "_SPTranslationSourceItemId '$translationSourceItemId' does not match any page in the library (orphaned)" $false
            }
        }
    }
}

# ── Report ───────────────────────────────────────────────────────────────────────
Write-Host ""
if ($issues.Count -eq 0) {
    Write-Host "OK – All $($items.Count) pages have correct translation configuration." -ForegroundColor Green
}
else {
    Write-Warning "$($issues.Count) issue(s) found across $($items.Count) pages:"
    $issues | Select-Object File, Type, Issue, UniqueId, ItemId | Format-Table -AutoSize
}

# ── Fix ──────────────────────────────────────────────────────────────────────────
if ($Fix -and $issues.Count -gt 0) {
    $fixable = $issues | Where-Object { $_.Fixable }
    $manual  = $issues | Where-Object { -not $_.Fixable }

    if ($fixable.Count -gt 0) {
        Write-Host "Applying $($fixable.Count) fixable issue(s)..." -ForegroundColor Cyan

        foreach ($issue in $fixable) {
            $values = @{}
            if ($issue.Issue -like "*_SPTranslatedLanguages*")              { $values["_SPTranslatedLanguages"]     = $null }
            if ($issue.Issue -like "*_SPTranslationLanguage should be empty*") { $values["_SPTranslationLanguage"]     = $null }
            elseif ($issue.Issue -like "*_SPTranslationLanguage is not set*" -and $issue.ResolvedValue) {
                $values["_SPTranslationLanguage"] = $issue.ResolvedValue
            }
            if ($issue.Issue -like "*_SPTranslationSourceItemId should be empty*") { $values["_SPTranslationSourceItemId"] = $null }
            elseif ($issue.Issue -like "*_SPTranslationSourceItemId is not set*" -and $issue.ResolvedValue) {
                $values["_SPTranslationSourceItemId"] = $issue.ResolvedValue
            }

            if ($values.Count -gt 0) {
                try {
                    Set-PnPListItem -List "SitePages" -Identity $issue.ItemId -Values $values -Connection $cn | Out-Null
                    Write-Host "Fixed item $($issue.ItemId) ($($issue.File))" -ForegroundColor Green
                }
                catch {
                    Write-Warning "Failed to fix item $($issue.ItemId) ($($issue.File)): $_"
                }
            }
        }
    }

    if ($manual.Count -gt 0) {
        Write-Host ""
        Write-Warning "$($manual.Count) issue(s) require manual review:"
        $manual | Select-Object File, Type, Issue | Format-Table -AutoSize
    }
}

Disconnect-PnPOnline -Connection $cn
```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***

## Contributors

| Author(s) |
|-----------|
| Fabian Hutzli |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-check-and-correct-translation-config" aria-hidden="true" />
