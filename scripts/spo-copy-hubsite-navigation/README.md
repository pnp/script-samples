---
plugin: add-to-gallery-preparation
---

# Copy a hubsite navigation from a source site to any desired taret hubsite

## Summary

This script copies a hub navigation from any hub site (source) to another hub site (target). Use this script to create a consistent hub navigation for all your sites in SharePoint Online.

Based on the navigation structure of any hub site of your choice – e.g. the hub navigation of your home site, which serves as a template - any desired hub navigation within your SharePoint Online site architecture can be created identically.

![Example Screenshot](assets/example.png)

> [!NOTE]
> The deployment process is idempotent; each navigation is only deployed once and replaced in the target hub site when it is deployed again. You can start the copying process as often as you like without expecting any side effects!


# [PnP PowerShell](#tab/pnpps)

```powershell

<your script>

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]


## Source Credit

Sample first appeared on [https://github.com/tmaestrini/easyProvisioning/](https://github.com/tmaestrini/easyProvisioning)

## Contributors

| Author(s) |
|-----------|
| [Tobias Maestrini](https://github.com/tmaestrini)|


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/template-script-submission" aria-hidden="true" />