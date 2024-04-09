---
plugin: add-to-gallery
---

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

# Iterate through each SharePoint site URL
foreach ($SiteUrl in $SiteUrls) {
    Write-Host "Processing SharePoint site: $SiteUrl" -ForegroundColor yellow
    
        # Connect to SharePoint site
        Connect-PnPOnline -Url $SiteUrl -interactive
        
        # Retrieve all lists and libraries
        $Lists = Get-PnPList
          Write-Host "Lists Retrieved!" -ForegroundColor Green
        foreach ($List in $Lists) {
            if ($List.BaseType -eq "GenericList" -or $List.BaseType -eq "DocumentLibrary") {
                # Retrieve all items in the list or library
                 Write-Host "Retrieving List items for list" -ForegroundColor yellow
                $Items = Get-PnPListItem -List $List
                
                # Set retention label field
                $RetentionLabelField = Get-PnPField -List $List -Identity "_ComplianceTag"
                write-host "Retention label field is: $RetentionLabelField"
                
                foreach ($Item in $Items) {
                     Write-Host "Processing Item" -ForegroundColor yellow
                     $ExistingRetentionLabel = $Item[$RetentionLabelField.InternalName]
                     Write-Host "Current label is $ExistingRetentionLabel" -ForegroundColor Blue   
                     
                     
                     if ($ExistingRetentionLabel -eq "Script Test 1 Old") {
                   Set-PnPListItem -List $List -Identity $Item.Id -label "Script Test 1 New"
        }
        elseif ($ExistingRetentionLabel -eq "Script Test 2 Old") {
            Set-PnPListItem -List $List -Identity $Item.Id -label "Script Test 2 New"
                    }
        #elseif ($ExistingRetentionLabel -eq "25 years") {
         #   Set-PnPListItem -List $List -Identity $Item.Id -Values @{ "_ComplianceTag" = "New 25 Years Label" }
        #}
        #elseif ($ExistingRetentionLabel -eq "30 years") {
         #   Set-PnPListItem -List $List -Identity $Item.Id -Values @{ "_ComplianceTag" = "New 30 Years Label" }
        #}
        #elseif ($ExistingRetentionLabel -eq "35 years") {
         #   Set-PnPListItem -List $List -Identity $Item.Id -Values @{ "_ComplianceTag" = "New 35 Years Label" }
        #}
        
        else {
            Write-Host "No matching retention label found for item $($Item.Id) in $($List.Title)."
        }
    }
    
    Write-Host "Retention labels set successfully."
}}} stop-Transcript
```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]



## Contributors

| Author(s) |
|-----------|
| Nick Brattoli|


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-change-retention-labels" aria-hidden="true" />