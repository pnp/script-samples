---
plugin: add-to-gallery
---

# Create Library and add custom Content Type

## Summary

The script will create a Site Columns by checking whether it exists or not. Adds the site columns to the existing Content Types.

# [PnP PowerShell](#tab/pnpps)

```powershell

function CreateField {
    param ([string] $FieldName, [string] $FieldXML)

    try {
        #Check the field and create
        $field = Get-PnPField -Identity $FieldName -ErrorAction SilentlyContinue

        If ($Null -eq $field) {
            Add-PnPFieldFromXml -FieldXml $FieldXML
            Write-host "Successfully created field '$FieldName'" -ForegroundColor Green
        }
        Else {
            Write-host "Field '$FieldName' already exists. Skipping creation" -f Green
        }
    }
    catch {
        Write-Error "Error in CreateField - $_"
        throw
    }
}

function CreateAndAddFieldsToCTs {
    param ([string[]] $ContentTypes)

    try {

        #region Create Site Columns
        $fieldsToCreate = @(
            @{
                FieldName = "admin_review"
                FieldXML  = "<Field Type='User' DisplayName='Admin Reviewer' Required='false' EnforceUniqueValues='false' Hidden='false' UserSelectionMode='PeopleAndGroups' Group='My Site Columns' ID='{3eccccb1-9789-40e9-bee8-0e27a2b0ea9f}' StaticName='admin_review' Name='admin_review' />"
            },
            @{
                FieldName = "admin_reviewdate"
                FieldXML  = "<Field Type='DateTime' DisplayName='Admin Review Date' Required='false' EnforceUniqueValues='false' Hidden='false' Group='My Site Columns' ID='{bee79067-c92c-4d9c-b80c-63a75a468b16}' StaticName='admin_reviewdate' Name='admin_reviewdate' />"
            }
        )

        foreach ($fieldToCreate in $fieldsToCreate) {
            Write-Host "Creating the field - $($fieldToCreate.FieldName)" -ForegroundColor Yellow
            CreateField -FieldName $($fieldToCreate.FieldName) -FieldXML $($fieldToCreate.FieldXML)
        }
        Write-Host `n `n
        #endregion

        foreach ($contentType in $ContentTypes) {
            foreach ($fieldToCreate in $fieldsToCreate) {
                Write-Host "Adding field - $($fieldToCreate.FieldName) to CT $contentType" -ForegroundColor Yellow
                Add-PnPFieldToContentType -Field $($fieldToCreate.FieldName) -ContentType $contentType
            }
            Write-Host "Successfully added fields to CT $contentType" -ForegroundColor Green
            Write-Host `n
        }
    }
    catch {
        Write-Error "Error in CreateAndAddFieldsToCTs - $_"
    }
}

try {
    $clientId = ""
    $clientSecret = ""
    $siteUrl = ""
    Connect-PnPOnline -Url $siteUrl -ClientId $clientId -ClientSecret $clientSecret

    CreateAndAddFieldsToCTs -ContentTypes @("My Review CT", "Global User Review CT")
}
catch {
    Write-Error "Something wrong: " $_
}
finally {
    $pnpConnection = Get-PnPConnection -ErrorAction SilentlyContinue
    if ($pnpConnection) {
        Disconnect-PnPOnline
    }
}

```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

## Contributors

| Author(s)           |
| ------------------- |
| Ahamed Fazil Buhari |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-add-fields-to-contenttypes" aria-hidden="true" />
