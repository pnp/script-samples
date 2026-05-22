# Identify OneDrive Users Over License-Based Storage Quota

## Summary

Identifies OneDrive for Business users who are over their **expected** storage quota based on their assigned license tier, with special handling for EDU A1 enforcement (100 GB entitlement). The script uses **Microsoft Graph exclusively** — no SharePoint Online Management Shell, no PnP, no third-party modules.

OneDrive sites are provisioned with a default storage quota based on tenant settings, but the *expected* quota varies by license tier. EDU A1 users, for example, are entitled to 100 GB — but if they were provisioned before A1 enforcement, they may have a 1 TB or 5 TB allocation and be storing far more than 100 GB today. This script answers: **Which OneDrive sites are storing more data than the owner's license tier entitles them to?**

The script is **strictly read-only**. It never modifies a quota, license, or file. It only reports.

Works on Windows PowerShell 5.1+ and PowerShell 7+, on commercial, GCC Moderate, GCC High, DoD, and 21Vianet (China) tenants.

![Example Screenshot](assets/sample-output.png)

## Implementation

### Quota tiers it evaluates

The expected quota is derived from the **highest-tier OneDrive service plan** in the user's licenses (SKUs stack — the script picks the most generous):

| Tier | Expected Quota | Typical SKUs |
|---|---|---|
| Enterprise | 5 TB | E3, E5, A3, A5, Plan 2 |
| Standard | 1 TB | Plan 1, Multi-Geo |
| Lite / **A1 (EDU)** | 100 GB | OneDrive Lite, **Office 365 A1** |
| BasicP2 | 10 GB | Basic 2 |
| Viral / Basic | 5 GB | Office for the web, Basic |
| Deskless | 2 GB | F1, F3, Kiosk |

Unlicensed users with a OneDrive (e.g. retained offboarded accounts) are flagged as over quota whenever `StorageUsed > 0`.

### Scan modes

| Mode | How invoked | Speed | Data freshness | Notes |
|---|---|---|---|---|
| **FastScan** | *default* | ~minutes on 100k-user tenants | Daily snapshot (~24-48h latency) | Uses Reports API. Returns provisioned OneDrives only. Won't work if tenant report anonymization is on. |
| **LegacyScan** | `-LegacyScan` | ~hours on 100k-user tenants | Real-time | Per-user enumeration. Works regardless of anonymization. |
| **TargetedUser** | `-UserPrincipalName` | seconds | Real-time | Looks up only the specified UPN(s). Bypasses both modes above. |

### Prerequisites

| Requirement | Notes |
|---|---|
| PowerShell 5.1+ or PowerShell 7+ | Script enforces `#Requires -Version 5.1`. |
| `Microsoft.Graph.Authentication` ≥ 2.0.0 | Auto-installable with `-InstallPrerequisites`. |
| `Microsoft.Graph.Users` ≥ 2.0.0 | Same. |
| Graph delegated scopes | `User.Read.All`, `Directory.Read.All`, `Reports.Read.All`, `Sites.Read.All`. May need Global Admin consent on first run. |
| M365 role | **Global Reader** is sufficient and recommended (least privilege). |

### CSV output

When `-ExportPath` is set, the CSV contains **every** evaluated site, sorted so over-quota rows appear first.

| Column | Description |
|---|---|
| `Owner`, `DisplayName`, `SiteUrl` | Identity and site location |
| `LicenseTier` | e.g. "Enterprise (5 TB)", "A1 (100 GB)", "Unlicensed" |
| `ExpectedQuota` / `CurrentQuota` / `StorageUsed` | Human-readable storage figures |
| `OverBy` | Amount over (blank if under) |
| `OverQuota` | **`True` / `False`** — filter on this in Excel |
| `StorageUsedMB`, `ExpectedQuotaMB`, `CurrentQuotaMB`, `OverByMB` | Numeric versions for pivots |
| `AssignedSKUs` | Comma-separated SKU part numbers |

# [Microsoft Graph PowerShell](#tab/graphps)

```powershell
# First run on a new machine — installs Graph modules and runs the scan
.\Get-ODBOverQuotaUsers.ps1 -InstallPrerequisites

# Tenant-wide scan with CSV export (recommended baseline)
.\Get-ODBOverQuotaUsers.ps1 -ExportPath "C:\Reports\OneDriveQuota.csv"

# Spot-check a specific user
.\Get-ODBOverQuotaUsers.ps1 -UserPrincipalName alice@contoso.com

# Spot-check several users with CSV export
.\Get-ODBOverQuotaUsers.ps1 `
    -UserPrincipalName alice@contoso.com,bob@contoso.com,carol@contoso.com `
    -ExportPath "C:\Reports\SpotCheck.csv"

# Force real-time scan instead of the daily snapshot (slower but live data)
.\Get-ODBOverQuotaUsers.ps1 -LegacyScan -ExportPath "C:\Reports\Live.csv"

# Sovereign cloud (GCC High shown; use USGovDoD or China as needed)
.\Get-ODBOverQuotaUsers.ps1 -Environment USGov -ExportPath "C:\Reports\GCCH.csv"

# Multi-tenant admin (MSP, CSP, delegated) targeting a customer tenant
.\Get-ODBOverQuotaUsers.ps1 -TenantId "contoso.onmicrosoft.com" -ExportPath "C:\Reports\Contoso.csv"

# Combine parameters freely — customer tenant in GCC High
.\Get-ODBOverQuotaUsers.ps1 `
    -TenantId "agency.onmicrosoft.us" `
    -Environment USGov `
    -ExportPath "C:\Reports\Agency-GCCH.csv"
```

The full script is in this folder: [`Get-ODBOverQuotaUsers.ps1`](./Get-ODBOverQuotaUsers.ps1).

***

[!INCLUDE [More about Microsoft Graph PowerShell](../../docfx/includes/MORE-GRAPHPS.md)]

## Parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `-ExportPath` | string | *(none)* | Full path for CSV export. **Use a full path** (e.g. `C:\Reports\report.csv`) — relative paths in elevated shells resolve to `C:\WINDOWS\system32`. Script validates writability before scanning. |
| `-TenantId` | string | *(home tenant)* | Tenant ID (GUID) or verified domain. Required for multi-tenant admins. |
| `-Environment` | string | `Global` | `Global` (commercial / GCC Moderate), `USGov` (GCC High), `USGovDoD`, or `China`. |
| `-UserPrincipalName` | string[] | *(none)* | One or more UPNs to evaluate. Bypasses FastScan/LegacyScan. |
| `-LegacyScan` | switch | off | Use per-user enumeration instead of the Reports API. Slower but real-time. |
| `-InstallPrerequisites` | switch | off | Auto-install missing Graph modules to current-user scope. |

**Parameter precedence:** `-UserPrincipalName` wins over `-LegacyScan`. All parameters compose freely with `-TenantId` and `-Environment`.

## Source Credit

Sample first appeared on [PnP Script Samples](https://pnp.github.io/script-samples/).

## Contributors

| Author(s) |
|-----------|
| [Sam Larson](https://github.com/salarson) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-onedrive-overquota-license-report" aria-hidden="true" />
