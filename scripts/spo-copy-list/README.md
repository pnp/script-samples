---
plugin: add-to-gallery
---

# Copy SharePoint list to another site 

## Summary

The script will copy a list from one site to another. It will copy the list settings, permissions, views and columns. It will not copy the items.


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


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-copy-list" aria-hidden="true" />