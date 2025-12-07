

# Create Site Columns and add to Content Types

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

# [CLI for Microsoft 365](#tab/cli-m365-ps)

```powershell
# .\Add-FieldsToContentTypes.ps1 -SiteUrl "https://contoso.sharepoint.com/sites/CLIForM365" -ContentTypes "My Review CT","Global User Review CT" -WhatIf
[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param (
    [Parameter(Mandatory = $true, HelpMessage = "Absolute URL of the site where the fields and content types exist.")]
    [ValidatePattern('^https://')]
    [string]$SiteUrl,

    [Parameter(Mandatory = $true, HelpMessage = "Content type names to which the fields should be added.")]
    [ValidateNotNullOrEmpty()]
    [string[]]$ContentTypes,

    [Parameter(HelpMessage = "Optional override for the field definitions.")]
    [ValidateNotNull()]
    [System.Collections.Hashtable[]]$FieldDefinitions
)

begin {
    Write-Verbose "Ensuring CLI for Microsoft 365 session."
    m365 login --ensure

    if (-not $FieldDefinitions) {
        $FieldDefinitions = @(
            @{ FieldName = 'admin_review'; FieldId = '3eccccb1-9789-40e9-bee8-0e27a2b0ea9f'; FieldXml = "<Field Type='User' DisplayName='Admin Reviewer' Required='false' EnforceUniqueValues='false' Hidden='false' UserSelectionMode='PeopleAndGroups' Group='My Site Columns' ID='{3eccccb1-9789-40e9-bee8-0e27a2b0ea9f}' StaticName='admin_review' Name='admin_review' />" },
            @{ FieldName = 'admin_reviewdate'; FieldId = 'bee79067-c92c-4d9c-b80c-63a75a468b16'; FieldXml = "<Field Type='DateTime' DisplayName='Admin Review Date' Required='false' EnforceUniqueValues='false' Hidden='false' Group='My Site Columns' ID='{bee79067-c92c-4d9c-b80c-63a75a468b16}' StaticName='admin_reviewdate' Name='admin_reviewdate' />" }
        )
    }

    $Script:Results = [System.Collections.Generic.List[pscustomobject]]::new()

    function Ensure-SiteField {
        param (
            [Parameter(Mandatory = $true)] [string]$WebUrl,
            [Parameter(Mandatory = $true)] [System.Collections.Hashtable]$Definition
        )

        $fieldLookup = m365 spo field list --webUrl $WebUrl --output json | ConvertFrom-Json
        $existingField = $fieldLookup | Where-Object { $_.Title -eq $Definition.FieldName -or $_.InternalName -eq $Definition.FieldName -or $_.Id -eq $Definition.FieldId }

        if ($existingField) {
            $Script:Results.Add([pscustomobject]@{
                    Action  = 'Field'
                    Target  = $Definition.FieldName
                    Status  = 'Skipped'
                    Message = 'Field already exists'
                })
            return $existingField
        }

        if (-not $PSCmdlet.ShouldProcess($Definition.FieldName, 'Create site column')) {
            $Script:Results.Add([pscustomobject]@{
                    Action  = 'Field'
                    Target  = $Definition.FieldName
                    Status  = 'WhatIf'
                    Message = 'Field creation skipped'
                })
            return $null
        }

        $createOutput = m365 spo field add --webUrl $WebUrl --xml $Definition.FieldXml --output json 2>&1
        if ($LASTEXITCODE -ne 0) {
            $Script:Results.Add([pscustomobject]@{
                    Action  = 'Field'
                    Target  = $Definition.FieldName
                    Status  = 'Failed'
                    Message = $createOutput
                })
            return $null
        }

        $createdField = $createOutput | ConvertFrom-Json
        $Script:Results.Add([pscustomobject]@{
                Action  = 'Field'
                Target  = $Definition.FieldName
                Status  = 'Created'
                Message = 'Field created successfully'
            })
        return $createdField
    }

    function Add-FieldToContentType {
        param (
            [Parameter(Mandatory = $true)] [string]$WebUrl,
            [Parameter(Mandatory = $true)] [string]$ContentTypeName,
            [Parameter(Mandatory = $true)] [System.Collections.Hashtable]$Definition
        )

        $contentTypeJson = m365 spo contenttype get --webUrl $WebUrl --name $ContentTypeName --output json 2>&1
        if ($LASTEXITCODE -ne 0) {
            $Script:Results.Add([pscustomobject]@{
                    Action  = 'ContentType'
                    Target  = $ContentTypeName
                    Status  = 'Failed'
                    Message = $contentTypeJson
                })
            return
        }

        $contentType = $contentTypeJson | ConvertFrom-Json
        if (-not $contentType.StringId) {
            $Script:Results.Add([pscustomobject]@{
                    Action  = 'ContentType'
                    Target  = $ContentTypeName
                    Status  = 'Failed'
                    Message = 'Content type not found'
                })
            return
        }

        if (-not $PSCmdlet.ShouldProcess($ContentTypeName, "Add field $($Definition.FieldName)")) {
            $Script:Results.Add([pscustomobject]@{
                    Action  = 'ContentType'
                    Target  = $ContentTypeName
                    Status  = 'WhatIf'
                    Message = "Skipped adding field $($Definition.FieldName)"
                })
            return
        }

        $setOutput = m365 spo contenttype field set --webUrl $WebUrl --contentTypeId $contentType.StringId --id $Definition.FieldId --output json 2>&1
        if ($LASTEXITCODE -ne 0) {
            $Script:Results.Add([pscustomobject]@{
                    Action  = 'ContentType'
                    Target  = $ContentTypeName
                    Status  = 'Failed'
                    Message = $setOutput
                })
            return
        }

        $Script:Results.Add([pscustomobject]@{
                Action  = 'ContentType'
                Target  = $ContentTypeName
                Status  = 'Updated'
                Message = "Field $($Definition.FieldName) bound successfully"
            })
    }
}

process {
    foreach ($definition in $FieldDefinitions) {
        Ensure-SiteField -WebUrl $SiteUrl -Definition $definition
    }

    foreach ($contentType in $ContentTypes) {
        foreach ($definition in $FieldDefinitions) {
            Add-FieldToContentType -WebUrl $SiteUrl -ContentTypeName $contentType -Definition $definition
        }
    }
}

end {
    $Script:Results | Sort-Object Action, Target | Format-Table -AutoSize
}
```

[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

***

## Contributors

| Author(s)           |
| ------------------- |
| Ahamed Fazil Buhari |
| [Ganesh Sanap](https://ganeshsanapblogs.wordpress.com/about) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-add-fields-to-contenttypes" aria-hidden="true" />
