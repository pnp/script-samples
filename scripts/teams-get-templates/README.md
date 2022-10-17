---
plugin: add-to-gallery
---
      
# Get Teams Templates
![Outputs](assets/header.png)
## Summary

Get Teams Templates 
  
This script allow us to collect\export current tenant Teams Templates .  

The script uses Teams Native API  and is a subset of the SPO powershell packages with content (PnPCandy) concept already been used across many projects.  


Excelsior, hum? :P  

# [PnP PowerShell](#tab/pnpps)

```powershell

[CmdletBinding()]
param (
    [Parameter(Mandatory = $True)]
    [string]$Tenant ,
    [Parameter(Mandatory = $False)]
    [string]$StoredCredentials,
    [Parameter(Mandatory = $False)]
    [string]$TeamTemplateNameOrId,
    [Parameter(Mandatory = $False)]
    [string]$ExportPath = ".\"
)
begin {
    $ErrorActionPreference = "Stop"
    $defaultResource= "https://api.spaces.skype.com"
    $defaultAuthRedirect= "https://login.microsoftonline.com/common/oauth2/nativeclient"
    $defaultClientId= "1fec8e78-bce4-4aaf-ab1b-5451cc387264"

    function Write-Log($msg) {
        
        $message = "$($env:MainFunctionName)$($env:FunctionName) $msg"
        $message = $message.Trim()
        Write-Output $message
    }
    function ShowOAuthWindow {
        param (
            [string]$WindowTitle,
            ## Default value : resource for teams
            [string]$Resource = $defaultResource ,
            ## Default value : edirect for native teams app
            [string]$Auth_Redirect = $defaultAuthRedirect,
            [string]$ClientId = $defaultClientId,
            [string]$Tenant = $Tenant,
            [bool]$ForceMFA = $false
        )
        if ([String]::IsNullOrEmpty($Tenant)) {
            $Tenant = "common"
        }
        # Create the url
        $request_id = (New-Guid).ToString()
        $url = "https://login.microsoftonline.com/$Tenant/oauth2/authorize?resource=$Resource&client_id=$ClientId&response_type=code&haschrome=1&redirect_uri=$auth_redirect&client-request-id=$request_id&prompt=select_account&scope=openid profile"
        
        if ($ForceMFA) {
            $url += "&amr_values=mfa"
        }
        
        Add-Type -AssemblyName System.Windows.Forms
        $form = New-Object -TypeName System.Windows.Forms.Form -Property @{Width = 600; Height = 800 }
        $form.Text = $WindowTitle
        $web = New-Object -TypeName System.Windows.Forms.WebBrowser -Property @{Width = 580; Height = 780; Url = ($URL -f ($Scope -join "%20")) }
        $form.Controls.Add($web)

        $docComp = {
            $global:uri = $web.Url.AbsoluteUri
            $global:web = $web
            Write-Host  $web.Url
            if ($global:uri -match "error=[^&]*|access_token=[^&]*|id_token=[^&]*|code=[^&]*") { 
                Write-Host "close"
                $response = [Web.HttpUtility]::ParseQueryString($web.Url.Query)

                # Create a body for REST API request
                $body = @{
                    client_id    = $ClientId
                    grant_type   = "authorization_code"
                    code         = $response["code"]
                    redirect_uri = $Auth_Redirect
                }
                # Dispose the control
                $form.Controls[0].Dispose()
      
                # Set the content type and call the Microsoft Online authentication API
                $contentType = "application/x-www-form-urlencoded"
                $script:jsonResponse = Invoke-RestMethod -UseBasicParsing -Uri "https://login.microsoftonline.com/$Tenant/oauth2/token" -ContentType $contentType -Method POST -Body $body
                $form.Close() 
            }
        }
        $web.Add_DocumentCompleted($docComp)
        $form.Add_Shown( { $form.Activate() })
        $form.ShowDialog() | Out-Null
        #return tokens
        $script:jsonResponse
    }

    function Get-TenantId([string]$Tenant) {
        #Get TenantId !
        $obj = (Invoke-WebRequest https://login.windows.net/$Tenant/.well-known/openid-configuration | ConvertFrom-Json)
        $tenantId = $obj.token_endpoint.Split('/')[3]
        $tenantId
    }
    function Get-TeamsApiTokens([PSCredential] $Credentials, [string] $Tenant) {
        $tenantId = Get-TenantId -Tenant $Tenant
        if ($null -ne $Credentials) {
            #Access Token
            $p = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Credentials.Password))
            #Get access token
            $body = @{
                "resource"   = "https://api.spaces.skype.com" # resource
                "client_id"  = "1fec8e78-bce4-4aaf-ab1b-5451cc387264" # teams web app id
                "grant_type" = "password"
                "username"   = $Credentials.UserName #username
                "password"   = $p #clearpassword
                "scope"      = "user_impersonation" #scope
            }
            $url = "https://login.microsoftonline.com/%7B$tenantId%7D/oauth2/token"
            $regularTokens = Invoke-RestMethod -Uri $url -Body $body -Method Post 
        }
        else {
            $regularTokens = ShowOAuthWindow
        }
        # get Skype Token needed to access Teams Native API
        $regularHeadersAuth = @{
            "Authorization" = ("Bearer " + $regularTokens.access_token)
        }
        $url = "https://authsvc.teams.microsoft.com/v1.0/authz"
        $teamsTokens = Invoke-RestMethod -Uri $url -Headers $regularHeadersAuth  -Method Post 

        $skypeHeadersAuth = @{
            "Authorization" = ("Bearer " + $regularTokens.access_token)
            "x-skypetoken"  = $teamsTokens.tokens.skypeToken
        }

        $body = @{
            "grant_type"    = "refresh_token"
            "refresh_token" = $regularTokens.refresh_token
            "scope"         = "https://templates.teams.microsoft.com/.default"

        }
        $url = "https://login.microsoftonline.com/%7B$tenantId%7D/oauth2/v2.0/token"
        $templatesTokens = Invoke-RestMethod -Uri $url -Body $body -Headers $regularHeadersAuth  -Method Post 

        $templatesHeadersAuth = @{
            "Authorization" = ("Bearer " + $templatesTokens.access_token)
        }
        
        $mainTokens = [PSCustomObject]::new()
        $mainTokens | Add-Member -Name "requestTokens" -MemberType NoteProperty -Value $regularTokens
        $mainTokens | Add-Member -Name "teamsTokens" -MemberType NoteProperty -Value $teamsTokens
        $mainTokens | Add-Member -Name "templatesTokens" -MemberType NoteProperty -Value $templatesTokens
        $mainTokens.teamsTokens | Add-Member  -Name "headers" -MemberType NoteProperty -Value  $skypeHeadersAuth
        $mainTokens.templatesTokens | Add-Member  -Name "headers" -MemberType NoteProperty -Value  $templatesHeadersAuth
        $mainTokens
    }

    $msg = "`n`r`n`r

    █▀█ █▄░█ █▀█ █▀▀ ▄▀█ █▄░█ █▀▄ █▄█
    █▀▀ █░▀█ █▀▀ █▄▄ █▀█ █░▀█ █▄▀ ░█░  `n    MSTeamsToolSet: `n`r    Get MSTeams Teams Templates    `n`n    ...aka ... [teams-get-templates]
    `n"
    $msg += ('#' * 70) + "`n"
    Write-Output  $msg

    ## Validate if Tenant value is ok
    if ($Tenant -notmatch '.onmicrosoft.com') {
        $msg = "Provided Tenant is not valid. Please use the following format [Tenant].onmicrosoft.com. Example:pnpcady.onmicrosoft.com"
        throw $msg
    }
    
    ## Validate if StoredCredentials value is ok
    $creds = $null
    if (![String]::IsNullOrEmpty($StoredCredentials)) {
        $creds = Get-PnPStoredCredential -Name $StoredCredentials -ErrorAction SilentlyContinue
        if ($null -eq $creds) {
            $msg = "Provided credentials [$StoredCredentials] not found  `n`r"
            $msg += "You can use [Add-PnPStoredCredential] to adds a credential to the Windows Credential Manager `n`r"
            $msg += "Link [https://docs.microsoft.com/en-us/powershell/module/sharepoint-pnp/add-pnpstoredcredential?view=sharepoint-ps]`n`r"
            throw $msg
        }
    }
    $url = "https://" + $Tenant.ToLower().Replace(".onmicrosoft.com", ".sharepoint.com")

    Write-Log "Connecting to $Url"
}
process {
    Write-Log " Get Teams Tokens"
    $tokens = Get-TeamsApiTokens -Credentials $creds -Tenant $Tenant
    $headers = $tokens.templatesTokens.headers

    Write-Log " Get all Templates"
    $url = "https://teams.microsoft.com/fabric/emea/templates/api/teamtemplates/v1.0/en-us"
    $allTemplates = @((Invoke-RestMethod -Uri $url  -Headers $headers  -Method Get).value) 
    #Build token Object

    $templatesDefinitions = @();
    $allTemplates | ForEach-Object {
        $t = $_
        $t | Add-Member -Name "TeamDefinition"  -MemberType NoteProperty -Value ""
        $serviceUrl = $tokens.teamsTokens.regionGtms.teamsAndChannelsProvisioningService.replace("/api", "")
        $url = $serviceUrl + $t."@odata.id"
        $definition = @((Invoke-RestMethod -Uri $url  -Headers $headers  -Method Get).value) 
        $t.teamDefinition = $definition[0].teamDefinition
        $templatesDefinitions += $definition[0].teamDefinition
    }
    #CammelCase all Properties
    $templates = @();
    $allTemplates | ForEach-Object {
        $t = $_
        $newObj = [PSCustomObject]::new()
        $t | Get-Member -MemberType Properties | ForEach-Object {
            $obj = $_
            $name = ($_.Name.substring(0, 1).toupper() + $_.Name.substring(1, $_.Name.length - 1))
            
            $newObj | Add-Member -Name $name  -MemberType NoteProperty -Value  $t."$name"
        }
        $templates += $newObj
    }
    $allTemplates = $templates
    if (($null -ne $TeamTemplateNameOrId) -and ($TeamTemplateNameOrId -ne "")) {
        Write-Log " Get specific template [$TeamTemplateNameOrId]"  
        $allTemplates = $templates | Where-object { ($_.id -eq $TeamTemplateNameOrId) -or ($_.name -eq $TeamTemplateNameOrId) }
    }
    $allTemplates = $allTemplates | Select-Object Id, Name, Description, ShortDescription, ChannelCount, AppCount, IconUri, Scope, TeamDefinition, "@odata.id", ModifiedBy, ModifiedOn

    if ($null -ne $allTemplates) {
        Write-Log " [$($allTemplates.Length)] Templates(s) were found"
    }
    else {
        Write-Log " No Templates(s) were found"
    }
    $ExportPath = Resolve-Path $ExportPath
    
    $allTemplates |  Export-Csv -Path "$ExportPath\TeamsTemplates.csv" -Force -NoTypeInformation
    $templatesDefinitions |  Export-Csv -Path "$ExportPath\TeamsTemplatesDefinitions.csv" -Force -NoTypeInformation
    Write-Log  " Template(s) info exported at [$ExportPath] "
    $allTemplates | Format-Table
}
end{
    Write-Log  "All done."
}



```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Contributors

| Author(s) |
|-----------|
| Rodrigo Pinto |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/teams-get-templates" aria-hidden="true" />






