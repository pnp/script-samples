# Export Entra ID user MFA phone details instead of masked phone number to CSV

Export Entra ID user MFA phone details to CSV.This PowerShell script enumerates users in Microsoft Entra ID (Azure AD) and reads their MFA/phone authentication methods from Microsoft Graph, then upserts that data into a Microsoft List named `MFAUserData` in SharePoint. If we directly query Phone number instead of masked number. This script mimics that and gets complete user number.

Key behaviors:

- Retrieves users (uses `Get-MgUser` with a filter for UPNs starting with 'T' in the provided script).
- Calls the Graph API `authentication/phoneMethods` endpoint for each user to collect MFA phone numbers.
- Cleans phone numbers (removes non-digit characters) and writes/upserts user and phone data into the `MFAUserData` list using PnP.PowerShell.

## Important security note

The version of the script included here contains a hard-coded client secret in `Get-UserToken`. Do NOT commit client secrets into source control. Before running in any production or shared repo, remove any hard-coded secrets and use one of the recommended approaches below:

- Use environment variables or a secure vault (Azure Key Vault, Windows Credential Manager, SecretManager).
- Use a certificate-based credential for app-only auth instead of a client secret.
- Use Managed Identity (if running from an Azure resource that supports it).

If this repository contains real secrets, rotate those credentials immediately.

### Prerequisites

- PowerShell 7+ (pwsh) is recommended.
- Install the Microsoft Graph PowerShell SDK and PnP.PowerShell modules:

```powershell
Install-Module -Name Microsoft.Graph -Scope CurrentUser -AllowClobber
Install-Module -Name PnP.PowerShell -Scope CurrentUser
```

- An Azure AD application with the required application permissions (granted by an administrator).

Suggested Graph application permissions (app-only) you'll likely need:

- Authentication Methods / phone read permission (e.g., AuthenticationMethods.Read.All or AuthenticationMethods.ReadWrite.All) — grant admin consent.
- User read permissions (User.Read.All) — grant admin consent.
- Directory.Read.All - grant admin consent

Note: permission names sometimes vary between SDKs and portal UI; grant the minimal required app permissions and test in a non-production tenant first.

### Configuration

Recommended: Export client secret and other values via environment variables and update `Get-UserToken` to read them:

## Description

- Prompts for Tenant Id, Client Id, and Client Secret (no secrets hard-coded)
- Uses Microsoft Graph REST with client credentials flow
- Retrieves users (script currently enumerates all users via `Get-MgUser`) and filters in code for the intended set (example: UPN starts with 'T')
- For each user, retrieves `authentication/phoneMethods` via Microsoft Graph
- Exports the following columns to CSV:

  - DisplayName
  - UserPrincipalName
  - LDAPUserName (onPremisesSamAccountName)
  - PhoneNumber
  - CleanedPhone (digits only)

> Note: The original header included `MethodType` in comments; the current script exports the five columns above. You can append `MethodType` when iterating phone methods by adding the `@odata.type` or other method properties to the PSCustomObject.


## How to run

1. Open PowerShell (pwsh).
2. Install the Microsoft.Graph module (see Prerequisites).
3. Save the script file locally (e.g., `Export-UserMfaPhoneDetails.ps1`).
4. Run the script. The script prompts for Tenant Id, Client Id, Client Secret and an output CSV path.

Example run:

``` powershell
# Run the script; you'll be prompted for TenantId, ClientId, ClientSecret and output path
.\Export-UserMfaPhoneDetails.ps1

```

After completion you'll have a UTF-8 CSV at the path you provided.

## Output columns

- DisplayName
- UserPrincipalName
- LDAPUserName (onPremisesSamAccountName)
- PhoneNumber
- CleanedPhone (digits only)

If you want `MethodType` or other phone-method metadata, add that property when building each PSCustomObject from `$m`.

