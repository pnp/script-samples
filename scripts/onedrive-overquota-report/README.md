# Get-ODBOverQuotaUsers

A PowerShell script for identifying OneDrive for Business users who are over their **expected** storage quota based on their assigned license tier, with special handling for EDU A1 enforcement.

Uses **Microsoft Graph exclusively** — no SharePoint Online Management Shell, no PnP, no third-party modules. Works on Windows PowerShell 5.1+ and PowerShell 7+, on commercial, GCC Moderate, GCC High, DoD, and 21Vianet (China) tenants.

---

## What this script does

OneDrive sites are provisioned with a default storage quota based on tenant settings, but the *expected* quota varies by license tier. EDU A1 users, for example, are entitled to 100 GB — but if they were provisioned before A1 enforcement, they may have a 1 TB or 5 TB allocation and be storing far more than 100 GB today.

This script answers a single question:

> **Which OneDrive sites are storing more data than the owner's license tier entitles them to?**

It produces a console summary plus an optional CSV containing **every** evaluated site with an `OverQuota` True/False column for filtering in Excel.

**Important:** the script is **strictly read-only**. It never modifies a quota, license, or file. It only reports.

---

## Quota tiers it evaluates

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

---

## Scan modes

| Mode | How invoked | Speed | Data freshness | Notes |
|---|---|---|---|---|
| **FastScan** | *default* | ~minutes on 100k-user tenants | Daily snapshot (~24-48h latency) | Uses Reports API. Returns provisioned OneDrives only. Won't work if tenant report anonymization is on. |
| **LegacyScan** | `-LegacyScan` | ~hours on 100k-user tenants | Real-time | Per-user enumeration. Works regardless of anonymization. |
| **TargetedUser** | `-UserPrincipalName` | seconds | Real-time | Looks up only the specified UPN(s). Bypasses both modes above. |

---

## Quick start

### First run on a new machine

```powershell
.\Get-ODBOverQuotaUsers.ps1 -InstallPrerequisites
```
Bootstraps NuGet, trusts PSGallery, installs `Microsoft.Graph.Authentication` and `Microsoft.Graph.Users` to current-user scope, then runs the scan.

### Tenant-wide scan with CSV export (recommended baseline)

```powershell
.\Get-ODBOverQuotaUsers.ps1 -ExportPath "C:\Reports\OneDriveQuota.csv"
```
Uses FastScan by default. Produces a console summary and a CSV with every site and an `OverQuota` column you can filter in Excel.

### Spot-check a specific user

```powershell
.\Get-ODBOverQuotaUsers.ps1 -UserPrincipalName alice@contoso.com
```
Skips tenant enumeration. Useful after a single user's complaint or to verify a known account.

### Spot-check several users with CSV export

```powershell
.\Get-ODBOverQuotaUsers.ps1 `
    -UserPrincipalName alice@contoso.com,bob@contoso.com,carol@contoso.com `
    -ExportPath "C:\Reports\SpotCheck.csv"
```
Targeted mode accepts a comma-separated list. Each UPN is looked up directly — no full-tenant scan.

### Force real-time scan instead of the daily snapshot

```powershell
.\Get-ODBOverQuotaUsers.ps1 -LegacyScan -ExportPath "C:\Reports\Live.csv"
```
Use this when the tenant has anonymized reports turned on, or when you need point-in-time storage numbers (e.g. verifying a quota cleanup within the last few hours).

### Sovereign cloud (GCC High, DoD, 21Vianet)

```powershell
.\Get-ODBOverQuotaUsers.ps1 -Environment USGov   -ExportPath "C:\Reports\GCCH.csv"
.\Get-ODBOverQuotaUsers.ps1 -Environment USGovDoD -ExportPath "C:\Reports\DoD.csv"
.\Get-ODBOverQuotaUsers.ps1 -Environment China    -ExportPath "C:\Reports\Vianet.csv"
```
GCC Moderate uses the commercial endpoint (`-Environment Global`, the default).

### Multi-tenant admin (MSP, CSP, delegated)

```powershell
.\Get-ODBOverQuotaUsers.ps1 -TenantId "contoso.onmicrosoft.com" -ExportPath "C:\Reports\Contoso.csv"
```
`-TenantId` accepts either a GUID or a verified domain. Without it, the script connects to your home tenant.

### Combine parameters freely

```powershell
# Customer tenant in GCC High, exported to a specific file
.\Get-ODBOverQuotaUsers.ps1 `
    -TenantId "agency.onmicrosoft.us" `
    -Environment USGov `
    -ExportPath "C:\Reports\Agency-GCCH.csv"

# Spot-check a user in a specific customer tenant
.\Get-ODBOverQuotaUsers.ps1 `
    -TenantId "contoso.onmicrosoft.com" `
    -UserPrincipalName alice@contoso.com

# Real-time scan of a customer tenant
.\Get-ODBOverQuotaUsers.ps1 `
    -TenantId "contoso.onmicrosoft.com" `
    -LegacyScan `
    -ExportPath "C:\Reports\Contoso-Live.csv"

# First run on a fresh machine — install prereqs and scan in one shot
.\Get-ODBOverQuotaUsers.ps1 `
    -InstallPrerequisites `
    -ExportPath "C:\Reports\FirstRun.csv"
```
---

## CSV output

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

---

## Prerequisites

| Requirement | Notes |
|---|---|
| PowerShell 5.1+ or PowerShell 7+ | Script enforces `#Requires -Version 5.1`. |
| `Microsoft.Graph.Authentication` ≥ 2.0.0 | Auto-installable with `-InstallPrerequisites`. |
| `Microsoft.Graph.Users` ≥ 2.0.0 | Same. |
| Graph delegated scopes | `User.Read.All`, `Directory.Read.All`, `Reports.Read.All`, `Sites.Read.All`. May need Global Admin consent on first run. |
| M365 role | **Global Reader** is sufficient and recommended (least privilege). Reports Reader works for FastScan only. |



