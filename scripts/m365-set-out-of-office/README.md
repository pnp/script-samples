

# Set Out of Office for a user's mailbox using the Microsoft Graph API

## Summary

Admins often need to configure Out of Office for users who are on leave, leaving the organisation, or unavailable (for example, during offboarding). This script lets an admin set it without logging in to the user's mailbox. The script connects with "MailboxSettings.ReadWrite" and "User.Read.All" permission

![Example Screenshot](assets/example.png)

By default, the script has only registered Microsoft Graph and SharePoint Online Microsoft AAD apps (with their respective appId property). Feel free to add any other API listed [here](https://learn.microsoft.com/troubleshoot/azure/active-directory/verify-first-party-apps-sign-in#application-ids-for-commonly-used-microsoft-applications) in the `AadApis` class!


# [CLI for Microsoft 365 using PowerShell](#tab/cli-m365-ps)

```powershell

# User Input
$api = "Microsoft Graph" # Or "SharePoint"
$permission = "Sites.Read.All" # Can be "Read" if seeking more permissions

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

# Dedicated class to store Azure AD (AAD) Enterprise Microsoft Apps as valid param inputs 
class AadApis : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        $Global:aadApis = @{
            "SharePoint" = "00000003-0000-0ff1-ce00-000000000000"
            "Microsoft Graph" = "00000003-0000-0000-c000-000000000000"
        }

        return ($Global:aadApis).Keys
    }
}

# Method to get delegated or application permissions from a registered AAD MS App, based on name
function Get-AADPermission {
    [cmdletbinding()]
    param(
        [parameter(Mandatory)]
        [ValidateSet([AadApis], IgnoreCase = $false)]
        $ApiName,
        [parameter(Mandatory)]
        $PermissionName,
        [parameter(Mandatory = $false)]
        [Switch]$Delegated,
        [parameter(Mandatory = $false)]
        [Switch]$Application
    )

    try {
        $sp = m365 aad sp get --appId ($Global:aadApis)[$ApiName] | Get-CLIValue

        if ($Delegated) {
            $permissionsInfo = $sp.oauth2PermissionScopes | Where-Object { $_.value -match $PermissionName }
        }
        elseif ($Application) {
            $permissionsInfo = $sp.appRoles | Where-Object { $_.value -match $PermissionName }
        }
        else {
            throw "Please define if seeked permission is a delegated (-Scope) or an application (-Role) one"
        }

        if ($permissionsInfo) {
            Write-Host "AAD app info:"
            Write-Host ($sp | Select-Object id, appId, displayName | Format-List | Out-String)
            Write-Host "-----------"
            Write-Host "Permissions info:"

            foreach ($perm in $permissionsInfo) {
                Write-Host ($perm | Format-List | Out-String)
            }
        }
        else {
            $permissionType = (&{If($Delegated -eq $true) {"Delegated"} Else {"Application"}})
            
            Write-Warning "No $($permissionType) permission named [$($PermissionName)] found for $($ApiName) App"
        }
    }
    catch {
        Write-Error $_.Exception
    }
}

# Run the command
Get-AADPermission -ApiName $api -PermissionName $permission -Application

```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]


# [Microsoft Graph PowerShell](#tab/graphps)

```powershell

# Connect to Microsoft Graph (used only for authentication)
Connect-MgGraph -Scopes "MailboxSettings.ReadWrite", "User.Read.All"

# Collect user input
$userPrincipalName = Read-Host "Enter the user's email address"

# Look up the user via REST API
try 
{
    $user = Invoke-MgGraphRequest -Method GET `
        -Uri "https://graph.microsoft.com/v1.0/users/$($userPrincipalName)?`$select=id,displayName,userPrincipalName"
}
catch 

{
    Write-Host "USER NOT FOUND!" -ForegroundColor Red
    return
}
$userID = $user.id

# Out of Office time inputs
$startTime = Read-Host "Enter OOO start date and time (yyyy-MM-dd HH:mm, e.g. 2026-11-21 09:00)"
$endTime   = Read-Host "Enter OOO end date and time   (yyyy-MM-dd HH:mm, e.g. 2026-11-21 20:00)"

$format  = "yyyy-MM-dd HH:mm"
$culture = [System.Globalization.CultureInfo]::InvariantCulture
$start = [datetime]::MinValue
$end   = [datetime]::MinValue

if (-not ([datetime]::TryParseExact($startTime, $format, $culture, 'None', [ref]$start) -and
          [datetime]::TryParseExact($endTime,   $format, $culture, 'None', [ref]$end))) {
    Write-Host "Invalid date format. Use $format." -ForegroundColor Red
    return
}
if ($end -le $start)
{
    Write-Host "End time must be after start time." -ForegroundColor Red
    return
}
if ($end -le (Get-Date))

{
    Write-Host "End time must be in the future." -ForegroundColor Red
    return
}

$startTimeInIso = $start.ToString("yyyy-MM-ddTHH:mm:ss")
$endTimeInIso   = $end.ToString("yyyy-MM-ddTHH:mm:ss")

# Out of Office messages
$internalMsg = Read-Host "Enter internal reply message"
$setExternal = Read-Host "Do you want to set an external reply message? (Yes/No)"

$externalMsg = ""
$externalAudience = "none"
if ($setExternal -eq "Yes") 
{
    $externalMsg = Read-Host "Enter external reply message"
    $externalAudience = "all"
}

# Body
$body = @{
    automaticRepliesSetting = @{
        status                = "scheduled"
        externalAudience      = $externalAudience
        scheduledStartDateTime = @{
            dateTime = $startTimeInIso
            timeZone = "India Standard Time"
        }
        scheduledEndDateTime = @{
            dateTime = $endTimeInIso
            timeZone = "India Standard Time"
        }
        internalReplyMessage = $internalMsg
        externalReplyMessage = $externalMsg
    }
} | ConvertTo-Json -Depth 5

# Set the OOO via REST API
$URI = "https://graph.microsoft.com/v1.0/users/$userID/mailboxSettings"
Invoke-MgGraphRequest -Uri $URI -Method PATCH -Body $body -ContentType "application/json"

Write-Host "Automatic reply settings successfully applied for $userPrincipalName." -ForegroundColor Green

```
[!INCLUDE [More about Microsoft Graph PowerShell SDK](../../docfx/includes/MORE-GRAPHSDK.md)]
***


## Contributors

| Author(s)                                            |
|------------------------------------------------------|
| [Sujin Nelladath](https://github.com/nelladath) | (https://www.linkedin.com/in/sujin-nelladath-8911968a/)


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/m365-set-out-of-office" aria-hidden="true" />