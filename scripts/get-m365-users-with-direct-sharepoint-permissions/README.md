

# Get M365 Users with Direct SharePoint Permissions
## Summary

This script identifies users who have been granted direct permissions on SharePoint Online sites, rather than receiving access through groups. Direct permissions can bypass standard governance and make permission management more difficult to audit. By detecting these users, the script helps organizations maintain least-privilege access, ensure compliance with internal policies, and reduce the risk of unintended data exposure. The output provides a detailed, actionable report of sites, users, and assigned roles, enabling administrators to remediate or review access efficiently.

## Why It Matters
In production environments, managing SharePoint permissions through groups is best practice to maintain governance, security, and compliance. Users with direct site permissions can bypass these controls, creating potential security risks and complicating audits. This script identifies such users, providing administrators with a clear, actionable report. By highlighting direct permissions, it helps enforce **least-privilege access**, supports regulatory compliance, and ensures that SharePoint sites remain secure and properly managed.

## Key Benefits
- **Governance & Compliance:** Detect deviations from standard group-based access.  
- **Security & Risk Management:** Identify users with potentially excessive permissions.  
- **Audit & Reporting:** Generate a clear, auditable record of all direct permissions.  
- **Operational Efficiency:** Quickly remediate unmanaged permissions.  
- **Proactive Monitoring:** Maintain least-privilege access in production environments.  


# [PnP PowerShell](#tab/pnpps)

```powershell

# ---------------------------
# Script: Find Users with Direct SharePoint Permissions
# Purpose: Identify users who have direct permissions on SharePoint sites rather than via groups
# ---------------------------

# Set the SharePoint Admin Center URL
$AdminCenterURL = "https://contoso-admin.sharepoint.com"

# Connect to SharePoint Online Admin Center
Connect-PnPOnline -Url $AdminCenterURL -Interactive

# Get all site collections in the tenant
$AllSites = Get-PnPTenantSite

# Prepare an array to hold results
$DirectPermissions = @()

foreach ($Site in $AllSites) {

    Write-Host "Processing site: $($Site.Url)" -ForegroundColor Cyan

    # Connect to each site
    Connect-PnPOnline -Url $Site.Url -Interactive

    # Get all users and groups with access to the site
    $RoleAssignments = Get-PnPProperty -ClientObject (Get-PnPSite) -Property RoleAssignments

    foreach ($RoleAssignment in $RoleAssignments) {
        $Member = $RoleAssignment.Member

        # Check if the member is a user (not a group)
        if ($Member.PrincipalType -eq "User") {

            # Store details
            $DirectPermissions += [PSCustomObject]@{
                SiteUrl        = $Site.Url
                SiteTitle      = $Site.Title
                UserName       = $Member.LoginName
                UserEmail      = $Member.Email
                PermissionRole = ($RoleAssignment.RoleDefinitionBindings | ForEach-Object { $_.Name }) -join ", "
            }
        }
    }
}

# Export results to CSV
$ExportPath = "C:\Temp\DirectSharePointPermissions.csv"
$DirectPermissions | Export-Csv -Path $ExportPath -NoTypeInformation -Encoding UTF8

Write-Host "Script completed. Direct permissions exported to $ExportPath" -ForegroundColor Green

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***


## Contributors

| Author(s) |
|-----------|
| [Josiah Opiyo](https://github.com/ojopiyo) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/get-spo-invalid-user-accounts" aria-hidden="true" />
