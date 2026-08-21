# Export and Import TermGroups

## Summary

This script exports Term Groups from a source SharePoint Online tenant and imports them into a target tenant using PnP PowerShell. It connects interactively to both tenants, retrieves all (or a specified subset of) Term Groups, exports each one to a local XML file, and then imports those XML files into the target tenant. Before importing, the script performs an in-place string replacement in the XML to update tenant-specific domain references from the source tenant to the target tenant.

# [PnP PowerShell](#tab/pnpps)

```powershell
# XML Export / Import Path
$xmlPath = "./Terms/xml"

# Source
$cnSource = Connect-PnPOnline -Url "https://sourcetenant-admin.sharepoint.com" -Interactive -ReturnConnection

# Target
$cnTarget = Connect-PnPOnline -Url "https://targettenant-admin.sharepoint.com" -Interactive -ReturnConnection

# 1) Get all TermGroups
$TermGroups = (Get-PnPTermGroup -Connection $cnSource).Name

<# 2) Get TermGroups
$TermGroups = @(
    "TermGroup1"
    "TermGroup2"
)
#>

# Export Terms to local disk
$TermGroups | ForEach-Object {
    $TermGroup = $_
    Write-Host "Export Termgroup $($TermGroup)"
    Export-PnPTermGroupToXml -Identity $TermGroup -Out "$($xmlPath)/$($TermGroup).xml" -Force -Connection $cnSource
}

# Import Terms
$confirm = Read-Host "Importing Terms to $($cnTarget.Url)? [y/n]" 
if ($confirm -eq "y") {
    $TermGroups | ForEach-Object {
        $TermGroup = $_
        Write-Host "Importing Termgroup $($TermGroup) to Tenant $($cnTarget.Url)..."
        (Get-Content -Path "$($xmlPath)/$($TermGroup).xml").Replace("@sourcetenant.ch","@targettenant.ch") | Set-Content -Path "$($xmlPath)/$($TermGroup).xml"
        Import-PnPTermGroupFromXml -Path "$($xmlPath)/$($TermGroup).xml" -Connection $cnTarget 
    }
}
else {
    Write-Host "No action performed" -ForegroundColor DarkGray
}
```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***

## Contributors

| Author(s) |
|-----------|
| [Fabian Hutzli](https://github.com/fabianhutzli)|


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-cleanup-spfx-solution" aria-hidden="true" />

