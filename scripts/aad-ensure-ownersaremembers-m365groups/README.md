

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
$OutPutView = $directorypath + "\" + $fileName
# Array to Hold Result - PSObjects
$m365GroupCollection = @()
#Write-host $"$ownerName not part of member in $siteUrl";
$m365Sites = Get-PnPTenantSite -Detailed | Where-Object { ($_.Template -eq 'GROUP#0') -and $_.Template -ne 'RedirectSite#0' }
$m365Sites | ForEach-Object {   
    $groupId = $_.GroupId;
    $siteUrl = $_.Url;
    $siteName = $_.Title
    #if owner is not part of m365 group member
    (Get-PnPMicrosoft365GroupOwner -Identity $groupId -ErrorAction Ignore) | foreach-object {
        $owner = $_;
        $ownerDisplayName = $owner.DisplayName;
        if (!(Get-PnPMicrosoft365GroupMember -Identity $groupId  -ErrorAction Ignore | Where-Object { $_.DisplayName -eq $owner.DisplayName })) {
            $ExportVw = New-Object PSObject
            $ExportVw | Add-Member -MemberType NoteProperty -name "Site Name" -value $siteName
            $ExportVw | Add-Member -MemberType NoteProperty -name "Site URL" -value $siteUrl
            $ExportVw | Add-Member -MemberType NoteProperty -name "Owner Name" -value $owner.DisplayName
            $m365GroupCollection += $ExportVw
            Add-PnPMicrosoft365GroupMember -Identity $groupId -Users $owner.Email
            Write-host "$ownerDisplayName has been added as member in $siteUrl";
      }
   }
}
# Export the result array to CSV file
$m365GroupCollection | sort-object "Site Name" | Export-CSV $OutPutView -Force -NoTypeInformation
```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365](#tab/cli-m365-ps)

```powershell
$m365Status = m365 status
if ($m365Status -match "Logged Out") {
    m365 login
}

$dateTime = (Get-Date).toString("dd-MM-yyyy")
$invocation = (Get-Variable MyInvocation).Value
$directorypath = Split-Path $invocation.MyCommand.Path
$fileName = "m365OwnersNotMembers-" + $dateTime + ".csv"
$OutPutView = $directorypath + "\" + $fileName
# Array to Hold Result - PSObjects
$m365GroupCollection = @()
#Write-host $"$ownerName not part of member in $siteUrl";
$m365Sites = m365 spo site list --query "[?Template == 'GROUP#0' && Template != 'RedirectSite#0'].{GroupId:GroupId, Url:Url, Title:Title}" --output json | ConvertFrom-Json
$m365Sites | ForEach-Object {   
    $groupId = $_.GroupId -replace "/Guid\((.*)\)/",'$1';
    $siteUrl = $_.Url;
    $siteName = $_.Title
    #if owner is not part of m365 group member
    (m365 entra m365group user list --role Owner --groupId $groupId --output json | ConvertFrom-Json) | foreach-object {
        $owner = $_;
        $ownerDisplayName = $owner.displayName
        if (!(m365 entra m365group user list --role Member --groupId $groupId --query "[?displayName == '$ownerDisplayName']" --output json | ConvertFrom-Json)) {
            $ExportVw = New-Object PSObject
            $ExportVw | Add-Member -MemberType NoteProperty -name "Site Name" -value $siteName
            $ExportVw | Add-Member -MemberType NoteProperty -name "Site URL" -value $siteUrl
            $ExportVw | Add-Member -MemberType NoteProperty -name "Owner Name" -value $ownerDisplayName
            $m365GroupCollection += $ExportVw
            m365 entra m365group user add --role Owner --groupId $groupId --userName $owner.userPrincipalName
            Write-host "$ownerDisplayName has been added as member in $siteUrl";
        }
    }
}
# Export the result array to CSV file
$m365GroupCollection | sort-object "Site Name" | Export-CSV $OutPutView -Force -NoTypeInformation

#Disconnect SharePoint online connection
m365 logout
```

[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

***

## Source Credit

Sample first appeared on [Ensuring Owners Are Members](https://reshmeeauckloo.com/posts/powershell_ensureownersaremembersm365group/)

## Contributors

| Author(s)                                 |
| ----------------------------------------- |
| [Reshmee Auckloo (Main author)](https://github.com/reshmee011) |
| [Michał Kornet (CLI for M365 version)](https://github.com/mkm17) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/aad-ensure-ownersaremembers-m365groups" aria-hidden="true" />
