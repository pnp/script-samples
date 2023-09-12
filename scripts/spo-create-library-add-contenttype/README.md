---
plugin: add-to-gallery
---

# Create Library and add custom Content Type

## Summary

This sample script creates a SharePoint document library by checking whether it exists or not. Adds custom content type to the document library and makes it as a default content type.

# [PnP PowerShell](#tab/pnpps)

```powershell

function CreateLibraryWithCT {
    param ([string] $LibraryName)

    $ctName = "My Custom CT"
    $libExist = Get-PnPList $LibraryName -ErrorAction SilentlyContinue
    if ($libExist) {
        Write-Host "Library - $LibraryName already exists" -ForegroundColor Yellow
    }
    else {
        #Creating library with Document library template
        New-PnPList -Title $LibraryName -Template DocumentLibrary
        Write-Host "Created Library: " $LibraryName -ForegroundColor Green
    }

    $ctExist = Get-PnPContentType $ctName -ErrorAction SilentlyContinue
    if ($ctExist) {
        Write-Host "Content type - $ctName already exists" -ForegroundColor Yellow
    }
    else {
        $ctExist = Add-PnPContentType -Name $ctName `
            -Group "Custom Content Types" `
            -Description "My Custom CT description"
        Write-Host "Created Content Type: " $ctName -ForegroundColor Green
    }

    #region Adding, setting default content type and remove existing CT
    Add-PnPContentTypeToList -List $LibraryName -ContentType $ctExist
    Set-PnPDefaultContentTypeToList -List $LibraryName -ContentType $ctName
    Remove-PnPContentTypeFromList -List $LibraryName -ContentType "Document"
    #endregion
}

try {
    $clientId = ""
    $clientSecret = ""
    $siteUrl = "https://contoso.sharepoint.com/sites/PnPPowerShell"
    Connect-PnPOnline -Url $siteUrl -ClientId $clientId -ClientSecret $clientSecret

    CreateLibraryWithCT -LibraryName "My Lib"
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

function CreateLibraryWithCT {
    param ([string] $LibraryName)

    # Set Variables
    $siteUrl = "https://contoso.sharepoint.com/sites/CLIForMicrosoft365"
    $ctName = "My Custom CT"
    $ctId = "0x010100CD5BDB7DDE03324794E155CE37E4B6BB"

    # Check if document library already exists
    $libExist = m365 spo list get --webUrl $siteUrl --title $LibraryName | ConvertFrom-Json
    if ($libExist) {
        Write-Host "Document Library - $LibraryName already exists" -ForegroundColor Yellow
    }
    else {
        # Create new SharePoint document library
        m365 spo list add --webUrl $siteUrl --title $LibraryName --baseTemplate DocumentLibrary
        Write-Host "SharePoint Document Library Created: " $LibraryName -ForegroundColor Green
    }

    # Check if SharePoint site content type already exists    
    $ctExist = m365 spo contenttype get --webUrl $siteUrl --name $ctName | ConvertFrom-Json
    if ($ctExist) {
        Write-Host "Content type - $ctName already exists" -ForegroundColor Yellow
        $ctId = $ctExist.StringId
    }
    else {
        # Create new SharePoint site content type
        $ctExist = m365 spo contenttype add --webUrl $siteUrl --name $ctName --id $ctId --group "Custom Content Types" --description "My custom content type inherited from default document content type" | ConvertFrom-Json
        Write-Host "Content Type Created: " $ctName -ForegroundColor Green
    }

    #region Add content type to document library, set it as a default content type and remove existing document content type
    Write-Host "Adding content type to document library"
    $listCT = m365 spo list contenttype add --webUrl $siteUrl --listTitle $LibraryName --id $ctId | ConvertFrom-Json
    
    Write-Host "Setting as default content type"
    m365 spo list contenttype default set --webUrl $siteUrl --listTitle $LibraryName --contentTypeId $listCT.StringId
    
    Write-Host "Removing Document content type"
    $listDocCT = m365 spo contenttype get --webUrl $siteUrl --listTitle $LibraryName --name "Document" | ConvertFrom-Json
    m365 spo list contenttype remove --webUrl $siteUrl --listTitle $LibraryName --id $listDocCT.StringId
    #endregion
}

try {
    # Get Credentials to connect to SharePoint Online site
    $m365Status = m365 status
    if ($m365Status -match "Logged Out") {
        m365 login
    }

    # Create SharePoint document library with content type
    CreateLibraryWithCT -LibraryName "My Lib"
}
catch {
    Write-Error "Something went wrong: " $_
}
finally {
    # Disconnect SharePoint online site
    m365 logout
}

```

[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

## Contributors

| Author(s)           |
| ------------------- |
| Ahamed Fazil Buhari |
| [Ganesh Sanap](https://ganeshsanapblogs.wordpress.com/about) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-create-library-add-contenttype" aria-hidden="true" />
