---
plugin: add-to-gallery
---

# Get SharePoint List Or Library Permissions And Export It To CSV

## Summary

Many times we have requirements like get any specific list/library permissions and Export to CSV.

## Implementation

- Open Windows PowerShell ISE
- Create a new file
- Write a script as below,
- First, we will connect to Tenant admin site.
    - Then we will Read site URL from user and connect to the Site.
	- then we will Read list/library title from user and get list information.
    - And then we will export it to CSV with some specific information.
 
# [PnP PowerShell](#tab/pnpps)
```powershell

$adminSiteURL = "https://domain-admin.sharepoint.com/"
$username = "user@domain.onmicrosoft.com"
$password = "********"
$secureStringPwd = $password | ConvertTo-SecureString -AsPlainText -Force 
$Creds = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secureStringPwd
$global:permissions = @()
$BasePath = "E:\Contribution\PnP-Scripts\ListOrLibraryPermission\"
$DateTime = "{0:MM_dd_yy}_{0:HH_mm_ss}" -f (Get-Date)
$CSVPath = $BasePath + "\permissions" + $DateTime + ".csv"

Function Login() {
    [cmdletbinding()]
    param([parameter(Mandatory = $true, ValueFromPipeline = $true)] $Creds)     
    Write-Host "Connecting to Tenant Admin Site '$($adminSiteURL)'" -f Yellow 
    Connect-PnPOnline -Url $adminSiteURL -Credentials $Creds
    Write-Host "Connection Successfull" -f Green 
}

#Login to SharePoint Site
Function ConnectToSPSite() {
    try {
        $SiteUrl = Read-Host "Please enter SiteURL"
        if ($SiteUrl) {
            Write-Host "Connecting to Site :'$($SiteUrl)'..." -ForegroundColor Yellow  
            Connect-PnPOnline -Url $SiteUrl -Credentials $Creds
            Write-Host "Connection Successfull to site: '$($SiteUrl)'" -ForegroundColor Green              
            GetPermissions
        }
        else {
            Write-Host "Site URL is empty" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Error in connecting to Site:'$($SiteUrl)'" $_.Exception.Message -ForegroundColor Red               
    } 
}

#Connect to list and get permissions
Function GetPermissions() {
    try {
        $ListName = Read-Host "Please enter list title"
        if ($ListName) {
            Write-Host "Connecting to List :'$($ListName)'..." -ForegroundColor Yellow  
            $List = Get-PnpList -Identity $ListName -Includes RoleAssignments

            Get-PnPProperty -ClientObject $List -Property HasUniqueRoleAssignments, RoleAssignments      
            $HasUniquePermissions = $List.HasUniqueRoleAssignments
            
            Write-Host "Getting permission for the List :'$($ListName)'..." -ForegroundColor Yellow  

            Foreach ($RoleAssignment in $List.RoleAssignments) {                
                Get-PnPProperty -ClientObject $RoleAssignment -Property RoleDefinitionBindings, Member
                  
                $PermissionType = $RoleAssignment.Member.PrincipalType
                     
                $PermissionLevels = $RoleAssignment.RoleDefinitionBindings | Select -ExpandProperty Name
                
                If ($PermissionLevels.Length -eq 0) { Continue } 

                If ($PermissionType -eq "SharePointGroup") {
                    
                    $GroupMembers = Get-PnPGroupMembers -Identity $RoleAssignment.Member.LoginName                                  
                    If ($GroupMembers.count -eq 0) { Continue }
                    ForEach ($User in $GroupMembers) {
                        $global:permissions += New-Object PSObject -Property ([ordered]@{
                                Title                = $User.Title 
                                PermissionType       = $PermissionType
                                PermissionLevels     = $PermissionLevels -join ","
                                Member               = $RoleAssignment.Member.Title     
                                HasUniquePermissions = $HasUniquePermissions                                     
                            })  
                    }
                }                        
                Else {                                        
                    $global:permissions += New-Object PSObject -Property ([ordered]@{
                            Title                = $RoleAssignment.Member.Title 
                            PermissionType       = $PermissionType
                            PermissionLevels     = $PermissionLevels -join ","
                            Member               = "Direct Permission"      
                            HasUniquePermissions = $HasUniquePermissions                             
                        })  
                }                            
            }   
            Write-Host "Getting permission successfully!" -ForegroundColor Green                         
            BindingtoCSV($global:permissions)
        }
        else {
            Write-Host "list title is empty" -ForegroundColor Red
        }
        $global:permissions = @()
    }
    catch {
        Write-Host "Error in getting list:'$($ListName)'" $_.Exception.Message -ForegroundColor Red               
    } 
}

Function BindingtoCSV {
    [cmdletbinding()]
    param([parameter(Mandatory = $true, ValueFromPipeline = $true)] $Global)   
    $global:permissions | Export-Csv $CSVPath -NoTypeInformation -Append
    Write-Host "Exported successfully" -ForegroundColor Green
}

Function StartProcessing {
    Login($Creds);   
    ConnectToSPSite 
}

StartProcessing

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365](#tab/cli-m365-ps)
```powershell
# Usage example:
# .\Exoprt-ListLibraryPermissions.ps1 -WebUrl "https://contoso.sharepoint.com/sites/Intranet" -ListName "Demo List"

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, HelpMessage = "Please enter Site URL, e.g. https://contoso.sharepoint.com/sites/Intranet")]
    [string]$WebUrl,
    [Parameter(Mandatory = $true, HelpMessage = "Please enter list title")]
    [string]$ListName
)
begin {
    #Log in to Microsoft 365
    Write-Host "Connecting to Tenant" -f Yellow

    $m365Status = m365 status
    if ($m365Status -match "Logged Out") {
        m365 login
    }

    Write-Host "Connection Successful!" -f Green 
}
process {
    $listPermissions = @()
    $dateTime = "{0:MM_dd_yy}_{0:HH_mm_ss}" -f (Get-Date)
    $csvPath = "$($ListName -replace '\s','_')-permissions-" + $dateTime + ".csv"

    # Gets information about the specific list
    $listInfo = m365 spo list get --webUrl $WebUrl --title $ListName --withPermissions | ConvertFrom-Json

    # Check if list has unique role permissions
    $hasUniquePermissions = $listInfo.HasUniqueRoleAssignments

    ForEach ($roleAssignment in $listInfo.RoleAssignments) {
        $permissionType = $roleAssignment.Member.PrincipalType
        $permissionLevels = $RoleAssignment.RoleDefinitionBindings | Select-Object -ExpandProperty Name

        If ($permissionType -eq 8) {
            # Get members of a SharePoint Group
            $groupMembers = m365 spo group user list --webUrl $WebUrl --groupName $roleAssignment.Member.LoginName | ConvertFrom-Json

            ForEach ($user in $groupMembers.value) {
                Write-Host "$($user.Title) have $($permissionLevels -join ",") permission(s) as part of group $($roleAssignment.Member.LoginName)"
                $listPermissions += New-Object PSObject -Property ([ordered]@{
                        Title                = $user.Title 
                        PermissionType       = "SharePoint Group"
                        PermissionLevels     = $permissionLevels -join ","
                        Member               = $roleAssignment.Member.Title     
                        HasUniquePermissions = $hasUniquePermissions                                     
                    })  
            }
        }
        Else {
            Write-Host "$($user.Title) have $($permissionLevels -join ",") permission(s) as direct permission"
            $listPermissions += New-Object PSObject -Property ([ordered]@{
                    Title                = $roleAssignment.Member.Title 
                    PermissionType       = "User"
                    PermissionLevels     = $permissionLevels -join ","
                    Member               = "Direct Permission"      
                    HasUniquePermissions = $hasUniquePermissions                             
                }) 
        }
    }

    Write-Host "Exporting the permissions to CSV..."
    $listPermissions | Export-Csv $csvPath -NoTypeInformation -Append
}
end { 
    Write-Host "Finished"
}
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
***


## Contributors

| Author(s) |
|-----------|
| Chandani Prajapati |
| [Nanddeep Nachan](https://github.com/nanddeepn) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-get-list-library-permission-export-to-csv" aria-hidden="true" />
