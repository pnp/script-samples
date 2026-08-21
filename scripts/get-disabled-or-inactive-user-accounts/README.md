

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

# [PnP PowerShell V2](#tab/pnppsv2)

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

# [PnP PowerShell](#tab/pnpps)

In order to keep your tenant clean (Governance), you might want to ensure that disabled or inactive user accounts will be replaced where oppropriate (Think Owners of sites/groups, assignedto user on tasks/planner and so on). This script will help you find those accounts.

```powershell

function Get-UserFromGraph 
{
    $disabledusersfromgraph = @()
    $result = Invoke-PnPGraphMethod -Url "users?`$select=displayName,mail, AccountEnabled" -Connection $conn

    $result.value.Count
    foreach($account in $result.value)
    {
        if($account.accountEnabled -eq $false)
        {
            $disabledusersfromgraph += $account.mail
        }
    }
    $disabledusersfromgraph
}
function Get-UserFromSharePointSearch 
{
    $usersfromsearch = @()
    #How you tag an account as disabled varies from org to org, so you might need to change the below
    #in one tenant the account name was prefixed with ZZ_[Year of leaving]
    #in another tenant they had a custom property called EmployeeStatus, and sometimes a DateLeft property
    #SourceId "b09a7990-05ea-4af9-81ef-edfab16c4e31"  is the People source in SharePoint
    $results = Invoke-PnPSearchQuery -Query "*" -SourceId "b09a7990-05ea-4af9-81ef-edfab16c4e31" -All -Connection $conn    
    
    foreach($result in $results.ResultRows)
    {
        #you can replace this with whatever you use to tag an account as disabled
        if($result["SPS-HideFromAddressLists"] -eq $true)
        {
            $usersfromsearch += $result["WorkEmail"]
        }
    }
    $usersfromsearch
}
function Get-UserFromGraphThatHasntLoggedInResently($duration = 90) 
{
    $inactiveusersfromgraph = @()
    $authToken = Get-PnPGraphAccessToken -Connection $conn
    $uri = "https://graph.microsoft.com/v1.0/users"
    $Headers = @{
        "Authorization" = "Bearer $($authToken)"
        "Content-type"  = "application/json"
    }
    $response = Invoke-RestMethod -Headers $Headers -Uri $uri -Method GET
    foreach($user in $response.value)
    {
        # requires the AuditLog.Read.All permission
        $signinsUri = "https://graph.microsoft.com/v1.0/auditLogs/signIns?$top=1&$filter=userPrincipalName eq '$($user.userPrincipalName)')"
        $response = Invoke-RestMethod -Headers $Headers -Uri $signinsUri -Method GET
        
        if($response.value.Count -eq 0)
        {
            #no signin found
            $inactiveusersfromgraph += $user.userPrincipalName
        }
        else {
            if($response.value[0].createdDateTime -lt (Get-Date).AddDays(-$duration))
            {
                #user has not signed in for 90 days
                $inactiveusersfromgraph += $user.userPrincipalName
                
            }
        }
    }
    $inactiveusersfromgraph
}


$ClientId = "clientid"
$TenantName = "[domain].onmicrosoft.com"
$SharePointAdminSiteURL = "https://[domain]-admin.sharepoint.com/"
#connect to SharePoint using a certificate or similar
$conn = Connect-PnPOnline -Url $SharePointAdminSiteURL -ClientId $ClientId -Tenant $TenantName -CertificatePath "C:\Users\[you]\[CertName].pfx" -CertificatePassword (ConvertTo-SecureString -AsPlainText -Force "ThePassWord") -ReturnConnection

#get user data from graph and log those which are disabled
$userd1 = Get-UserFromGraph
$userd2 = Get-UserFromSharePointSearch
$users3 = Get-UserFromGraphThatHasntLoggedInResently

