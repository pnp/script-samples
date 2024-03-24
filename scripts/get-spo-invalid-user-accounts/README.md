---
plugin: add-to-gallery
---

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

function Get-AllUsersFromUPA
{
    $allUPAusers = @()
    $UPAusers = Submit-PnPSearchQuery -Query "*" -SourceId "b09a7990-05ea-4af9-81ef-edfab16c4e31" -SelectProperties "Title,WorkEmail" -All -Connection $conn
    foreach($user in $UPAusers.ResultRows)
    {
        $allUPAusers += $user.LoginName
    }
    $allUPAusers
}

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

$disabledusersfromgraph = Get-UserFromGraph
$allUPAusers = Get-AllUsersFromUPA

$allSiteUsers = Get-PnPUser -Connection $conn
$validUsers = @()
$invalidUsers = @()
foreach($user in $allSiteUsers)
{
    try {
        $userObj = Get-PnPUser -Identity $user.LoginName -Connection $conn -ErrorAction Stop
        if($userObj.Email -in $disabledusersfromgraph)
        {
            Write-Host "User $($userObj.LoginName) is disabled in Azure AD"
            $invalidUsers += $user
        }
        else
        {
            $hit = $allUPAusers | Where-Object {$_ -eq $userObj.LoginName}
            if(-not $hit)
            {
                Write-Host "User $($userObj.LoginName) is not in the UPA"
                $invalidUsers += $user
            }
        }
        
        
    }
    catch {
        $invalidUsers += $user
    }
}
$invalidUsers | Export-Csv -Path "C:\temp\invalidusers.csv" -Delimiter "|" -Encoding utf8 -Force

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***


## Contributors

| Author(s) |
|-----------|
| Kasper Larsen |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/get-spo-invalid-user-accounts" aria-hidden="true" />
