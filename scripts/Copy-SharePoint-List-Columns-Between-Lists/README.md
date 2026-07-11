# How to Copy SharePoint List Columns Between Lists Using PowerShell

## Professional Summary

This PowerShell script copies selected SharePoint list fields from a source Microsoft 365 SharePoint site to a destination SharePoint site using PnP PowerShell authentication with an Azure AD application certificate.

The script validates existing destination fields, identifies missing source fields, creates required fields using the original SharePoint schema XML, and produces an operational CSV report containing execution results, status, and error details.

Designed for Microsoft 365 administrators, the script supports repeatable tenant administration tasks, controlled migrations, and SharePoint list standardisation activities.

## Why it matters

During Microsoft 365 migrations, tenant consolidations, SharePoint information architecture projects, or application deployments, administrators often need to replicate SharePoint list structures across sites.
Manually recreating fields introduces risks:

- Incorrect field types
- Missing internal names
- Configuration inconsistencies
- Deployment delays
- Lack of audit visibility

This script provides a controlled method to replicate required list columns while maintaining SharePoint schema integrity and generating an audit trail suitable for enterprise change management.

## Benefits

- Automates SharePoint field replication at scale
- Preserves SharePoint field schema definitions
- Avoids duplicate field creation
- Provides detailed operational reporting
- Supports unattended execution using certificate-based authentication
- Suitable for large Microsoft 365 environments
- Improves consistency across SharePoint site collections
- Provides migration validation evidence for governance and compliance requirements
- Helps teams adopt a more controlled Dev/Test/Production lifecycle for SharePoint solutions

## Prerequisites

- PowerShell 7+
- PnP.PowerShell module
- Azure AD application registration
- Certificate-based authentication permissions:
  - SharePoint Sites.Selected or appropriate SharePoint application permissions

# [PnP PowerShell](#tab/pnpps)

```powershell
#==========================================
# Configuration
#==========================================
$SourceSiteUrl      = "https://contoso.sharepoint.com/sites/TEST-Finance"
$DestinationSiteUrl = "https://contoso.sharepoint.com/sites/PROD-Finance"

$ClientId   = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$Thumbprint = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$Tenant     = "contoso.onmicrosoft.com"

$SourceListName      = "Finance"
$DestinationListName = "Finance"

$FieldsToCopy = @(
    "CostCentre"
    "Department"
    "BudgetCode"
    "GLAccount"
    "ExpenseCategory"
    "BudgetAmount"
    "ForecastAmount"
    "ClaimAmount"
    "Supplier"
    "InvoiceNumber"
    "PurchaseOrder"
    "FinancialYear"
    "ApprovalStatus"
    "Approver"
    "ReceiptReference"
)

$OutputFolder = "C:\Temp\FieldCopy"

#==========================================
# Initialisation
#==========================================

$null = New-Item -Path $OutputFolder -ItemType Directory -Force

$timeStamp = Get-Date -Format "yyyyMMdd_HHmmss"

$reportPath = Join-Path $OutputFolder "FieldCopy_$timeStamp.csv"

$startTime = Get-Date
$operator = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$computer = $env:COMPUTERNAME

$results = [System.Collections.Generic.List[object]]::new()

Write-Host ""
Write-Host "Field Copy Started" -ForegroundColor Cyan
Write-Host "Operator          : $operator"
Write-Host "Computer          : $computer"
Write-Host "Source Site       : $SourceSiteUrl"
Write-Host "Destination Site  : $DestinationSiteUrl"
Write-Host ""

#==========================================
# Authentication
#==========================================

try {

    $sourceConnection = Connect-PnPOnline `
        -Url $SourceSiteUrl `
        -ClientId $ClientId `
        -Thumbprint $Thumbprint `
        -Tenant $Tenant `
        -ReturnConnection `
        -ErrorAction Stop

    $destinationConnection = Connect-PnPOnline `
        -Url $DestinationSiteUrl `
        -ClientId $ClientId `
        -Thumbprint $Thumbprint `
        -Tenant $Tenant `
        -ReturnConnection `
        -ErrorAction Stop

    $sourceFields = Get-PnPField `
        -List $SourceListName `
        -Connection $sourceConnection `
        -ErrorAction Stop

    $destinationFields = Get-PnPField `
        -List $DestinationListName `
        -Connection $destinationConnection `
        -ErrorAction Stop
}
catch {
    throw "Failed to connect to SharePoint or retrieve list fields. $($_.Exception.Message)"
}

$destinationFieldNames = [System.Collections.Generic.HashSet[string]]::new(
    [string[]]$destinationFields.InternalName
)

$totalFields = $FieldsToCopy.Count
$currentField = 0

foreach ($fieldName in $FieldsToCopy) {

    $currentField++

    Write-Progress `
        -Activity "Copying SharePoint Fields" `
        -Status "Processing $fieldName ($currentField of $totalFields)" `
        -PercentComplete (($currentField / $totalFields) * 100)

    $status = ""
    $errorMessage = ""

    try {

        if ($destinationFieldNames.Contains($fieldName)) {

            $status = "Already Exists"

            Write-Host "[SKIP] $fieldName already exists." -ForegroundColor Yellow
        }
        else {

            $sourceField = $sourceFields | Where-Object InternalName -eq $fieldName

            if ($null -eq $sourceField) {

                $status = "Source Missing"

                Write-Host "[WARN] $fieldName not found in source list." -ForegroundColor Yellow
            }
            else {

                Add-PnPFieldFromXml `
                    -List $DestinationListName `
                    -FieldXml $sourceField.SchemaXml `
                    -Connection $destinationConnection `
                    -ErrorAction Stop | Out-Null

                $destinationFieldNames.Add($fieldName) | Out-Null

                $status = "Copied"

                Write-Host "[OK]   $fieldName copied." -ForegroundColor Green
            }
        }
    }
    catch {

        $status = "Failed"
        $errorMessage = $_.Exception.Message

        Write-Host "[FAIL] $fieldName" -ForegroundColor Red
        Write-Host "       $errorMessage" -ForegroundColor DarkRed
    }

    $results.Add([PSCustomObject]@{
        Date              = Get-Date
        Operator          = $operator
        Computer          = $computer
        SourceSite        = $SourceSiteUrl
        DestinationSite   = $DestinationSiteUrl
        SourceList        = $SourceListName
        DestinationList   = $DestinationListName
        Field             = $fieldName
        Status            = $status
        Error             = $errorMessage
    })
}

