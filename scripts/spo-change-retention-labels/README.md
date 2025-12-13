

# M365 Consultant's Script Kit

## Summary

This scripts is part of the Microsoft 365 Consultant's Script kit, created by Nick Brattoli and Three Six Five Consulting.

It will scan every SharePoint site (or OneDrive URL) and look at every item. When it does this, it will check the retention label for said item. If the retention label matches the hardcoded value, the label will be set to a new one.

The reason for this script is because you cannot change certain actions in retention labels without making a new one, and there is no easy way to switch many items at once. Note that you may need to mess with pagination if you have a large amount of items.

  ##  Pre-requisites
	PowerShell 7 must be installed

	The following PowerShell modules are needed:
	PnP.PowerShell
	
## Setup
### Prepare the CSV file with SharePoint site URLs:
1. Use the included URLStoScan csv file
2. Place the urls in the csv file 
###	Edit the script:
1.	Open the script file in a text editor (or Visual Studio Code).
2.	Modify the variable $CsvFilePath to specify the path to the CSV file you are using if necessary
#### Customize retention label updates:
1.	Review the if and elseif statements within the script.
2. change the first two "if/else" statements to include the your old and new labels
3. If you have more than two, uncomment and modify the sections related to retention labels that you want to update based on your specific requirements.
For example, if you want to update the "25 years" retention label, uncomment the section and modify it as follows:

elseif ($ExistingRetentionLabel -eq "25 years") {
    Set-PnPListItem -List $List -Identity $Item.Id -Values @{ "_ComplianceTag" = "New 25 Years Label" }
}

![Setup your labels](assets/retentionlabels.png)
 
4.	Save the modified script:

## Running the Script

Now that the scripts are setup, you just need to run them. All these steps are the same, just change the name of the script.
1.	Open PowerShell 7 (as administrator recommended)
2.	Type CD “<whatever the path is where these scripts are>”
3.	Run the Script


# [PnP PowerShell](#tab/pnpps)

```powershell

Start-Transcript -Append log.txt
# Import PnP PowerShell module
Import-Module -Name pnp.powershell -DisableNameChecking


# Read SharePoint site URLs from CSV file
$CsvFilePath = "<PATH>\URLStoScan.csv"
$SiteUrls = Import-Csv -Path $CsvFilePath | Select-Object -ExpandProperty SiteUrl

# Define retention label mapping
$RetentionLabelMapping = @{
    "Script Test 1 Old" = "Script Test 1 New"
    "Script Test 2 Old" = "Script Test 2 New"
    #"25 years"          = "New 25 Years Label"
    #"30 years"          = "New 30 Years Label"
    #"35 years"          = "New 35 Years Label"
}

# Function to process a single list item
function Set-RetentionLabel {
    param (
        [Parameter(Mandatory)]
        $List,

        [Parameter(Mandatory)]
        $Item,

        [Parameter(Mandatory)]
        $FieldInternalName,

        [Parameter(Mandatory)]
        $Mapping
    )

    $CurrentLabel = $Item[$FieldInternalName]
    Write-Host "Item ID: $($Item.Id) | Current label: $CurrentLabel" -ForegroundColor Blue

    if ($Mapping.ContainsKey($CurrentLabel)) {
        $NewLabel = $Mapping[$CurrentLabel]
        Set-PnPListItem -List $List -Identity $Item.Id -Label $NewLabel
        Write-Host "Updated label to: $NewLabel" -ForegroundColor Green
    } else {
        Write-Host "No matching retention label found for Item ID $($Item.Id) in List '$($List.Title)'" -ForegroundColor Yellow
    }
}

# Iterate through each SharePoint site
foreach ($SiteUrl in $SiteUrls) {
    Write-Host "Processing SharePoint site: $SiteUrl" -ForegroundColor Cyan

    Connect-PnPOnline -Url $SiteUrl -Interactive

    # Retrieve all lists and libraries
    $Lists = Get-PnPList | Where-Object { $_.BaseType -in @("GenericList","DocumentLibrary") }
    Write-Host "$($Lists.Count) lists/libraries retrieved." -ForegroundColor Green

    foreach ($List in $Lists) {
        Write-Host "Processing list: $($List.Title)" -ForegroundColor Cyan

        # Get retention label field
        $RetentionField = Get-PnPField -List $List -Identity "_ComplianceTag"
        if (-not $RetentionField) {
            Write-Host "Retention label field not found in list $($List.Title)." -ForegroundColor Red
            continue
        }

        # Retrieve all items
        $Items = Get-PnPListItem -List $List
        Write-Host "$($Items.Count) items found in list $($List.Title)." -ForegroundColor Yellow

        foreach ($Item in $Items) {
            Set-RetentionLabel -List $List -Item $Item -FieldInternalName $RetentionField.InternalName -Mapping $RetentionLabelMapping
        }

        Write-Host "Finished processing list $($List.Title)." -ForegroundColor Green
    }

    Write-Host "Finished processing site $SiteUrl." -ForegroundColor Cyan
}

Stop-Transcript

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]



## Contributors

| Author(s) |
|-----------|
| Nick Brattoli|


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-change-retention-labels" aria-hidden="true" />
