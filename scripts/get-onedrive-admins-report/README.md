

# M365 Get OneDrive Admins Report

## Summary
Imagine your organization recently had an internal audit, or you’re reviewing governance after a team restructure. You need to know which administrators have access to employee OneDrive accounts to ensure no unnecessary permissions exist. Get-OneDrive-Admins helps by exporting all OneDrive sites in the tenant along with their Site Collection Administrators. With this report, you can quickly identify administrators who may have elevated access they don’t need — for example, ex-managers, IT staff who no longer require direct access, or temporary admins — and take action to remove unnecessary permissions. The output is CSV-based, making it easy to filter, sort, and review in Excel.


## Parameters / Configuration

Customize the following values:
- **AdminURL** – SharePoint Admin Center URL
- **ClientId** – Azure AD App Client ID
- **Thumbprint** – Certificate thumbprint
- **Tenant** – Tenant domain (e.g., contoso.onmicrosoft.com)
- **OutputFile** – Path to export the CSV

## Output Details

The CSV output file will contain the following values:
- **SiteURL** – URL of the OneDrive site
- **SiteName** – Name of the OneDrive site
- **SiteCollectionAdmin** – Admin email address
- **SiteCollectionAdminName** – Admin display name


## Real-World Scenarios / Use Cases
- Auditing OneDrive admins after an internal restructure or staff departures
- Ensuring compliance and least-privilege access policies
- Preparing for internal or external security audits


## Notes / Tips
- For large tenants, consider running in PowerShell 7 for better performance
- CSV can be filtered in Excel to quickly identify unnecessary or excessive access
- The script is **read-only**; it does not modify permissions

# [PnP PowerShell](#tab/pnpps)

```powershell

# Parameters
$AdminURL = "https://contoso-admin.sharepoint.com"
$ClientId = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
$Thumbprint = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
$Tenant = "contoso.onmicrosoft.com"
$OutputFile = "C:\Reports\OneDriveAdmins.csv"

# Connect to SharePoint Admin Center
Connect-PnPOnline -Url $AdminURL -ClientId $ClientId -Thumbprint $Thumbprint -Tenant $Tenant -ErrorAction Stop

# Get all OneDrive (MySite) sites
$MySites = Get-PnPTenantSite -IncludeOneDriveSites -Filter "Url -like '-my.sharepoint.com/personal/'"

# Initialize results and error logs
$AllAdmins = @()
$ErrorLog = @()

# Process each MySite
foreach ($MySite in $MySites) {
    try {
        Write-Host "Processing: $($MySite.Title)" -ForegroundColor Green

        # Connect to the MySite
        Connect-PnPOnline -Url $MySite.Url -ClientId $ClientId -Thumbprint $Thumbprint -Tenant $Tenant -ErrorAction Stop

        # Get site collection admins
        $Admins = Get-PnPSiteCollectionAdmin -ErrorAction Stop

        foreach ($admin in $Admins) {
            $AllAdmins += [PSCustomObject]@{
                SiteURL                 = $MySite.Url
                SiteName                = $MySite.Title
                SiteCollectionAdmin     = $admin.Email
                SiteCollectionAdminName = $admin.Title
            }
        }
    }
    catch {
        Write-Warning "Error processing site $($MySite.Title): $_"
        $ErrorLog += [PSCustomObject]@{
            SiteURL = $MySite.Url
            SiteName = $MySite.Title
            ErrorMessage = $_.Exception.Message
        }
    }
}

# Export results to CSV
$AllAdmins | Export-Csv -Path $OutputFile -NoTypeInformation -Encoding UTF8

# Export errors if any
if ($ErrorLog.Count -gt 0) {
    $ErrorFile = "C:\Reports\Errors-OneDriveAdmins.csv"
    $ErrorLog | Export-Csv -Path $ErrorFile -NoTypeInformation -Encoding UTF8
    Write-Warning "Errors encountered. See $ErrorFile for details."
}

Write-Host "Script completed successfully!" -ForegroundColor Green


```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***


## Contributors

| Author(s) |
|-----------|
| [Josiah Opiyo](https://github.com/ojopiyo) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/onedrive-export-admins" aria-hidden="true" />
