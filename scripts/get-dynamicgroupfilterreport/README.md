# Exchange Online Mailboxes with Calendar Delegates

## Summary

This PowerShell script retrieves all Exchange Online Dynamic Distribution Groups across the tenant and exports their recipient filter configuration to a timestamped CSV report. The report includes group identifiers, SMTP addresses, recipient filter types and expressions, included recipients, conditional attributes, recipient container settings and group owners. It also identifies negative operators in recipient filters as indicators for further review and records execution details in a log file.

## Why It Matters

Dynamic Distribution Groups use recipient filters to determine which recipients qualify for group membership and receive messages sent to the group. Incorrect, outdated or overly restrictive filters can result in intended recipients being excluded or unintended recipients being included.

This assessment provides visibility of filter configuration across the tenant, helping administrators identify exclusion logic, review filtering criteria, troubleshoot distribution issues and support Exchange Online configuration audits.

## Prerequisites

- Exchange Online PowerShell module (`ExchangeOnlineManagement`)
- Exchange Online application registration configured for certificate-based authentication
- Valid certificate associated with the application
- Appropriate Exchange Online application permissions and administrative configuration
- Access to the certificate private key from the system executing the script

## Configuration

Update the following variables before execution:

| Variable          | Description                                                                                                            |
| ----------------- | ---------------------------------------------------------------------------------------------------------------------- |
| `$ClientID`       | Microsoft Entra application (client) ID used for certificate-based authentication.                                     |
| `$ThumbPrint`     | Thumbprint of the certificate registered with the application and available to the account running the script.         |
| `$Tenant`         | Exchange Online tenant's primary organisation domain, such as (`contoso.onmicrosoft.com`)                              |
| `$OutputFolder`   | Local directory where the CSV report and execution log are saved. Defaults to (`C:\Temp\DynamicGroupFilterReport`)     |
| `$TimeStamp`      | Generates a timestamp in `yyyyMMdd_HHmmss` format to uniquely identify each report and log file.                       |

# [PnP PowerShell](#tab/pnpps)

```powershell

# =====================================================================
# Dynamic Distribution Group Filter Report
# Reviews recipient filters, filter criteria and exclusion indicators
# =====================================================================

$ErrorActionPreference = "Stop"

# Configuration
$ClientID   = "xxxxxxxxxxxxxxxxxxxxx"
$ThumbPrint = "xxxxxxxxxxxxxxxxxxxxx"
$Tenant     = "contoso.onmicrosoft.com"

$OutputFolder = "C:\Temp\DynamicGroupFilterReport"

if (-not (Test-Path -LiteralPath $OutputFolder)) {
    New-Item -Path $OutputFolder -ItemType Directory -Force |
        Out-Null
}

$TimeStamp = Get-Date -Format "yyyyMMdd_HHmmss"

$CsvFile = Join-Path $OutputFolder "DynamicGroupFilterReport_$TimeStamp.csv"
$LogFile = Join-Path $OutputFolder "DynamicGroupFilterReport_$TimeStamp.log"

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )

    $Entry = "{0} [{1}] {2}" -f (
        Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    ), $Level, $Message

    Add-Content -LiteralPath $LogFile -Value $Entry
    Write-Host $Entry
}

$Connected = $false

try {
    Write-Log "Connecting to Exchange Online."

    Connect-ExchangeOnline `
        -AppId $ClientID `
        -CertificateThumbprint $ThumbPrint `
        -Organization $Tenant `
        -ShowBanner:$false `
        -ErrorAction Stop

    $Connected = $true

    Write-Log "Retrieving Dynamic Distribution Groups."

    $Groups = @(
        Get-DynamicDistributionGroup `
            -ResultSize Unlimited `
            -ErrorAction Stop
    )

    $Report = foreach ($Group in $Groups) {
        $Filter = [string]$Group.RecipientFilter

        # Identify negative operators for manual filter review.
        # These indicators do not fully interpret OPATH filter logic.
        $ExclusionOperators = @(
            [regex]::Matches(
                $Filter,
                '(?i)-(?:notlike|notcontains|notin|not|ne)\b'
            ) |
                ForEach-Object { $_.Value.ToLowerInvariant() } |
                Sort-Object -Unique
        )

        [PSCustomObject]@{
            DisplayName                  = $Group.DisplayName
            Alias                        = $Group.Alias
            PrimarySmtpAddress           = [string]$Group.PrimarySmtpAddress
            Identity                     = [string]$Group.Identity
            Guid                         = [string]$Group.Guid
            RecipientFilterType          = $Group.RecipientFilterType
            RecipientFilter              = $Filter
            HasNegativeFilterLogic       = ($ExclusionOperators.Count -gt 0)
            FilterExclusionIndicators    = $ExclusionOperators -join "; "
            IncludedRecipients           = @($Group.IncludedRecipients) -join "; "
            ConditionalCompany           = @($Group.ConditionalCompany) -join "; "
            ConditionalDepartment        = @($Group.ConditionalDepartment) -join "; "
            ConditionalStateOrProvince   = @($Group.ConditionalStateOrProvince) -join "; "
            ConditionalCustomAttribute1  = @($Group.ConditionalCustomAttribute1) -join "; "
            ConditionalCustomAttribute2  = @($Group.ConditionalCustomAttribute2) -join "; "
            ConditionalCustomAttribute3  = @($Group.ConditionalCustomAttribute3) -join "; "
            ConditionalCustomAttribute4  = @($Group.ConditionalCustomAttribute4) -join "; "
            ConditionalCustomAttribute5  = @($Group.ConditionalCustomAttribute5) -join "; "
            ConditionalCustomAttribute6  = @($Group.ConditionalCustomAttribute6) -join "; "
            ConditionalCustomAttribute7  = @($Group.ConditionalCustomAttribute7) -join "; "
            ConditionalCustomAttribute8  = @($Group.ConditionalCustomAttribute8) -join "; "
            ConditionalCustomAttribute9  = @($Group.ConditionalCustomAttribute9) -join "; "
            ConditionalCustomAttribute10 = @($Group.ConditionalCustomAttribute10) -join "; "
            ConditionalCustomAttribute11 = @($Group.ConditionalCustomAttribute11) -join "; "
            ConditionalCustomAttribute12 = @($Group.ConditionalCustomAttribute12) -join "; "
            ConditionalCustomAttribute13 = @($Group.ConditionalCustomAttribute13) -join "; "
            ConditionalCustomAttribute14 = @($Group.ConditionalCustomAttribute14) -join "; "
            ConditionalCustomAttribute15 = @($Group.ConditionalCustomAttribute15) -join "; "
            RecipientContainer            = [string]$Group.RecipientContainer
            ManagedBy                     = @($Group.ManagedBy) -join "; "
        }
    }

    if ($Groups.Count -gt 0) {
        $Report |
            Sort-Object DisplayName |
            Export-Csv -LiteralPath $CsvFile -NoTypeInformation -Encoding UTF8

        Write-Log "Report exported to $CsvFile"
    }
    else {
        Write-Log "No Dynamic Distribution Groups were found." "WARN"
    }

    Write-Log "Total Dynamic Distribution Groups: $($Groups.Count)"
}
catch {
    Write-Log "Assessment failed: $($_.Exception.Message)" "ERROR"
    throw
}
finally {
    if ($Connected) {
        Write-Log "Disconnecting from Exchange Online."

        Disconnect-ExchangeOnline `
            -Confirm:$false `
            -ErrorAction SilentlyContinue

        Write-Log "Disconnected from Exchange Online."
    }

    Write-Log "Assessment finished."
}


