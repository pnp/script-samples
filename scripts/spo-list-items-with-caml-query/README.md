---
plugin: add-to-gallery
---

# Read SharePoint List Items Using CAML Query

## Summary

Sometimes we want to read SharePoint list items using CAML query.

## Implementation

- Open Windows PowerShell ISE
- Create a new file
- Write a script as below,
- First, we will connect to Tenant admin site.
    - Then we will connect to SharePoint site in which we want to read list items.
    - And then create a separate functions for all the field operations.

# [PnP PowerShell](#tab/pnpps)
```powershell

#Global Variable Declaration
$AdminURL = "https://tenant-admin.sharepoint.com/"
$SiteURL = "https://tenant.sharepoint.com/sites/SiteName/"
$ListName = "ListName"
$UserName = "USERNAME"
$Password = "********"
$SecureStringPwd = $Password | ConvertTo-SecureString -AsPlainText -Force 
$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $UserName, $SecureStringPwd

Function LoginToAdminSite() {
    [cmdletbinding()]
    param([parameter(Mandatory = $true, ValueFromPipeline = $true)] $Credentials)
    Write-Host "Connecting to Tenant Admin Site '$($AdminURL)'..." -ForegroundColor Yellow
    Connect-PnPOnline -Url $AdminURL -Credentials $Credentials
    Write-Host "Connection Successfull to Tenant Admin Site :'$($AdminURL)'" -ForegroundColor Green
}

Function ConnectToSPSite() {
    try {     
        Write-Host "Connecting to Site :'$($SiteUrl)'..." -ForegroundColor Yellow  
        Connect-PnPOnline -Url $SiteUrl -Credentials $Credentials
        Write-Host "Connection Successfull to site: '$($SiteUrl)'" -ForegroundColor Green    
        GetListItemsUsingCAML                           
    }
    catch {
        Write-Host "Error in connecting to Site:'$($SiteUrl)'" $_.Exception.Message -ForegroundColor Red               
    } 
}

Function FilterTextField() {     
    Write-Host "**************** FILTER BY TEXT **************** " -ForegroundColor Green
    $FilterTextField = Get-PnPListItem -List $ListName -Query "@<View>
                                                                <ViewFields>
                                                                    <FieldRef Name='Title'/>                                                                    
                                                                    <FieldRef Name='GUID'/>                                                                    
                                                                </ViewFields>
                                                                <Query>
                                                                    <Where>
                                                                        <Eq>
                                                                            <FieldRef Name='Title'/>
                                                                                <Value Type='Text'>Ankit</Value>
                                                                         </Eq>
                                                                    </Where>
                                                                </Query>
                                                            </View>"
    if ($FilterTextField -eq $null) {
        Write-Host "No records found for filter by text" -ForegroundColor Gray
    }
    else {
        $FilterTextField | Format-Table
    }   
}

Function FilterDateField() {
    Write-Host "**************** FILTER BY DATE **************** " -ForegroundColor Green
    $FilterDateField = Get-PnPListItem -List $ListName -Query "@<View>
                                                                <ViewFields>
                                                                    <FieldRef Name='Title'/>                                                                   
                                                                    <FieldRef Name='GUID'/>
                                                                    <FieldRef Name='Modified'/>
                                                                </ViewFields>
                                                                <Query><Where>
                                                                    <Eq><FieldRef Name='Modified'/><Value Type='DateTime'><Today/></Value></Eq></Where>
                                                                </Query>
                                                            </View>"

    if ($FilterDateField -eq $null) {
        Write-Host "No records found for filter by date" -ForegroundColor Gray
    }
    else {
        $FilterDateField | Format-Table
    }    
}

Function FilterChoiceField() {    
    Write-Host "**************** FILTER BY CHOICE **************** " -ForegroundColor Green 
    $FilterChoiceField = Get-PnPListItem -List $ListName -Query "@<View>
                                                                <ViewFields>
                                                                    <FieldRef Name='Title'/>
                                                                    <FieldRef Name='Hobby'/>
                                                                    <FieldRef Name='GUID'/>
                                                                </ViewFields>
                                                                 <Query>
                                                                    <Where>
                                                                        <Eq>
                                                                            <FieldRef Name='Hobby'/>
                                                                            <Value Type='Choice'>Drawing</Value>
                                                                        </Eq>
                                                                    </Where>
                                                                </Query>
                                                              </View>"

    if ($FilterChoiceField -eq $null) {
        Write-Host "No records found for filter by text" -ForegroundColor Gray
    }
    else {
        $FilterChoiceField | Format-Table
    }    
}

Function FilterLookupField() {   
    Write-Host "**************** FILTER BY LOOKUP **************** " -ForegroundColor Green
    $FilterLookupField = Get-PnPListItem -List $ListName -Query "@<View>
                                                                <ViewFields>
                                                                    <FieldRef Name='Title'/>
                                                                    <FieldRef Name='Country'/>
                                                                    <FieldRef Name='GUID'/>
                                                                </ViewFields>
                                                                 <Query>
                                                                    <Where>
                                                                        <Eq>
                                                                            <FieldRef Name='Country'/>
                                                                            <Value Type='Lookup'>India</Value>
                                                                        </Eq>
                                                                    </Where>
                                                                </Query>
                                                              </View>"                                                                      
    if ($FilterLookupField -eq $null) {
        Write-Host "No records found for filter by text" -ForegroundColor Gray
    }
    else {
        $FilterLookupField | Format-Table
    }    
}

Function FilterUserField() {   
    Write-Host "**************** FILTER BY PEOPLE **************** " -ForegroundColor Green
    $filterByPeople = Get-PnPListItem -List $ListName -Query "@<View>
                                                                <ViewFields>
                                                                    <FieldRef Name='Title'/>
                                                                    <FieldRef Name='User'/>
                                                                    <FieldRef Name='GUID'/>
                                                                </ViewFields>
                                                                <Query>
                                                                    <Where>
                                                                        <Eq>
                                                                            <FieldRef Name='User'/>
                                                                            <Value Type='User'>Chandani Prajapati</Value>
                                                                        </Eq>
                                                                     </Where>
                                                                     </Query>
                                                                 </View>"        
    if ($filterByPeople -eq $null) {
        Write-Host "No records found for filter by text" -ForegroundColor Gray
    }
    else {
        $filterByPeople | Format-Table
    }     
}

Function BeginsWith() {   
    Write-Host "**************** FILTER BY TEXT BEGINS WITH **************** " -ForegroundColor Green
    $FilterByTextBeginsWith = Get-PnPListItem -List $ListName -Query "@<View>
                                                                <ViewFields>
                                                                    <FieldRef Name='Title'/>                                                                    
                                                                    <FieldRef Name='GUID'/>                                                                                                                                       
                                                                </ViewFields>
                                                                <Query>
                                                                    <Where>
                                                                        <BeginsWith>
                                                                            <FieldRef Name='Title'/>
                                                                                <Value Type='Text'>Emp</Value>
                                                                         </BeginsWith>
                                                                    </Where>
                                                                </Query>
                                                            </View>"       
    if ($FilterByTextBeginsWith -eq $null) {
        Write-Host "No records found for filter by choice" -ForegroundColor Gray
    }
    else {
        $FilterByTextBeginsWith | Format-Table
    }    
}

Function ContainsValue() {    
    Write-Host "**************** FILTER BY TEXT CONTAINS VALUE **************** " -ForegroundColor Green
    $FilterByTextContainsVal = Get-PnPListItem -List $ListName -Query "@<View>
                                                                <ViewFields>
                                                                    <FieldRef Name='Title'/>                                                                    
                                                                    <FieldRef Name='GUID'/>                                                                    
                                                                </ViewFields>
                                                                <Query>
                                                                    <Where>
                                                                        <Contains>
                                                                            <FieldRef Name='Title'/>
                                                                                <Value Type='Text'>i</Value>
                                                                         </Contains>
                                                                    </Where>
                                                                </Query>
                                                            </View>"   

    if ($FilterByTextContainsVal -eq $null) {
        Write-Host "No records found for filter by contains" -ForegroundColor Gray
    }
    else {
        $FilterByTextContainsVal | Format-Table
    }        
}

Function GetListItemsUsingCAML() {
    FilterTextField
    FilterDateField
    FilterChoiceField
    FilterLookupField
    FilterUserField  
    BeginsWith
    ContainsValue  
}

Function Main() {
    LoginToAdminSite($Credentials);
    ConnectToSPSite
}

Main

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]


# [CLI for Microsoft 365 with PowerShell](#tab/cli-m365-ps)
```powershell

