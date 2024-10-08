---
plugin: add-to-gallery
---

# Update list icons & color

## Summary

With a recent change in SharePoint Online, lists now have a icon and a color. However the defaults seem kinda random, this script demonstrates how to change the icons, and the colors, including mapping the current colors and icons to enums to make it easier to work with.

# [PnP PowerShell](#tab/pnpps)

```powershell
function get-customFormatting() {
    Connect-PnPOnline "Site Url"

    Enum Icons {
        Bug = 0
        Calendar = 1
        Target = 2
        Clipboard = 3
        Plane = 4
        Rocket = 5
        ColorPalette = 6
        Lightbulb = 7
        Cube = 8
        Beaker = 9
        Robot = 10
        PiggyBank = 11
        Playlist = 12
        Hospital = 13
        Bank = 14
        MapPin = 15
        CoffeCup = 16
        ShoppingCart = 17
        BirthdayCake = 18
    }

    Enum Color {
        DarkRed = 0
        Red = 1
        Orange = 2
        Green = 3
        DarkGreen = 4
        Teal = 5
        Blue = 6
        NavyBlue = 7
        BluePurple = 8
        DarkBlue = 9
        Lavender = 10
        Pink = 11
    }

    $list = Get-PnPList "Onboarding tasks";
    $list.Icon = [int][Icons]::Rocket;
    $list.Color = [int][Color]::NavyBlue;
    $list.Update()
    Invoke-PnPQuery

```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***

## Contributors

| Author(s) |
|-----------|
| [Dan Toft](https://x.com/tanddant) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-update-list-icons-and-color" aria-hidden="true" />