---
plugin: add-to-gallery
---

# Get All hub site and its main sites navigation nodes and update the navigation nodes if needed

## Summary

This script shows how to get all hub site and its main sites navigation nodes and update the navigation nodes if needed.

## Implementation

- Open Windows PowerShell ISE
- Create a new file
- Write a script as below,
- You need admin access to run this script
 
# [PnP PowerShell](#tab/pnpps)
```powershell

# Connect to the SharePoint Admin site
$adminUrl = "https://[tenant]-admin.sharepoint.com"

Connect-PnPOnline -Url $adminUrl -UseWebLogin

# Get all main sites in the hub
$hubSiteUrl = "https://[tenant].sharepoint.com/sites/[hubsite]"
$mainSites = Get-PnPHubSiteChild -Identity $hubSiteUrl

# Initialize an array to hold the results
$myResults = @()

foreach ($site in $mainSites) {
    # Switch context to the main site
    Connect-PnPOnline -Url $site -UseWebLogin

    # Get top-level navigation nodes
    $navNodes = Get-PnPNavigationNode # -Location TopNavigationBar

    foreach ($node in $navNodes) {
        # Add parent node to results
        $myResults += [PSCustomObject]@{
            NodeCode = $node.Id
            NodeTitle = $node.Title
            NodeType = "Parent"
            URL      = $node.Url
        }

        # Get child nodes
        $childNodes = Get-PnPNavigationNode -Id $node.Id

        foreach ($childNode in $childNodes.Children) {

            # Check if the child node title is "Confluence" and change it to "Confluence2"
            if ($childNode.Title -eq "Confluence") {
                # Rename the child node to "Confluence2"
                  $childNode.Title = "Confluence2"
                  $childNode.Url = "/Lists/TestLlist"
                  $childNode.Update()
                  $childNode.Context.ExecuteQuery()
               
                $childNode.Title = "Confluence2" # Update local object for display
            }

            # Add child nodes to results
            $myResults += [PSCustomObject]@{
                NodeCode = $childNode.Id
                NodeTitle = $childNode.Title
                NodeType = "Child"
                URL      = $childNode.Url
            }
        }
    }

    Disconnect-PnPOnline
}

# Display the results in a formatted table
$myResults | Format-Table -AutoSize

```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***

## Contributors

| Author(s) |
|-----------|
| [Valeras Narbutas](https://github.com/ValerasNarbutas) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-get-all-hub-site-main-sites-and-navigation-nodes" aria-hidden="true" />
