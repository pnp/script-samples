# Delete inactive Guest User

## Summary

This PowerShell script audits Microsoft Entra ID guest accounts for inactivity using the Microsoft Graph PowerShell SDK.

The script:

- Retrieves all users with userType set to Guest.
- Evaluates inactivity using LastSuccessfulSignInDateTime.
- Optionally identifies guests who have never successfully signed in using CreatedDateTime.
- Applies configurable user and domain exclusions.
- Generates a timestamped CSV audit report.
- Maintains an execution log for operational traceability.
- Runs in REPORT ONLY mode by default.
- Supports optional deletion of identified inactive guest accounts following administrative review and approval.
- Records deletion attempts, successful deletions, and errors in the final audit report.
The default inactivity threshold is 90 days, but this can be changed through the configuration section.

## Why It Matters

Guest accounts can accumulate in Microsoft 365 environments as external collaborators, suppliers, consultants, partners, and temporary project users leave the organisation.

Without periodic review, inactive guest accounts can:

- Increase the external identity attack surface.
- Retain access that is no longer required.
- Complicate access governance and entitlement reviews.
- Increase the number of identities administrators must maintain.
- Create unnecessary audit and compliance exposure.
This script provides a repeatable PROD process for identifying potentially stale guest identities and producing an auditable dataset for review before remediation.

A typical operational workflow is:

1. Run the script in REPORT ONLY mode.
2. Review the generated CSV report.
3. Validate exclusions and business ownership.
4. Obtain the appropriate PROD/change approval.
5. Enable deletion if remediation has been authorised.
6. Retain the generated reports and execution logs according to organisational retention requirements.


[!INCLUDE [Delete Warning](../../docfx/includes/DELETE-WARN.md)]

## Requirements

### PowerShell Module

The script requires:

> #requires -Modules Microsoft.Graph.Users

Install the Microsoft Graph PowerShell SDK module if required:

> Install-Module Microsoft.Graph.Users -Scope CurrentUser

### Microsoft Graph Permissions

For audit/reporting:

- **User.Read.All**
- **AuditLog.Read.All**
Deletion requires additional Microsoft Graph permissions appropriate to the organisation's identity governance and delegated/application access model.

The executing identity must also be authorised to perform the requested operations.

## Configuration

The primary configuration is controlled through `$Config`:

| Setting | Default | Purpose |
|---|---|---|
| `InactiveDays` | `90` | Number of days before a guest is considered inactive |
| `IncludeNeverUsedGuests` | `$true` | Includes guests who have never successfully signed in |
| `ExecuteDeletion` | `$false` | Controls whether inactive guests are deleted |
| `ReportPath` | `C:\Temp\GuestAccountAudit` | CSV report directory |
| `LogPath` | `C:\Temp\GuestAccountAudit\GuestAccountAudit.log` | Execution log location |
| `ExcludedUserPrincipalNames` | `Empty` | Specific guest UPNs excluded from processing |
| `ExcludedDomains` | `Empty` | Guest domains excluded from processing |

# [PnP PowerShell V2](#tab/pnpps2)

