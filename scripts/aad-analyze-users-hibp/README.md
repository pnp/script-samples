---
plugin: add-to-gallery
---

# Analyze users for known data breaches with have i been pwned

## Summary

Validate all your users against known breaches with the have i been pwned api. That way you can quickly scan if your users are part of any known breaches.

# [CLI for Microsoft 365 with PowerShell](#tab/cli-m365-ps)

```powershell
$apiKey = "<PUTYOURKEYHERE>"
$m365Status = m365 status

if ($m365Status -match "Logged Out") {
    # Connection to Microsoft 365
    m365 login
}

$users = m365 aad user list --properties "displayName,userPrincipalName" | ConvertFrom-Json

$users | ForEach-Object {
    $user = $_
    $i++
    Write-Host "Check HBIP status for user '$($user.userPrincipalName)' - ($i/$($users.length))"

    $hbipStatus = m365 aad user hibp --userName $user.userPrincipalName --apiKey $apiKey --verbose | ConvertFrom-Json

    if ($hbipStatus -ne "No pwnage found") {
        Write-Host -ForegroundColor Red "Issue with user '$($user.userPrincipalName)'"
        $hbipStatus
    }

    Start-Sleep -Milliseconds 1500
}
```

[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
***

## Source Credit

Sample first appeared on [Analyze users for known data breaches with have i been pwned | CLI for Microsoft 365](https://pnp.github.io/cli-microsoft365/sample-scripts/aad/analyze-users-haveibeenpwnd/)

## Contributors

| Author(s) |
|-----------|
| Albert-Jan Schot |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/aad-analyze-users-hibp" aria-hidden="true" />

