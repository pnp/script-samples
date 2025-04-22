

# Get sharing links within the tenant

## Summary

Effective oversight of sharing links is paramount to ensuring data security, compliance, and optimal collaboration experiences.

For Copilot for M365 implementations, ensuring there is no oversharing is a critical aspect of safeguarding sensitive information and maintaining regulatory compliance. By integrating the sharing link audit process into deployment strategies, administrators can preemptively address security vulnerabilities and uphold the integrity of M365 environments.

![Example Screenshot](assets/preview.png)

### Prerequisites

- The user account that runs the script must have SharePoint Online tenant administrator access.

# [PnP PowerShell](#tab/pnpps)

```powershell
#Parameters
$tenantUrl = Read-Host -Prompt "Enter tenant collection URL";
$dateTime = (Get-Date).toString("dd-MM-yyyy-hh-ss")
$invocation = (Get-Variable MyInvocation).Value
$directorypath = Split-Path $invocation.MyCommand.Path
$fileName = "SharedLinks-" + $dateTime + ".csv"
$ReportOutput = $directorypath + "\Logs\"+ $fileName

#Connect to PnP Online
Connect-PnPOnline -Url $tenantUrl -Interactive

$global:Results = @();

function getSharingLink($_object,$_type,$_siteUrl,$_listUrl)
{
    $relativeUrl = $_object.FieldValues["FileRef"]
    $SharingLinks = if ($_type -eq "File" -or $_type -eq "Item") {
        Get-PnPFileSharingLink -Identity $relativeUrl
    } elseif ($_type -eq "Folder") {
        Get-PnPFolderSharingLink -Folder $relativeUrl
    }
    
    ForEach($ShareLink in $SharingLinks)
    {
        $result = New-Object PSObject -property $([ordered]@{
            SiteUrl = $_SiteURL
            listUrl = $_listUrl
            Name = $_type -eq 'Item' ? $_object.FieldValues["Title"] : $_object.FieldValues["FileLeafRef"]          
            RelativeURL = $_object.FieldValues["FileRef"] 
            ObjectType = $_Type
            ShareId = $ShareLink.Id
            RoleList = $ShareLink.Roles -join "|"
            Users = $ShareLink.GrantedToIdentitiesV2.User.Email -join "|"
            ShareLinkUrl  = $ShareLink.Link.WebUrl
            ShareLinkType  = $ShareLink.Link.Type
            ShareLinkScope  = $ShareLink.Link.Scope
            Expiration = $ShareLink.ExpirationDateTime
            BlocksDownload = $ShareLink.Link.PreventsDowload
            RequiresPassword = $ShareLink.HasPassword
                        
        })
        $global:Results +=$result;
    }     
}

#Exclude certain libraries
$ExcludedLists = @("Access Requests", "App Packages", "appdata", "appfiles", "Apps in Testing", "Cache Profiles", "Composed Looks", "Content and Structure Reports", "Content type publishing error log", "Converted Forms",
    "Device Channels", "Form Templates", "fpdatasources", "Get started with Apps for Office and SharePoint", "List Template Gallery", "Long Running Operation Status", "Maintenance Log Library", "Images", "site collection images"
    , "Master Docs", "Master Page Gallery", "MicroFeed", "NintexFormXml", "Quick Deploy Items", "Relationships List", "Reusable Content", "Reporting Metadata", "Reporting Templates", "Search Config List", "Site Assets", "Preservation Hold Library",
    "Site Pages", "Solution Gallery", "Style Library", "Suggested Content Browser Locations", "Theme Gallery", "TaxonomyHiddenList", "User Information List", "Web Part Gallery", "wfpub", "wfsvc", "Workflow History", "Workflow Tasks", "Pages")

$m365Sites = Get-PnPTenantSite| Where-Object { ( $_.Url -like '*/sites/*') -and $_.Template -ne 'RedirectSite#0' } 
$m365Sites | ForEach-Object {
$siteUrl = $_.Url;     
Connect-PnPOnline -Url $siteUrl -Interactive

Write-Host "Processing site $siteUrl"  -Foregroundcolor "Red"; 

#getSharingLink $ctx $web "site" $siteUrl "";
$ll = Get-PnPList -Includes BaseType, Hidden, Title,HasUniqueRoleAssignments,RootFolder | Where-Object {$_.Hidden -eq $False -and $_.Title -notin $ExcludedLists } #$_.BaseType -eq "DocumentLibrary" 
  Write-Host "Number of lists $($ll.Count)";

  foreach($list in $ll)
  {
    $listUrl = $list.RootFolder.ServerRelativeUrl;       

    #Get all list items in batches
    $ListItems = Get-PnPListItem -List $list -PageSize 2000 

        ForEach($item in $ListItems)
        {
            #Check if the Item has unique permissions
            $HasUniquePermissions = Get-PnPProperty -ClientObject $Item -Property "HasUniqueRoleAssignments"
            If($HasUniquePermissions)
            {       
                #Get Shared Links
                if($list.BaseType -eq "DocumentLibrary")
                {
                    $type= $item.FileSystemObjectType;
                }
                else
                {
                    $type= "Item";
                }
                getSharingLink $item $type $siteUrl $listUrl;
            }
        }
    }
 }
 
 $global:Results | Export-CSV $ReportOutput -NoTypeInformation
  #Export-CSV $ReportOutput -NoTypeInformation
Write-host -f Green "Sharing Links Report Generated Successfully!"
```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***

## Source Credit

Sample first appeared on [Oversight of Sharing Links in SharePoint sites using PowerShell](https://reshmeeauckloo.com/posts/powershell-get-sharing-links-sharepoint/)

## Contributors

| Author(s) |
|-----------|
| [Reshmee Auckloo](https://github.com/reshmee011) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-get-sharinglinks" aria-hidden="true" />