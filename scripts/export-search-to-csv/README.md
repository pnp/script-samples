---
plugin: add-to-gallery
---

# Run A Seach Query And Export To CSV

## Summary

Perform a search query (such as "Show me all News Posts in this tenant") and export the results to CSV.

![Example Screenshot](assets/example.png)

## Instructions

- Open your favourite text/script editor and copy/paste the script template below 
- Modify the search query to your requirements, add the desired Managed Properties to the Select Properties list
- Also update the `PSCustomObject` with the properties that you require in the resulting CSV file
- Open a PowerShell terminal
- Connect to your SharePoint tenancy using PnP PowerShell
- Run the script
- Retrieve the generated CSV file

# [PnP PowerShell](#tab/pnpps)

``` powershell
$itemsToSave = @()

$query = "PromotedState:2"
$properties = "Title,Path,Author"

$search = Submit-PnPSearchQuery -Query $query -SelectProperties $properties -All

foreach ($row in $search.ResultRows) {


  $data = [PSCustomObject]@{
    "Title"      = $row["Title"]
    "Author"     = $row["Author"]
    "Path"       = $row["Path"]
  }

  $itemsToSave += $data
}

$itemsToSave | Export-Csv -Path "SearchResults.csv" -NoTypeInformation
```

## Contributors

| Author(s) |
|-----------|
| James Love |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/export-search-to-csv" aria-hidden="true" />