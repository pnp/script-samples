---
plugin: add-to-gallery
---

# Modernize Blog Pages

## Summary

Converts all blog pages in a site, this includes:

- Conversion of blog pages
- Connecting to MFA or supplying credentials
- Includes Logging to File, log flushing into single log file

> [!note]
> This script uses the older [SharePoint PnP PowerShell Online module](https://www.powershellgallery.com/packages/SharePointPnPPowerShellOnline/3.29.2101.0)

![Example Screenshot](assets/modern-page.png)

# [PnP PowerShell](#tab/pnpps)

```powershell

    # Classic blog site url
    $SourceUrl,

    # Target modern communication site url
    [string]$TargetUrl,

    # Supply credentials for multiple runs/sites
    $Credentials = Get-Credential

    # Specify log file location
    [string]$LogOutputFolder = "c:\temp"

    Connect-PnPOnline -Url $SourceUrl -Credentials $Credentials -Verbose
    Start-Sleep -s 3

    Write-Host "Modernizing blog pages..." -ForegroundColor Cyan

    $posts = Get-PnPListItem -List "Posts"

    Write-Host "pages fetched"

    Foreach($post in $posts)
    {
        $postTitle = $post.FieldValues["Title"]

        Write-Host " Processing blog post $($postTitle)"

        ConvertTo-PnPClientSidePage -Identity $postTitle `
                                    -BlogPage `
                                    -Overwrite `
                                    -TargetWebUrl $TargetUrl `
                                    -LogType File `
                                    -LogVerbose `
                                    -LogSkipFlush `
                                    -LogFolder $LogOutputFolder `
                                    -KeepPageCreationModificationInformation `
                                    -PostAsNews `
                                    -SetAuthorInPageHeader `
                                    -CopyPageMetadata
    }

    # Write the logs to the folder
    Save-PnPClientSidePageConversionLog

    Write-Host "Blog site modernization complete! :)" -ForegroundColor Green

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Contributors

| Author(s) |
|-----------|
| Bert Jansen |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]

