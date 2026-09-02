# Exchange Online Distribution Group External Sender Audit

## Summary

This PowerShell script connects to Exchange Online using certificate-based app-only authentication, retrieves all distribution groups in the tenant, and identifies whether each group permits messages from external or unauthenticated senders.

The results are displayed in the console and exported to a CSV report for auditing, security review, and operational documentation.

## Why It Matters

Distribution groups that accept messages from external senders can be intentionally configured for legitimate business purposes, but they can also increase exposure to unsolicited email, spoofing attempts, and abuse.

This report provides administrators with a tenant-wide inventory of distribution groups and their external sender configuration, allowing potentially exposed groups to be identified and reviewed.

### Benefits

- Provides a tenant-wide distribution group audit.
- Identifies groups that allow external senders.
- Produces a CSV suitable for security and compliance reviews.
- Supports large tenants using -ResultSize Unlimited.
- Uses certificate-based, non-interactive authentication suitable for automation.
- Provides summary statistics for rapid assessment.
- Includes error handling and guaranteed Exchange Online disconnection.
- Can be scheduled or incorporated into broader Microsoft 365 reporting processes.

## Requirements

- Exchange Online PowerShell module installed.
- An Entra ID application configured for Exchange Online app-only authentication.
- A valid certificate installed and accessible to the account running the script.
- The application configured with the required Exchange Online permissions/RBAC configuration.
- Appropriate administrative permissions to retrieve distribution group information.

## Usage

Update the configuration values before execution:

| Variable          | Description                                                |
| ----------------- | ---------------------------------------------------------- |
| `$ClientID`       | Azure AD Application (Client) ID                           |
| `$ThumbPrint`     | Certificate thumbprint                                     |
| `$Tenant`         | Microsoft 365 tenant name (e.g. `contoso.onmicrosoft.com`) |

# [PnP PowerShell](#tab/pnpps)

```powershell

# ==========================================================
# Configuration 
# ==========================================================

$ClientID = "xxxxxxxxxxxxxxxxxxxxxxxxx"
$ThumbPrint = "xxxxxxxxxxxxxxxxxxxxxxxxx"
$Tenant = "contoso.onmicrosoft.com"

$OutputFolder = "C:\Temp\Outlook"
$OutputFile = Join-Path -Path $OutputFolder -ChildPath "DistributionGroups-ExternalSendersAllowed.csv"

# ==========================================================
# Create Output Folder 
# ==========================================================

try {
    if (-not (Test-Path -Path $OutputFolder)) {
        New-Item -Path $OutputFolder -ItemType Directory -Force -ErrorAction Stop | Out-Null
    }
}
catch {
    Write-Error "Failed to create output folder '$OutputFolder'. Error: $($_.Exception.Message)"
    exit 1
}

# ==========================================================
# Connect to Exchange Online
# ==========================================================

$exchangeConnected = $false

try {
    Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan

    Connect-ExchangeOnline `
        -AppId $ClientID `
        -CertificateThumbprint $ThumbPrint `
        -Organization $Tenant `
        -ShowBanner:$false `
        -ErrorAction Stop

    $exchangeConnected = $true

    Write-Host "Connected successfully." -ForegroundColor Green
}
catch {
    Write-Error "Failed to connect to Exchange Online. Error: $($_.Exception.Message)"
    exit 1
}


try {

    # ==========================================================
    # Retrieve Distribution Groups
    # ==========================================================
    
        Write-Host "Retrieving distribution groups..." -ForegroundColor Cyan

    $distributionGroups = @(
        Get-DistributionGroup `
            -ResultSize Unlimited `
            -ErrorAction Stop |
            Select-Object `
                DisplayName,
                PrimarySmtpAddress,
                @{
                    Name = "ExternalSendersAllowed"
                    Expression = {
                        if ($_.RequireSenderAuthenticationEnabled -eq $false) {
                            "YES"
                        }
                        else {
                            "NO"
                        }
                    }
                }
    )

    # ==========================================================
    # Display Results
    # ==========================================================

    Write-Host ""
    Write-Host "Distribution Groups" -ForegroundColor Cyan
    Write-Host "====================" -ForegroundColor Cyan
    Write-Host ""

    if ($distributionGroups.Count -gt 0) {
        $distributionGroups |
            Format-Table -AutoSize
    }
    else {
        Write-Host "No distribution groups found." -ForegroundColor Yellow
    }

    # ==========================================================
    # Export Results
    # ==========================================================

    $distributionGroups |
        Export-Csv `
            -Path $OutputFile `
            -NoTypeInformation `
            -Encoding UTF8 `
            -ErrorAction Stop

    Write-Host ""
    Write-Host "Report saved to:" -ForegroundColor Green
    Write-Host $OutputFile

    # ==========================================================
    # Summary
    # ==========================================================

    $totalGroups = $distributionGroups.Count

    $externalSendersAllowed = @(
        $distributionGroups |
            Where-Object { $_.ExternalSendersAllowed -eq "YES" }
    ).Count

    $externalSendersBlocked = @(
        $distributionGroups |
            Where-Object { $_.ExternalSendersAllowed -eq "NO" }
    ).Count

    Write-Host ""
    Write-Host "Audit Summary" -ForegroundColor Cyan
    Write-Host "============="
    Write-Host "Total distribution groups : $totalGroups"
    Write-Host "External senders allowed  : $externalSendersAllowed"
    Write-Host "External senders blocked  : $externalSendersBlocked"
}
catch {
    Write-Error "An error occurred while retrieving or exporting distribution groups. Error: $($_.Exception.Message)"
}
finally {
    
    # ==========================================================
    # Disconnect
    # ==========================================================

    if ($exchangeConnected) {
        Write-Host ""
        Write-Host "Disconnecting from Exchange Online..." -ForegroundColor Cyan

        Disconnect-ExchangeOnline `
            -Confirm:$false `
            -ErrorAction SilentlyContinue

        Write-Host "Disconnected." -ForegroundColor Green
    }
}

```

## Output

The script generates:

> C:\Temp\Outlook\DistributionGroups-ExternalSendersAllowed.csv

The CSV contains:

- DisplayName
- PrimarySmtpAddress
- ExternalSendersAllowed

The console also provides an audit summary:

- Total distribution groups : 1250
- External senders allowed  : 37
- External senders blocked  : 1213

## Interpretation

| Value  | Meaning                                                                          |
| ------ | -------------------------------------------------------------------------------  |
| `YES`  | The distribution group permits messages from unauthenticated/external senders.   |
| `NO`   | The distribution group requires sender authentication.                           |

## Notes

- The script reports the current value of `RequireSenderAuthenticationEnabled`; it does not modify any distribution group configuration.
- `-ResultSize Unlimited` is used to support tenants with large numbers of distribution groups.
- The CSV is overwritten if the script is run again with the same output path.
- Certificate-based authentication is non-interactive and is appropriate for scheduled automation when the required Entra ID and Exchange Online configuration is in place.
- The report should be treated as an audit/inventory report rather than proof that a particular external message will be delivered. Mail flow rules, moderation, transport restrictions, and other Exchange Online controls can also affect message delivery.

## Contributors

|Author(s)|
|-----------|
|[Josiah Opiyo](https://github.com/ojopiyo)|

*Built with a focus on automation, governance, least privilege, and clean Microsoft 365 tenants-helping M365 admins gain visibility and reduce operational risk.*

## Version history

|Version|Date|Comments|
|-------|----|--------|
|1.0|September 02, 2026|Initial release|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
