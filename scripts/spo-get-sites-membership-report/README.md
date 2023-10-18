---
plugin: add-to-gallery
---

# Get membership report of site(s) within tenant

## Summary

The scripts get membership permission report of site(s) within tenant and export it to a CSV file. The report retrieves
-  Site Admins
-  m365 Group Owners
-  m365 Group Members
-  m365 Group Guests
-  Site Owners
-  Site Members
-  Site Visitors

![PnP Powershell result](assets/preview.png)

# [PnP PowerShell](#tab/pnpps)
```powershell
$AdminCenterURL="https://contoso-admin.sharepoint.com/"# Connect to SharePoint Online admin center
Connect-PnPOnline -Url $AdminCenterURL -Interactive
$dateTime = (Get-Date).toString("dd-MM-yyyy")
$invocation = (Get-Variable MyInvocation).Value
$directorypath = Split-Path $invocation.MyCommand.Path
$fileName = "m365GroupUsersReport-" + $dateTime + ".csv"
$OutPutView = $directorypath + "\Logs\"+ $fileName
# Array to Hold Result - PSObjects
$m365GroupCollection = @()
#Amend query to retrieve the sites within tenant
$m365Sites = Get-PnPTenantSite -Detailed | Where-Object {($_.Url -like '*/Dev-*' -or  $_.Url -like '*/Test-*' -or  $_.Url -like '*/Uat-*' -or $_.Template -eq 'TEAMCHANNEL#1') -and $_.Template -ne 'RedirectSite#0' }

$m365Sites | ForEach-Object {
    $ExportVw = New-Object PSObject
    $ExportVw | Add-Member -MemberType NoteProperty -name "Site Name" -value $_.Title
    $m365GroupOwnersName="";
    $m365GroupMembersName="";
    $m365GroupGuestsName = "";
    $groupId = $_.GroupId;
    $siteUrl = $_.Url;
    #Check if site template is a Team template to retrieve the m365 group membership
    if($_.Template -eq "GROUP#0")
    {
        $m365GroupOwnersName = (Get-PnPMicrosoft365GroupOwner -Identity $groupId -ErrorAction Ignore| select-object -ExpandProperty DisplayName ) -join ";";
        $m365GroupMembersName = (Get-PnPMicrosoft365GroupMember -Identity $groupId  -ErrorAction Ignore| select-object -ExpandProperty DisplayName) -join ";";
        $m365GroupGuestsName = (Get-PnPMicrosoft365GroupMember -Identity $groupId  -ErrorAction Ignore |Where-Object UserType -eq Guest | select-object -ExpandProperty DisplayName) -join ";";
    }

    $ExportVw | Add-Member -MemberType NoteProperty -name "Group Owners" -value $m365GroupOwnersName    
    $ExportVw | Add-Member -MemberType NoteProperty -name "Group Members" -value $m365GroupMembersName
    $ExportVw | Add-Member -MemberType NoteProperty -name "Group Guests" -value $m365GroupGuestsName      
    Connect-PnPOnline -Url $siteUrl -Interactive
    
    $site = Get-PnPSite -Includes ID
    $ExportVw | Add-Member -MemberType NoteProperty -name "Site Id" -value $site.Id  
    $siteadmins = (Get-PnPSiteCollectionAdmin | select-object -ExpandProperty Title) -join ";";
    $ExportVw | Add-Member -MemberType NoteProperty -name "Site admins" -value $siteadmins  
    $siteowners  = (Get-PnPGroupMember -Group (Get-PnPGroup -AssociatedOwnerGroup)  | select-object -ExpandProperty Title) -join ";"
    $ExportVw | Add-Member -MemberType NoteProperty -name "Site owners" -value $siteowners
    $sitemembers =  (Get-PnPGroupMember -Group (Get-PnPGroup -AssociatedMemberGroup)  | select-object -ExpandProperty Title) -join ";"
    $ExportVw | Add-Member -MemberType NoteProperty -name "Site members" -value  $sitemembers
    $sitevisitors =  (Get-PnPGroupMember -Group (Get-PnPGroup -AssociatedVisitorGroup)  | select-object -ExpandProperty Title) -join ";"
    $ExportVw | Add-Member -MemberType NoteProperty -name "Site visitors" -value  $sitevisitors
    $m365GroupCollection += $ExportVw

}
# Export the result array to CSV file
$m365GroupCollection | sort-object "Site Name" |Export-CSV $OutPutView -Force -NoTypeInformation
# Disconnect SharePoint online connection
Disconnect-PnPOnline
```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***

## Contributors

| Author(s) |
|-----------|
| [Reshmee Auckloo](https://github.com/reshmee011)|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-get-sites-membership-report" aria-hidden="true" />
