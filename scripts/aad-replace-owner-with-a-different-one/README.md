---
plugin: add-to-gallery
---

# Replace an owner in a Microsoft 365 Group or Microsoft Team

## Summary

Find all the Microsoft 365 Groups that a user is an Owner of and replace them with someone else useful for when an employee leaves and ownership needs to be updated.
 
# [CLI for Microsoft 365 with PowerShell](#tab/cli-m365-ps)
```powershell
# This script replaces an owner with a different person in all Microsoft 365 Groups
$oldUser = "oldUserUpn"
$newUser = "newUserUpn"
# Parameters end

$m365Status = m365 status

if ($m365Status -eq "Logged Out") {
  # Connection to Microsoft 365
  m365 login
}

# configure the CLI to output JSON on each execution
m365 cli config set --key output --value json
m365 cli config set --key errorOutput --value stdout
m365 cli config set --key showHelpOnFailure --value false
m365 cli config set --key printErrorsAsPlainText --value false

function Get-CLIValue {
  [cmdletbinding()]
  param(
    [parameter(Mandatory = $true, ValueFromPipeline = $true)]
    $input
  )
    $output = $input | ConvertFrom-Json
    if ($output.error -ne $null) {
      throw $output.error
    }
    return $output
}

function Replace-Owner {
    [cmdletbinding()]
    param(
        [parameter(Mandatory = $true)]
        $oldUser,
        [parameter(Mandatory = $true)]
        $newUser
    )
    $groupsToProcess = m365 aad o365group list | Get-CLIValue  
    $i = 0
    $groupsToProcess | ForEach-Object {
        $group = $_
        $i++
        Write-Host "Processing Group ($($group.id)) - $($group.displayName) - ($i/$($groupsToProcess.Length))" -ForegroundColor DarkGray
 
        $hasOwner = $null
        # verify if the old user is in the owners list
        $hasOwner = m365 aad o365group user list --groupId $group.id --query "[?userType=='Owner' && userPrincipalName=='$oldUser'].[id]" | Get-CLIValue
        if ($hasOwner -ne $null) {
            Write-Host "Found $oldUser" -ForegroundColor Green
            try {
                Write-Host "Granting $newUser owner rights"
                m365 aad o365group user add --groupId $group.id --userName $newUser --role Owner | Get-CLIValue
            }
            catch  {
                Write-Host $_.Exception.Message -ForegroundColor White
            }

            try {
                Write-Host "Removing $oldUser permissions..."
                m365 aad o365group user remove --groupId $group.id --userName $oldUser --confirm $false | Get-CLIValue
            }
            catch  {
                Write-Host $_.Exception.Message -ForegroundColor Red
                continue
            }
        }
    }
}

Replace-Owner $oldUser $newUser
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

# [PnP PowerShell](#tab/pnpps)
```powershell
$AdminCenterURL="https://contoso-admin.sharepoint.com/"
$oldOwnerUPN = Read-Host "Enter the old owner UPN to be replaced with" #testUser1@contose.onmicrosoft.com
$newOwnerUPN = Read-Host "Enter the new owner UPN to  replace with" #testuser2@contoso.onmicrosoft.com
#Connect to SharePoint Online admin centre
Connect-PnPOnline -Url $AdminCenterURL -Interactive

$dateTime = (Get-Date).toString("dd-MM-yyyy")
$invocation = (Get-Variable MyInvocation).Value
$directorypath = Split-Path $invocation.MyCommand.Path
$fileName = "m365GroupOwnersReport-" + $dateTime + ".csv"
$OutPutView = $directorypath + "\Logs\"+ $fileName

#Array to Hold Result - PSObjects

$m365GroupCollection = @()
#retrieve any m 365 group starting with Permission
$m365Groups = Get-PnPMicrosoft365Group | where-object {$_.DisplayName -like "Permission*"}
$m365Groups | ForEach-Object{
$ExportVw = New-Object PSObject
$ExportVw | Add-Member -MemberType NoteProperty -name "Group Name" -value $_.DisplayName
$m365GroupOwnersName="";
 try
  {
   $oldOwner = Get-PnPMicrosoft365GroupOwners  -Identity $_.GroupId | where-object {$_.Email -eq $oldOwnerUPN}

   if($oldOwner)
   {
    #replace old owner with new owner
    Remove-PnPMicrosoft365GroupOwner -Identity $_.GroupId -Users $oldOwner.Email;
    Add-PnPMicrosoft365GroupOwner -Identity $_.GroupId -Users $newOwnerUPN;
   }
 }
catch
  {
  write-host $("Error occured to update group " + $_.DisplayName + $Error)
  }

 #for auditing purposes
 $m365GroupOwnersName = (Get-PnPMicrosoft365GroupOwners  -Identity $_.GroupId | select -ExpandProperty DisplayName) -join ";";

 $ExportVw | Add-Member -MemberType NoteProperty -name " Group Owners" -value $m365GroupOwnersName
 $m365GroupCollection += $ExportVw
}

#Export the result Array to CSV file
$m365GroupCollection | sort "Group Name" |Export-CSV $OutPutView -Force -NoTypeInformation
Disconnect-PnPOnline
```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Source Credit

Sample first appeared on [Replace an owner in a Microsoft 365 Group or Microsoft Team | CLI for Microsoft 365](https://pnp.github.io/cli-microsoft365/sample-scripts/aad/replace-owner-with-a-different-one/)

## Contributors

| Author(s) |
|-----------|
| Alan Eardley |
| Patrick Lamber |
| Reshmee Auckloo |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/aad-replace-owner-with-a-different-one" aria-hidden="true" />