#output to csv file or use the data in some other way, like checking if the disabled users is a Owner of some site or group
$userd1 | Export-Csv -Path "C:\temp\disabledusers.csv" -NoTypeInformation 

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365 using PowerShell](#tab/cli-m365-ps)

In order to keep your tenant clean (Governance), you might want to ensure that disabled or inactive user accounts will be replaced where appropriate (Think Owners of sites/groups, assignedto user on tasks/planner and so on). This script will help you find those accounts using CLI for Microsoft 365.

```powershell

# =========================================
# Script: User Status Discovery (CLI for Microsoft 365)
# Purpose: Identify disabled and inactive users from multiple sources
# =========================================

# User Input
$InactiveDays = 90
$ExportPath   = "$env:TEMP\UserStatusFindings.csv"
# People result source id used for the SharePoint user profile search
$peopleSourceId = "b09a7990-05ea-4af9-81ef-edfab16c4e31"

# Connect to Microsoft 365
if ($(m365 status) -match "Logged Out") {
  m365 login
}

# Configure the CLI to output as JSON on each execution
$m365output = m365 cli config get --key output
if ($m365output -notmatch "json") {
    m365 cli config set --key output --value json
}

# Get CLI commands JSON output converted as objects
function Get-CLIValue {
    [cmdletbinding()]
    param(
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $input
    )

    $output = $input | ConvertFrom-Json
    if ($null -ne $output.error) {
        throw $output.error
    }
    return $output
}

# Helper to call Microsoft Graph and follow paging (@odata.nextLink)
function Invoke-GraphRequestAll {
    param(
        [Parameter(Mandatory)][string]$Url
    )

    $items = @()
    $next = $Url
    while ($next) {
        $page = m365 request --url $next | Get-CLIValue
        if ($page.value) { $items += $page.value }
        $next = $page.'@odata.nextLink'
    }
    return $items
}

# 1) Disabled accounts from Entra ID (Microsoft Graph)
function Get-DisabledUsersFromGraph {
    Invoke-GraphRequestAll -Url "https://graph.microsoft.com/v1.0/users?`$select=displayName,userPrincipalName,mail,accountEnabled" |
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

# 2) Accounts tagged as left/disabled in the SharePoint user profile (People search)
function Get-DisabledUsersFromSharePointSearch {
    # How an account is tagged as disabled varies from org to org, so you might need to change the
    # filter below (e.g. a custom EmployeeStatus / DateLeft property, or a naming convention).
    $results = m365 spo search --queryText "*" --sourceId $peopleSourceId `
        --selectProperties "WorkEmail,SPS-HideFromAddressLists,PreferredName" --allResults | Get-CLIValue

    $results |
    Where-Object { "$($_.'SPS-HideFromAddressLists')" -eq "true" } |
    ForEach-Object {
        [PSCustomObject]@{
            DisplayName       = $_.PreferredName
            UserPrincipalName = $_.WorkEmail
            Mail              = $_.WorkEmail
            Reason            = "HiddenFromGAL"
            Source            = "SharePointSearch"
        }
    }
}

# 3) Inactive accounts based on last interactive sign-in (requires AuditLog.Read.All + Entra ID P1)
function Get-InactiveUsersFromGraph {
    param(
        [int]$Days = 90
    )

    $cutoff = (Get-Date).AddDays(-$Days)
    $users = Invoke-GraphRequestAll -Url "https://graph.microsoft.com/v1.0/users?`$select=id,displayName,userPrincipalName"

    foreach ($user in $users) {
        $signInUrl = "https://graph.microsoft.com/v1.0/auditLogs/signIns?`$top=1&`$filter=userPrincipalName eq '$($user.userPrincipalName)'"
        $signIn = m365 request --url $signInUrl | Get-CLIValue

        if ($signIn.value.Count -eq 0 -or [datetime]$signIn.value[0].createdDateTime -lt $cutoff) {
            [PSCustomObject]@{
                DisplayName       = $user.displayName
                UserPrincipalName = $user.userPrincipalName
                Mail              = $null
                Reason            = "Inactive > $Days days"
                Source            = "AuditLogs"
            }
        }
    }
}

# ---------------------------
# Execution
# ---------------------------

$results = @()
$results += Get-DisabledUsersFromGraph
$results += Get-DisabledUsersFromSharePointSearch
$results += Get-InactiveUsersFromGraph -Days $InactiveDays

$results |
    Sort-Object UserPrincipalName, Reason |
    Export-Csv -Path $ExportPath -NoTypeInformation -Encoding UTF8

Write-Host "Exported $($results.Count) findings to $ExportPath"

```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

***


## Contributors

| Author(s) |
|-----------|
| Kasper Larsen |
| [Josiah Opiyo](https://github.com/ojopiyo) |
| [juandresrodca](https://github.com/juandresrodca) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/get-disabled-or-inactive-user-accounts" aria-hidden="true" />
