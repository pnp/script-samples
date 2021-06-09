---
plugin: add-to-gallery
---

# Replace an owner in a Microsoft 365 Group or Microsoft Team

## Summary

Find all the Microsoft 365 Groups that a user is an Owner of and replace them with someone else useful for when an employee leaves and ownership needs to be updated.
 
![Example Screenshot](assets/example.png)
 
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


## Source Credit

Sample first appeared on [Replace an owner in a Microsoft 365 Group or Microsoft Team | CLI for Microsoft 365](https://pnp.github.io/cli-microsoft365/sample-scripts/aad/replace-owner-with-a-different-one/)

## Contributors

| Author(s) |
|-----------|
| Alan Eardley |
| Patrick Lamber |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/aad-replace-owner-with-a-different-one" aria-hidden="true" />