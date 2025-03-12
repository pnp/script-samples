---
plugin: add-to-gallery
---

# Hide people who have lists open

## Summary

In Microsoft Lists, you can see in real time who is viewing the currently open list or list items. However, for privacy and other reasons, you may want to hide this information.

This sample script demonstrates how to hide real-time viewing information for a specific site.

![Screenshot of the example](./assets/example.png)

# [SPO Management Shell](#tab/spoms-ps)

```powershell
$adminCenterUrl = "https://{tenantName}-admin.sharepoint.com/"
$targetSiteUrl = "https://{tenantName}.sharepoint.com/sites/{siteName}"

# Connect to SharePoint Admin Center
Connect-SPOService -Url $adminCenterUrl

# Hide people who have lists open on the target site
Set-SPOSite -Identity $targetSiteUrl -HidePeopleWhoHaveListsOpen $true

# Disconnect from the SharePoint Admin Center
Disconnect-SPOService
```
[!INCLUDE [More about SPO Management Shell](../../docfx/includes/MORE-SPOMS.md)]

***

## Additional Notes

- **This setting change is applied at the site level**, not at the list level. Please keep that in mind.
- As of March 12, 2025, I am not aware of a way to change this setting at the list level.

## References

- [Microsoft Lists forms: What's New](https://techcommunity.microsoft.com/blog/spblog/microsoft-lists-forms-whats-new/4374037)
- [Set-SPOSite - -HidePeopleWhoHaveListsOpen](https://learn.microsoft.com/powershell/module/sharepoint-online/set-sposite?view=sharepoint-ps#-hidepeoplewhohavelistsopen)

## Contributors

| Author(s)        |
|------------------|
| [Tetsuya Kawahara](https://github.com/tecchan1107) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-hide-people-who-have-lists-open" aria-hidden="true" />