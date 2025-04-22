

# Deletes expired and older sharing links for folder, file and item

## Summary

Currently, there is no default expiry time for "people you choose" or "people in your organization" links, and expired links are not automatically deleted. Using this script can help clean up your environment by removing expired or older sharing links, thereby enhancing security and governance.

![Example Screenshot](assets/preview.png)

### Prerequisites

- The user account that runs the script must have access to the SharePoint Online site.

# [PnP PowerShell](#tab/pnpps)

```powershell
param(
    [Parameter(Mandatory)]
    [string]$daysToKeepSharingLinkAfterCreationIfNoExpiryDateSpecified,
    [Parameter(Mandatory)]
    [ValidateSet('Yes','No')]
    [string]$DeleteSharingink,
    [Parameter(Mandatory)]
    [string]$siteUrl
)
 

#$daysToKeep = Read-Host -Prompt "Enter the number of days to keep sharinglinks if no expired date is set";
$dateTime = (Get-Date).toString("dd-MM-yyyy-hh-ss")
$invocation = (Get-Variable MyInvocation).Value
$directorypath = Split-Path $invocation.MyCommand.Path
$fileName = "DeletedExpiredSharedLinks-PnP" + $dateTime + ".csv"
$logDirectory = $directorypath + "\Log1s"
if (-not (Test-Path -Path $logDirectory)) {
    New-Item -ItemType Directory -Path $logDirectory
}
$ReportOutput = $directorypath + "\Log1s\"+ $fileName

#Connect to PnP Online
Connect-PnPOnline -Url $siteUrl
write-host $("Start time " + (Get-Date))
$global:Results = @();

function Get-ListItems_WithUniquePermissions{
    param(
        [Parameter(Mandatory)]
        [Microsoft.SharePoint.Client.List]$List
    )
    $selectFields = "ID,HasUniqueRoleAssignments,FileRef,FileLeafRef,FileSystemObjectType"
   
    $Url = $siteUrl + '/_api/web/lists/getbytitle(''' + $($list.Title) + ''')/items?$select=' + $($selectFields)
    $nextLink = $Url
    $listItems = @()
    $Stoploop =$true
    while($nextLink){  
        do{
        try {
            $response = invoke-pnpsprestmethod -Url $nextLink -Method Get
            $Stoploop =$true
    
        }
        catch {
            write-host "An error occured: $_  : Retrying" -ForegroundColor Red
            $Stoploop =$true
            Start-Sleep -Seconds 30
        }
    }
    While ($Stoploop -eq $false)
    
        $listItems += $response.value | where-object{$_.HasUniqueRoleAssignments -eq $true}
        if($response.'odata.nextlink'){
            $nextLink = $response.'odata.nextlink'
        }    else{
            $nextLink = $null
        }
    }

    return $listItems
}

function getSharingLink($_object,$_type,$_siteUrl,$_listUrl,$_listid)
{
    $sharingSettings = Invoke-PnPSPRestMethod -Method Post -Url "$($siteUrl)/_api/web/Lists(@a1)/GetItemById(@a2)/GetSharingInformation?@a1='{$($_listId)}'&@a2='$($_object.Id)'&`$Expand=permissionsInformation,pickerSettings"  -ContentType "application/json;odata=verbose" -Content "{}"
    ForEach ($ShareLink in $sharingSettings.permissionsInformation.links) 
    {
        $linkDetails = $shareLink.linkDetails
        if($linkDetails.ShareTokenString){
        $action = $null

        #update expiration date to be created date + x days if created date + 180 days is less than today otherwise delete the sharing link
        $CurrentDateTime = Get-Date
        $createdDate = Get-Date -Date $linkDetails.Created
    #    delete any sharing links created more than x days ago
        $expirationDate = $createdDate.AddDays($daysToKeepSharingLinkAfterCreationIfNoExpiryDateSpecified)
      
        if($expirationDate -lt $CurrentDateTime -or ($linkDetails.Expiration -ne "" -and (Get-Date -Date $linkDetails.Expiration) -lt $CurrentDateTime))
        {                      
            if($DeleteSharingink -eq 'Yes'){
                #Instead using the rest api call, use the Remove-PnPFileSharingLink or Remove-PnPFolderSharingLink
                $url = "$siteUrl/_api/web/Lists('$_listid')/GetItemById($($_object.Id))/UnshareLink" 
                $varBody = '{"linkKind":'+ $linkDetails.LinkKind +',"shareId":"'+ $linkDetails.ShareId +'"}'
                $action = "Deleted"
                $sharingInfo = invoke-pnpsprestmethod -Url $url -Method Post -Content $varBody
            }

        $invitees = (
            $linkDetails.Invitations | 
            ForEach-Object { $_.Invitee.email   }
        ) -join '|'

        $result = New-Object PSObject -property $([ordered]@{
            ItemID   = $item.Id
            ShareId = $linkDetails.ShareId
            ShareLink = $linkDetails.Url
            Invitees  = $invitees
            Name = $_object.FileLeafRef ?? $_object.Title       
            Type = $_type -eq 1 ? "Folder" : "File"
            RelativeURL = $_object.FileRef ?? ""
            LinkAccess = "ViewOnly"
            Created = Get-Date -Date $linkDetails.Created
            CreatedBy = $linkDetails.CreatedBy.email
            LastModifiedBy = $linkDetails.LastModifiedBy.email
            LastModified = $LastModified
            ShareLinkType  = $linkDetails.LinkKind
            Expiration = $linkDetails.Expiration
            BlocksDownload = $linkDetails.BlocksDownload
            RequiresPassword = $linkDetails.RequiresPassword
            PasswordLastModified = $linkDetails.PasswordLastModified
            PassLastModifiedBy = $linkDetails.PasswordLastModifiedBy.email
            HasExternalGuestInvitees = $linkDetails.HasExternalGuestInvitees
            HasAnonymousLink = $linkDetails.HasAnonymousLink
            AllowsAnonymousAccess = $linkDetails.AllowsAnonymousAccess
            ShareTokenString = $linkDetails.ShareTokenString
            Action = $action                        
        })
        $global:Results +=$result;
    }     
  }
 }
}

