

# Revoke permissions for a given Azure Entra ID application registration

This script demonstrates how to audit and revoke Entra ID app permissions across SharePoint sites. The script automates the process of scanning all tenant sites, generating CSV reports of app permissions, and revoking access while implementing verification steps to ensure successful removal. 

## Summary

# [PnP PowerShell](#tab/pnpps)

```powershell
param (
    [Parameter(Mandatory = $true)]
    [string] $domain,
    
    [Parameter(Mandatory = $true)]
    [string] $app,
    
    [Parameter(Mandatory = $false)]
    [switch] $RevokePermissions
)

# Construct SharePoint URLs
$adminSiteURL = "https://$domain-admin.sharepoint.com"
$TenantURL = "https://$domain.sharepoint.com"

# Generate timestamped filename for the report
$dateTime = "_{0:MM_dd_yy}_{0:HH_mm_ss}" -f (Get-Date)
$invocation = (Get-Variable MyInvocation).Value
$directorypath = Split-Path $invocation.MyCommand.Path
$fileName = "entraid_site_permissions" + $dateTime + ".csv"
$outputPath = Join-Path $directorypath $fileName

# Create output file if it doesn't exist
if (-not (Test-Path $outputPath)) {
    New-Item -ItemType File -Path $outputPath | Out-Null
}

# Connect to SharePoint Admin Center
Connect-PnPOnline -Url $adminSiteURL -Interactive -WarningAction SilentlyContinue

Write-Host "Scanning sites for Entra ID app permissions..." -ForegroundColor Yellow

# Process each site in the tenant
$report = Get-PnPTenantSite -Filter "Url -like '$TenantURL'" | 
    Where-Object { $_.Template -ne 'RedirectSite#0' } | 
    ForEach-Object {
        $siteUrl = $_.Url
        Write-Host "Processing site: $siteUrl" -ForegroundColor Cyan
        
        # Connect to the specific site
        Connect-PnPOnline -Url $siteUrl -Interactive -WarningAction SilentlyContinue
        
        # Get app permissions for the specified app
        Get-PnPAzureADAppSitePermission -AppIdentity $app | ForEach-Object {
            # Create report object
            $permissionData = [PSCustomObject]@{
                PermissionId = $_.Id
                SiteUrl      = $siteUrl
                Roles        = $_.Roles -join ","
                Apps         = $_.Apps -join ","
                DisplayName  = $_.DisplayName
                RevokedDate  = if ($RevokePermissions) { Get-Date -Format "yyyy-MM-dd HH:mm:ss" } else { "Not Revoked" }
            }
             
            # Revoke the permission only if the switch is enabled
            if ($RevokePermissions) {
                try {
                    Write-Host "  Revoking permission ID: $($_.Id)" -ForegroundColor Yellow
                    Revoke-PnPEntraIDAppSitePermission -PermissionId $_.Id -Site $siteUrl -Force
                    Write-Host "  Successfully revoked permission" -ForegroundColor Green
                }
                catch {
                    Write-Host "  Error revoking permission: $($_.Exception.Message)" -ForegroundColor Red
                }
                
                # Verify the permission was revoked
                Start-Sleep -Seconds 2
                $remainingPerms = Get-PnPAzureADAppSitePermission -AppIdentity $app -ErrorAction SilentlyContinue
                if ($remainingPerms | Where-Object { $_.Id -eq $_.Id }) {
                    Write-Host "  WARNING: Permission may still exist. Verify manually!" -ForegroundColor Red
                }
            }
            else {
                Write-Host "  Found permission ID: $($_.Id) (not revoking - report only mode)" -ForegroundColor Cyan
            }
            
            # Return the permission data for the report
            $permissionData
        }
    }

# Export report to CSV
$report | Export-Csv $outputPath -NoTypeInformation -Append

Write-Host "`nReport saved to: $outputPath" -ForegroundColor Green
if ($RevokePermissions) {
    Write-Host "Permissions have been revoked. Please verify that permissions were successfully revoked." -ForegroundColor Yellow
}
else {
    Write-Host "Report-only mode: No permissions were revoked. Use -RevokePermissions switch to revoke." -ForegroundColor Yellow
}
```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]


## Source Credit

Sample idea first appeared on [Revoke Entra ID App Permissions from SharePoint Sites Using PnP PowerShell](https://reshmeeauckloo.com/posts/powershell-sharepoint-revokeentraidpermissions/). 

## Contributors

| Author(s) |
|-----------|
| [Reshmee Auckloo](https://github.com/reshmee011) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-revoke-app-site-permission" aria-hidden="true" />