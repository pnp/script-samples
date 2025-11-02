
# Export Microsoft 365 Active Users to CSV Using Microsoft Graph (Cross-Platform)

## Summary

This PowerShell script exports Microsoft 365 users — including properties such as Display Name, UPN, Department, Job Title, Account Status, and Manager Email — into a CSV file using the Microsoft Graph API.

It automatically ensures that the Microsoft.Graph module is installed, connects securely using interactive or device-code authentication, and retrieves enabled users by default (with optional switches for guests, disabled accounts, and manager lookups).

The script is fully optimized for macOS and Linux, performing a safe write-access check on the Graph cache directory (~/.mg) to prevent permission issues caused by previous sudo runs.
If you are running on Windows, that permission check can be safely skipped or removed since Windows manages Graph credentials differently.



# [Microsoft Graph PowerShell](#tab/graphps)

```powershell

<#
.SYNOPSIS
Export active Microsoft 365 users to CSV using Microsoft Graph.

.DESCRIPTION
Wraps the script in an advanced function that ensures the Microsoft.Graph module is available,
connects using device code (with a macOS-friendly context scope), queries enabled users by default,
optionally looks up manager email, and writes a CSV. Includes a fallback to interactive login if
device code fails on macOS environments.

.EXAMPLE
Export-M365ActiveUsers
Exports enabled Member users to Desktop/M365_ActiveUsers.csv using device-code authentication.

.EXAMPLE
Export-M365ActiveUsers -IncludeGuests -Path "/tmp/users.csv"
Includes Guests in addition to Members and writes to /tmp/users.csv
#>
function Export-M365ActiveUsers {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter()]
        [string]$Path =  'M365_ActiveUsers.csv',

        [Parameter()]
        [string]$TenantId = $(Read-Host "Enter your Azure AD Tenant ID"),

        [Parameter()]
        [string[]]$Scopes = @('User.Read.All','Directory.Read.All'),

        [Parameter()]
        [switch]$IncludeGuests,

        [Parameter()]
        [switch]$IncludeDisabled,

        [Parameter()]
        [switch]$IncludeManager = $true,

        [Parameter()]
        [switch]$DeviceCode = $true,

        [Parameter()]
        [switch]$Force
    )

    # 1) Ensure Graph module exists
    $moduleName = 'Microsoft.Graph'
    if (-not (Get-Module -ListAvailable -Name $moduleName)) {
        Write-Host "Microsoft Graph module not found. Installing to CurrentUser scope..." -ForegroundColor Yellow
        try {
            Install-Module -Name $moduleName -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop | Out-Null
        } catch {
            throw "Failed to install module '$moduleName': $($_.Exception.Message)"
        }
    }
    Import-Module -Name $moduleName -ErrorAction Stop

    # Preflight check: warn if ~/.mg is owned by root (from a previous sudo run)
   $platform = [System.Environment]::OSVersion.Platform
if ($platform -eq 'Unix' -or $platform -eq 'MacOSX') {
    $mgDir = Join-Path $HOME '.mg'
    if (Test-Path $mgDir) {
        try {
            $testFile = Join-Path $mgDir "test_write_$(Get-Random).tmp"
            [void][System.IO.File]::WriteAllText($testFile, 'test')
            Remove-Item $testFile -Force -ErrorAction SilentlyContinue
        } catch {
            Write-Warning "Cannot write to $mgDir — likely owned by root from a previous sudo run."
            Write-Host "Fix with: sudo chown -R `$USER:staff ~/.mg && sudo chmod 700 ~/.mg" -ForegroundColor Yellow
            Write-Host "Or remove it: sudo rm -rf ~/.mg`n" -ForegroundColor Yellow
            throw "Access denied to Microsoft Graph cache directory. See instructions above."
        }
    }
} else {
    Write-Verbose "Windows detected — skipping ~/.mg permission check."
}

    # 2) Connect to Graph
    Disconnect-MgGraph -ErrorAction SilentlyContinue | Out-Null

    Write-Host "`n🔐 Connecting to Microsoft Graph..." -ForegroundColor Cyan
    Write-Host "A browser window will open for authentication.`n" -ForegroundColor Yellow

    try {
        # Use interactive browser login - more reliable on macOS than device code
        # ContextScope Process keeps tokens in memory only (not persisted to disk)
        Connect-MgGraph -Scopes $Scopes -TenantId $TenantId -ContextScope Process -ErrorAction Stop
    } catch {
        $msg = $_.Exception.Message
        Write-Error "Failed to connect to Microsoft Graph: $msg"
        Write-Host "`n💡 Troubleshooting:" -ForegroundColor Yellow
        Write-Host "   1. Make sure you complete the browser sign-in" -ForegroundColor Yellow
        Write-Host "   2. If the browser doesn't open, check for popup blockers" -ForegroundColor Yellow
        Write-Host "   3. Close all browser windows and try again`n" -ForegroundColor Yellow
        throw
    }

    $context = Get-MgContext
    if (-not $context) { throw "Authentication context not available after login." }
    Write-Host "✅ Connected as: $($context.Account)" -ForegroundColor Green

    # 3) Query users
    $filters = @()
    if (-not $IncludeDisabled) { $filters += "accountEnabled eq true" }
    if (-not $IncludeGuests) { $filters += "userType eq 'Member'" }
    $filterStr = $filters -join ' and '

    $props = @('Id','DisplayName','UserPrincipalName','Department','JobTitle','AccountEnabled')
    if ([string]::IsNullOrWhiteSpace($filterStr)) {
        $users = Get-MgUser -All -Property $props
    } else {
        $users = Get-MgUser -All -Filter $filterStr -Property $props
    }

    # 4) Project output
    $export = @()
    foreach ($u in $users) {
        $mgr = $null
        if ($IncludeManager) {
            try {
                $mgrObj = Get-MgUserManager -UserId $u.Id -ErrorAction SilentlyContinue
                if ($mgrObj) { $mgr = $mgrObj.AdditionalProperties.mail }
            } catch {}
        }
        $export += [PSCustomObject]@{
            EmployeeId     = $u.Id
            EmployeeName   = $u.DisplayName
            Email          = $u.UserPrincipalName
            Department     = $u.Department
            JobTitle       = $u.JobTitle
            ManagerEmail   = $mgr
            AccountEnabled = $u.AccountEnabled
        }
    }

    # 5) Export
    if ($PSCmdlet.ShouldProcess($Path, 'Export users to CSV')) {
        $export | Export-Csv -Path $Path -NoTypeInformation -Encoding UTF8 -Force:$Force
        Write-Host "📄 Export complete. File saved to $Path" -ForegroundColor Cyan
    }

    return $export
}

# Run with defaults if executed directly
Export-M365ActiveUsers | Out-Null
```

[!INCLUDE [More about Microsoft Graph PowerShell SDK](../../docfx/includes/MORE-GRAPHSDK.md)]
***

## Contributors

| Author(s) |
|-----------|
| Divya Akula|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]

<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/graph-get-teams-tabs-export-to-csv" aria-hidden="true" />
