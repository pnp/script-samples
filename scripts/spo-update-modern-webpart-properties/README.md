---
plugin: add-to-gallery
---

# Update modern web part properties

## Summary

Script will update web part properties on multiple pages by their Id, Instance Id, or Title

## Implementation

- Open Windows PowerShell ISE
- Edit Script and add details like SharePoint tenant URL, Term groups, and the output directory
- Press run

# [PnP PowerShell](#tab/pnpps)
```powershell

Function Update-CCWebpartProperties() {
    PARAM (
        [Parameter(Mandatory = $true)]
        [string]$SiteURL,

        [Parameter(Mandatory = $false)]
        [string[]]$Pages,

        [Parameter(Mandatory = $true)]
        [string]$WebPartIdentity,

        [Parameter(Mandatory = $false)]
        [string]$PropertyKey,

        [Parameter(Mandatory = $true)]
        [object]$PropertyValue
    )

    Try {
        ## Connect to SharePoint Online site  
        Write-Host "Connect to $($SiteURL)"
        Connect-PnPOnline -URL $SiteURL -UseWebLogin

        # If page parameter is empty, loop through all pages
        if ($Pages.Length -lt 1) {
            $pageItems = Get-PnPListItem -List "Site Pages"
            $Pages = $pageItems | ForEach-Object { $_["FileLeafRef"] }
        }

        $Pages | ForEach-Object {
            try {

                $page = Get-PnPPage -Identity $_
                # Get controls on the page with the identity (id, instance id, or title)
                $controls = $page.Controls | Where-Object { $WebPartIdentity -eq $_.Title -or $WebPartIdentity -eq $_.WebPartId -or $WebPartIdentity -eq $_.InstanceId }    
                Write-Host "Found ($($controls.Length)) web part(s)"

                $controls | ForEach-Object {                        
                    Write-Host "Updating web part, Title: $($_.Title), InstanceId: $($_.InstanceId)"
                    try {
                        $webpartJsonObj = ConvertFrom-Json $_.PropertiesJson
                        if ($PropertyKey) {
                            $webpartJsonObj.$PropertyKey = $PropertyValue
                        }
                        else {
                            $webpartJsonObj = $PropertyValue
                        }

                        $_.PropertiesJson = $webpartJsonObj | ConvertTo-Json
                        Write-Host "Web part properties updated!" -ForegroundColor Green

                    }
                    catch {                           
                        Write-Host "Failed updating web part, Title: $($_.Title), InstanceId: $($_.InstanceId), Error: $($_.Exception)"
                    }
                }

                $null = $page.Save()
                $null = $page.Publish()

                Write-Host "$($_) saved and published." -ForegroundColor Green                    

            }
            catch {
                Write-Host "Failed updating $($page.Title): $($_.Exception)" -ForegroundColor Red
            }
        }

        ## Disconnect the context  
        Disconnect-PnPOnline  
    }

    Catch {
        Write-Host $_.Exception
            
        Break
    }

}

Update-CCWebpartProperties -SiteURL https://contoso.sharepoint.com/sites/test -Pages "PnPSamples" -WebPartIdentity "HelloWorld" -PropertyKey "description" -PropertyValue "Sharing is caring!"

# More examples
<#
# Multi pages
Update-CCWebpartProperties -SiteURL https://contoso.sharepoint.com -Pages "Home","PnPCommunity" -WebPartIdentity "HelloWorld" -PropertyKey "description" -PropertyValue "My web part"

# Update all pages
Update-CCWebpartProperties -SiteURL https://contoso.sharepoint.com -WebPartIdentity "HelloWorld" -PropertyKey "description" -PropertyValue "My web part"

# Update by web part Id
Update-CCWebpartProperties -SiteURL https://contoso.sharepoint.com -WebPartIdentity "6f53d9afa5e347db90e63d6eab04b78c" -PropertyKey "description" -PropertyValue "My web part"

# Update more than one property using object

$link = @{
            title = "Environment"
            url = "$siteAbsoluteUrl/SitePages/Environment.aspx"
            iconName = "DocLibrary"
        }
Update-CCWebpartProperties -SiteURL https://contoso.sharepoint.com -WebPartIdentity "Links" -PropertyValue $link

#>


```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Contributors

| Author(s) |
|-----------|
| [Ramin Ahmadi](https://github.com/ahmadiramin) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-update-modern-webpart-properties" aria-hidden="true" />
