# Export Entra ID User MFA Phone Details (Unmasked) to CSV

This PowerShell script enumerates users in Microsoft Entra ID (formerly Azure AD) and retrieves their **Multi-Factor Authentication (MFA) / phone authentication methods** using Microsoft Graph.  
Unlike standard user directory properties that return **masked** phone numbers, this script queries the **Authentication Phone Methods API**, which returns the **actual configured MFA phone number**, and exports the data to CSV.

This is useful for administrators who need to reconcile MFA phone numbers, validate ownership, or support audit and migration activities.

> ⚠️ **Security Notice**  
> MFA phone numbers are sensitive data. Ensure correct governance, storage protection, and access controls when running or distributing this script.


## ✨ Features

- Retrieves Microsoft Entra ID users  
- Calls the Graph `authentication/phoneMethods` endpoint to return **unmasked MFA phone numbers**
- Cleans and normalizes phone numbers (digits-only format included)
- Supports **app-only authentication** using OAuth2 client credentials
- Exports structured output to CSV containing:
  - `DisplayName`
  - `UserPrincipalName`
  - `LDAPUserName` (`onPremisesSamAccountName`)
  - `PhoneNumber`
  - `CleanedPhone` (digits only)

---

## 🔐 Required Microsoft Graph Permissions (Application / App-Only)

Create an App Registration and grant **admin-consented** Graph API permissions such as:

- `AuthenticationMethod.Read.All`  
  **or**
- `AuthenticationMethods.Read.All`
- `User.Read.All`
- `Directory.Read.All`

> Use least-privilege permissions and validate in a non-production tenant first.

## 🧰 Prerequisites

- **PowerShell 7+ (recommended)**
- Install required modules:

```powershell
Install-Module -Name Microsoft.Graph -Scope CurrentUser -AllowClobber
Install-Module -Name PnP.PowerShell -Scope CurrentUser
```

- An Azure AD application with the required application permissions (granted by an administrator).
- Suggested Graph application permissions (app-only) you'll likely need:
  - Authentication Methods / phone read permission (e.g., AuthenticationMethods.Read.All or AuthenticationMethods.ReadWrite.All) — grant admin consent.
  - User read permissions (User.Read.All) — grant admin consent.
  - Directory.Read.All - grant admin consent

Note: permission names sometimes vary between SDKs and portal UI; grant the minimal required app permissions and test in a non-production tenant first.

## ⚙️ Authentication & Security

The script securely prompts for the following values at runtime:

- **Tenant ID**
- **Client ID**
- **Client Secret**
- **Output CSV path**

No credentials or secrets are stored in the script.

Authentication is performed using the **OAuth2 client credentials flow** against Microsoft Graph.

> 🔐 **Security Best Practice**  
> Use least-privileged access, store secrets securely, and rotate credentials regularly.

---

## ▶️ How It Works

1. Authenticates to Microsoft Graph using the App Registration  
2. Retrieves users via:

   ```powershell
   Get-MgUser
   ```
3. Queries each user’s authentication phone methods using:
   https://graph.microsoft.com/v1.0/users/{id}/authentication/phoneMethods
4. Extracts the configured MFA phone number(s)

5. Normalizes phone values (including a digits-only variant)

6. Exports the results to CSV

---

## 📄 Output Columns

| Column | Description |
|--------|-------------|
| **DisplayName** | User display name |
| **UserPrincipalName** | Sign-in name |
| **LDAPUserName** | `onPremisesSamAccountName` |
| **PhoneNumber** | Full MFA phone number |
| **CleanedPhone** | Digits-only version of the phone |

Additional properties such as `@odata.type` may be included if required.

---

## ▶️ Running the Script

Run the script in PowerShell:

```powershell
.\Export-UserMfaPhoneDetails.ps1
```
## 🛠 Troubleshooting

- **No phone number returned**  
  The user does not have any phone-based MFA method configured.

- **403 – Permission Denied**  
  Verify that the App Registration has the required **admin-consented** Microsoft Graph permissions.

- **Rate limiting / throttling**  
  For large tenants, implement retry logic with exponential back-off when calling Microsoft Graph.

- **Masked phone values appear**  
  Ensure the script is querying the **Authentication Phone Methods API** and not user profile attributes.

---

## 🔄 Suggested Enhancements

- Replace raw REST calls with Microsoft Graph PowerShell SDK equivalents
- Secure credentials using environment variables or Azure Key Vault
- Add structured logging and verbose tracing
- Introduce paging and server-side filtering to limit user scope
- Implement retry and resilience policies for Graph calls
- Optionally upsert results into a SharePoint List

---

## 🛡 Governance & Data Handling

Because this script retrieves **unmasked MFA phone numbers**, ensure that:

- Script execution is restricted to authorized administrators
- Exported CSV files are encrypted and stored securely
- Data retention policies are followed
- Script usage and access are auditable

Treat MFA phone numbers as **confidential information**.

---

## 📝 Script 

# [Microsoft Graph PowerShell](#tab/graphps)

```powershell
<#
.SYNOPSIS
    Export Entra ID user MFA phone details (unmasked) to CSV.

.DESCRIPTION
    Retrieves MFA phone authentication methods from Microsoft Graph
    using app-only authentication and exports the full MFA phone number
    along with user metadata to CSV.

    Warning: Output contains sensitive authentication data.
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

## Contributors

| Author(s) |
|-----------|
| [Divya Akula](https://github.com/divya-akula)|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/graph-get-mfa-user-number" aria-hidden="true" />
