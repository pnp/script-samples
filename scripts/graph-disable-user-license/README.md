

# Deactivate User License

## Summary

This script connects to Micrsoft Graph and searches all Microsoft E3 Licenses for YAMMER_Enterprise licenses. It will then deactive the Yammer license within Office 365, it can be used to remove other Office 365 licenses as well. It will cycle through the entire Office 365 directory for all users.

[!INCLUDE [Delete Warning](../../docfx/includes/DELETE-WARN.md)]

# [Microsoft Graph PowerShell](#tab/graphps)

```powershell

Connect-Graph -Scopes User.Read.All, Organization.Read.All

# Set variable is e3Sku

# Get all users with SPE_E3 licenses
$users = Get-MgUser -Filter "assignedLicenses/any(x:x/skuId eq $($e3Sku.SkuId) )" -ConsistencyLevel eventual -CountVariable e3licensedUserCount -All

# Get the new service plans that are going to be disabled
$e3Sku = Get-MgSubscribedSku -All | Where SkuPartNumber -eq 'SPE_E3'
$newDisabledPlans = $e3Sku.ServicePlans |
Where-Object { $_.ServicePlanName -in ("YAMMER_ENTERPRISE") } |
Select-Object -ExpandProperty ServicePlanId

foreach ($user in $users) {
    # Get the services that have already been disabled for the user.
    $userLicense = Get-MgUserLicenseDetail -UserId $user.UserPrincipalName
    $userDisabledPlans = $userLicense.ServicePlans |
    Where-Object { $_.ProvisioningStatus -eq "Disabled" } |
    Select-Object -ExpandProperty ServicePlanId

    # Merge the new plans that are to be disabled with the user's current state of disabled plans
    $disabledPlans = ($userDisabledPlans + $newDisabledPlans) | Select-Object -Unique

    $addLicenses = @{
        SkuId         = $e3Sku.SkuId
        DisabledPlans = $disabledPlans
    }

    # Update user's license
    Set-MgUserLicense -UserId $user.UserPrincipalName -AddLicenses $addLicenses -RemoveLicenses @()
}  

```
[!INCLUDE [More about Microsoft Graph PowerShell SDK](../../docfx/includes/MORE-GRAPHSDK.md)]
***


## Contributors

| Author(s) |
|-----------|
| Brad Chaney |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/graph-disable-user-license" aria-hidden="true" />
