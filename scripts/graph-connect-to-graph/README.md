

# Connect to Graph using V1 or V2 SDK

## Summary

With Graph SDK 2, the connection method has changed slightly. This function will connect to either V1 or V2 via a query.


# [Microsoft Graph PowerShell](#tab/graphps)

```powershell

## Install Modules if missing
if (Get-Module -ListAvailable -Name microsoft.graph.authentication) {
    Write-Host "Microsoft Graph Authentication Module Already Installed"
} 
else {
    try {
        Install-Module -Name microsoft.graph.authentication -Scope CurrentUser -Repository PSGallery -Force -AllowClobber 
    }
    catch [Exception] {
        $_.message 
    }
}

## Import Module
Import-Module Microsoft.Graph.authentication

Function Connect-ToGraph {
    <#
    .SYNOPSIS
    Authenticates to the Graph API via the Microsoft.Graph.Authentication module.
    
    .DESCRIPTION
    The Connect-ToGraph cmdlet is a wrapper cmdlet that helps authenticate to the Intune Graph API using the Microsoft.Graph.Authentication module. It leverages an Azure AD app ID and app secret for authentication or user-based auth.
    
    .PARAMETER Tenant
    Specifies the tenant (e.g. contoso.onmicrosoft.com) to which to authenticate.
    
    .PARAMETER AppId
    Specifies the Azure AD app ID (GUID) for the application that will be used to authenticate.
    
    .PARAMETER AppSecret
    Specifies the Azure AD app secret corresponding to the app ID that will be used to authenticate.

    .PARAMETER Scopes
    Specifies the user scopes for interactive authentication.
    
    .EXAMPLE
    Connect-ToGraph -TenantId $tenantID -AppId $app -AppSecret $secret
    
    -#>
    [cmdletbinding()]
    param
    (
        [Parameter(Mandatory = $false)] [string]$Tenant,
        [Parameter(Mandatory = $false)] [string]$AppId,
        [Parameter(Mandatory = $false)] [string]$AppSecret,
        [Parameter(Mandatory = $false)] [string]$scopes
    )

    Process {
        Import-Module Microsoft.Graph.Authentication
        $version = (get-module microsoft.graph.authentication | Select-Object -expandproperty Version).major

        if ($AppId -ne "") {
            $body = @{
                grant_type    = "client_credentials";
                client_id     = $AppId;
                client_secret = $AppSecret;
                scope         = "https://graph.microsoft.com/.default";
            }
     
            $response = Invoke-RestMethod -Method Post -Uri https://login.microsoftonline.com/$Tenant/oauth2/v2.0/token -Body $body
            $accessToken = $response.access_token
     
            $accessToken
            if ($version -eq 2) {
                write-host "Version 2 module detected"
                $accesstokenfinal = ConvertTo-SecureString -String $accessToken -AsPlainText -Force
            }
            else {
                write-host "Version 1 Module Detected"
                Select-MgProfile -Name Beta
                $accesstokenfinal = $accessToken
            }
            $graph = Connect-MgGraph  -AccessToken $accesstokenfinal 
            Write-Host "Connected to Intune tenant $TenantId using app-based authentication (Azure AD authentication not supported)"
        }
        else {
            if ($version -eq 2) {
                write-host "Version 2 module detected"
            }
            else {
                write-host "Version 1 Module Detected"
                Select-MgProfile -Name Beta
            }
            $graph = Connect-MgGraph -scopes $scopes
            Write-Host "Connected to Intune tenant $($graph.TenantId)"
        }
    }
}    

```

[!INCLUDE [More about Microsoft Graph PowerShell SDK](../../docfx/includes/MORE-GRAPHSDK.md)]

***

## Contributors

| Author(s)                                            |
|------------------------------------------------------|
| [Andrew Taylor](https://github.com/andrew-s-taylor) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/graph-connect-to-graph" aria-hidden="true" />
