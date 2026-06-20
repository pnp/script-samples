# Group-Connected SharePoint Sites and Microsoft Teams Relationship Report

## Professional Summary

This PowerShell script generates a comprehensive inventory of Microsoft 365 Group-connected SharePoint Online sites across the tenant. It identifies the associated Microsoft 365 Group, determines whether the group is connected to Microsoft Teams, retrieves group ownership information, and exports the results to a CSV report for analysis and governance purposes.

The report provides visibility into the relationship between SharePoint Online, Microsoft 365 Groups, and Microsoft Teams, enabling administrators to better understand collaboration workloads across the tenant.

## Why it matters

As Microsoft 365 environments mature, organisations often accumulate hundreds or thousands of Microsoft 365 Groups, SharePoint sites, and Teams workspaces.

Without a central inventory, administrators can face challenges such as:

- Identifying orphaned collaboration workspaces with no owners.
- Determining which SharePoint sites are actively associated with Teams.
- Assessing migration readiness during tenant consolidations or mergers.
- Reviewing governance compliance for Microsoft 365 Groups.
- Understanding the relationship between Teams, Groups, and SharePoint resources.

This report provides a single source of truth for Group-connected SharePoint sites and their associated ownership and Teams status.

## Benefits

- Provides a complete inventory of Microsoft 365 Group-connected SharePoint sites.
- Identifies sites with no assigned owners.
- Highlights which Groups are connected to Microsoft Teams.
- Supports governance and lifecycle management initiatives.
- Assists with migration and tenant consolidation projects.
- Simplifies audit and compliance reviews.
- Enables proactive management of collaboration workloads.
- Produces a timestamped CSV report suitable for further analysis and reporting.

## Prerequisites

- PowerShell 7.x or Windows PowerShell 5.1
- PnP PowerShell module
- SharePoint Administrator permissions
- Microsoft Entra ID App Registration configured for certificate-based authentication
- Appropriate SharePoint Online application permissions granted and consented

## Usage

1. Configure tenant-specific values:
    - Admin Center URL
    - Client ID
    - Certificate Thumbprint
    - Tenant Name
    - Output Folder
2. Execute the script using a privileged administrative account context.
3. Review the generated CSV reports.

# [PnP PowerShell](#tab/pnpps)

```powershell


# ==========================================
# Group-Connected SharePoint Sites Report
# ==========================================

# ---------- Configuration ----------
$AdminCenterUrl =  "https://contoso-admin.sharepoint.com"
$ClientID = "xxxxxxxxxxxxxxxxxxxxxxxxx"
$ThumbPrint = "xxxxxxxxxxxxxxxxxxxxxxxxxx"  
$Tenant = "contoso.onmicrosoft.com" 

$OutputFolder   = "C:\Temp\GroupConnectedSites"

# ---------- Initialization ----------
$TimeStamp  = Get-Date -Format "yyyyMMdd_HHmmss"
$OutputFile = Join-Path $OutputFolder "GroupConnectedSites_$TimeStamp.csv"

if (-not (Test-Path $OutputFolder)) {
    New-Item -Path $OutputFolder -ItemType Directory -Force | Out-Null
}

$StartTime = Get-Date

Write-Host "===== GROUP CONNECTED SITES REPORT =====" -ForegroundColor Cyan

# ---------- Connect ----------
Connect-PnPOnline `
    -Url $AdminCenterUrl `
    -ClientId $ClientID `
    -Thumbprint $ThumbPrint `
    -Tenant $Tenant

# ---------- Processing ----------
$Results = @()

try {

    Write-Host "Retrieving tenant sites..." -ForegroundColor Yellow

    $Sites = Get-PnPTenantSite -Detailed |
        Where-Object { $_.GroupId -ne [Guid]::Empty }

    $TotalSites = $Sites.Count
    $Index = 0

    foreach ($Site in $Sites) {

        $Index++

        Write-Progress `
            -Activity "Processing Group-Connected Sites" `
            -Status "[$Index/$TotalSites] $($Site.Url)" `
            -PercentComplete (($Index / $TotalSites) * 100)

        try {

            $GroupId = $Site.GroupId
            $Owners = @()
            $TeamConnected = $false

            # ---------- Get Owners ----------
            try {
                $Owners = Get-PnPMicrosoft365GroupOwners -Identity $GroupId |
                    Select-Object -ExpandProperty UserPrincipalName
            }
            catch {
                Write-Warning "Failed to retrieve owners for $GroupId"
            }

            # ---------- Check Teams Connection ----------
            try {
                $Team = Get-PnPTeamsTeam -Identity $GroupId -ErrorAction Stop
                if ($Team) { $TeamConnected = $true }
            }
            catch {
                $TeamConnected = $false
            }

            # ---------- Add Result ----------
            $Results += [PSCustomObject]@{
                SiteUrl       = $Site.Url
                SiteTitle     = $Site.Title
                GroupId       = $GroupId
                TeamConnected = $TeamConnected
                OwnerCount    = $Owners.Count
                Owners        = ($Owners -join "; ")
                CreatedDate   = $Site.CreationDate
                StorageMB     = $Site.StorageUsageCurrent
                Template      = $Site.Template
            }
        }
        catch {
            Write-Warning "Failed processing site: $($Site.Url)"
        }
    }

    # ---------- Export ----------
    $Results |
        Sort-Object SiteTitle |
        Export-Csv -Path $OutputFile -NoTypeInformation -Encoding UTF8

    # ---------- Summary ----------
    $Summary = [PSCustomObject]@{
        TotalSites        = $Results.Count
        TeamsConnected    = ($Results | Where-Object TeamConnected).Count
        NonTeamsSites     = ($Results | Where-Object { -not $_.TeamConnected }).Count
        SitesNoOwners     = ($Results | Where-Object { $_.OwnerCount -eq 0 }).Count
        GeneratedUtc      = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        RuntimeMinutes    = [math]::Round(((Get-Date) - $StartTime).TotalMinutes, 2)
    }

    # ---------- Output ----------
    Write-Host ""
    Write-Host "===== SUMMARY =====" -ForegroundColor Cyan
    $Summary | Format-List

    Write-Host ""
    Write-Host "Report exported:" -ForegroundColor Green
    Write-Host $OutputFile -ForegroundColor Green

}
finally {
    Disconnect-PnPOnline
    Write-Host ""
    Write-Host "Disconnected from SharePoint" -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "===== COMPLETE ====="


```

## Output

### Detailed Report

The script exports a timestamped CSV file containing the following information:

Column|Description
-------|----
SiteUrl|SharePoint site URL
SiteTitle|SharePoint site title
GroupId|Associated Microsoft 365 Group ID
TeamConnected|Indicates whether a Team exists
OwnerCount|Number of Group owners
Owners|Group owner UPNs
CreatedDate|Site creation date
StorageMB|Current storage consumption
Template|SharePoint site template

## Notes

- Only Microsoft 365 Group-connected SharePoint sites are included.
- Standalone SharePoint sites are excluded from the report.
- Teams-connected sites are identified using Microsoft Graph through PnP PowerShell.
- Sites without owners should be reviewed as part of ongoing governance and lifecycle management processes.
- The script uses certificate-based authentication and is suitable for unattended execution via Azure Automation, Task Scheduler, or other automation platforms.

## Contributors

 Author(s) |
-----------|
 [Josiah Opiyo](https://github.com/ojopiyo) |

*Built with a focus on automation, governance, least privilege, and clean Microsoft 365 tenants-helping M365 admins gain visibility and reduce operational risk.*

## Version history

Version|Date|Comments
-------|----|--------
1.0|June 17, 2026|Initial release

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