```powershell
#requires -Modules Microsoft.Graph.Users

<#
.SYNOPSIS
    Identifies inactive Microsoft Entra ID guest accounts and optionally deletes them.

.DESCRIPTION
    This script:
      - Retrieves all guest accounts
      - Determines inactivity using lastSuccessfulSignInDateTime
      - Handles guests who have never successfully signed in
      - Produces an audit CSV report
      - Runs in REPORT-ONLY mode by default
      - Supports exclusions
      - Includes error handling and execution logging
      - Supports optional deletion after review

    IMPORTANT:
      Deletion is disabled by default.
      Set $Config.ExecuteDeletion = $true only after appropriate PROD approval.

.NOTES
    Recommended permissions:
      - User.Read.All
      - AuditLog.Read.All

    Deletion additionally requires appropriate write/delete permissions.
#>

# ============================================================
# CONFIGURATION
# ============================================================

$Config = @{
    # Number of days after which a guest is considered inactive
    InactiveDays = 90

    # If a guest has never successfully signed in,
    # use CreatedDateTime to determine inactivity
    IncludeNeverUsedGuests = $true

    # Safety control:
    # FALSE = report only
    # TRUE  = perform deletion
    ExecuteDeletion = $false

    # Output locations
    ReportPath = "C:\Temp\GuestAccountAudit"
    LogPath    = "C:\Temp\GuestAccountAudit\GuestAccountAudit.log"

    # Optional exclusions
    ExcludedUserPrincipalNames = @(
        # "important.external.user@external.com"
    )

    # Optional excluded domains
    ExcludedDomains = @(
        # "trustedpartner.com"
    )
}

# ============================================================
# INITIALISE
# ============================================================

$ErrorActionPreference = "Stop"

$ExecutionStart = Get-Date
$CalcDate = $ExecutionStart.AddDays(-$Config.InactiveDays)

# Ensure output directory exists
if (-not (Test-Path -Path $Config.ReportPath)) {
    New-Item -Path $Config.ReportPath -ItemType Directory -Force | Out-Null
}

# ============================================================
# LOGGING FUNCTION
# ============================================================

function Write-Log {
    param (
        [Parameter(Mandatory)]
        [string]$Message,

        [ValidateSet("INFO", "WARNING", "ERROR")]
        [string]$Level = "INFO"
    )

    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "$Timestamp [$Level] $Message"

    Write-Host $LogEntry

    Add-Content -Path $Config.LogPath -Value $LogEntry
}

# ============================================================
# START
# ============================================================

Write-Log "============================================================"
Write-Log "Guest account inactivity audit started"
Write-Log "Execution mode: $(if ($Config.ExecuteDeletion) { 'DELETE' } else { 'REPORT ONLY' })"
Write-Log "Inactivity threshold: $($Config.InactiveDays) days"
Write-Log "Cut-off date: $($CalcDate.ToString('yyyy-MM-dd HH:mm:ss'))"
Write-Log "============================================================"

# ============================================================
# CONNECT TO MICROSOFT GRAPH
# ============================================================

try {

    Write-Log "Connecting to Microsoft Graph..."

    Connect-MgGraph `
        -Scopes "User.Read.All", "AuditLog.Read.All" `
        -NoWelcome

    Write-Log "Successfully connected to Microsoft Graph."

}
catch {

    Write-Log "Failed to connect to Microsoft Graph: $($_.Exception.Message)" "ERROR"
    throw
}

# ============================================================
# RETRIEVE GUEST USERS
# ============================================================

try {

    Write-Log "Retrieving guest accounts..."

    $GuestUsers = Get-MgUser `
        -Filter "userType eq 'Guest'" `
        -All `
        -Property Id,
                   DisplayName,
                   Mail,
                   UserPrincipalName,
                   UserType,
                   CreatedDateTime,
                   AccountEnabled,
                   SignInActivity

    Write-Log "Guest accounts retrieved: $($GuestUsers.Count)"

}
catch {

    Write-Log "Failed to retrieve guest accounts: $($_.Exception.Message)" "ERROR"

    Disconnect-MgGraph | Out-Null
    throw
}

# ============================================================
# IDENTIFY INACTIVE USERS
# ============================================================

$InactiveUsers = [System.Collections.Generic.List[object]]::new()

$ExcludedUsers = 0
$ActiveUsers = 0
$NeverUsedUsers = 0

