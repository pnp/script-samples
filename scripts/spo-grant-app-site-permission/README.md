

# Grant permissions for a given Azure Active Directory application registration

## Summary

This script simplifies the process of granting `FullControl` or `Manage` permissions for an application registration in a SharePoint site collection, specifically when used in conjunction with the Azure Active Directory SharePoint application permission `Sites.Selected`.

# [PnP PowerShell](#tab/pnpps)

```powershell
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$SiteUrl,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$AppId,

    [Parameter(Mandatory)]
    [ValidateSet('Read', 'Write', 'Manage', 'FullControl')]
    [string]$Permissions
)

Connect-PnPOnline -Url $SiteUrl -Interactive

$DisplayName = (Get-PnPAzureADApp -Identity $AppId).DisplayName
if ($Permissions -eq 'FullControl' -or $Permissions -eq 'Manage') {    
    Grant-PnPAzureADAppSitePermission -Permissions Write -Site $SiteUrl -AppId $AppId -DisplayName $DisplayName | Out-Null
    $PermissionId = Get-PnPAzureADAppSitePermission -AppIdentity $AppId
    Set-PnPAzureADAppSitePermission -Site $SiteUrl -PermissionId $(($PermissionId).Id) -Permissions $Permissions | Out-Null
    Get-PnPAzureADAppSitePermission -AppIdentity $AppId
}
else {
    Grant-PnPAzureADAppSitePermission -Permissions $Permissions -Site $SiteUrl -AppId $AppId -DisplayName $DisplayName
}
```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]


## Source Credit

Sample idea first appeared on [https://www.leonarmston.com/2022/02/use-sites-selected-permission-with-fullcontrol-rather-than-write-or-read/](https://www.leonarmston.com/2022/02/use-sites-selected-permission-with-fullcontrol-rather-than-write-or-read/). This is a slightly modified version.

## Contributors

| Author(s) |
|-----------|
| [Michał Romiszewski](https://github.com/mromiszewski) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-grant-app-site-permission" aria-hidden="true" />