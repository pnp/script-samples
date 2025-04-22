

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

function CreateField {
    param ([string] $FieldName, [string] $FieldXML)

    try {
        # Check if the field exists and create
        $field = m365 spo field get --webUrl $siteUrl --title $FieldName | ConvertFrom-Json

        if ($null -eq $field) {
            # Add new field based on XML
            m365 spo field add --webUrl $siteUrl --xml $FieldXML
            Write-Host "Successfully created field '$FieldName'" -ForegroundColor Green
        }
        else {
            Write-Host "Field '$FieldName' already exists. Skipping creation" -f Green
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
        #region Create SharePoint Site Columns
        $fieldsToCreate = @(
            @{
                FieldName = "admin_review"
                FieldID   = "3eccccb1-9789-40e9-bee8-0e27a2b0ea9f" 
                FieldXML  = "<Field Type='User' DisplayName='Admin Reviewer' Required='false' EnforceUniqueValues='false' Hidden='false' UserSelectionMode='PeopleAndGroups' Group='My Site Columns' ID='{3eccccb1-9789-40e9-bee8-0e27a2b0ea9f}' StaticName='admin_review' Name='admin_review'></Field>"
            },
            @{
                FieldName = "admin_reviewdate"
                FieldID   = "bee79067-c92c-4d9c-b80c-63a75a468b16"
                FieldXML  = "<Field Type='DateTime' DisplayName='Admin Review Date' Required='false' EnforceUniqueValues='false' Hidden='false' Group='My Site Columns' ID='{bee79067-c92c-4d9c-b80c-63a75a468b16}' StaticName='admin_reviewdate' Name='admin_reviewdate'></Field>"
            }
        )

        foreach ($fieldToCreate in $fieldsToCreate) {
            Write-Host "Creating the field - $($fieldToCreate.FieldName)" -ForegroundColor Yellow
            CreateField -FieldName $($fieldToCreate.FieldName) -FieldXML $($fieldToCreate.FieldXML)
        }
        Write-Host `n `n
        #endregion

        #region Add Site Columns to Content Types
        foreach ($contentType in $ContentTypes) {
            $contentTypeObj = m365 spo contenttype get --webUrl $siteUrl --name $contentType | ConvertFrom-Json
            if ($contentTypeObj.StringId) {
                foreach ($fieldToCreate in $fieldsToCreate) {
                    Write-Host "Adding field - $($fieldToCreate.FieldName) to CT $contentType" -ForegroundColor Yellow
                
                    m365 spo contenttype field set --webUrl $siteUrl --contentTypeId $contentTypeObj.StringId --id $fieldToCreate.FieldID
                    Write-Host "Successfully added fields to CT $contentType" -ForegroundColor Green
                    Write-Host `n
                }
            } 
            else {
                Write-Host "Content Type not found: $contentType" -ForegroundColor Green
                Write-Host `n
            }

        }
        #endregion
    }
    catch {
        Write-Error "Error in CreateAndAddFieldsToCTs - $_"
    }
}

try {
    # SharePoint Online Site Url
    $siteUrl = "https://contoso.sharepoint.com/sites/CLIForM365"

    # Get Credentials to connect
    $m365Status = m365 status
    if ($m365Status -match "Logged Out") {
        m365 login
    }

    # Create and add fields to SharePoint content types
    CreateAndAddFieldsToCTs -ContentTypes @("My Review CT", "Global User Review CT")
}
catch {
    Write-Error "Something wrong: " $_
}
finally {
    # Disconnect SharePoint online connection
    m365 logout
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
