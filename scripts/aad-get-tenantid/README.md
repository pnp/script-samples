---
plugin: add-to-gallery
---

# Get Tenant ID

## Summary

These are practical scripts I have to get Tenant ID from either a domain name or from a Subscription ID.

These are simple, but very useful to be combined in other scripts.


# [PowerShell (Domain)](#tab/ps)

```powershell

function Get-TenantIdFromDomain {
    <#
    .SYNOPSIS
        Get the tenant ID for any Domain.

    .DESCRIPTION
        Will check and return the tenant ID for any domin, or return  $false if no ID is found.

    .PARAMETER domain
        Any domain name, ex. domain.com

    .INPUTS
        domain name: domain.com
 
    .OUTPUTS
        String or boolean False.

    .EXAMPLE
        Get-TenantIdFromDomain domain.com
        Get-TenantIdFromDomain -domain domain.com
        "domain.com" | Get-TenantIdFromDomain

    .NOTES
        FileName:   Get-TenantIdFromDomain.psm1
        Author:     Daniel Kåven
        Contact:    @dkaaven
        Created:    2022-03-25
        Updated:    2024-10-13
        Version History:
        1.0.0 - (2022-03-25) Script created
        1.1.0 - (2024-06-20) Added check for missing domain
        1.2.0 - (2024-08-13) Added ability to get data from Pipeline

    #>

    param(
        [CmdletBinding()]
        [parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = "The domain name of the target tenant.",
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [String]$domain
    )

    # Check if tenant exists
    try {
        $request = Invoke-WebRequest -Uri https://login.windows.net/$domain/.well-known/openid-configuration
    }
    catch {
        if ($null -eq $request) {
            return $false
        } else {
            Write-Error $_
        }
    }

    # Return tenant ID
    $data = ConvertFrom-Json $request.Content
    $result = $data.token_endpoint.split('/')[3]
    return $result
}

```
[!INCLUDE [More about PowerShell](../../docfx/includes/MORE-PS.md)]


# [PowerShell (Subscription)](#tab/ps1)

```powershell

function Get-TenantIdFromSubscriptionId {
    <#
    .SYNOPSIS
        Get the tenant ID from an Azure Subscription ID.
    .DESCRIPTION
        Will check and return the tenant ID for an Azure Subscription ID or return $false if no ID is found.
        Inspired from [Jos Lieben @ lieben.nu](https://www.lieben.nu/liebensraum/2020/08/get-tenant-id-using-azure-subscription-id/)
 
    .PARAMETER subscriptionId
        The Azure Subscription ID to check.
 
    .INPUTS
        Azure Subscription Id: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
 
    .OUTPUTS
        String or boolean False.
 
    .EXAMPLE
        Get-TenantIdFromSubscriptionId xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
        Get-TenantIdFromSubscriptionId -subscriptionId xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
        xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx | Get-TenantIdFromSubscriptionId
 
    .NOTES
        FileName:    Get-TenantIdFromSubscriptionId.psm1
        Author:      Daniel Kåven
        Contact:     @DKaaven
        Created:     2024-08-06
        Updated:     2024-08-06
        Version history:
        1.0.0 - (2024-08-06) Script created
    #>
    param (
        [CmdletBinding()]
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = "The Azure Subscription ID",
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias("subId")]
        [String]$subscriptionId
    )
    # Check Subscription ID format
    $guidPattern = "^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$"
    if ($subscriptionId -notmatch $guidPattern) {
        Write-Error "$subscriptionId is not a valid Azure Subscription ID."
        return $false
    }
    $response = try {(Invoke-WebRequest -UseBasicParsing -Uri "https://management.azure.com/subscriptions/$($subscriptionId)?api-version=2015-01-01" -ErrorAction Stop).BaseResponse} catch { $_.Exception.Response } 
    $stringHeader = $response.Headers.ToString()
    $tenantId = $stringHeader.SubString($stringHeader.IndexOf("login.windows.net")+18,36)

    # Check if it exist or return false
    if ($tenantId -match $guidPattern) {
        return $tenantId
    }
    else {
        return $false
    }

}

```
[!INCLUDE [More about PowerShell](../../docfx/includes/MORE-PS.md)]

# [PnP PowerShell](#tab/pnpps)

```powershell

param (
    [Parameter(Mandatory = $true)]
    [string] $domain
)

$adminSiteURL = "https://$domain-Admin.SharePoint.com"
Connect-PnPOnline -Url $adminSiteURL -Interactive -WarningAction SilentlyContinue
Get-PnPTenantId

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***

## Source Credit

Sample first appeared on [https://github.com/dkaaven/M365-Scripts](https://github.com/dkaaven/M365-Scripts)

## Contributors

| Author(s) |
|-----------|
| [Daniel Kåven](https://github.com/dkaaven)|
| [Reshmee Auckloo](https://github.com/reshmee011) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/aad-get-tenantid" aria-hidden="true" />
