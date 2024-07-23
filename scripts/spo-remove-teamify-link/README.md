---
plugin: add-to-gallery
---

# Remove the Teamify link on Group sites

## Summary

If your governance dictate that Group owners should not be able to change a Group site to a Teams site, you can remove the promote link with this script.

![Example Screenshot](assets/example.png)

Remove the Teamify link on Group sites

# [PnP PowerShell](#tab/pnpps)

```powershell
    #connect to the site using one of the many options available
    $conn = Connect-PnPOnline -Url $url -interactive -ReturnConnection  -ErrorAction Stop  
        
    #enable custom script on site   
    Set-PnPSite -Identity $url -NoScriptSite $false -Connection $conn
    #Update the Property bag key to remove Teams Prompt
    Set-PnPPropertyBagValue -Key "TeamifyHidden" -Value "True" -Connection $conn
    #Disable custom script on site or leave it enabled, it will automatically be disabled after 24 hours
    Set-PnPSite -Identity $url -NoScriptSite $true -Connection $conn

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

# [CLI for Microsoft 365](#tab/cli-m365-ps)

```bash
    # m365 login --authType browser --url $url
    m365 login --authType browser

    # Enable custom script on the site
    m365 spo site classic set --url $url --noScriptSite false
   
    # Update the Property bag key to remove Teams Prompt
    m365 spo propertybag set --webUrl $url --key "TeamifyHidden" --value "False"

    # Disable custom script on the site
    m365 spo site classic set --url $url --noScriptSite true

```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

## Contributors

| Author(s) |
|-----------|
| Kasper Larsen |
| [Valeras NArbutas](https://github.com/ValerasNarbutas) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-remove-teamify-link" aria-hidden="true" />
