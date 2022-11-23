---
plugin: add-to-gallery
---

# Replace an owner in a Microsoft 365 Group or Microsoft Team

## Summary

Find all the Microsoft 365 Groups that a user is an Owner of and replace them with someone else useful for when an employee leaves and ownership needs to be updated.
 

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

## Contributors

| Author(s) |
|-----------|
| Reshmee Auckloo |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/aad-replace-owner-with-a-different-one" aria-hidden="true" />
