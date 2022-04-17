# Export OneDrive Admins

## Summary
Have you ever needed to know which Admins have added themselves to which OneDrives? This script exports every OneDrive in the tenant, and the site collection admins of the site. This helps audit which admins have unnecessary access to user OneDrives. 

![Example Screenshot](assets/OneDriveAdmins.png)

The report produces a csv file with one row per Site Collection Admin and OneDrive. This report has four columns:
SiteURL
SiteName
SiteCollectionAdmin
SiteCollectionAdminName


# [PnP PowerShell](#tab/pnpps)

```powershell

#Parameters
$AdminURL = "https://contoso-admin.sharepoint.com"
$ReportOutput = "OneDriveAdmins.csv"

#Authentication Details - If you have not registered PnP before, simply run the command Register-PnPAzureADApp to create an App
$ClientId = "xxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxx"
$Thumbprint = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
$Tenant = "contoso.onmicrosoft.com"

#Connect to SharePoint Online Admin site
Connect-PnPOnline $AdminURL -ClientId $ClientId -Thumbprint $Thumbprint  -Tenant $Tenant 

#Get all Mysites
$MySites = Get-PnPTenantSite -IncludeOneDriveSites -Filter "Url -like '-my.sharepoint.com/personal/'"

foreach ($MySite in $MySites) {
    try{
        write-host "Processing"$Mysite.Title -ForegroundColor Green
        #Connect to the MySite
        Connect-PnPOnline $MySite.Url -ClientId $ClientId -Thumbprint $Thumbprint  -Tenant $Tenant -ErrorAction Stop
        #Get the admins
        $Admins = Get-PnPSiteCollectionAdmin -ErrorAction Stop
        
        foreach($admin in $Admins){
            #Foreach admin make a record to output to CSV   
            $Result = New-Object PSObject -Property ([ordered]@{
                SiteURL = $Mysite.Url
                SiteName = $Mysite.Title
                SiteCollectionAdmin = $admin.Email
                SiteCollectionAdminName = $admin.Title
            })
            
            #Export the results to CSV
            $Result | Export-Csv -Path $ReportOutput -NoTypeInformation -Append

        }
    }catch{
        #We encountered an error, print it to the screen
        write-host "Error with site collection"$Mysite.Title -ForegroundColor Red
    }
}


```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365 using PowerShell](#tab/cli-m365-ps)

```powershell

<your powershell script>

```

# [CLI for Microsoft 365 using Bash](#tab/cli-m365-bash)

```bash

<your bash script>

```

[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

# [Microsoft Graph PowerShell](#tab/graphps)

```powershell

<your powershell script>

```
[!INCLUDE [More about Microsoft Graph PowerShell SDK](../../docfx/includes/MORE-GRAPHSDK.md)]

# [SPO Management Shell](#tab/spoms-ps)

```powershell

<your powershell script>

```
[!INCLUDE [More about SPO Management Shell](../../docfx/includes/MORE-SPOMS.md)]

# [Azure CLI](#tab/azure-cli)

```Azure CLI

<your cli script>  

```
[!INCLUDE [More about Azure CLI](../../docfx/includes/MORE-AZURECLI.md)]


# [Power Apps PowerShell](#tab/powerapps-ps)
```powershell

<your powershell script>

```
[!INCLUDE [More about Power Apps PowerShell](../../docfx/includes/MORE-POWERAPPS.md)]


# [MicrosoftTeams PowerShell](#tab/teamsps)
```powershell

<your powershell script>

```
[!INCLUDE [More about Microsoft Teams PowerShell](../../docfx/includes/MORE-TEAMSPS.md)]

***

