---
plugin: add-to-gallery
---

# Copy SharePoint list to another site 

## Summary

The script will copy a list from one site to another. It will copy the list settings, permissions, views and columns. It will not copy the items.


# [PnP PowerShell](#tab/pnpps)
```powershell
$SPBaseTemplates = @{ 100 = 'GenericList'; 101 = 'DocumentLibrary'; 102 = 'Survey'; 103 = 'Links'; 104 = 'Announcements'; 105 = 'Contacts'; 106 = 'Events'; 107 = 'Tasks'; 108 = 'DiscussionBoard'; 109 = 'PictureLibrary'; 110 = 'DataSources'; 118 = 'WorkflowProcess'; 120 = 'CustomGrid'; 140 = 'WorkflowHistory'; 1100 = 'IssuesTracking'; 119 = 'WebPageLibrary' }
$DraftVersionVisibilityList = @{ 0 = 'Reader'; 1 = 'Author'; 2 = 'Approver'; }
$ReadSecurityList = @{ 1 = 'AllUsersReadAccess'; 2 = 'AllUsersReadAccessOnItemsTheyCreate'; }
$WriteSecurityList = @{ 1 = 'WriteAllItems'; 2 = 'WriteOnlyMyItems'; 3 = 'WriteNoItems' }
$RoleDefinitionBindingsList = @{ 1073741826 = 'Full Control'; 1073741827 = 'Design'; 1073741828 = 'Edit'; 1073741829 = 'Contribute'; 1073741830 = 'Read' }
$listTitle = "<ListTitle>"
$sourceWeb = "<SourceSiteUrl>"
$destinationWeb = "<DestintionSiteUrl>"

Write-host "Ensure logged in"
try {
    $context = Get-PnPContext
    if ($context -eq $null) {
        throw "No PnP context found."
    }
    Write-Host "PnP context found."
}
catch {
    Connect-PnPOnline -Url $sourceWeb -Interactive
}

Write-Host "Get list settings, views, fields and Check if list has unique permissions"
$sourceListSettings = Get-PnPList -Identity $listTitle -Includes RoleAssignments, Fields, Views, BaseTemplate, DraftVersionVisibility
$sourceListViews = $sourceListSettings.Views
$sourceListColumns = $sourceListSettings.Fields
$sourceListPermissions = $sourceListSettings.RoleAssignments

#AllUsersReadAccess, AllUsersReadAccessOnItemsTheyCreate
$sourceListSettings.ReadSecurity = "AllUsersReadAccess"


# Switch context to destination web
Connect-PnPOnline -Url $destinationWeb -Interactive

Write-Host "Translate template number to name"
$baseTemplate = $SPBaseTemplates[$sourceListSettings.BaseTemplate]

Write-Host "Create new list"
New-PnPList -Title $sourceListSettings.Title -Template $baseTemplate -OnQuickLaunch

Write-Host "Set other list settings"
# Note: You will need to map all other properties from the source list to the appropriate parameters for Set-PnPList
Set-PnPList `
-Identity $sourceListSettings.Title `
-Description $sourceListSettings.Description `
-EnableAttachments $sourceListSettings.EnableAttachments `
-EnableContentTypes $sourceListSettings.AllowContentTypes `
-EnableFolderCreation $sourceListSettings.EnableFolderCreation `
-EnableMinorVersions $sourceListSettings.EnableMinorVersions `
-EnableModeration $sourceListSettings.EnableModeration `
-DraftVersionVisibility $sourceListSettings.DraftVersionVisibility `
-EnableVersioning $sourceListSettings.EnableVersioning `
-ForceCheckout $sourceListSettings.ForceCheckout `
-Hidden $sourceListSettings.Hidden `
-ListExperience $sourceListSettings.ListExperienceOptions `
-MajorVersions $sourceListSettings.MajorVersionLimit `
-MinorVersions $sourceListSettings.MajorWithMinorVersionsLimit `
-ReadSecurity $ReadSecurityList[1] `
-WriteSecurity $WriteSecurityList[1] `
-NoCrawl `
-DisableGridEditing $sourceListSettings.DisableGridEditing


# Permissions are not copied by default, so we need to check if the source list has unique permissions and if so, copy them to the destination list
if ($sourceListSettings.HasUniqueRoleAssignments) {
    Write-Host "Set unique permissions"
    
    # Break role inheritance without copying existing permissions
    Set-PnPList -Identity $sourceListSettings.Title -BreakRoleInheritance $true -CopyRoleAssignments $false
    
    # Retrieve all role definitions for the site
    $RoleDefinitionBindingsList = Get-PnPRoleDefinition | Select-Object -Property Id, Name
    
    # Create a hashtable mapping role definition names to their IDs for easy lookup
    $roleMap = @{}
    foreach ($role in $RoleDefinitionBindingsList) {
        $roleMap[$role.Name] = $role.Id
    }
    
    foreach ($roleAssignment in $sourceListPermissions) {
        $member = $roleAssignment | Select-Object -ExpandProperty Member
        
        # Assuming the role assignment has a single role definition. If there are multiple, this needs to be adjusted.
        $roleName = $roleAssignment.RoleDefinitionBindings[0].Name
        
        if ($roleMap.ContainsKey($roleName)) {
            Set-PnPListPermission -Identity $sourceListSettings.Title -User $Member.LoginName -AddRole $roleName
        } else {
            Write-Host "Role $roleName not found in destination site." -ForegroundColor Yellow
        }
    }
}


Write-Host "Add columns"
$destinationListColumns = Get-PnPField -List $sourceListSettings.Title
foreach ($column in $sourceListColumns) {
    $fnd = $destinationListColumns | Where-Object { $_.InternalName -eq $column.InternalName }
    if (-not $fnd) {
        Add-PnPFieldFromXml -List $sourceListSettings.Title -FieldXml $column.SchemaXml
    }
}


Write-Host "Add views"
foreach ($view in $sourceListViews) {
    $schema = [xml]$view.HtmlSchemaXml
    $fields = $schema.View.ViewFields.FieldRef.Name
    
    $viewQuery = $view.ViewQuery.replace('"', "'")
    if (-not $viewQuery) {
        Add-PnPView -List $sourceListSettings.Title -Title $view.Title -Fields $fields | Out-Null
    } else {
        Add-PnPView -List $sourceListSettings.Title -Title $view.Title -Fields $fields -Query $viewQuery | Out-Null
    }
}

```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]


