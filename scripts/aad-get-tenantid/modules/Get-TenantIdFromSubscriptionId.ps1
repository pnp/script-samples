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