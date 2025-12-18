

# Get Site Collection invalid user accounts

## Summary

When you have an old site collection with a lot of users, it can be hard to keep track of which users are valid and which are not. This script will help you find all the invalid users in your site collection.

In this script I have checked for two things:
1. Users that are disabled in Azure AD
2. Users that are not in the User Profile Application

![Example Screenshot](assets/example.png)


# [PnP PowerShell](#tab/pnpps)

```powershell

#extract all users from a site collection and check for validity
$SiteURL = "https://contoso.sharepoint.com/sites/workspaces"
if(-not $conn)
{
    $conn = Connect-PnPOnline -Url $SiteURL -Interactive -ReturnConnection
}

# ---------------------------
# Function: Get all users from UPA
# ---------------------------
function Get-AllUsersFromUPA {
    param([Parameter(Mandatory)] $Connection)

    $UPAusers = Submit-PnPSearchQuery `
        -Query "*" `
        -SourceId "b09a7990-05ea-4af9-81ef-edfab16c4e31" `
        -SelectProperties "Title,WorkEmail" `
        -All `
        -Connection $Connection

    return $UPAusers.ResultRows | ForEach-Object { $_.LoginName }
}

# ---------------------------
# Function: Get disabled users from Azure AD (Graph)
# ---------------------------
function Get-DisabledUsersFromGraph {
    param([Parameter(Mandatory)] $Connection)

    $result = Invoke-PnPGraphMethod -Url "users?`$select=displayName,mail,accountEnabled" -Connection $Connection
    return $result.value | Where-Object { $_.accountEnabled -eq $false } | ForEach-Object { $_.mail }
}

# ---------------------------
# Function: Validate site users
# ---------------------------
function Validate-SiteUsers {
    param(
        [Parameter(Mandatory)] $Connection,
        [Parameter(Mandatory)] $UPAusers,
        [Parameter(Mandatory)] $DisabledUsers
    )

    $invalidUsers = @()
    $allSiteUsers = Get-PnPUser -Connection $Connection

    foreach ($user in $allSiteUsers) {
        try {
            $userObj = Get-PnPUser -Identity $user.LoginName -Connection $Connection -ErrorAction Stop

            if ($userObj.Email -in $DisabledUsers) {
                Write-Host "User $($userObj.LoginName) is disabled in Azure AD" -ForegroundColor Yellow
                $invalidUsers += $user
            }
            elseif (-not ($UPAusers -contains $userObj.LoginName)) {
                Write-Host "User $($userObj.LoginName) is not in the UPA" -ForegroundColor Yellow
                $invalidUsers += $user
            }
        }
        catch {
            Write-Host "Error retrieving user $($user.LoginName), marking as invalid." -ForegroundColor Red
            $invalidUsers += $user
        }
    }

    return $invalidUsers
}

# ---------------------------
# Main Script Execution
# ---------------------------
$allUPAusers = Get-AllUsersFromUPA -Connection $conn
$disabledUsersFromGraph = Get-DisabledUsersFromGraph -Connection $conn
$invalidUsers = Validate-SiteUsers -Connection $conn -UPAusers $allUPAusers -DisabledUsers $disabledUsersFromGraph

# Export invalid users to CSV
$invalidUsers | Export-Csv -Path "C:\temp\invalidusers.csv" -Delimiter "|" -Encoding utf8 -Force

Write-Host "Script completed. Invalid users exported to C:\temp\invalidusers.csv" -ForegroundColor Green

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***


## Contributors

| Author(s) |
|-----------|
| Kasper Larsen |
| ojopiyo |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/get-spo-invalid-user-accounts" aria-hidden="true" />
