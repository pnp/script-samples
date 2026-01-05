

# Revoke permissions for a given Azure Entra ID application registration

This script demonstrates how to audit and revoke Entra ID app permissions across SharePoint sites. The script automates the process of scanning all tenant sites, generating CSV reports of app permissions, and revoking access while implementing verification steps to ensure successful removal. 

## Summary

# [CLI for Microsoft 365](#tab/cli-m365-ps)

```powershell
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $true, HelpMessage = "SharePoint admin center URL (e.g., https://contoso-admin.sharepoint.com)")]
    [ValidatePattern('^https://')]
    [string]$TenantAdminUrl,

    [Parameter(Mandatory = $true, HelpMessage = "Display name of the Entra ID application to search for")]
    [string]$AppDisplayName,

    [Parameter(Mandatory = $false, HelpMessage = "Path for CSV export (optional, defaults to current directory)")]
    [string]$OutputPath,

    [Parameter(Mandatory = $false, HelpMessage = "Switch to revoke permissions (requires confirmation unless -Force is used)")]
    [switch]$RevokePermissions
)

begin {
    # Start transcript logging
    $dateTime = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $transcriptPath = "RevokeAppPermissions_$dateTime.log"
    Start-Transcript -Path $transcriptPath | Out-Null
    Write-Host "Transcript started: $transcriptPath" -ForegroundColor Cyan

    # Set OutputPath if not specified
    if ([string]::IsNullOrEmpty($OutputPath)) {
        $OutputPath = Join-Path -Path (Get-Location) -ChildPath "EntraIDAppPermissions_$dateTime.csv"
    }
    else {
        # Validate parent folder exists when user specifies path
        $parentFolder = Split-Path -Path $OutputPath -Parent
        if (-not (Test-Path -Path $parentFolder)) {
            Stop-Transcript
            throw "Output path parent folder does not exist: $parentFolder"
        }
    }

    Write-Host "Output CSV will be saved to: $OutputPath" -ForegroundColor Cyan

    # Ensure user is signed in to CLI for Microsoft 365
    Write-Host "Ensuring CLI for Microsoft 365 authentication..." -ForegroundColor Yellow
    m365 login --ensure
    if ($LASTEXITCODE -ne 0) {
        Stop-Transcript
        throw "Failed to authenticate with CLI for Microsoft 365. Please run 'm365 login' manually."
    }
    Write-Host "Successfully authenticated" -ForegroundColor Green

    # Initialize script-level variables
    $script:ReportCollection = [System.Collections.Generic.List[PSCustomObject]]::new()
    $script:TotalSites = 0
    $script:PermissionsFound = 0
    $script:PermissionsRevoked = 0
    $script:Failures = 0
}

process {
    # Get all SharePoint sites (excluding redirect sites)
    Write-Host "\nRetrieving all SharePoint sites (excluding redirect sites)..." -ForegroundColor Yellow
    $sitesJson = m365 spo site list --filter "Template ne 'RedirectSite#0'" --output json 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Failed to retrieve sites: $sitesJson"
        return
    }

    $sites = @($sitesJson | ConvertFrom-Json)
    $script:TotalSites = $sites.Count
    Write-Host "Found $($script:TotalSites) sites to scan" -ForegroundColor Green

    if ($script:TotalSites -eq 0) {
        Write-Host "No sites found to process" -ForegroundColor Yellow
        return
    }

    # Process each site
    $siteCounter = 0
    foreach ($site in $sites) {
        $siteCounter++
        Write-Progress -Activity "Scanning sites for app permissions" -Status "Processing site $siteCounter of $($script:TotalSites): $($site.Url)" -PercentComplete (($siteCounter / $script:TotalSites) * 100)

        Write-Verbose "Processing site: $($site.Url)"

        # Get app permissions for the specified app
        try {
            $permissionsJson = m365 spo site apppermission list --siteUrl $site.Url --appDisplayName $AppDisplayName --output json 2>&1
            if ($LASTEXITCODE -ne 0) {
                Write-Verbose "No permissions found or error retrieving permissions for site: $($site.Url)"
                continue
            }

            $permissions = @($permissionsJson | ConvertFrom-Json)
            if ($permissions.Count -eq 0) {
                Write-Verbose "No permissions found for app '$AppDisplayName' on site: $($site.Url)"
                continue
            }

            # Process each permission
            foreach ($permission in $permissions) {
                $script:PermissionsFound++

                $reportItem = [PSCustomObject]@{
                    PermissionId    = $permission.permissionId
                    SiteUrl         = $site.Url
                    SiteTitle       = $site.Title
                    AppDisplayName  = $permission.appDisplayName
                    AppId           = $permission.appId
                    Roles           = ($permission.roles -join '|')
                    RevokedDate     = ""
                    Status          = "Not Revoked"
                }

                # Revoke permission if switch is enabled
                if ($RevokePermissions) {
                    if ($PSCmdlet.ShouldProcess($site.Url, "Revoke permission for app '$AppDisplayName' (ID: $($permission.permissionId))")) {
                        try {
                            Write-Host "  Revoking permission ID: $($permission.permissionId) on $($site.Url)" -ForegroundColor Yellow
                            m365 spo site apppermission remove --siteUrl $site.Url --id $permission.permissionId --force 2>&1 | Out-Null
                            if ($LASTEXITCODE -eq 0) {
                                $script:PermissionsRevoked++
                                $reportItem.RevokedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                                $reportItem.Status = "Success"
                                Write-Host "  Successfully revoked permission" -ForegroundColor Green
                            }
                            else {
                                $script:Failures++
                                $reportItem.Status = "Failed"
                                Write-Warning "  Failed to revoke permission ID: $($permission.permissionId)"
                            }
                        }
                        catch {
                            $script:Failures++
                            $reportItem.Status = "Failed"
                            Write-Warning "  Error revoking permission: $($_.Exception.Message)"
                        }
                    }
                    else {
                        $reportItem.Status = "Skipped (WhatIf)"
                    }
                }
                else {
                    Write-Host "  Found permission ID: $($permission.permissionId) (report only mode)" -ForegroundColor Cyan
                }

                $script:ReportCollection.Add($reportItem)
            }
        }
        catch {
            Write-Warning "Error processing site $($site.Url): $($_.Exception.Message)"
            continue
        }
    }

    Write-Progress -Activity "Scanning sites for app permissions" -Completed
}

end {
    # Export CSV report
    if ($script:ReportCollection.Count -gt 0) {
        Write-Host "\nExporting report to CSV..." -ForegroundColor Yellow
        $script:ReportCollection | Sort-Object SiteUrl | Export-Csv -Path $OutputPath -NoTypeInformation -Force
        Write-Host "Report exported to: $OutputPath" -ForegroundColor Green
    }
    else {
        Write-Host "\nNo app permissions found for '$AppDisplayName'" -ForegroundColor Yellow
    }

    # Display summary
    Write-Host "\n" -NoNewline
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "         SUMMARY" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Total sites scanned       : " -NoNewline
    Write-Host $script:TotalSites -ForegroundColor White
    Write-Host "Permissions found         : " -NoNewline
    Write-Host $script:PermissionsFound -ForegroundColor White
    
    if ($RevokePermissions) {
        Write-Host "Permissions revoked       : " -NoNewline
        Write-Host $script:PermissionsRevoked -ForegroundColor Green
        Write-Host "Failures                  : " -NoNewline
        if ($script:Failures -gt 0) {
            Write-Host $script:Failures -ForegroundColor Red
        }
        else {
            Write-Host $script:Failures -ForegroundColor Green
        }
    }
    Write-Host "========================================" -ForegroundColor Cyan

    if ($RevokePermissions -and $script:PermissionsRevoked -gt 0) {
        Write-Host "\nPermissions have been revoked. Please verify in your Entra ID admin center." -ForegroundColor Yellow
    }

    # Stop transcript
    Write-Host "\nTranscript saved to: $transcriptPath" -ForegroundColor Cyan
    Stop-Transcript | Out-Null
}

# Report only mode - scan all sites for app permissions
# ./Revoke-AppSitePermissions.ps1 -TenantAdminUrl "https://contoso-admin.sharepoint.com" -AppDisplayName "MyApp"

# Revoke permissions with confirmation prompt
# ./Revoke-AppSitePermissions.ps1 -TenantAdminUrl "https://contoso-admin.sharepoint.com" -AppDisplayName "MyApp" -RevokePermissions

# Revoke permissions without confirmation (use with caution)
# ./Revoke-AppSitePermissions.ps1 -TenantAdminUrl "https://contoso-admin.sharepoint.com" -AppDisplayName "MyApp" -RevokePermissions -Force

# Preview what would be revoked (WhatIf mode)
# ./Revoke-AppSitePermissions.ps1 -TenantAdminUrl "https://contoso-admin.sharepoint.com" -AppDisplayName "MyApp" -RevokePermissions -WhatIf
```

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
| [Adam Wójcik](https://github.com/Adam-it) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-revoke-app-site-permission" aria-hidden="true" />
