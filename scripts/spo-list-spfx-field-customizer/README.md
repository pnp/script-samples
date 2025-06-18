# List all SPFx field customizer

## Summary

This is a simple PnP PowerShell script to list all SPFx field customizers in a SharePoint Online environment.

It's done by scarping your entire tenant, every site, and every field on every list, and checking if the `ClientSideComponentId` is set to a non-empty value, which indicates that the field has a customizer applied.


![Example Screenshot](assets/preview.png)

In light of the recent [announcement from Microsoft](https://support.microsoft.com/en-gb/office/support-update-for-sharepoint-framework-field-customizers-in-lists-and-document-libraries-0eccc64e-4512-47df-9da0-d855be22fb0a#) you might want to get a holistic picture of your tenants usage of Field Customizers.


# [PnP PowerShell](#tab/pnpps)

```powershell

$AdminUrl = "https://<Tenant>-admin.sharepoint.com/";



$FieldCustomizers = @()

Connect-PnPOnline $AdminUrl # <Your connection parameters go here>

$sites = Get-PnPTenantSite

foreach($site in $sites){
    Write-Host "Processing site: $($site.Url)" -ForegroundColor Cyan
    $siteCon = Connect-PnPOnline -Url $site.Url -ReturnConnection # <Your connection parameters go here>

    $lists = Get-PnPList -Connection $siteCon
    foreach($list in $lists){
        Write-Host "Processing list: $($list.Title)" -ForegroundColor Yellow
        $fields = Get-PnPField -List $list -Connection $siteCon 

        foreach($field in $fields){
            if($field.ClientSideComponentId -ne [Guid]::Empty){
                $FieldCustomizers += [PSCustomObject]@{
                    SiteUrl = $site.Url
                    ListTitle = $list.Title
                    FieldTitle = $field.Title
                    FieldInternalName = $field.InternalName
                    ClientSideComponentId = $field.ClientSideComponentId
                    ClientSideComponentProperties = $field.ClientSideComponentProperties
                }
            }
        }
    }
}

# Export the results to a CSV file
if ($FieldCustomizers.Count -eq 0) {
    Write-Host "No field customizers found." -ForegroundColor Red
    return
}

Write-host $FieldCustomizers | Format-Table -AutoSize

$FieldCustomizers | Export-Csv -Path "FieldCustomizers.csv" -NoTypeInformation

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***


## Contributors

| Author(s)                       |
| ------------------------------- |
| [Dan Toft](https://Dan-toft.dk) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-list-spfx-field-customizer" aria-hidden="true" />