

# Get disabled or inactive user accounts

## Summary

Maintaining a clean and well-governed Microsoft 365 tenant requires visibility into disabled and inactive user accounts. These accounts can unintentionally retain ownership or assignments across SharePoint sites, Microsoft Teams, Microsoft 365 Groups, and task-based workloads such as Planner.

This script helps identify disabled and inactive user accounts from multiple sources, enabling administrators to proactively review and replace users where appropriate. By doing so, organizations can reduce operational risk, improve governance, and ensure continued accountability for owned resources and assigned workloads.

![Example Screenshot](assets/example.png)

### Purpose

The purpose of this script is to support Microsoft 365 governance by identifying user accounts that are disabled or inactive but may still hold ownership, permissions, or assignments across the tenant. The output can be used as an input for remediation activities such as ownership reassignment, access review, or account cleanup.

### Use Cases

- Identifying disabled users who still own SharePoint sites or Microsoft Teams
- Detecting inactive users assigned to Planner tasks or project deliverables
- Supporting periodic access reviews and governance audits
- Preparing for offboarding or tenant cleanup initiatives

# [PnP PowerShell](#tab/pnpps)

```powershell

# =========================================
# Script: User Status Discovery (PnP + Graph)
# Purpose: Identify disabled and inactive users from multiple sources
# =========================================

function Get-DisabledUsersFromGraph {
    param (
        [Parameter(Mandatory)]
        [PnP.PowerShell.Commands.Base.PnPConnection]$Connection
    )

    Invoke-PnPGraphMethod `
        -Url "users?`$select=displayName,userPrincipalName,mail,accountEnabled" `
        -All `
        -Connection $Connection |
    Where-Object { $_.accountEnabled -eq $false } |
    ForEach-Object {
        [PSCustomObject]@{
            DisplayName       = $_.displayName
            UserPrincipalName = $_.userPrincipalName
            Mail              = $_.mail
            Reason            = "AccountDisabled"
            Source            = "EntraID"
        }
    }
}

function Get-DisabledUsersFromSharePointSearch {
    param (
        [Parameter(Mandatory)]
        [PnP.PowerShell.Commands.Base.PnPConnection]$Connection
    )

    $results = Invoke-PnPSearchQuery `
        -Query "*" `
        -SourceId "b09a7990-05ea-4af9-81ef-edfab16c4e31" `
        -SelectProperties "WorkEmail,SPS-HideFromAddressLists" `
        -All `
        -Connection $Connection

    $results.ResultRows |
    Where-Object { $_["SPS-HideFromAddressLists"] -eq $true } |
    ForEach-Object {
        [PSCustomObject]@{
            DisplayName       = $null
            UserPrincipalName = $_["WorkEmail"]
            Mail              = $_["WorkEmail"]
            Reason            = "HiddenFromGAL"
            Source            = "SharePointSearch"
        }
    }
}

function Get-InactiveUsersFromGraph {
    param (
        [Parameter(Mandatory)]
        [PnP.PowerShell.Commands.Base.PnPConnection]$Connection,

        [int]$InactiveDays = 90
    )

    $token = Get-PnPGraphAccessToken -Connection $Connection
    $headers = @{
        Authorization  = "Bearer $token"
        "Content-Type" = "application/json"
    }

    $users = Invoke-RestMethod `
        -Uri "https://graph.microsoft.com/v1.0/users?`$select=id,displayName,userPrincipalName" `
        -Headers $headers `
        -Method GET

    foreach ($user in $users.value) {
        $signInUri = "https://graph.microsoft.com/v1.0/auditLogs/signIns?`$top=1&`$filter=userPrincipalName eq '$($user.userPrincipalName)'"
        $signIn = Invoke-RestMethod -Uri $signInUri -Headers $headers -Method GET

        if (
            $signIn.value.Count -eq 0 -or
            $signIn.value[0].createdDateTime -lt (Get-Date).AddDays(-$InactiveDays)
        ) {
            [PSCustomObject]@{
                DisplayName       = $user.displayName
                UserPrincipalName = $user.userPrincipalName
                Mail              = $null
                Reason            = "Inactive > $InactiveDays days"
                Source            = "AuditLogs"
            }
        }
    }
}

# ---------------------------
# Connection
# ---------------------------

$ClientId = "clientid"
$TenantName = "[domain].onmicrosoft.com"
$AdminUrl = "https://[domain]-admin.sharepoint.com"

$conn = Connect-PnPOnline `
    -Url $AdminUrl `
    -ClientId $ClientId `
    -Tenant $TenantName `
    -CertificatePath "C:\Certs\Cert.pfx" `
    -CertificatePassword (ConvertTo-SecureString "ThePassword" -AsPlainText -Force) `
    -ReturnConnection

# ---------------------------
# Execution
# ---------------------------

$results = @()
$results += Get-DisabledUsersFromGraph -Connection $conn
$results += Get-DisabledUsersFromSharePointSearch -Connection $conn
$results += Get-InactiveUsersFromGraph -Connection $conn -InactiveDays 90

$results |
    Sort-Object UserPrincipalName, Reason |
    Export-Csv "C:\Temp\UserStatusFindings.csv" -NoTypeInformation -Encoding UTF8


 

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***


## Contributors

| Author(s) |
|-----------|
| Kasper Larsen |
| [Josiah Opiyo](https://github.com/ojopiyo) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/get-disabled-or-inactive-user-accounts" aria-hidden="true" />
