---
plugin: add-to-gallery
---

# Get Flows Connected to SharePoint

## Summary

This script will generate a csv listing all flows which connect to SharePoint.
 
# [Power Apps PowerShell](#tab/powerapps-ps)
```powershell
$environment="{Your EnvironmentName}"
Connect-AzureAD
$flows=Get-AdminFlow -EnvironmentName $environment
$results=@()
foreach ($flow in $flows){

    $flowdetail=Get-AdminFlow  -EnvironmentName  $environment -FlowName $flow.FlowName

    foreach($referencedrsource in $flowdetail.Internal.properties.referencedResources){
    
    if ($referencedrsource.service -eq 'sharepoint'){
        $creator =  Get-AzureADUser -ObjectId  $flowdetail.Internal.properties.creator.objectId
        $flowdetail.DisplayName
        $canedit=Get-AdminFlowOwnerRole  -EnvironmentName  $environment -FlowName $flow.FlowName |Where-Object {$_.RoleType -eq "CanEdit"}
        $editUsers=""
        $canedit
        if ($canedit -ne $null){
            if ($canedit -is [array]){
                foreach($edituser in $canedit){
                   if ($edituer.PrincipalType -eq 'User'){
                       $editorName+=  (Get-AzureADUser -ObjectId  $edituser.PrincipalObjectId).UserPrincipalName + "; "
                   }
                   if ($canedit.PrincipalType -eq 'Group'){
                      $editorName=  (Get-AzureADGroup -ObjectId  $edituser.PrincipalObjectId).DisplayName + "; "
                    }

                }
            }
            else{
               if ($canedit.PrincipalType -eq 'User'){
                   $editorName=  (Get-AzureADUser -ObjectId  $canedit.PrincipalObjectId).UserPrincipalName
               }
               if ($canedit.PrincipalType -eq 'Group'){
                   $editorName=  (Get-AzureADGroup -ObjectId  $canedit.PrincipalObjectId).DisplayName
               }
            }
        }
        $owner=Get-AdminFlowOwnerRole  -EnvironmentName  $environment -FlowName $flow.FlowName |Where-Object {$_.RoleType -eq "Owner"}
        $ownerName=""
        if ($owner.PrincipalType -eq 'User'){
           $ownerName=  (Get-AzureADUser -ObjectId  $owner.PrincipalObjectId).UserPrincipalName
        }
        if ($owner.PrincipalType -eq 'Group'){
           $ownerName=  (Get-AzureADGroup -ObjectId  $owner.PrincipalObjectId).DisplayName
        }
        

        $results += [pscustomobject]@{Name=$flow.FlowName;DisplayName=$flowdetail.DisplayName;Site=$referencedrsource.resource.site;List=$referencedrsource.resource.list;Creator=$creator.UserPrincipalName;Owner=$ownerName;State=$flowdetail.Internal.properties.state;SuspensionReason=$flowdetail.Internal.properties.flowSuspensionReason;Created=$flowdetail.Internal.properties.createdTime;lastModified=$flowdetail.Internal.properties.lastModifiedTime;Editors=$editorName}
    
    }
    }


}
$results | Export-Csv -NoTypeInformation -Path [locationOfYourCsv]
```
[!INCLUDE [More about Power Apps PowerShell](../../docfx/includes/MORE-POWERAPPS.md)]
***

## Contributors

| Author(s) |
|-----------|
| Russell Gove |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/flow-get-flows-connected-to-sharepoint" aria-hidden="true" />
