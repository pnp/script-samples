---
plugin: add-to-gallery
---

# Create Library and add custom Content Type

## Summary

The script will create a SharePoint library by checking whether it exists or not. Adds custom Content Type to the library and make it as a default content type.

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
        Write-Host "Created Library " $LibraryName -ForegroundColor Green
    }

    $ctExist = Get-PnPContentType $ctName -ErrorAction SilentlyContinue
    if ($ctExist) {
        Write-Host "Content type - $ctName already exists" -ForegroundColor Yellow
    }
    else {
        $ctExist = Add-PnPContentType -Name $ctName `
            -Group "Custom Content Types" `
            -Description "My custom ct"
        Write-Host "Created Content Type " $ctName -ForegroundColor Green
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
    $siteUrl = ""
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

## Contributors

| Author(s)           |
| ------------------- |
| Ahamed Fazil Buhari |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-create-library-add-contenttype" aria-hidden="true" />