```

## Usage

1. Configure $ClientID, $ThumbPrint, and $Tenant with the appropriate application and tenant details.
2. Set $OutputFolder to a suitable location with sufficient storage and appropriate access controls.
3. Run the script under an identity that can access the configured certificate and output directory.
4. Review the generated CSV report and log file.

## Output

The script creates the output directory if it does not already exist and generates two timestamped files per execution.

| File                                               | Description                                                              |
| -------------------------------------------------- | ------------------------------------------------------------------------ |
| `DynamicGroupFilterReport_<timestamp>.csv`         | Dynamic Distribution Group configuration and filter assessment results.  |
| `DynamicGroupFilterReport_<timestamp>.log`         | Execution progress, warnings and errors.                                 |

## Notes

- The assessment is read-only and does not modify Dynamic Distribution Groups or their recipient filters.
- The report covers all Exchange Online Dynamic Distribution Groups accessible to the authenticated application in the tenant.
- Recipient filters are reported as configured at the time of execution. Changes made after the assessment will not be reflected in the exported report.
- Negative filter operators are flagged as indicators for manual review. Their presence does not necessarily indicate a misconfiguration or an unintended recipient exclusion.
- The report includes filter criteria such as company, department, state/province and custom attributes 1-15, supporting the investigation of group membership rules.
- The script does not calculate actual recipient membership or verify whether individual recipients are included or excluded.
- Microsoft 365 groups and Microsoft Entra dynamic membership groups are outside the scope of this assessment.
- The account running the script must have access to the certificate's private key, and the application must have the appropriate Exchange Online permissions.
- CSV and log files are saved locally in the configured output folder. Each run generates timestamped filenames to help preserve historical assessment results.
- If no Dynamic Distribution Groups are found, the script records a warning in the log and does not generate a CSV report.

## Contributors

|Author(s)|
|-----------|
|[Josiah Opiyo](https://github.com/ojopiyo)|

*Built with a focus on automation, governance, least privilege, and clean Microsoft 365 tenants - helping M365 admins gain visibility and reduce operational risk.*

## Version history

|Version|Date|Comments|
|-------|----|--------|
|1.0|October 24, 2026|Initial release|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
