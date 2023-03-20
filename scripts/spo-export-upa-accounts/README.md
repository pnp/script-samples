---
plugin: add-to-gallery
---

# Export User Profiles to csv

## Summary

Sometimes you will have to export all or a sub set of the account in the User Profiles in order to do some validation or cleaning. This is where this script sample comes in handy.
The sample is an update of an existing script by Salaudeen Rajack , see https://www.sharepointdiary.com/2017/08/sharepoint-online-export-user-profile-properties-to-csv-using-powershell.html#ixzz7vvoXWaLr

![Example Screenshot](assets/example.png)


# [PnP PowerShell](#tab/pnpps)

```powershell

$adminsiteUrl = "https://contoso-admin.sharepoint.com/"
$conn = Connect-PnPOnline -Url $adminsiteUrl -Interactive -ReturnConnection
Connect-AzAccount
$AllUsers = Get-AzADUser 
$Counter = 0
$AllUsers.Count
$UserProfileData = @()
$emaildomain = "@contoso.com"


ForEach($User in $AllUsers)
{
        #filter out those account you dont need
        if($User.ObjectType -ne "User")
        {
            continue
        }
        # exclude those without an email address that matches this domain
        if($null -eq $User.Mail -or $User.Mail.IndexOf($emaildomain) -eq -1 )
        {
            continue
        }
        
        
        Write-host "`nGetting User Profile Property for: $($User.UserPrincipalName)" -f Yellow
        #Get the User Property value from SharePoint 
        try 
        {
            $UserProfile = Get-PnPUserProfileProperty -Account ($User.UserPrincipalName) -Connection $conn
            $UserProfile.UserProfileProperties["Department"]
            
            # Yet another option to exclude account from the export. Here we exclude account without a value in the Department field
            if($null -eq $UserProfile.UserProfileProperties["Department"] -or $UserProfile.UserProfileProperties["Department"] -eq "")
            {
                continue
            }
            #Get User Profile Data
            $UserData = New-Object PSObject
            ForEach($Key in $UserProfile.UserProfileProperties.Keys)
            { 
                $UserData | Add-Member NoteProperty $Key($UserProfile.UserProfileProperties[$Key])
            }
            $UserProfileData += $UserData
            $Counter++
            Write-Progress -Activity "Getting User Profile Data..." -Status "Getting User Profile $Counter of $($AllUsers.Count)" -PercentComplete (($Counter / $AllUsers.Count)  * 100)
        
        }
        catch 
        {
            Write-Host $_.Exception.Message
            
        }     
        

}
#Export the data to CSV
$CSVPath = "C:\temp\UPAAccounts.csv"
$UserProfileData | Export-Csv $CSVPath -Encoding utf8BOM -Delimiter "|"
   
write-host -f Green "User Profiles Data Exported Successfully to:" $CSVPath

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365](#tab/cli-m365-ps)
```powershell

m365 login --authType deviceCode

# Get all users and their properties, add properties as needed with --properties and separate with comma
m365 aad user list --properties "displayName,mail"

# Get all users and their properties and export to csv
m365 aad user list --output csv --properties "displayName,mail,givenName,jobTitle,mail,mobilePhone,officeLocation,preferredLanguage,surname,userPrincipalName,id" > users.csv

# Get current user with all properties
m365 aad user get --id "@meId"

# get any user with all properties
m365 aad user get --id "UserID"

```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
***

## Contributors

| Author(s) |
|-----------|
| Kasper Larsen |
| Valeras Narbutas |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-export-upa-accounts" aria-hidden="true" />
