---
plugin: add-to-gallery
---

# Ensure the Site Assets Library is created

## Summary

There are occasions when creating a new modern SharePoint site using the CLI/REST API that the Site Assets library isn't created, use this script to ensure that the Site Assets library is created.
Reference: ['ensure' commands #1427](https://github.com/pnp/cli-microsoft365/discussions/1427)

* gets the collection of lists at the site url supplied
* if a list with the title "Site Assets" isn't found
* gets an access token for the tenant's SharePoint resource
* calls the _api/web/Lists/EnsureSiteAssetsLibrary REST endpoint to create the Site Assets library
* returns the existing or created SPList as a JSON object

![Example Screenshot](assets/example.png)

# [CLI for Microsoft 365 using PowerShell](#tab/cli-m365-ps)

```powershell

function EnsureSiteAssetsLibrary {
  param (
    [Parameter(Mandatory)][string]$siteUrl
  )

  <#
    send a HTTP POST request to:
    https://<tenant>.sharepoint.com/sites/<sitename>/_api/web/Lists/EnsureSiteAssetsLibrary/
    which returns an SPList
  #>
  $list = $null

  Write-Host "-> Ensure Site Assets library: $siteUrl"
  $lists = m365 spo list list --webUrl "$siteUrl" -o json | ConvertFrom-Json
  if (($null -ne $lists) -and ($null -ne $lists.value)) {
    $list = $lists.value | Where-Object { $_.Title -eq "Site Assets" }
  }

  if ($null -eq $list) {
    Write-Host "...Creating Site Assets library"

    try {
      $resource = ($siteUrl -split "/")[2]
      $accessToken = m365 util accesstoken get --resource "https://$resource"
    }
    catch {
      throw "!! Unable to get AccessToken for EnsureSiteAssetsLibrary at '$siteUrl'`nERROR: $_"
    }
    try {
      $headers = @{ "Authorization" = "Bearer $accessToken"; "Accept" = "application/json;odata=nometadata" }
      $endpoint = "$siteUrl/_api/web/Lists/EnsureSiteAssetsLibrary/"
      $response = (Invoke-RestMethod -Uri $endpoint -Headers $headers -Method POST)
      $list = $response

      Write-Host "...Created: $($list.Id)"
    }
    catch {
      throw "!! Unable to EnsureSiteAssetsLibrary at '$siteUrl'`nERROR: $_"
    }
  } else {
    Write-Host "...Already exists: $($list.Id)"
  }

  $list
}

```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
***

## Source Credit

Sample first appeared on [Ensure the Site Assets Library is created | CLI for Microsoft 365](https://pnp.github.io/cli-microsoft365/sample-scripts/spo/ensure-siteassets-library/)

## Contributors

| Author(s) |
|-----------|
| Phillip Allan-Harding |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/spo-ensure-siteassets-library" aria-hidden="true" />