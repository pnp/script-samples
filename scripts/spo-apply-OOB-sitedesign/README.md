# Apply Out-of-the-Box SharePoint Site Designs to Existing Sites

## Summary

What if you need to apply Microsoft's out-of-the-box site designs to existing sites using automation? The PnP PowerShell, CLI for M365 and other PowerShell module cover applying custom site designs only. We can leverage a PowerShell hack using REST API calls to achieve this functionality. Thanks to Arash Aghajani who pinpointed on feasibility and requested for it to be natively available within PnP PowerShell. However the implementation with PnP PowerShell uses CSOM and does not the option to apply out of the box site design.

---

## The Challenge

Microsoft provides several useful out-of-the-box site designs like:
- **Project Management** - Adds project-related lists and libraries
- **Training Portal** - Sets up training-focused site structure
- **Team Collaboration** - Configures collaboration features

These are available from the UI to apply to a site only. The existing PowerShell modules are lacking the functionality to replicate the behaviour. 

---

## The Solution: REST API Hack

By using SharePoint's REST API hack through PnP PowerShell as a hack, we can programmatically apply these site designs to existing sites. Here's how to do it:

# [PnP PowerShell](#tab/pnpps)

```powershell
# Configuration
$siteDesignId = "b8ef3134-92a2-4c9d-bca6-2f14e79fe98e" # Project Management
$webUrl = "https://yourtenant.sharepoint.com/sites/yoursite"

try {
    # Connect to SharePoint
    Connect-PnPOnline -Url $webUrl
    Write-Host "Connected to $webUrl" -ForegroundColor Green

    # Get available site designs
    $getSiteDesignsUrl = "$webUrl/_api/Microsoft.SharePoint.Utilities.WebTemplateExtensions.SiteScriptUtility.GetSiteDesigns"
    $siteDesigns = (Invoke-PnPSPRestMethod -Url $getSiteDesignsUrl -Method POST -ContentType "application/json" -content "{`"store`": 1}").value | select Id, Title

    Write-Host "`nAvailable Site Designs:" -ForegroundColor Yellow
    $siteDesigns | ForEach-Object { Write-Host "  $($_.Id) - $($_.Title)" }

    # Validate site design ID
    $selectedDesign = $siteDesigns | Where-Object { $_.Id -eq $siteDesignId }
    if (-not $selectedDesign) {
        Write-Host "`nError: Site Design ID '$siteDesignId' not found!" -ForegroundColor Red
         Write-Host "`nAvailable Site Designs:" -ForegroundColor Yellow
         $siteDesigns | ForEach-Object { Write-Host "  $($_.Id) - $($_.Title)" }
        exit 1
    }

    Write-Host "`nApplying site design: $($selectedDesign.Title)" -ForegroundColor Yellow

    # Apply the site design
    $restUrl = "$webUrl/_api/Microsoft.SharePoint.Utilities.WebTemplateExtensions.SiteScriptUtility.ApplySiteDesign"
    $body = "{`"siteDesignId`": `"$siteDesignId`", `"webUrl`": `"$webUrl`", `"store`": 1}"
    $response = Invoke-PnPSPRestMethod -Url $restUrl -Method Post -ContentType "application/json" -Content $body

    Write-Host "✅ Site design '$($selectedDesign.Title)' applied successfully!" -ForegroundColor Green
    
    if ($response) {
        Write-Host "Response details:" -ForegroundColor Cyan
        $response | ConvertTo-Json -Depth 3
    }
}
catch {
    Write-Host "❌ Error applying site design: $($_.Exception.Message)" -ForegroundColor Red
}
```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***

## Source Credit

Sample first appeared on [PowerShell Hack: Apply Out-of-the-Box SharePoint Site Designs to Existing Sites](https://reshmeeauckloo.com/posts/powershell-apply-outofthebox-sitedesigns/)

## Contributors

| Author(s) |
|-----------|
| [Reshmee Auckloo](https://github.com/reshmee011) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-apply-OOB-sitedesign" aria-hidden="true" />
