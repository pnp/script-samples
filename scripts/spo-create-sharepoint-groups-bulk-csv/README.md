

# Create SharePoint Groups in Bulk using CSV file

## Summary

This script shows how to create multiple groups in SharePoint for different site collection providing input from CSV file.

## Implementation

- Open Windows PowerShell ISE
- Create a new file
- Write a script as below,
- Create a CSV using the provided sample. Two columns are required SharePointUrl and SharePointGroupName
- Then we provide the path of the file as input to the PowerShell when prompted in the window when executed.

Download Sample CSV from this [link](assets/SampleInput.csv)

### Execution Image and output Image

![ExecutionImage](assets/SampleExecution.png)

![OutPutImage](assets/OutPut.png)
 
# [PnP PowerShell](#tab/pnpps)

```powershell

#Uncomment below line if facing remote server 400 error
#Import-Module SharePointPnPPowerShellOnline -UseWindowsPowerShell

$filePath = Read-Host "Please provide CSV file path"

# Import CSV file from given path
$importedFile = Import-Csv -Path $filePath

for ($index = 0; $index -lt $importedFile.Count; $index++) {
    # Connect to SharePoint online site
    Connect-PnPOnline -Url $importedFile[$index].SharePointUrl -Interactive

    # Create a new group in SharePoint site
    New-PnPGroup -Title $importedFile[$index].SharePointGroupName
}

```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365](#tab/cli-m365-ps)

```powershell

# Get Credentials to connect
$m365Status = m365 status
if ($m365Status -match "Logged Out") {
   m365 login
}

$filePath = Read-Host "Please provide CSV file path"

# Import CSV file from given path
$importedFile = Import-Csv -Path $filePath

for ($index = 0; $index -lt $importedFile.Count; $index++) {
	# Create a new group in SharePoint site
	m365 spo group add --webUrl $importedFile[$index].SharePointUrl --name $importedFile[$index].SharePointGroupName
}

# Disconnect SharePoint online connection
m365 logout

```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

# [SPO Management Shell](#tab/spoms-ps)

```powershell

# SharePoint online admin center site url
$adminSiteUrl = "https://contoso-admin.sharepoint.com"

# Connect to SharePoint online admin center
Connect-SPOService -Url $adminSiteUrl

$filePath = Read-Host "Please provide CSV file path"

# Import CSV file from given path
$importedFile = Import-Csv -Path $filePath

for ($index = 0; $index -lt $importedFile.Count; $index++) {
	# Create a new group in SharePoint site
	New-SPOSiteGroup -Site $importedFile[$index].SharePointUrl -Group $importedFile[$index].SharePointGroupName -PermissionLevels "Read"
}

# Disconnect SharePoint online connection
Disconnect-SPOService

```

[!INCLUDE [More about SPO Management Shell](../../docfx/includes/MORE-SPOMS.md)]

***

## Contributors

| Author(s) |
|-----------|
| Kunj Sangani |
| [Ganesh Sanap](https://ganeshsanapblogs.wordpress.com/about) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-create-sharepointgroups-bulk-csv" aria-hidden="true" />