foreach ($User in $GuestUsers) {

    $UPN = $User.UserPrincipalName
    $Domain = if ($UPN -and $UPN.Contains("@")) {
        $UPN.Split("@")[1].ToLower()
    }
    else {
        ""
    }

    # --------------------------------------------------------
    # EXCLUSIONS
    # --------------------------------------------------------

    if ($Config.ExcludedUserPrincipalNames -contains $UPN) {

        $ExcludedUsers++

        Write-Log "Excluded user: $UPN"

        continue
    }

    if ($Domain -and ($Config.ExcludedDomains -contains $Domain)) {

        $ExcludedUsers++

        Write-Log "Excluded domain user: $UPN"

        continue
    }

    # --------------------------------------------------------
    # DETERMINE LAST SUCCESSFUL ACTIVITY
    # --------------------------------------------------------

    $LastSuccessfulSignIn = $null

    if ($User.SignInActivity) {

        $LastSuccessfulSignIn =
            $User.SignInActivity.LastSuccessfulSignInDateTime
    }

    $ActivityDate = $null
    $ActivitySource = $null
    $IsInactive = $false

    # --------------------------------------------------------
    # USER HAS SUCCESSFUL SIGN-IN HISTORY
    # --------------------------------------------------------

    if ($LastSuccessfulSignIn) {

        $ActivityDate = [DateTime]$LastSuccessfulSignIn
        $ActivitySource = "LastSuccessfulSignInDateTime"

        if ($ActivityDate -lt $CalcDate) {

            $IsInactive = $true
        }
        else {

            $ActiveUsers++
        }
    }

    # --------------------------------------------------------
    # USER HAS NEVER SUCCESSFULLY SIGNED IN
    # --------------------------------------------------------

    elseif ($Config.IncludeNeverUsedGuests) {

        if ($User.CreatedDateTime) {

            $ActivityDate = [DateTime]$User.CreatedDateTime
            $ActivitySource = "CreatedDateTime - Never Successfully Signed In"

            if ($ActivityDate -lt $CalcDate) {

                $IsInactive = $true
                $NeverUsedUsers++
            }
        }
    }

    # --------------------------------------------------------
    # ADD INACTIVE USER TO REPORT
    # --------------------------------------------------------

    if ($IsInactive) {

        $DaysInactive = [math]::Floor(
            ($ExecutionStart - $ActivityDate).TotalDays
        )

        $InactiveUsers.Add(
            [PSCustomObject]@{
                Id                         = $User.Id
                DisplayName                = $User.DisplayName
                UserPrincipalName          = $User.UserPrincipalName
                Mail                       = $User.Mail
                AccountEnabled             = $User.AccountEnabled
                CreatedDateTime            = $User.CreatedDateTime
                LastSuccessfulSignIn      = $LastSuccessfulSignIn
                ActivityDateUsed           = $ActivityDate
                ActivitySource             = $ActivitySource
                DaysInactive               = $DaysInactive
                InactivityThresholdDays   = $Config.InactiveDays
                RecommendedAction          = "Review"
                DeletionAttempted          = $false
                DeletionSuccessful         = $false
                Error                      = $null
            }
        )
    }
}

# ============================================================
# SUMMARY
# ============================================================

Write-Log "Guest accounts assessed: $($GuestUsers.Count)"
Write-Log "Active accounts: $ActiveUsers"
Write-Log "Excluded accounts: $ExcludedUsers"
Write-Log "Never-used inactive accounts: $NeverUsedUsers"
Write-Log "Inactive accounts identified: $($InactiveUsers.Count)"

# ============================================================
# EXPORT REPORT
# ============================================================

$ReportTimestamp = Get-Date -Format "yyyyMMdd_HHmmss"

$ReportPath = Join-Path `
    $Config.ReportPath `
    "GuestAccountAudit_$ReportTimestamp.csv"

try {

    if ($InactiveUsers.Count -gt 0) {

        $InactiveUsers |
            Export-Csv `
                -Path $ReportPath `
                -NoTypeInformation `
                -Encoding UTF8

        Write-Log "Audit report created: $ReportPath"
    }
    else {

        Write-Log "No inactive guest accounts identified."

        # Still create a report so that every execution
        # has an auditable output.
        $InactiveUsers |
            Export-Csv `
                -Path $ReportPath `
                -NoTypeInformation `
                -Encoding UTF8

        Write-Log "Empty audit report created: $ReportPath"
    }

}
catch {

    Write-Log "Failed to create audit report: $($_.Exception.Message)" "ERROR"
}

# ============================================================
# DELETE USERS
# ============================================================

