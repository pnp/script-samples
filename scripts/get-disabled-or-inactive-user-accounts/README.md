---
plugin: add-to-gallery
---

# Get disabled or inactive user accounts

## Summary

In order to keep your tenant clean (Governance), you might want to ensure that disabled or inactive user accounts will be replaced where oppropriate (Think Owners of sites/groups, assignedto user on tasks/planner and so on). This script will help you find those accounts.

![Example Screenshot](assets/example.png)


# [PnP PowerShell](#tab/pnpps)

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
***


## Contributors

| Author(s) |
|-----------|
| Kasper Larsen |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/get-disabled-or-inactive-user-accounts" aria-hidden="true" />