# [CLI for Microsoft 365](#tab/cli-m365-ps)
```powershell
$SPBaseTemplates = @{ 100 = 'GenericList'; 101 = 'DocumentLibrary'; 102 = 'Survey'; 103 = 'Links'; 104 = 'Announcements'; 105 = 'Contacts'; 106 = 'Events'; 107 = 'Tasks'; 108 = 'DiscussionBoard'; 109 = 'PictureLibrary'; 110 = 'DataSources'; 118 = 'WorkflowProcess'; 120 = 'CustomGrid'; 140 = 'WorkflowHistory'; 1100 = 'IssuesTracking'; 119 = 'WebPageLibrary' }
$DraftVersionVisibilityList = @{ 0 = 'Reader'; 1 = 'Author'; 2 = 'Approver'; }
$listTitle = "<listToCopy>"
$sourceWeb = "<sourceSite>"
$destinationWeb = "<destinationSite>"

Write-host "ensure logged in"
$m365Status = m365 status
if ($m365Status -match "Logged Out") {
   m365 login
}

Write-host "set context"
m365 context option set --name "title" --value $listTitle
m365 context option set --name "listTitle" --value $listTitle
m365 context option set --name "webUrl" --value $sourceWeb

Write-host "get list settings"
$sourceListSettings = m365 spo list get --withPermissions | ConvertFrom-Json
$sourceListPermissions = @()
$sourceListViews = @()
$sourceListColumns = @()

Write-host "check if list has unique permissions"
if ($sourceListSettings.HasUniqueRoleAssignments) {
   foreach ($RoleAssignment in $sourceListSettings.RoleAssignments) {
      $sourceListPermissions += $RoleAssignment
   }
}

Write-host "get list views"
$sourceListViews = m365 spo list view list | ConvertFrom-Json

Write-host "get list columns"
$sourceListColumns = m365 spo field list | ConvertFrom-Json

Write-host "set context to destination web"
m365 context option set --name "webUrl" --value $destinationWeb

Write-host "translate template number to name"
$baseTemplate = $SPBaseTemplates[$sourceListSettings.BaseTemplate]
$draftVersionVisibility = $DraftVersionVisibilityList[$sourceListSettings.DraftVersionVisibility]

Write-host "create new list"
m365 spo list add `
--title $sourceListSettings.Title `
--baseTemplate $baseTemplate `
--templateFeatureId $sourceListSettings.TemplateFeatureId `
--contentTypesEnabled $sourceListSettings.AllowContentTypes `
--crawlNonDefaultViews $sourceListSettings.CrawlNonDefaultViews `
--defaultContentApprovalWorkflowId $sourceListSettings.DefaultContentApprovalWorkflowId `
--disableCommenting $sourceListSettings.DisableCommenting `
--disableGridEditing $sourceListSettings.DisableGridEditing `
--draftVersionVisibility $draftVersionVisibility `
--enableAttachments $sourceListSettings.EnableAttachments `
--enableFolderCreation $sourceListSettings.EnableFolderCreation `
--enableMinorVersions $sourceListSettings.EnableMinorVersions `
--enableModeration $sourceListSettings.EnableModeration `
--enableVersioning $sourceListSettings.EnableVersioning `
--forceCheckout $sourceListSettings.ForceCheckout `
--hidden $sourceListSettings.Hidden `
--irmEnabled $sourceListSettings.IrmEnabled `
--irmReject $sourceListSettings.IrmReject `
--isApplicationList $sourceListSettings.IsApplicationList `
--majorVersionLimit $sourceListSettings.MajorVersionLimit `
--majorWithMinorVersionsLimit $sourceListSettings.MajorWithMinorVersionsLimit `
--multipleDataList $sourceListSettings.MultipleDataList `
--noCrawl $sourceListSettings.NoCrawl `
--parserDisabled $sourceListSettings.ParserDisabled | Out-Null

if ($sourceListSettings.Description -ne "") {
   m365 spo list set --description $sourceListSettings.Description
}

if ($sourceListSettings.HasUniqueRoleAssignments) {
   Write-host "set unique permissions"
   # currently it supports only users as the destination site may not have the same SP groups 
   m365 spo list roleinheritance break --clearExistingPermissions --confirm
   foreach ($roleAssignment in $sourceListPermissions) {
      m365 spo list roleassignment add --principalId $RoleAssignment.Member.Id --roleDefinitionId $RoleAssignment.RoleDefinitionBindings.Id[0] | Out-Null
   }
}

Write-host "add columns"
$destinationListColumns = m365 spo field list | ConvertFrom-Json
foreach ($column in $sourceListColumns) {
   $fnd = $destinationListColumns | Where { $_.InternalName -eq "$($column.InternalName )" }
   if ($fnd.Count -eq 0) {
      $schema = $column.SchemaXml.replace('"',"'")
      m365 spo field add --xml "$($schema)" | Out-Null
   }
}

Write-host "add views"
foreach ($view in $sourceListViews) {
   $schema = [xml]$view.HtmlSchemaXml
   $fields = $schema.View.ViewFields.FieldRef.Name -join ","
   $viewQuery = $view.ViewQuery.replace('"',"'")
   if ($viewQuery -eq "") {
      m365 spo list view add --title $view.Title --fields $fields | Out-Null
   }
   else {
      m365 spo list view add --title $view.Title --fields $fields --viewQuery $viewQuery | Out-Null
   }
}
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

***

## Contributors

| Author(s) |
|-----------|
| [Adam Wójcik](https://github.com/Adam-it)|
| [Valeras Narbutas](https://github.com/ValerasNarbutas) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-copy-list" aria-hidden="true" />