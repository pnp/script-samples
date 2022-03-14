---
plugin: add-to-gallery
---
     
# Export a csv report on all Whiteboards

## Summary

Export a report on all Whiteboard owners and it's usage.
This script allow us to export a list of all Whiteboards created in our tenant and it's owner.

> [!Warning]
> The data returned is precalculated and therefore not realtime. Results are precalculated approximately every two weeks.

The script exports Geography, Owner ID, Owner UPN, Owner Name, Whiteboard ID, Title, Is Shared, Created, Modified as follows.

![Sample Output file Screenshot](assets/sample-output.png)

## Prerequisites

This script uses [MicrosoftWhiteboardAdmin](https://docs.microsoft.com/en-us/powershell/module/whiteboard/) PowerShell module.

Install the module by running below cmdlet.

```powershell
Install-Module -Name WhiteboardAdmin
```

You may need to update your execution policy by running below cmdlet.

```powershell
Set-ExecutionPolicy RemoteSigned
```

To get the owner details, this script uses [MSOnline](https://www.powershellgallery.com/packages/MSOnline/) PowerShell module.

```powershell
Install-Module -Name MSOnline
```

# [Microsoft Whiteboard Admin](#tab/whiteboard)

```powershell
# Import modules
Import-Module WhiteboardAdmin
Import-Module MSOnline

try {
	$dateTime = (Get-Date).toString("dd-MM-yyyy")
	$invocation = (Get-Variable MyInvocation).Value
	$directoryPath = Split-Path $invocation.MyCommand.Path
	$fileName = "WhiteboardReport-" + $dateTime + ".csv"
	$outputView = $directoryPath + "\" + $fileName
	
	# Connect to Azure AD
	$Msolcred = Get-credential
	Connect-MsolService -Credential $MsolCred

	# The geography to look for board owners in. Accepted values are: Europe, Australia, or Worldwide (all boards not in australia or europe).
	$supportedGeographies = @("Europe", "Australia", "Worldwide")
	
	# Array to hold Whiteboard owners
	$whiteboardOwners = @()
	
	foreach ($geography in $supportedGeographies) {
		Write-Host "Getting Whiteboard owners for geography: $($geography) ..."
		$geographyOwners = Get-WhiteboardOwners -Geography $geography		
		
		foreach ($geographyOwner in $geographyOwners.items) {			
			$exportOwner = New-Object PSObject
			$exportOwner | Add-Member -MemberType NoteProperty -name "Geography" -value $geography
			$exportOwner | Add-Member -MemberType NoteProperty -name "OwnerID" -value $geographyOwner
			
			try {
				$ownerInfo = Get-MsolUser -ObjectId $geographyOwner
				if ($ownerInfo) {
					$exportOwner | Add-Member -MemberType NoteProperty -name "OwnerUPN" -value $ownerInfo.UserPrincipalName
					$exportOwner | Add-Member -MemberType NoteProperty -name "OwnerDisplayName" -value $ownerInfo.DisplayName
				}
			}
			catch {
				write-host -f Red "Error:" $_.Exception.Message
			}
				
			$whiteboardOwners += $exportOwner
		}
		
		Write-Host "Found $($geographyOwners.items.Count) Whiteboard owners."
	}
	
	# Array to hold Whiteboard details
	$whiteboards = @()
	
	# Get whiteboards from the Microsoft Whiteboard service by owners
	foreach ($whiteboardOwner in $whiteboardOwners) {
		Write-Host "Getting Whiteboards for owner: $($whiteboardOwner.OwnerUPN) ..."
		$whiteboardInfo = Get-Whiteboard -UserId $whiteboardOwner.OwnerID
		
		foreach ($whiteboardInstance in $whiteboardInfo) {
			$exportWhiteboard = New-Object PSObject
			$exportWhiteboard | Add-Member -MemberType NoteProperty -name "Geography" -value $whiteboardOwner.Geography
			$exportWhiteboard | Add-Member -MemberType NoteProperty -name "Owner ID" -value $whiteboardOwner.OwnerID
			$exportWhiteboard | Add-Member -MemberType NoteProperty -name "Owner UPN" -value $whiteboardOwner.OwnerUPN
			$exportWhiteboard | Add-Member -MemberType NoteProperty -name "Owner Name" -value $whiteboardOwner.OwnerDisplayName
			$exportWhiteboard | Add-Member -MemberType NoteProperty -name "Whiteboard ID" -value $whiteboardInstance.id
			$exportWhiteboard | Add-Member -MemberType NoteProperty -name "Title" -value $whiteboardInstance.title
			$exportWhiteboard | Add-Member -MemberType NoteProperty -name "Is Shared" -value $whiteboardInstance.isShared
			$exportWhiteboard | Add-Member -MemberType NoteProperty -name "Created" -value $whiteboardInstance.createdTime
			$exportWhiteboard | Add-Member -MemberType NoteProperty -name "Modified" -value $whiteboardInstance.lastModifiedTime
			
			$whiteboards += $exportWhiteboard
		}
		
		Write-Host "Found $($whiteboards.Count) Whiteboards owned by: $($whiteboardOwner.OwnerUPN)"
	}
	
	Write-Host "Found $($whiteboards.Count) Whiteboards in a tenant."

	# Export the result Array to CSV file
	$whiteboards | sort "Geography" | Export-CSV -Path $outputView -Force -NoTypeInformation
	
	Write-Host "Finished"
}
catch {
    Write-Host -f Red "Error:" $_.Exception.Message
}
```
[!INCLUDE [More about Microsoft Whiteboard Admin](../../docfx/includes/MORE-WHITEBOARD.md)]
***

## Contributors

| Author(s) |
|-----------|
| Nanddeep Nachan |
| Smita Nachan |

# Alternative approach

[Reporting Whiteboards with PowerShell with Graph PowerShell - Whiteboard Nears End of Transition to OneDrive | Office IT Pros ](https://office365itpros.com/2022/03/10/whiteboard-transition-ending/)

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/whiteboard-report-usage" aria-hidden="true" />
