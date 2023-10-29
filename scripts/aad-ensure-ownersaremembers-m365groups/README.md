---
plugin: add-to-gallery
---

# Ensuring Owners Are Members

## Summary

It may happen that owners are not members of the m365 group because of the various methods of managing M365 group permissions, such as through the Teams admin center, Microsoft Teams, SharePoint admin center, SharePoint connected sites, Planner, or scripting using PowerShell. The script will help identify these discrepancies and ensures m365 group owners are also m365 group members.

# [PnP PowerShell](#tab/pnpps)

```powershell

$AdminCenterURL="https://contoso-admin.sharepoint.com/"# Connect to SharePoint Online admin center
Connect-PnPOnline -Url $AdminCenterURL -Interactive
$dateTime = (Get-Date).toString("dd-MM-yyyy")
$invocation = (Get-Variable MyInvocation).Value
$directorypath = Split-Path $invocation.MyCommand.Path
$fileName = "m365OwnersNotMembers-" + $dateTime + ".csv"
$OutPutView = $directorypath + "\Logs\"+ $fileName
# Array to Hold Result - PSObjects
$m365GroupCollection = @()
#Write-host $"$ownerName not part of member in $siteUrl";
$m365Sites = Get-PnPTenantSite -Detailed | Where-Object {($_.Url -like '*/TEST-*'-or $_.Template -eq 'TEAMCHANNEL#1') -and $_.Template -ne 'RedirectSite#0' }
$m365Sites | ForEach-Object {   
    $groupId = $_.GroupId;
    $siteUrl = $_.Url;
     if($_.Template -eq "GROUP#0")
     {
       #if owner is not part of m365 group member
    (Get-PnPMicrosoft365GroupOwner -Identity $groupId -ErrorAction Ignore) | foreach-object {
       $owner = $_;
        if(!(Get-PnPMicrosoft365GroupMember -Identity $groupId  -ErrorAction Ignore| Where-Object {$_.DisplayName -eq $owner.DisplayName}))
        {
            $ExportVw = New-Object PSObject
            $ExportVw | Add-Member -MemberType NoteProperty -name "Site URL" -value $siteUrl
            $ExportVw | Add-Member -MemberType NoteProperty -name "Owner Name" -value $owner.DisplayName
            $m365GroupCollection += $ExportVw
            Add-PnPMicrosoft365GroupMember -Identity $groupId  -Users $owner.Email
            Write-host $"$owner.DisplayName has been added as member in $siteUrl";
        }
      }
   }
}
# Export the result array to CSV file
$m365GroupCollection | sort-object "Group Name" |Export-CSV $OutPutView -Force -NoTypeInformation
```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***

## Source Credit

Sample first appeared on [Ensuring Owners Are Members](https://reshmeeauckloo.com/posts/powershell_ensureownersaremembersm365group/)

## Contributors

| Author(s)                                 |
| ----------------------------------------- |
| [Reshmee Auckloo](https://github.com/reshmee011) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/aad-delete-m365-groups-and-sharepoint-sites" aria-hidden="true" />
