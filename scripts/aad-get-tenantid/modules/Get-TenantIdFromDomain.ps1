
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