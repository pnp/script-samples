

# Replace an owner in a Microsoft 365 Group or Microsoft Team

## Summary

Find all the Microsoft 365 Groups that a user is an Owner of and replace them with someone else useful for when an employee leaves and ownership needs to be updated. 

# [PnP PowerShell](#tab/pnpps)

```powershell
$AdminCenterURL = "https://contoso-admin.sharepoint.com/"

$oldOwnerUPN = Read-Host "Enter the old owner UPN to be replaced with" #testUser1@contose.onmicrosoft.com
$newOwnerUPN = Read-Host "Enter the new owner UPN to replace with" #testuser2@contoso.onmicrosoft.com

#Connect to SharePoint Online admin center
Connect-PnPOnline -Url $AdminCenterURL -Interactive

$dateTime = (Get-Date).toString("dd-MM-yyyy")
$invocation = (Get-Variable MyInvocation).Value
$directorypath = Split-Path $invocation.MyCommand.Path
$fileName = "m365GroupOwnersReport-" + $dateTime + ".csv"
$OutPutView = $directorypath + "\Logs\"+ $fileName

#Array to Hold Result - PSObjects
$m365GroupCollection = @()

#Retrieve any m 365 group starting with Permission
$m365Groups = Get-PnPMicrosoft365Group | where-object {$_.DisplayName -like "Permission*"}

$m365Groups | ForEach-Object {
	$ExportVw = New-Object PSObject
	$ExportVw | Add-Member -MemberType NoteProperty -name "Group Name" -value $_.DisplayName
	$m365GroupOwnersName = "";
	
  	try
  	{
    	$oldOwner = Get-PnPMicrosoft365GroupOwners  -Identity $_.GroupId | where-object {$_.Email -eq $oldOwnerUPN}

    	if($oldOwner)
    	{
			#Replace old owner with new owner
			Remove-PnPMicrosoft365GroupOwner -Identity $_.GroupId -Users $oldOwner.Email;
			Add-PnPMicrosoft365GroupOwner -Identity $_.GroupId -Users $newOwnerUPN;
    	}
  	}
  	catch
  	{
    	write-host $("Error occured to update group " + $_.DisplayName + $Error)
  	}

  	#For auditing purposes - get owners of the group
  	$m365GroupOwnersName = (Get-PnPMicrosoft365GroupOwners  -Identity $_.GroupId | select -ExpandProperty DisplayName) -join ";";

	$ExportVw | Add-Member -MemberType NoteProperty -name " Group Owners" -value $m365GroupOwnersName
	$m365GroupCollection += $ExportVw
}

#Export the result Array to CSV file
$m365GroupCollection | sort "Group Name" |Export-CSV $OutPutView -Force -NoTypeInformation

# Disconnect PnP online connection
Disconnect-PnPOnline
```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365](#tab/cli-m365-ps)

```powershell
$oldOwnerUPN = Read-Host "Enter the old owner UPN to be replaced with" #testUser1@contose.onmicrosoft.com
$newOwnerUPN = Read-Host "Enter the new owner UPN to replace with" #testuser2@contoso.onmicrosoft.com

#Get Credentials to connect
$m365Status = m365 status
if ($m365Status -match "Logged Out") {
    m365 login
}

$dateTime = (Get-Date).toString("dd-MM-yyyy")
$invocation = (Get-Variable MyInvocation).Value
$directorypath = Split-Path $invocation.MyCommand.Path
$fileName = "m365GroupOwnersReport-" + $dateTime + ".csv"
$OutPutView = $directorypath + "\Logs\"+ $fileName

#Array to Hold Result - PSObjects
$m365GroupCollection = @()

#Retrieve any M365 group starting with "Permission" (you can use filter as per your requirements)
$m365Groups = m365 entra m365group list --displayName Permission | ConvertFrom-Json

$m365Groups | ForEach-Object {
	$ExportVw = New-Object PSObject
	$ExportVw | Add-Member -MemberType NoteProperty -name "Group Name" -value $_.displayName
	$m365GroupOwnersName = "";
	
	try
	{
		#Check if old user is an owner of the group
		$oldOwner = m365 entra m365group user list --groupId $_.id --role Owner --filter "userPrincipalName eq '$($oldOwnerUPN)'"

		if($oldOwner)
		{
			#Add new user as an owner of the group
			m365 entra m365group user add --groupId $_.id --userName $newOwnerUPN --role Owner
			
			#Remove old user from the group
			m365 entra m365group user remove --groupId $_.id --userName $oldOwnerUPN --force
		}
	}
	catch
	{
		write-host $("Error occured while updating the group " + $_.displayName + $Error)
	}
	
	#For auditing purposes - get owners of the group
	$m365GroupOwnersName = (m365 entra m365group user list --groupId $_.id --role Owner | ConvertFrom-Json | select -ExpandProperty displayName) -join ";";

	$ExportVw | Add-Member -MemberType NoteProperty -name " Group Owners" -value $m365GroupOwnersName
	$m365GroupCollection += $ExportVw
}

#Export the result Array to CSV file
$m365GroupCollection | sort "Group Name" |Export-CSV $OutPutView -Force -NoTypeInformation

#Disconnect online connection
m365 logout
```

[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

***

## Contributors

| Author(s) |
|-----------|
| Reshmee Auckloo |
| [Ganesh Sanap](https://ganeshsanapblogs.wordpress.com/) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/aad-replace-owner-with-a-different-one" aria-hidden="true" />
