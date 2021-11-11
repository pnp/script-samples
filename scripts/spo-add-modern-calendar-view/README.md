---
plugin: add-to-gallery-preparation
---

# Adding a new modern calendar view to a SharePoint list using PnP PowerShell

## Summary

Recently we have finally been able to add a modern calendar view to a list in SharePoint Online but only through the UI. Before this a calendar view was only available in SharePoint classic mode.

![Example Screenshot](assets/example.png)

This script allow you to add a new modern calendar view to an existing SharePoint list. It uses the SharePoint REST API to add the view using the PnP cmdlet **Invoke-PnPSPRestMethod** as currently Modern calendar view is not available using just **Add-PnPView**.

Key points to note regarding the JSON body

* **RowLimit** is set to zero – this is to ensure all items for the current month/week/day are fetched correctly.
* **StartDate** (internal field name) is mapped to 0th entry in ViewFields
* **EndDate** (internal field name) is mapped to 1st entry in ViewFields
* **ViewData** has 5 FieldRef entries – 1 for month view and 2 each for week and day view. The fields are used as ‘Title’ for respective visualizations. If this is missing, you will see the popup to ‘fix’ calendar view.
* **CalendarViewStyles** has 3 CalendarViewStyle entry – will be used in future. Even if this is missing, View creation will succeed.
* **ViewType2** is MODERNCALENDAR
* **ViewTypeKind** is 1 – which maps to HTML.
* **Query** can be set if required.


# [PnP PowerShell](#tab/pnpps)

```powershell

<your powershell script>

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
  
***

## Source Credit

* Sample first appeared on [Adding the New Modern Calendar View to a SharePoint List using PnP PowerShell - Leon Armston Blog](https://www.leonarmston.com/2021/11/adding-the-new-modern-calendar-view-to-a-sharepoint-list-using-pnp-powershell/)
* JSON body explanation [stackoverflow](https://stackoverflow.com/questions/67271425/create-modern-calendar-view-for-sharepoint-online-list-using-the-rest-api) - credit [@shagra-ms](https://github.com/shagra-ms)


## Contributors

| Author(s) |
|-----------|
| Leon Armston |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/template-script-submission" aria-hidden="true" />
