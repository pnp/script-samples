---
plugin: add-to-gallery
---

# List all teams and teams members in Microsoft Teams in the tenant

List all teams and teams members in Microsoft Teams in the tenant and exports the results in a CSV.
 
# [PnP PowerShell](#tab/pnpps)
```powershell
$adminSiteURL = "https://domain-admin.sharepoint.com/"
$userName = "user@domain.onmicrosoft.com"
$password = "********"
$secureStringPwd = $password | ConvertTo-SecureString -AsPlainText -Force 
$creds = New-Object System.Management.Automation.PSCredential -ArgumentList $userName, $secureStringPwd
$dateTime = "_{0:MM_dd_yy}_{0:HH_mm_ss}" -f (Get-Date)
$basePath = "E:\Contribution\PnP-Scripts\TeamsInformation\Logs\"
$csvPath = $basePath + "\TeamReports" + $dateTime + ".csv"
$global:TeamReports = @()
$siteURL = "https://domain.sharepoint.com/"

Function Login() {
    [cmdletbinding()]
    param([parameter(Mandatory = $true, ValueFromPipeline = $true)] $creds)
 
    #connect to O365 admin site
    Write-Host "Connecting to Tenant Admin Site '$($adminSiteURL)'" -f Yellow 
  
    Connect-PnPOnline -Url $adminSiteURL -Credentials $creds
    Write-Host "Connecting successfully!..." -f Green 
}
Function GetTeamsInformation {
    try {
        Write-Host "Getting teams information..."  -ForegroundColor Yellow
        #get teams information    
        $teams = Get-PnPTeamsTeam 

        Write-Host "Getting teams information successfully!"  -ForegroundColor Green
        try {
            Write-Host "Getting teams user information..."  -ForegroundColor Yellow 	 
            foreach ($team in $teams) { 
                #get users as per teams  			
                $teamsUsers = Get-PnPTeamsUser -Team $team.DisplayName  
               
                foreach ($teamsUser in $teamsUsers) {
                    $global:TeamReports += New-Object PSObject -Property ([ordered]@{  
                            'Team ID'                           = $team.GroupId
                            'Team MailNickname'                 = $team.MailNickname              
                            'Team Name'                         = $team.DisplayName 
                            'Team Description'                  = $team.Description
                            'Team GroupId'                      = $team.GroupId   
                            'Team Allow Create Update Channels' = $team.GuestSettings.AllowCreateUpdateChannels   
                            'Team Allow Delete Channels'        = $team.GuestSettings.AllowDeleteChannels               
                            'Team Visibility'                   = $team.Visibility
                            'User Id'                           = $teamsUser.Id 
                            'User Email'                        = $teamsUser.UserPrincipalName 
                            'User Name'                         = $teamsUser.DisplayName
                            'User Type'                         = $teamsUser.UserType                                      
                        })
                } 
            } 
            Write-Host "Getting teams user information successfully!"  -ForegroundColor Green	 						
        } 
        catch {
            Write-Host "Error in getting teams user information:" $_.Exception.Message -ForegroundColor Red                 
        } 
    }	 
    catch {
        Write-Host "Error in getting teams information:" $_.Exception.Message -ForegroundColor Red                 
    }  	
    Write-Host "Exporting to CSV..."  -ForegroundColor Yellow 
    $global:TeamReports | Export-Csv $csvPath -NoTypeInformation -Append
    Write-Host "Exported to CSV successfully!"  -ForegroundColor Green	 
}

Function StartProcessing {
    Login($creds); 
    GetTeamsInformation         
}

StartProcessing
```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365](#tab/cli-m365-ps)
```powershell
$adminSiteURL = "https://domain-admin.sharepoint.com/"
$userName = "user@domain.onmicrosoft.com"
$password = "********"
$secureStringPwd = $password | ConvertTo-SecureString -AsPlainText -Force 
$creds = New-Object System.Management.Automation.PSCredential -ArgumentList $userName, $secureStringPwd
$dateTime = "_{0:MM_dd_yy}_{0:HH_mm_ss}" -f (Get-Date)
$basePath = "E:\Contribution\PnP-Scripts\TeamsInformation\Logs\"
$csvPath = $basePath + "\TeamReportsM365" + $dateTime + ".csv"
$global:TeamReports = @()
$siteURL = "https://domain.sharepoint.com/"

Function Login
{
    Write-Host "Connecting to Tenant Admin Site '$($adminSiteURL)'" -f Yellow   
    $m365Status = m365 status
    if ($m365Status -match "Logged Out") {
        m365 login
    }
    Write-Host "Connecting successfully!..." -f Green
}


Function GetTeamsInformation {
    try {
        Write-Host "Getting teams information..."  -ForegroundColor Yellow
        #get teams information    
        $teams = m365 teams team list -o json | ConvertFrom-Json 
        Write-Host "Getting teams information successfully!"  -ForegroundColor Green
        try {
            Write-Host "Getting teams user information..."  -ForegroundColor Yellow 	 
            foreach ($team in $teams) { 
                #get users as per teams  			
                $teamsUsers = m365 teams user list --teamId $team.id -o 'json' | ConvertFrom-Json 
               
                foreach ($teamsUser in $teamsUsers) {
                    $global:TeamReports += New-Object PSObject -Property ([ordered]@{  
                            'Team ID'                           = $team.id
                            'Team MailNickname'                 = $team.MailNickname              
                            'Team Name'                         = $team.displayName 
                            'Team Description'                  = $team.description                              
                            'User Id'                           = $teamsUser.id 
                            'User Email'                        = $teamsUser.userPrincipalName 
                            'User Name'                         = $teamsUser.displayName
                            'User Type'                         = $teamsUser.userType                                      
                        })
                } 
            } 
            Write-Host "Getting teams user information successfully!"  -ForegroundColor Green	 						
        } 
        catch {
            Write-Host "Error in getting teams user information:" $_.Exception.Message -ForegroundColor Red                 
        } 
    }	 
    catch {
        Write-Host "Error in getting teams information:" $_.Exception.Message -ForegroundColor Red                 
    }  	
    Write-Host "Exporting to CSV..."  -ForegroundColor Yellow 
    $global:TeamReports | Export-Csv $csvPath -NoTypeInformation -Append
    Write-Host "Exported to CSV successfully!"  -ForegroundColor Green	 
}

Function StartProcessing {
    Login($creds); 
    GetTeamsInformation         
}

StartProcessing
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

***
## Contributors

| Author(s) |
|-----------|
| Chandani Prajapati |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/teams-teams-export-teams-information" aria-hidden="true" />
