---
plugin: add-to-gallery
---

# Get SharePoint Site Collection and their Subwebs Permissions And Export It To CSV

## Summary

Sometimes we have requirement like get User Permissions Audit Report for a Site Collection with their all SubWebs.

## Implementation

- Open Windows PowerShell ISE
- Create a new file
- Write a script as below,
- First, we will Read site URL from user and connect to the Site
	- then we will get all subwebs for the site collcetion.
    - And then we will get all the permissions for site collection and subwebs.
    - Then we will export an object to CSV.
 
# [PnP PowerShell](#tab/pnpps)
```powershell

$username = "chandani@domain.onmicrosoft.com"
$password = "********"
$secureStringPwd = $password | ConvertTo-SecureString -AsPlainText -Force 
$Creds = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secureStringPwd
$global:permissions = @()
$BasePath = "E:\Contribution\PnP-Scripts\SitePermission\"
$DateTime = "{0:MM_dd_yy}_{0:HH_mm_ss}" -f (Get-Date)
$CSVPath = $BasePath + "\sitepermissions" + $DateTime + ".csv"

Function ConnectToSPSite() {
    try {
        $SiteUrl = Read-Host "Please enter Site URL"
        if ($SiteUrl) {
            Write-Host "Connecting to Site :'$($SiteUrl)'..." -ForegroundColor Yellow  
            Connect-PnPOnline -Url $SiteUrl -Credentials $Creds
            Write-Host "Connection Successfull to site: '$($SiteUrl)'" -ForegroundColor Green              
            WebPermission
        }
        else {
            Write-Host "Site URL is empty." -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Error in connecting to Site:'$($SiteUrl)'" $_.Exception.Message -ForegroundColor Red               
    } 
}

Function WebPermission {
    try {
        $Web = Get-PnPWeb -Includes RoleAssignments
        CheckPermission $Web    
        SubWebPermission        
    }
    catch {
        Write-Host "Error in getting web:" $_.Exception.Message -ForegroundColor Red               
    } 
}

Function CheckPermission ($obj) {
    try {
        Write-Host "Getting permission for the :'$($obj.Url)'..." -ForegroundColor Yellow
        Get-PnPProperty -ClientObject $obj -Property HasUniqueRoleAssignments, RoleAssignments      
        $HasUniquePermissions = $obj.HasUniqueRoleAssignments
   
        Foreach ($RoleAssignment in $obj.RoleAssignments) {                
            Get-PnPProperty -ClientObject $RoleAssignment -Property RoleDefinitionBindings, Member
                  
            $PermissionType = $RoleAssignment.Member.PrincipalType
                     
            $PermissionLevels = $RoleAssignment.RoleDefinitionBindings | Select -ExpandProperty Name
                
            If ($PermissionLevels.Length -eq 0) { Continue } 

            If ($PermissionType -eq "SharePointGroup") {
                    
                $GroupMembers = Get-PnPGroupMembers -Identity $RoleAssignment.Member.LoginName                                  
                If ($GroupMembers.count -eq 0) { Continue }
                ForEach ($User in $GroupMembers) {
                    $global:permissions += New-Object PSObject -Property ([ordered]@{
                            'Site URL'           = $obj.Url
                            'Site Title'         = $obj.Title
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
                        'Site URL'           = $obj.Url
                        'Site Title'         = $obj.Title
                        Title                = $RoleAssignment.Member.Title 
                        PermissionType       = $PermissionType
                        PermissionLevels     = $PermissionLevels -join ","
                        Member               = "Direct Permission"      
                        HasUniquePermissions = $HasUniquePermissions                             
                    })  
            }                            
        }                                  
        BindingtoCSV($global:permissions)
        $global:permissions = @()
        Write-Host "Getting permission successfully for the :'$($obj.Url)'..." -ForegroundColor Green
    }
    catch {
        Write-Host "Error in checking permission" $_.Exception.Message -ForegroundColor Red               
    } 
}

Function SubWebPermission {
    try {    
        $subwebs = Get-PnPSubWebs -Recurse  
        foreach ($subweb in $subwebs) { 
            Write-Host "Connecting to Subweb :'$($subweb.Url)'..." -ForegroundColor Yellow
            Connect-PnPOnline -Url $subweb.Url -Credentials $Creds
            Write-Host "Connection successfully to Subweb :'$($subweb.Url)'..." -ForegroundColor Green
            CheckPermission $subweb
        } 
    }
    catch {
        Write-Host "Error in connecting to sub web" $_.Exception.Message -ForegroundColor Red               
    } 
}

Function BindingtoCSV {
    [cmdletbinding()]
    param([parameter(Mandatory = $true, ValueFromPipeline = $true)] $Global)       
    $global:permissions | Export-Csv $CSVPath -NoTypeInformation -Append            
}

ConnectToSPSite

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***


## Contributors

| Author(s) |
|-----------|
| Chandani Prajapati |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-export-sitecollection-permission-with-subwebs" aria-hidden="true" />