#Global Variable Declaration
$SiteURL = "https://tenant.sharepoint.com/sites/SiteName/"
$ListName = "ListName"

Function loginToTenant() {
    $m365Status = m365 status
    if ($m365Status -match "Logged Out") {
        m365 login
    }
}

Function FilterTextField() {     
    Write-Host "**************** FILTER BY TEXT **************** " -ForegroundColor Green
    $FilterTextField = m365 spo listitem list --title $ListName --webUrl $SiteURL --camlQuery "@<View>
                                                                <ViewFields>
                                                                    <FieldRef Name='Title'/>                                                                    
                                                                    <FieldRef Name='GUID'/>                                                                    
                                                                </ViewFields>
                                                                <Query>
                                                                    <Where>
                                                                        <Eq>
                                                                            <FieldRef Name='Title'/>
                                                                            <Value Type='Text'>Ankit</Value>
                                                                         </Eq>
                                                                    </Where>
                                                                </Query>
                                                            </View>"
    if ($FilterTextField -eq $null) {
        Write-Host "No records found for filter by text" -ForegroundColor Gray
    }
    else {
        $FilterTextField | Format-Table
    }   
}

Function FilterDateField() {
    Write-Host "**************** FILTER BY DATE **************** " -ForegroundColor Green
    $FilterDateField = m365 spo listitem list --title $ListName --webUrl $SiteURL --camlQuery "@<View>
                                                                <ViewFields>
                                                                    <FieldRef Name='Title'/>                                                                   
                                                                    <FieldRef Name='GUID'/>
                                                                    <FieldRef Name='Modified'/>
                                                                </ViewFields>
                                                                <Query><Where>
                                                                    <Eq><FieldRef Name='Modified'/><Value Type='DateTime'><Today/></Value></Eq></Where>
                                                                </Query>
                                                            </View>"

    if ($FilterDateField -eq $null) {
        Write-Host "No records found for filter by date" -ForegroundColor Gray
    }
    else {
        $FilterDateField | Format-Table
    }    
}

