---
plugin: add-to-gallery
---

# Connected Account tooltip in PowerShell

When using PowerShell, the [Magic Tooltips module](https://www.powershellgallery.com/packages/MagicTooltips) can be installed to help determine the account that is connected to Microsoft 365 or Azure.

> [!div class="full-image-size"]
> ![Magic Tooltip displaying the account connected to Microsoft Graph](assets/powershell-tooltip.gif)

## Get Started with Tooltip for Connected Account

To get started with the Magic Tooltip module, perform the following steps:

1. Install and import the module

```
Install-Module MagicTooltips
Import-Module MagicTooltips -Force
```

To make the module auto-load, add the Import-Module line to your [PowerShell profile](https://github.com/pschaeflein/MagicTooltips#powershell-profile).

2. Start typing a CLI command or Microsoft Graph PowerShell cmdlet.

That's it! 😊

## Tooltip Configuration

The Magic Tooltips module provides for configuring its triggers and display. Complete configuration information can be found in [the GitHub repo for the module](https://github.com/pschaeflein/MagicTooltips).

## Contributors

| Author(s) |
|-----------|
| Paul Schaeflein |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]

<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/magic-tooltips-module" aria-hidden="true" />
