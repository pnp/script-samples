

# Extract all custom formatting

## Summary

This script stems from a scenario where a client had wiped out some column formatting I had built, and I realized that there was no good way to get it back.

This script will scrape every list, field, view and ContentType form on the site, and save it in a folder structure that's easy to navigate, and to store in your DevOps repo, or other version control, so you can easily restore it if it gets wiped out, or just see what has changed.

# [PnP PowerShell](#tab/pnpps)

```powershell
function get-customFormatting() {
    $url = Read-Host -Prompt "Enter the URL of the site you wish to backup custom formatting from"
    Connect-PnPOnline $url -Interactive

    try {
        $web = Get-PnPWeb -Includes Title
    }
    catch {
        Write-Host "Please connect to a site first" -Color Red
        return;
    }

    Write-Host "Backing up formatting for '$($web.Title)', fetching lists";

    $lists = Get-PnPList -Includes Id, Title, Views, Fields, ContentTypes | Where-Object { -not $_.Hidden }

    Write-Host "Fetched data - starting backup";


    foreach ($list in $lists) {
        $fields = $list.Fields | Where-Object { $_.CustomFormatter -ne $null -and $_.CustomFormatter -ne "" }
    
        foreach ($field in $fields) {
            try {
                Write-Host "List '$($list.Title)' > field: '$($field.Title)'";
                New-Item -Path "CustomFormatting\$($list.Title)\Columns\" -Name "$($field.Title) ($($field.InternalName)).column-formatter.json" -ItemType File -Value $($field.CustomFormatter | ConvertFrom-Json | ConvertTo-Json -Depth 100) -Force | Out-Null;
            }
            catch {
                Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red;
            }
        }

        $views = $list.Views | Where-Object { $_.CustomFormatter -ne $null -and $_.CustomFormatter -ne "" }
        foreach ($view in $views) {
            try {
                Write-Host "List '$($list.Title)' > `View: '$($view.Title)'";
                New-Item -Path "CustomFormatting\$($list.Title)\Views\" -Name "$($view.Title).view-formatter.json" -ItemType File -Value $($view.CustomFormatter | ConvertFrom-Json | ConvertTo-Json -Depth 100) -Force | Out-Null;
            }
            catch {
                Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red;
            }
        }

        $formCustomizer = $list.ContentTypes | Where-Object { $_.ClientFormCustomFormatter -ne $null -and $_.ClientFormCustomFormatter -ne "" }
        foreach ($form in $formCustomizer) {
            try {
                Write-Host "List '$($list.Title)' > form: '$($form.Name)'";
                New-Item -Path "CustomFormatting\$($list.Title)\Forms\" -Name "$($form.Name).form-formatter.json" -ItemType File -Value $($form.ClientFormCustomFormatter | ConvertFrom-Json | ConvertTo-Json -Depth 100) -Force | Out-Null;
            }
            catch {
                Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red;
            }
        }
    }

}

get-customFormatting;
```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***

## Contributors

| Author(s) |
|-----------|
| [Dan Toft](https://twitter.com/tanddant) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-export-all-customformatting" aria-hidden="true" />