Function FilterChoiceField() {    
    Write-Host "**************** FILTER BY CHOICE **************** " -ForegroundColor Green 
    $FilterChoiceField = m365 spo listitem list --title $ListName --webUrl $SiteURL --camlQuery "@<View>
                                                                <ViewFields>
                                                                    <FieldRef Name='Title'/>
                                                                    <FieldRef Name='Hobby'/>
                                                                    <FieldRef Name='GUID'/>
                                                                </ViewFields>
                                                                 <Query>
                                                                    <Where>
                                                                        <Eq>
                                                                            <FieldRef Name='Hobby'/>
                                                                            <Value Type='Choice'>Drawing</Value>
                                                                        </Eq>
                                                                    </Where>
                                                                </Query>
                                                              </View>"

    if ($FilterChoiceField -eq $null) {
        Write-Host "No records found for filter by text" -ForegroundColor Gray
    }
    else {
        $FilterChoiceField | Format-Table
    }    
}

Function FilterLookupField() {   
    Write-Host "**************** FILTER BY LOOKUP **************** " -ForegroundColor Green
    $FilterLookupField = m365 spo listitem list --title $ListName --webUrl $SiteURL --camlQuery "@<View>
                                                                <ViewFields>
                                                                    <FieldRef Name='Title'/>
                                                                    <FieldRef Name='Country'/>
                                                                    <FieldRef Name='GUID'/>
                                                                </ViewFields>
                                                                 <Query>
                                                                    <Where>
                                                                        <Eq>
                                                                            <FieldRef Name='Country'/>
                                                                            <Value Type='Lookup'>India</Value>
                                                                        </Eq>
                                                                    </Where>
                                                                </Query>
                                                              </View>"                                                                      
    if ($FilterLookupField -eq $null) {
        Write-Host "No records found for filter by text" -ForegroundColor Gray
    }
    else {
        $FilterLookupField | Format-Table
    }    
}

