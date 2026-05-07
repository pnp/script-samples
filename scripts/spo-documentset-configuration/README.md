# Configure SharePoint Document Set

## Summary

Document Sets in SharePoint are a powerful way to manage groups of related documents as a single entity. They enable you to apply metadata, workflows, and permissions to a collection of documents, making them ideal for project folders, case files, or any scenario where you need to keep related content together.

This script automates the configuration of Document Sets across multiple libraries:

- Enable the Document Set feature
- Create a custom Document Set content type
- Add site columns to the content type
- Add the content type to all document libraries (excluding system libraries)
- Create sample document sets and set metadata
- Add columns to the default view

### Prerequisites

- The user account that runs the script must have access to the SharePoint Online site.

# [PnP PowerShell](#tab/pnpps)

```powershell
param (
    [Parameter(Mandatory = $true)]
    [string] $siteUrl,
    [Parameter(Mandatory = $true)]
    [string] $docsetCTName,
    [Parameter(Mandatory = $true)]
    [string] $columnsToAddToDocSet = "Company,Department",
    [Parameter(Mandatory = $false)]
    [string] $docSetToAdd = "CompanyA,CompanyB",
    [Parameter(Mandatory = $false)]
    [boolean] $enableModernLayout
)

Connect-PnPOnline -Url $siteUrl

# Activate Document Set feature
Enable-PnPFeature -Identity "3bae86a2-776d-499d-9db8-fa4cdc7884f8" -Scope Site -ErrorAction SilentlyContinue

# Ensure parent content type is available
$parentContentType = $null
while($null -eq $parentContentType ) {
    $parentContentType = Get-PnPContentType -Identity "Document Set"
    Start-Sleep -Seconds 5
}

# Create custom Document Set content type
Add-PnPContentType -Name $docsetCTName -ParentContentType $parentContentType -Group "Doc Set Content Types" -ErrorAction SilentlyContinue | Out-Null

# Add columns to content type
$columnsToAddToDocSet.Split(",") | ForEach-Object {
    Add-PnPFieldToContentType -Field $_ -ContentType $docsetCTName | Out-Null
}

# Exclude system libraries
$ExcludedLists = @("Access Requests", "App Packages", ... ) # (truncated for brevity)

Get-PnPList | Where-Object { $_.BaseTemplate -eq 101 -and $_.Hidden -eq $False -and $_.Title -notin $ExcludedLists } | ForEach-Object {
    $list = Get-PnPList -Identity $_
    Set-PnPList -Identity $list -EnableContentTypes $True
    Add-PnPContentTypeToList -List $list -ContentType $docsetCTName | Out-Null
    Set-PnPDefaultContentTypeToList -List $list -ContentType $docsetCTName

    # Create document sets and set metadata
    $docSetToAdd.Split(",") | ForEach-Object {
        $docSetName = $_
        $docSet = Add-PnPDocumentSet -List $list -ContentType $docsetCTName -Name $docSetName
        $docSetItem = Get-PnPListItem -List $list -Query "<View><Query><Where><Eq><FieldRef Name='FileLeafRef'/><Value Type='Text'>$docSetName</Value></Eq></Where></Query></View>"
        Set-PnPListItem -List $list -Identity $docSetItem.Id -Values @{Company="Company A"; Department="Finance"; } | Out-Null
        Write-Host "Document set '$docSetName' created and metadata set."
    }

    # Add columns to default view
    $DefaultListView = Get-PnPView -List $list | Where-Object { $_.DefaultView -eq $True }
    $columnsToAddToDocSet.Split(",") | ForEach-Object {
        if ($DefaultListView.ViewFields -notcontains $_) {
            try {
                $DefaultListView.ViewFields.Add($_)
                $DefaultListView.Update()
                Invoke-PnPQuery
                Write-Host -f Green "$_ column added to the Default View in library $($list.Title)!"
            } catch {
                Write-Host -f Red "Error adding $_ column to the View! $($list.Title)"
            }
        }
    }

    if($enableModernLayout) {
        # Enable modern layout for the content type
        $ct = Get-PnPContentType -Identity $docsetCTName -List $list
        $ct.NewFormClientSideComponentId = $null
        $ct.Update($false)
        Invoke-PnPQuery
        Write-Host -f Green "Modern layout enabled for content type $docsetCTName in library $($list.Title)!"
    }
}
```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***

## Source Credit

Sample first appeared on [Automate SharePoint Document Set Configuration with PowerShell](https://reshmeeauckloo.com/posts/powershell-sharepoint-documentset-configuration/)

## Contributors

| Author(s)                                        |
| ------------------------------------------------ |
| [Reshmee Auckloo](https://github.com/reshmee011) |
| [Dan Toft](https://dan-toft.dk)                  |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-documentset-configuration" aria-hidden="true" />