#Exclude certain libraries
$ExcludedLists = @("Access Requests", "App Packages", "appdata", "appfiles", "Apps in Testing", "Cache Profiles", "Composed Looks", "Content and Structure Reports", "Content type publishing error log", "Converted Forms",
    "Device Channels", "Form Templates", "fpdatasources", "Get started with Apps for Office and SharePoint", "List Template Gallery", "Long Running Operation Status", "Maintenance Log Library", "Images", "site collection images"
    , "Master Docs", "Master Page Gallery", "MicroFeed", "NintexFormXml", "Quick Deploy Items", "Relationships List", "Reusable Content", "Reporting Metadata", "Reporting Templates", "Search Config List", "Site Assets", "Preservation Hold Library",
    "Site Pages", "Solution Gallery", "Style Library", "Suggested Content Browser Locations", "Theme Gallery", "TaxonomyHiddenList", "User Information List", "Web Part Gallery", "wfpub", "wfsvc", "Workflow History", "Workflow Tasks", "Pages")


Write-Host "Processing site $siteUrl"  -Foregroundcolor "Red"; 

$ll = Get-PnPList -Includes BaseType, Hidden, Title,HasUniqueRoleAssignments,RootFolder | Where-Object {$_.Hidden -eq $False -and $_.Title -notin $ExcludedLists } #$_.BaseType -eq "DocumentLibrary" 
  Write-Host "Number of lists $($ll.Count)";

  foreach($list in $ll)
  {
    $listUrl = $list.RootFolder.ServerRelativeUrl;       

    #Get all list items in batches
    $ListItems = Get-ListItems_WithUniquePermissions -List $list

        ForEach($item in $ListItems)
        {
            $type= $item.FileSystemObjectType;
            getSharingLink $item $type $siteUrl $listUrl $list.Id;
        }
    }
 
 $global:Results | Export-CSV $ReportOutput -NoTypeInformation
Write-host -f Green "Deletion of expired Sharing Links Report Generated Successfully! at $ReportOutput"
write-host $("End time " + (Get-Date))
```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***

## Source Credit

Sample first appeared on [Automate the Removal of Expired Sharing Links in SharePoint with PowerShell](https://reshmeeauckloo.com/posts/powershell-sharinglink-remove-expiredlinks/)

## Contributors

| Author(s) |
|-----------|
| [Reshmee Auckloo](https://github.com/reshmee011) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-delete-expired-sharingLink-folder-file-item" aria-hidden="true">