Function FilterUserField() {   
    Write-Host "**************** FILTER BY PEOPLE **************** " -ForegroundColor Green
    $filterByPeople = m365 spo listitem list --title $ListName --webUrl $SiteURL --camlQuery "@<View>
                                                                <ViewFields>
                                                                    <FieldRef Name='Title'/>
                                                                    <FieldRef Name='User'/>
                                                                    <FieldRef Name='GUID'/>
                                                                </ViewFields>
                                                                <Query>
                                                                    <Where>
                                                                        <Eq>
                                                                            <FieldRef Name='User'/>
                                                                            <Value Type='User'>Adam Wójcik</Value>
                                                                        </Eq>
                                                                     </Where>
                                                                     </Query>
                                                                 </View>"        
    if ($filterByPeople -eq $null) {
        Write-Host "No records found for filter by text" -ForegroundColor Gray
    }
    else {
        $filterByPeople | Format-Table
    }     
}

Function BeginsWith() {   
    Write-Host "**************** FILTER BY TEXT BEGINS WITH **************** " -ForegroundColor Green
    $FilterByTextBeginsWith = m365 spo listitem list --title $ListName --webUrl $SiteURL --camlQuery "@<View>
                                                                <ViewFields>
                                                                    <FieldRef Name='Title'/>                                                                    
                                                                    <FieldRef Name='GUID'/>                                                                                                                                       
                                                                </ViewFields>
                                                                <Query>
                                                                    <Where>
                                                                        <BeginsWith>
                                                                            <FieldRef Name='Title'/>
                                                                                <Value Type='Text'>Emp</Value>
                                                                         </BeginsWith>
                                                                    </Where>
                                                                </Query>
                                                            </View>"       
    if ($FilterByTextBeginsWith -eq $null) {
        Write-Host "No records found for filter by choice" -ForegroundColor Gray
    }
    else {
        $FilterByTextBeginsWith | Format-Table
    }    
}

Function ContainsValue() {    
    Write-Host "**************** FILTER BY TEXT CONTAINS VALUE **************** " -ForegroundColor Green
    $FilterByTextContainsVal = m365 spo listitem list --title $ListName --webUrl $SiteURL --camlQuery "@<View>
                                                                <ViewFields>
                                                                    <FieldRef Name='Title'/>                                                                    
                                                                    <FieldRef Name='GUID'/>                                                                    
                                                                </ViewFields>
                                                                <Query>
                                                                    <Where>
                                                                        <Contains>
                                                                            <FieldRef Name='Title'/>
                                                                                <Value Type='Text'>i</Value>
                                                                         </Contains>
                                                                    </Where>
                                                                </Query>
                                                            </View>"   

    if ($FilterByTextContainsVal -eq $null) {
        Write-Host "No records found for filter by contains" -ForegroundColor Gray
    }
    else {
        $FilterByTextContainsVal | Format-Table
    }        
}

Function GetListItemsUsingCAML() {
    FilterTextField
    FilterDateField
    FilterChoiceField
    FilterLookupField
    FilterUserField  
    BeginsWith
    ContainsValue  
}

Function Main() {
    loginToTenant
    GetListItemsUsingCAML
}

Main


```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
***

## Contributors

| Author(s) |
|-----------|
| Chandani Prajapati |
| [Adam Wójcik](https://github.com/Adam-it)|
| Jago Pauwels |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-list-items-with-caml-query" aria-hidden="true" />