if ($Config.ExecuteDeletion -and $InactiveUsers.Count -gt 0) {

    Write-Log "============================================================"
    Write-Log "DELETION MODE ENABLED"
    Write-Log "Inactive users scheduled for deletion: $($InactiveUsers.Count)"
    Write-Log "============================================================"

    foreach ($InactiveUser in $InactiveUsers) {

        try {

            Write-Log "Attempting deletion: $($InactiveUser.UserPrincipalName)"

            $InactiveUser.DeletionAttempted = $true

            Remove-MgUser `
                -UserId $InactiveUser.Id `
                -Confirm:$false `
                -ErrorAction Stop

            $InactiveUser.DeletionSuccessful = $true
            $InactiveUser.RecommendedAction = "Deleted"

            Write-Log "Successfully deleted: $($InactiveUser.UserPrincipalName)"

        }
        catch {

            $InactiveUser.DeletionSuccessful = $false
            $InactiveUser.RecommendedAction = "Deletion Failed"
            $InactiveUser.Error = $_.Exception.Message

            Write-Log `
                "Failed to delete $($InactiveUser.UserPrincipalName): $($_.Exception.Message)" `
                "ERROR"
        }
    }

    # Re-export report with deletion results
    try {

        $InactiveUsers |
            Export-Csv `
                -Path $ReportPath `
                -NoTypeInformation `
                -Encoding UTF8

        Write-Log "Final deletion audit report updated."

    }
    catch {

        Write-Log "Failed to update final audit report: $($_.Exception.Message)" "ERROR"
    }
}
else {

    if ($InactiveUsers.Count -gt 0) {

        Write-Log "REPORT ONLY mode enabled."
        Write-Log "No accounts were deleted."
        Write-Log "Review the audit report before any remediation."
    }
}

# ============================================================
# DISCONNECT
# ============================================================

try {

    Disconnect-MgGraph | Out-Null

    Write-Log "Disconnected from Microsoft Graph."

}
catch {

    Write-Log "Unable to disconnect cleanly from Microsoft Graph." "WARNING"
}

# ============================================================
# FINAL SUMMARY
# ============================================================

$ExecutionEnd = Get-Date
$Duration = $ExecutionEnd - $ExecutionStart

Write-Log "============================================================"
Write-Log "Guest account inactivity audit completed"
Write-Log "Execution duration: $($Duration.ToString())"
Write-Log "Inactive accounts identified: $($InactiveUsers.Count)"
Write-Log "Report: $ReportPath"
Write-Log "============================================================"

```
[!INCLUDE [More about Microsoft Graph PowerShell SDK](../../docfx/includes/MORE-GRAPHSDK.md)]

## Output

### CSV Audit Report

Default output: *C:\Temp\GuestAccountAudit_yyyyMMdd_HHmmss.csv*

The CSV contains:

- Entra ID object ID
- Display name
- User principal name
- Mail address
- Account enabled state
- Account creation date
- Last successful sign-in
- Activity date used for inactivity evaluation
- Activity source
- Calculated days inactive
- Configured inactivity threshold
- Recommended action
- Whether deletion was attempted
- Whether deletion succeeded
- Error information

### Execution Log

The execution log records:

- Script start and completion
- Execution mode
- Inactivity threshold
- Number of guests retrieved
- Number of active guests
- Number of excluded guests
- Number of never-used guests
- Number of inactive guests
- Report location
- Deletion attempts and outcomes
- Graph connection and disconnection events
- Errors encountered during execution


# [Microsoft Graph PowerShell](#tab/graphps)

```powershell
#Install-Module Microsoft.Graph
# Define the number of days of inactivity
$daysInactive = 30

Connect-MgGraph -Scopes "User.Read.All", "User.ReadWrite.All","AuditLog.Read.All"

$calcDate = (Get-Date).AddDays($daysInactive * -1)

$guestUsers = Get-MgUser -Filter "userType eq 'Guest'" -All -Property id,displayName,mail,signInActivity,UserPrincipalName

$inactiveUsers = @()

foreach ($user in $guestUsers) {
        if ($user.SignInActivity.LastSignInDateTime -ge $calcDate) {
            $inactiveUsers += $user
        }
}

if ($inactiveUsers.Count -gt 0) {
    Write-Host "The following guest users have been inactive for $daysInactive days or more:"
    $inactiveUsers | ForEach-Object {
        Write-Host "$($_.DisplayName) ($($_.UserPrincipalName))"
    }

    # Ask if the user wants to delete the inactive users
    $delete = Read-Host "Do you want to delete these users? (y/n)"
    if ($delete -eq 'y') {
        $inactiveUsers | ForEach-Object {
            Remove-MgUser -UserId $_.Id -Confirm:$false
            Write-Host "Deleted user: $($_.DisplayName) ($($_.UserPrincipalName))"
        }
    }
} else {
    Write-Host "No inactive guest users found."
}


Disconnect-MgGraph
```
[!INCLUDE [More about Microsoft Graph PowerShell SDK](../../docfx/includes/MORE-GRAPHSDK.md)]
***



## Contributors

|Author(s)|
|-----------|
|[Peter Paul Kirschner](https://github.com/petkir)|
|[Josiah Opiyo](https://github.com/ojopiyo)|

*Built with a focus on automation, governance, least privilege, and clean Microsoft 365 tenants-helping M365 admins gain visibility and reduce operational risk.*

## Version history

|Version|Date|Comments|
|-------|----|--------|
|1.0|October 02, 2024|Initial release|
|2.0|August 23, 2026|Refactored and improved version|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
