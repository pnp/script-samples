

# Site Collection Ownership Validation

## Summary

This script audits all SharePoint Online site collections in a Microsoft 365 tenant to validate site ownership. It identifies site collections that have **no owners**, **disabled owners**, or **guest-only owners**, helping administrators detect governance and operational risks across the tenant.

The output provides a clear, actionable dataset that can be used for remediation, reporting, or ongoing governance monitoring in large Microsoft 365 environments.

## Why It Matters / Real-World Scenario

In large tenants, SharePoint sites are frequently created through Teams, automation, or self-service processes. Over time, owners leave the organisation, accounts are disabled, or sites become orphaned.

Without a valid internal owner:
- Access requests and security incidents cannot be actioned
- Data retention and compliance requirements may be violated
- External users may retain unmanaged access
- IT teams become the default escalation point with no clear decision authority

This script enables proactive identification of these risks before they result in security, compliance, or operational issues.

## Benefits
- Improves governance by enforcing clear ownership accountability
- Reduces security and compliance risk across SharePoint and Teams-connected sites
- Supports audits and compliance reviews with evidence-based reporting
- Enables targeted remediation rather than blanket administrative ownership
- Scales efficiently for large Microsoft 365 tenants


# [PnP PowerShell](#tab/pnpps)

```powershell

# Prerequisites:
# - PnP.PowerShell module
# - Microsoft Graph permissions: User.Read.All, Directory.Read.All

Connect-PnPOnline -Url "https://<tenant>-admin.sharepoint.com" -Interactive

$tenantSites = Get-PnPTenantSite -IncludeOneDriveSites:$false
$results = @()

foreach ($site in $tenantSites) {
    try {
        Connect-PnPOnline -Url $site.Url -Interactive -ErrorAction Stop
        $owners = Get-PnPSiteCollectionAdmin

        $ownerDetails = foreach ($owner in $owners) {
            $user = Get-MgUser -UserId $owner.LoginName -ErrorAction SilentlyContinue

            [PSCustomObject]@{
                DisplayName = $owner.Title
                UserPrincipalName = $owner.LoginName
                IsGuest = ($user.UserType -eq "Guest")
                IsDisabled = (-not $user.AccountEnabled)
            }
        }

        $hasInternalActiveOwner = $ownerDetails | Where-Object {
            $_.IsGuest -eq $false -and $_.IsDisabled -eq $false
        }

        if (-not $hasInternalActiveOwner) {
            $results += [PSCustomObject]@{
                SiteUrl        = $site.Url
                SiteTitle      = $site.Title
                OwnerCount     = $ownerDetails.Count
                Owners         = ($ownerDetails | Select-Object -ExpandProperty UserPrincipalName) -join "; "
                RiskReason     = if ($ownerDetails.Count -eq 0) {
                                    "No owners assigned"
                                } elseif ($ownerDetails.IsGuest -notcontains $false) {
                                    "Guest-only ownership"
                                } else {
                                    "All owners disabled"
                                }
            }
        }
    }
    catch {
        Write-Warning "Failed to process site: $($site.Url)"
    }
}

$results



```


# [Usage](#tab/pnpps)

1. Install required modules:

```powershell

Install-Module PnP.PowerShell
Install-Module Microsoft.Graph


```

2. Install required modules:
- SharePoint Administrator role
- Microsoft Graph permissions: **User.Read.All**, **Directory.Read.All**

3. Run the script from a secure admin workstation.

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***


## Output

The script returns a collection of objects containing:
- Site URL
- Site title
- Owner count
- Owner UPNs
- Governance risk reason

This output can be:
- Exported to CSV
- Ingested into Power BI
- Used as input for remediation automation

## Notes
- Script excludes OneDrive sites by default
- Designed to be read-only (no changes applied)
- Suitable for scheduled execution (e.g. quarterly governance reviews)
- Can be extended to auto-assign fallback owners if required

## Contributors

| Author(s) |
|-----------|
| [Josiah Opiyo](https://github.com/ojopiyo) |

*Built with a focus on automation, governance, least privilege, and clean Microsoft 365 tenants—helping M365 admins gain visibility and reduce operational risk.*


## Version history

Version|Date|Comments
-------|----|--------
1.0|Dec 22, 2025|Initial release


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]

