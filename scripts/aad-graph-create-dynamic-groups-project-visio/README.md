---
plugin: add-to-gallery
---

# Create Dynamic Install and Uninstall Azure AD Groups using Graph

## Summary

When deploying Microsoft Visio and Microsoft Project via Intune, license management can be a lot of work.  This script will create dynamic user groups based on the user having an enabled license for each application (or not for the uninstall groups)

![Example Screenshot](assets/example.png)




# [Microsoft Graph PowerShell](#tab/graphps)

```powershell

##Install Modules if missing
if (Get-Module -ListAvailable -Name microsoft.graph.groups) {
    Write-Host "Microsoft Graph Groups Module Already Installed"
} 
else {
    try {
        Install-Module -Name microsoft.graph.groups -Scope CurrentUser -Repository PSGallery -Force -AllowClobber 
    }
    catch [Exception] {
        $_.message 
    }
}

##Import Module
Import-Module Microsoft.Graph.Groups


##Connect to Graph
Select-MgProfile -Name Beta
Connect-MgGraph -Scopes Group.ReadWrite.All

##Note: Removing a license does not remove the plan ID, it just disables it, hence the check that is it enabled

##Create Visio Install Group - User has service plan and it is enabled
write-host "Creating Visio Install Group" -ForegroundColor Green
try {
    $visioinstall = New-MGGroup -DisplayName "Visio-Install"  `
        -Description "Dynamic group for Licensed Visio Users" `
        -MailEnabled:$False `
        -MailNickName "visiousers" `
        -SecurityEnabled `
        -GroupTypes "DynamicMembership" `
        -MembershipRule "(user.assignedPlans -any (assignedPlan.servicePlanId -eq ""663a804f-1c30-4ff0-9915-9db84f0d1cea"" -and assignedPlan.capabilityStatus -eq ""Enabled""))" `
        -MembershipRuleProcessingState "On"
}
catch {
    Write-Error $_.Exception
}

$groupidvi = $visioinstall.id
write-host "Visio Install Group Created - $groupidvi" -ForegroundColor Green

##Create Visio Uninstall Group - User does NOT have service plan and it is not enabled
write-host "Creating Visio Uninstall Group" -ForegroundColor Green
try {
    $visiouninstall = New-MGGroup -DisplayName "Visio-Uninstall" `
        -Description "Dynamic group for users without Visio license" `
        -MailEnabled:$False `
        -MailNickName "visiouninstall" `
        -SecurityEnabled `
        -GroupTypes "DynamicMembership" `
        -MembershipRule "(user.assignedPlans -all (assignedPlan.servicePlanId -ne ""663a804f-1c30-4ff0-9915-9db84f0d1cea"" -and assignedPlan.capabilityStatus -ne ""Enabled""))" `
        -MembershipRuleProcessingState "On"
}
catch {
    Write-Error $_.Exception
}
$groupidvu = $visiouninstall.id
write-host "Visio Uninstall Group Created - $groupidvu" -ForegroundColor Green
       

##Create Project Install Group - User has service plan and it is enabled
write-host "Creating Project Install Group" -ForegroundColor Green
try {
    $projectinstall = New-MGGroup -DisplayName "Project-Install" `
        -Description "Dynamic group for Licensed Project Users" `
        -MailEnabled:$False `
        -MailNickName "projectinstall" `
        -SecurityEnabled `
        -GroupTypes "DynamicMembership" `
        -MembershipRule "(user.assignedPlans -any (assignedPlan.servicePlanId -eq ""fafd7243-e5c1-4a3a-9e40-495efcb1d3c3"" -and assignedPlan.capabilityStatus -eq ""Enabled""))" `
        -MembershipRuleProcessingState "On"
}
catch {
    Write-Error $_.Exception
}
$groupidpi = $projectinstall.id
write-host "Project Install Group Created - $groupidpi" -ForegroundColor Green
       
##Create Project Uninstall Group - User does NOT have service plan and it is not enabled
write-host "Creating Project Uninstall Group" -ForegroundColor Green
try {
    $projectuninstall = New-MGGroup -DisplayName "Project-Uninstall" `
        -Description "Dynamic group for users without Project license" `
        -MailEnabled:$False `
        -MailNickName "projectuninstall" `
        -SecurityEnabled `
        -GroupTypes "DynamicMembership" `
        -MembershipRule "(user.assignedPlans -all (assignedPlan.servicePlanId -ne ""fafd7243-e5c1-4a3a-9e40-495efcb1d3c3"" -and assignedPlan.capabilityStatus -ne ""Enabled""))" `
        -MembershipRuleProcessingState "On"
}
catch {
    Write-Error $_.Exception
}
$groupidpu = $projectuninstall.id
write-host "Project Uninstall Group Created - $groupidpu" -ForegroundColor Green
       
```
[!INCLUDE [More about Microsoft Graph PowerShell SDK](../../docfx/includes/MORE-GRAPHSDK.md)]
***


## Contributors

| Author(s)                                            |
|------------------------------------------------------|
| [Andrew Taylor](https://github.com/andrew-s-taylor) |



<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/aad-graph-create-dynamic-groups-project-visio?labelText=Visitors" class="img-visitor" aria-hidden="true" />

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