``` powershell
<#
.SYNOPSIS
    Export Entra ID user MFA phone details to CSV.

.DESCRIPTION
    - Prompts for Tenant Id, Client Id, and Client Secret (no secrets hard-coded)
    - Uses Microsoft Graph REST with client credentials flow
    - Retrieves users where userPrincipalName starts with 'T'
    - For each user, retrieves authentication phoneMethods
    - Exports:
        DisplayName
        UserPrincipalName
        LDAPUserName (onPremisesSamAccountName)
        PhoneNumber
        CleanedPhone (digits only)
        MethodType (@odata.type from phoneMethods)
#>

# ================================
# Get access token (interactive)
# ================================
function Get-UserToken {
    # Read from user
    $TenantId  = Read-Host "Enter Tenant Id (Directory Id / GUID)"
    $ClientId  = Read-Host "Enter Client Id (App Registration Id)"
    $SecSecret = Read-Host "Enter Client Secret" 

    # Convert secure string to plain text for token request
    $Body = @{ 
        grant_type    = "client_credentials"
        scope         = "https://graph.microsoft.com/.default"
        client_id     = $ClientId
        client_secret = $SecSecret
    }

    try {
        $TokenResponse = Invoke-RestMethod -Method Post `
            -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" `
            -Body $Body -ErrorAction Stop

        $AccessToken = $TokenResponse.access_token
        Write-Host "Access Token Obtained Successfully" -ForegroundColor Green
        return $AccessToken
    }
    catch {
        Write-Error "Failed to obtain access token: $($_.Exception.Message)"
        throw
    }
}

# ================================
# Export MFA phone details to CSV
# ================================
function Export-UserMfaPhoneDetailsToCsv {
    param (
        [Parameter(Mandatory)]
        [string]$AccessToken,

        [Parameter(Mandatory)]
        [string]$OutputPath
    )

    $headers = @{
        Authorization = "Bearer $AccessToken"
        'Content-Type' = 'application/json'
    }

    # Helper: clean phone (digits only)
    function CleanPhone {
        param([string]$p)
        if ([string]::IsNullOrWhiteSpace($p)) { return '' }
        return ($p.ToCharArray() | Where-Object { [char]::IsDigit($_) }) -join ''
    }

    # Get all users (UPN starts with 'T')
    $users = Get-MgUser -All -Property "displayName,userPrincipalName,onPremisesSamAccountName,Id" 
         Write-Host "Retrieved $($users.Count) users from Graph" -ForegroundColor Cyan

    $results = @()

    foreach ($u in $users) {
        $userId      = $u.id
        $displayName = $u.displayName
        $upn         = $u.userPrincipalName
        $ldapUser    = $u.onPremisesSamAccountName   # This is your LDAP username

        $pmUrl = "https://graph.microsoft.com/v1.0/users/$([uri]::EscapeDataString($userId))/authentication/phoneMethods"
        try {
            $pm = Invoke-RestMethod -Headers $headers -Uri $pmUrl -Method Get -ErrorAction Stop
        }
        catch {
            Write-Verbose "Failed phoneMethods for $upn : $($_.Exception.Message)"
            continue
        }
       # Write-Host $pm.value
        if (-not $pm.value) {
            # No phone methods: still record the user if you want them in the CSV
            $results += [PSCustomObject]@{
                DisplayName       = $displayName
                UserPrincipalName = $upn
                LDAPUserName      = $ldapUser
                PhoneNumber       = $null
                CleanedPhone      = $null
            }
            continue
        }

        foreach ($m in $pm.value) {
            $phone      = $m.phoneNumber
            $cleaned    = CleanPhone $phone

            $results += [PSCustomObject]@{
                DisplayName       = $displayName
                UserPrincipalName = $upn
                LDAPUserName      = $ldapUser
                PhoneNumber       = $phone
                CleanedPhone      = $cleaned
            }
        }
    }

    # Write to CSV
    $results | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8
    Write-Host $results.Count
    Write-Host "Exported $($results.Count) rows to $OutputPath" -ForegroundColor Green
}

# ================================
# Main
# ================================
$token = Get-UserToken

$outputPath = Read-Host "Enter full path for CSV output (e.g. C:\Temp\MfaUserData.csv)"

Export-UserMfaPhoneDetailsToCsv -AccessToken $token -OutputPath $outputPath
```

[!INCLUDE [More about Microsoft Graph PowerShell SDK](../../docfx/includes/MORE-GRAPHSDK.md)]
***

## Troubleshooting

- No phone methods for user: the script records a row with empty phone fields for users without phone methods (adjust logic if you prefer to skip those users).
- Permission errors: ensure the app has the required application permissions and admin consent. Use the Azure portal to double-check consent.
- Graph throttling: implement retry/backoff for `Invoke-RestMethod` calls if you hit rate limits.

## Suggested improvements / next steps

- Do not echo secrets; use `Read-Host -AsSecureString` or environment variables.
- Replace raw REST calls with Microsoft.Graph SDK method calls where feasible for consistency.
- Add paging support or server-side filtering to only retrieve the users you need (the current script enumerates all users via `Get-MgUser -All`).
- Add logging, error handling, and a dry-run or verbose mode.
- 
## Contributors

| Author(s) |
|-----------|
| [Divya Akula](https://github.com/divya-akula)|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/graph-get-licenses-by-sku-email-if-low" aria-hidden="true" />
