---
plugin: add-to-gallery
---

# Delete inactive Guest User

The script will report inactive users for x days and provides an option to delete them.


## Summary

This PowerShell script identifies and optionally deletes inactive guest users in Microsoft 365. It connects to Microsoft Graph, retrieves guest users, checks their last sign-in date, and lists those who have been inactive for a specified number of days. The script then prompts the user to confirm whether to delete these inactive users.


- Open Windows PowerShell ISE or VS Code
- Copy script below to your clipboard
- Modify the $daysInactive variable as needed.
- Run the script to identify and optionally delete inactive guest users.

[!INCLUDE [Delete Warning](../../docfx/includes/DELETE-WARN.md)]

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

| Author(s) |
|-----------|
| [Peter Paul Kirschner](https://github.com/petkir) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/aad-inactive-guest-delete" aria-hidden="true" />