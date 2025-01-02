---
plugin: add-to-gallery
---

# Retrieve & Store SharePoint Site Pages Viewers Details

## Summary
This sample shows how to retrieve and store SharePoint site pages viewers' details using Exchange Online and PnP PowerShell.

## Prerequisites

Before running this script, ensure the following:

1. **PnP PowerShell Installed**:
   - Install the latest version of [PnP PowerShell](https://pnp.github.io/powershell/articles/installation.html).
   - Example: `Install-Module -Name PnP.PowerShell`.

2. **Exchange Online Module Installed**:
   - Install the Exchange Online module.
   - Example: `Install-Module -Name ExchangeOnlineManagement`.

3. **App Registration**:
   - Create an Azure AD app registration with the appropriate API permissions (e.g., `AuditLog.Read.All` for Microsoft Graph and `Sites.ReadWrite.All` for SharePoint).

4. **PowerShell Environment**:
   - Ensure PowerShell 7 or higher is installed for cross-platform compatibility.

5. **List Creation**:
   - A SharePoint list (e.g., `AuditLog`) must exist in the specified site to store the retrieved data. The list should include the following fields:
     - **User** (Single line of text)
     - **Timestamp** (Date and Time)
     - **Action** (Single line of text)

---


## [PnP PowerShell](#tab/pnpps)

```powershell
try {
    # Configurations
    $siteUrl = "https://contoso.sharepoint.com/sites/DemoSite"  # SharePoint site URL
    $listName = "AuditLog"                                      # List name
    $startDate = (Get-Date).AddDays(-90)                        # Fetch data from the past 90 days
    $endDate = (Get-Date)                                       # Until today
    $clientId = "your-app-client-id"

    # Authentication to Exchange Online
    Connect-ExchangeOnline -UserPrincipalName "admin@contoso.onmicrosoft.com"

    # Fetch Audit Data
    $auditRecords = Search-UnifiedAuditLog -StartDate $startDate -EndDate $endDate -Operations "PageViewed" -SiteIds "your-site-id"

    if ($auditRecords) {
        # Connect to SharePoint
        Connect-PnPOnline -Url $siteUrl -ClientId $clientId -Interactive

        # Add Records to List
        foreach ($record in $auditRecords) {
            Add-PnPListItem -List $listName -Values @{
                "User"      = $record.UserIds
                "Timestamp" = $record.CreationDate
                "Action"    = $record.Operations
            }
        }
        Write-Host "Audit data successfully added to the SharePoint list."
        Disconnect-PnPOnline
    } else {
        Write-Host "No records found for the specified date range."
    }
} catch {
    Write-Error "An error occurred: $_"
} finally {
    Disconnect-ExchangeOnline -Confirm:$false
}

StartProcessing
```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Contributors

| Author(s) |
|-----------|
| [Sandeep P S](https://github.com/Sandeep-FED) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-get-sp-site-page-viewers-details" aria-hidden="true" />