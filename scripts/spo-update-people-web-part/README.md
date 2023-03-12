---
plugin: add-to-gallery
---

# Sample showing how to ensure that the Role/Title in each People web part is updated

## Summary

Not entirely sure if the Role/Title field shown in the People Web part is supposed to be updated by MS on some sort of schedule. If that is the case this trigger either has an error or takes forever to be triggered.

## Implementation

- Open VS Code
- Create a new file
- Copy the code below,
- Change the variables to target to your environment
- Run the script.
 
## Screenshot of Output

![Example Screenshot](assets/preview.png)

# [PnP PowerShell](#tab/pnpps)
```powershell

# Author Kasper Larsen Fellowmind.dk
# Purpose : locate any People Web part and update those where the users title does not match the User profile anymore


#define which site collections you wish to iterate
$tenentUrl = "https://[YourTenant].sharepoint.com"
$conn = Connect-PnPOnline -Url $tenentUrl -Interactive -ReturnConnection
$relevantsitecollections = Get-PnPTenantSite | Where-Object {$_.Url -eq "https://[YourTenant].sharepoint.com/sites/HubsiteA"}

$SPAdminUrl = "https://[YourTenant]-admin.sharepoint.com/"
$spAdminConn = Connect-PnPOnline -Url $SPAdminUrl -Interactive -ReturnConnection

$Output = @()

function UpdatePeopleWebPart ($theWebpart, $page, $pageUrl)
{
    #$pageObj = Get-PnPPage -Identity $page["FileLeafRef"]

    $props =  $thewebpart.PropertiesJson | ConvertFrom-Json
    $layout = $props.layout
    $persons = $props.persons
    $webpartTitle = $props.title

    foreach($person in $props.persons)
    {
        $User = Get-PnPUserProfileProperty -Account $person.id -Connection $spAdminConn
        $currentJobTitle = $User.UserProfileProperties["SPS-JobTitle"]
        $oldrole = $person.role
        if($currentJobTitle -ne $person.role)
        {
            $person.role = $currentJobTitle
            $myObject = [PSCustomObject]@{
                URL     = $pageUrl
                personid = $person.id
                personupn = ""
                errorcode = "Role has been updated from $oldrole to $currentJobTitle"
        
            }        
            $Output+=($myObject)
        }
    }

    

    $thewebpart.PropertiesJson = $props | ConvertTo-Json
    $null = $page.Save()
    $null = $page.Publish()

    
}

foreach($site in  $relevantsitecollections)
{
    $sitecollectionUrl = $site.Url
    Write-Host "Url =  $sitecollectionUrl" -ForegroundColor Yellow
    
    $localConn = Connect-PnPOnline -Url $sitecollectionUrl -Interactive -ReturnConnection
    $pages = Get-PnPListItem -List "sitePages" -Connection $localConn

    foreach($page in $pages)
    {
        try 
        {
            $fullUrl = $tenentUrl+$page["FileRef"]
            Write-Host " Page = $fullUrl" -ForegroundColor Green
            $webpartpage = Get-PnPClientSidePage -Identity $page["FileLeafRef"] -ErrorAction Stop -Connection $localConn
            
            $webparts = $webpartpage.controls | Where-Object {$_.PropertiesJson -like "*persons*"}

            foreach($webpart in $webparts)
            {
                $props =  $webpart.PropertiesJson | ConvertFrom-Json
                write-host "Found $props.persons.count people in the web part" -ForegroundColor Blue

                $ShouldPeopleWebPartBeupdated = $false # checking if the Title of the users match the value from the User Profile 
                foreach($person in $props.persons)
                {
                    if(-not $ShouldPeopleWebPartBeupdated)
                    {
                        $User = Get-PnPUserProfileProperty -Account $person.id -Connection $spAdminConn
                        $currentJobTitle = $User.UserProfileProperties["SPS-JobTitle"]
    
                        if($currentJobTitle -ne $person.role)
                        {
                            Write-Host "The user $($person.Id) currently has a role as $($person.role) but the User Profile JobTitle is $currentJobTitle" -ForegroundColor Red
                            $ShouldPeopleWebPartBeupdated = $true
                        }
                    }
                }
                if($ShouldPeopleWebPartBeupdated)
                {
                    UpdatePeopleWebPart -theWebpart $webpart -page $webpartpage -pageUrl $fullUrl
                }
            }
        }
        catch 
        {
            $myObject = [PSCustomObject]@{
                URL     = $tenentUrl+$page["FileRef"]
                personid = ""
                personupn = ""
                errorcode = $_.Exception.Message

            }        
            $Output+=($myObject)
        }
        
        
        
        
    }
}
$Output | Export-Csv  -Path c:\temp\PeopleWebPartHasBeenUpdated.csv -Encoding utf8NoBOM -Force  -Delimiter "|"


```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Contributors

| Author(s) |
|-----------|
| Kasper Larsen, Fellowmind|


<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-update-people-web-part?labelText=Visitors" class="img-visitor" aria-hidden="true" />


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