Write-Progress -Activity "Copying SharePoint Fields" -Completed

$results |
    Sort-Object Field |
    Export-Csv $reportPath -NoTypeInformation -Encoding UTF8

$endTime = Get-Date
$duration = $endTime - $startTime

$copied = ($results | Where-Object Status -eq "Copied").Count
$existing = ($results | Where-Object Status -eq "Already Exists").Count
$missing = ($results | Where-Object Status -eq "Source Missing").Count
$failed = ($results | Where-Object Status -eq "Failed").Count

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Field Copy Complete" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host ("Fields Requested : {0}" -f $totalFields)
Write-Host ("Copied           : {0}" -f $copied) -ForegroundColor Green
Write-Host ("Already Exists   : {0}" -f $existing) -ForegroundColor Yellow
Write-Host ("Source Missing   : {0}" -f $missing) -ForegroundColor Yellow
Write-Host ("Failed           : {0}" -f $failed) -ForegroundColor Red
Write-Host ""
Write-Host ("Started          : {0}" -f $startTime)
Write-Host ("Completed        : {0}" -f $endTime)
Write-Host ("Duration         : {0}" -f $duration)
Write-Host ""
Write-Host ("CSV Report       : {0}" -f $reportPath)
Write-Host ""

```

# [Install module](#tab/pnpps)

```powershell

Install-Module PnP.PowerShell -Scope CurrentUser

```

# [Run](#tab/pnpps)

```powershell

.\Copy-SharePointListColumnsBetweenLists.ps1

```

## Output

### CSV Report Location

C:\Temp\FieldCopy\

### Report Contents

The script generates a CSV report containing:

|Column|Description|
|------|-----------|
|Date|Execution timestamp|
|Operator|Account running the script|
|Computer|Execution host|
|SourceSite|Source SharePoint site|
|DestinationSite|Target SharePoint site|
|SourceList|Source list name|
|DestinationList|Destination list name|
|Field|Field processed|
|Status|Copy result|
|Error|Failure details if applicable|

## Notes

- Field creation uses the original SharePoint SchemaXml to preserve configuration.
- Existing destination fields are skipped automatically.
- The script is idempotent and safe to rerun.
- For enterprise deployments, store application IDs and certificates securely using Azure Key Vault, managed automation accounts, or enterprise credential management solutions.

## Contributors

|Author(s)|
|-----------|
|[Josiah Opiyo](https://github.com/ojopiyo)|

*Built with a focus on automation, governance, least privilege, and clean Microsoft 365 tenants-helping M365 admins gain visibility and reduce operational risk.*

## Version history

|Version|Date|Comments|
|-------|----|--------|
|1.0|July 11, 2026|Initial release|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
