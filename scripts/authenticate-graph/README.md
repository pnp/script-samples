---
plugin: add-to-gallery
---

# Authenticate with and call the Microsoft Graph

## Summary

Obtain a new access token for the Microsoft Graph and use it an HTTP request, or connect to the Graph to perform operations.

![Example Screenshot](assets/example.png)

## Scripts

# [CLI for Microsoft 365)](#tab/m365cli)

```powershell

$token = m365 util accesstoken get --resource https://graph.microsoft.com --new
$me = Invoke-RestMethod -Uri https://graph.microsoft.com/v1.0/me -Headers @{"Authorization"="Bearer $token"}
$me

```

# [PnP PowerShell](#tab/pnpps)

```powershell
#https://docs.microsoft.com/en-us/powershell/module/sharepoint-pnp/connect-pnponline?view=sharepoint-ps#example-7
Connect-PnPOnline -Url "https://contoso.sharepoint.com" -ClientId 6c5c98c7-e05a-4a0f-bcfa-0cfc65aa1f28 -Tenant 'contoso.onmicrosoft.com' -Thumbprint 34CFAA860E5FB8C44335A38A097C1E41EEA206AA

$token = Get-PnPGraphAccessToken
$uri = 'https://graph.microsoft.com/v1.0/users?$filter=displayName eq ''Paul Bullock'''
$me = Invoke-RestMethod -Uri $uri -Headers @{"Authorization"="Bearer $($token)"} -Method Get -ContentType "application/json"
$me.value
```

# [Microsoft Graph PowerShell](#tab/graphps)

```powershell

Connect-MgGraph
Get-MgContext
Get-MgUser -Filter "displayName eq 'Paul Bullock'"
Disconnect-MgGraph

```

***

## Source Credit

Sample first appeared on  [https://pnp.github.io/cli-microsoft365/sample-scripts/graph/call-graph/](https://pnp.github.io/cli-microsoft365/sample-scripts/graph/call-graph/)

## Contributors

| Author(s) |
|-----------|
| Garry Trinder |
| Paul Bullock |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]

<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/authenticate-graph" aria-hidden="true" />